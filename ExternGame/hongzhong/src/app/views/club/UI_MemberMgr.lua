
local UI_MemberMgr = class("UI_MemberMgr", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_MemberMgr:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_MemberMgr.csb")
    self.root:addTo(self)

    UI_MemberMgr.super.ctor(self)
    _w = self._childW

    self:initUI()
end

function UI_MemberMgr:initUI()
    -- body
    self.btn_chengyuan = _w["btn_chengyuan"]
    self.btn_tongji = _w["btn_tongji"]
    -- self.btn_fakajilu = _w["btn_fakajilu"]
    self.btn_clearData = _w["btn_clearData"]
    self.txt_onlineNum = _w["txt_onlineNum"]
    self.memberList = _w["memberList"]
    self.tongjiList = _w["tongjiList"]

    -- self.btn_shenqing = _w["btn_shenqing"]
    self.panel_chengyuan = _w["panel_chengyuan"]
    self.panel_tongyi = _w["panel_tongyi"]
    -- self.uiTitle = _w["uiTitle"]

    -- self.panel_sq_xiaoxi = _w["panel_sq_xiaoxi"]
    -- self.txt_sq_xiaoxiNum = _w["txt_sq_xiaoxiNum"]
    self.txt_cy_page = _w["txt_cy_page"]
    self.cur_cy_pageIdx = 1
    self.max_cy_pageIdx = 100
    self.cur_cy_pageMember = 0
    self.cy_common_tab = {}

    self.txt_sj_page = _w["txt_sj_page"]
    self.cur_sj_pageIdx = 1
    self.max_sj_pageIdx = 10
    self.max_sj_NumOfPage = 10
    self.data_sj_tb = {}

end

function UI_MemberMgr:onEnter()
    CCXNotifyCenter:listen(self,function(obj,key,data) self:resetMemberList(data) end, "S2C_memberList")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:updateMemberInfo(data) end, "S2C_updateMemberInfo")

    -- CCXNotifyCenter:listen(self,function(obj,key,data) self:resetTongJiList(data) end, "S2C_tongjiList")

    --CCXNotifyCenter:listen(self,function(obj,key,data) self:resetRedPoint() end, "S2C_clubSetting")
    --ex_clubHandler:C2S_clubSetting()

    CCXNotifyCenter:listen(self,function(obj,key,data) self:recvKickResult() end, "S2C_KickOut")

    CCXNotifyCenter:listen(self,function(obj,key,data) self:resetTongJiList(data) end, "S2C_onClubDataStatistics")

    self.tableView = nil

    self:onClickBtnIndex(0)

    -- if ClubManager:isGuanliyuan() == false then
    --     self.btn_fakajilu:setVisible(false)
    -- end

    -- self:resetMemberList(res)
    -- self:resetTongJiList()
end

function UI_MemberMgr:update(t)
    
end

function UI_MemberMgr:onExit()
    CCXNotifyCenter:unListenByObj(self)

    cc.AnimationCache:destroyInstance()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end

function UI_MemberMgr:onUIClose()
    self:removeFromParent()
end

function UI_MemberMgr:onClick(_sender)
	local name = _sender:getName()
    cclog("UI_MemberMgr name:"..name)
    if name == "btn_back" then
        self:closeUI()
    elseif name == "btn_chengyuan" then
        self:onClickBtnIndex(0)
    elseif name == "btn_tongji" then
        self:onClickBtnIndex(1)
        --GlobalFun:showToast("尚未开放!", 1)

    -- elseif name == "btn_shenqing" then  --申请列表
    --    local scene = cc.Director:getInstance():getRunningScene()
    --    local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_ClubShenqingliebiao")
    --    scene:addChild(ui.new({app = nil}))
    elseif name == "btn_help" then  --帮助
        local scene = cc.Director:getInstance():getRunningScene()
        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_ClubHelp")
        scene:addChild(ui.new({app = nil}))

    elseif name == "btn_cy_last" then --成员列表上一页
        if self.cur_cy_pageIdx -1 >0 then
            ex_clubHandler:requestMemberList(self.cur_cy_pageIdx -1)
        end
    elseif name == "btn_cy_next" then  --成员列表下一页
        if self.cur_cy_pageIdx +1 <= self.max_cy_pageIdx then
            ex_clubHandler:requestMemberList(self.cur_cy_pageIdx +1)
        end

    elseif name == "btn_sj_last" then --数据统计上一页
        cclog("上一页")
        self:switchPageForTongJi(-1)

    elseif name == "btn_sj_next" then  --数据统计下一页
        cclog("下一页")
        self:switchPageForTongJi(1)
    elseif name == "btn_clearData" then  --数据统计清除
        cclog("清除统计数据")
        self:clearDataForTongJi()
    -- elseif name == "btn_fakajilu" then
    --     local scene = cc.Director:getInstance():getRunningScene()
    --     local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_RoomCardRecord")
    --     scene:addChild(ui.new({app = nil}))
    end    
end


function UI_MemberMgr:setMemberPage(cur, max)
    self.txt_cy_page:setString(string.format("%s/%s", cur, max))
    self.cur_cy_pageIdx = cur
    self.max_cy_pageIdx = max
    cclog("UI_MemberMgr:setMemberPage >>>", cur, max)
end

function UI_MemberMgr:onTouch(_sender, _type)
	
end

function UI_MemberMgr:onClickBtnIndex(index)
    -- body
    cclog("onClickBtnIndex index == "..tostring(index))
    index = index or 0
    self.curIndex = index
    if index == 0 then
        -- self.uiTitle:loadTexture("club/title/title_chengyuanliebiao.png")
        self.btn_chengyuan:setEnabled(false)
        self.btn_tongji:setEnabled(true)
        self.panel_chengyuan:setVisible(true)
        self.panel_tongyi:setVisible(false)
        self.btn_clearData:setVisible(false)
        -- self.btn_shenqing:setVisible(false)
        if ClubManager:isGuanliyuan() then
            --self.btn_shenqing:setVisible(true)
        end
        ex_clubHandler:requestMemberList(1)
    elseif index == 1 then
        -- self.uiTitle:loadTexture("club/title/title_chengyuanliebiao2.png")
        self.btn_chengyuan:setEnabled(true)
        self.btn_tongji:setEnabled(false)
        self.panel_chengyuan:setVisible(false)
        self.panel_tongyi:setVisible(true)
        self.btn_clearData:setVisible(true)
    
        --self:resetTongJiList()
        ex_clubHandler:toClubDataStatistics(1)
    end
end

function UI_MemberMgr:createMemberCommon(res)
    if next(self.cy_common_tab) then return end

    local contentSize = self.memberList:getContentSize()
    local data = res.data
    local num = res.curShowNum
    local row = 7--排数
    local col = math.ceil(num/row)--行数
    local w, h = 128, 128
    local totalWidth = w * row--总宽度
    local totalHeight = h * col--总高度
    if totalHeight <= contentSize.height then
        totalHeight = contentSize.height
    end
    local offset_x, offset_y = w, h
    local uiIndex = 0
    local pos_x, pos_y = 0, totalHeight

    


    for index = 1, num do

        if uiIndex%row == 0  then
            pos_x = 10 
            pos_y = pos_y - offset_y
        else
            pos_x = pos_x + offset_x + 15
        end
        uiIndex = uiIndex + 1

        local layout = ccui.Layout:create()
        local size = cc.size(130,130)
        layout:setContentSize(size)
        layout:setPosition(cc.p(pos_x,pos_y))



        local icon = ex_fileMgr:loadLua("app.views.club.PlayerIcon").new()
        
        local _itemW = self:loadChildrenWidget(icon)

        icon:setPosition(size.width/2, size.height/2)
        icon:setScale(0.8)
        icon:addTo(layout)


        _itemW["name"]:setVisible(true)
        _itemW["btn_add"]:setVisible(false)


        GlobalFun:uiTextCut(_itemW["name"])

        icon:setClickFunc(function() self:onClickMember(index) end)
        self.memberList:addChild(layout)
        self.cy_common_tab[index] = {item = layout, _itemW = _itemW, icon = icon, data = nil}
    end
    local innerSize = self.memberList:getInnerContainer():getContentSize()
    self.memberList:setInnerContainerSize(cc.size(innerSize.width,totalHeight))
end

function UI_MemberMgr:resetMemberList(res)
   --  -- body
   --  -- print_r(res)
   --  cclog("UI_MemberMgr:resetMemberList >>>", res.num, #res.data)
   --  self.memberList:removeAllChildren()


    -- local res = {
    --     maxPage = 10,
    --     curPage = 1,
    --     curShowNum = 100,
    --     num = 21,
    --     data = {},
    -- }

    -- for i=1,res.num do
    --     res.data[i] = {
    --         id = i,
    --         userID = i,
    --         name = i,
    --         icon = i,
    --         jiarutime = i,
    --         beizhu = i,
    --         isHeimingdan = false,
    --     }
    -- end




    self.cur_cy_pageMember = res.num
    self.txt_onlineNum:setString(string.format("%s/%s", res.total, ClubManager:getInfo("clubPeopleMaxNum")))

    self:setMemberPage(res.curPage, res.maxPage)
    self:createMemberCommon(res)
    self:showMember(res)
end

function UI_MemberMgr:showMemberCommonData(idx, info)
    local common = self.cy_common_tab[idx]
    if info then
        if common then
            local icon = common.icon
            local _itemW = common._itemW
            local item = common.item
            common.item:setVisible(true)
            icon:setPlayerStatus(info.status == 0 and -1 or info.status)
            _itemW["name"]:setString(info.name)
            _itemW["img_heimingdan"]:setVisible(info.isHeimingdan)
            icon:setIcon(info.userID, info.icon)
            icon:showZhiWei(info.userID)

            common.data = info
        end
    else
        if common then
            local icon = common.icon
            local _itemW = common._itemW
            local item = common.item
            common.item:setVisible(false)
            icon:setPlayerStatus(-1)
            _itemW["name"]:setString("")
            _itemW["img_heimingdan"]:setVisible(false)
            icon:removeHeadImg()
            icon:showZhiWei(-1)
            common.data = nil

        end
    end
end

function UI_MemberMgr:showMember(res)
    for k = 1, res.curShowNum do
        self:cleanMemberCommon(k)

        local info = res.data[k]
        self:showMemberCommonData(k, info)
        -- local common = self.cy_common_tab[k]
        -- if info then
        --     if common then
        --         local icon = common.icon
        --         local _itemW = common._itemW
        --         local item = common.item
        --         common.item:setVisible(true)
        --         icon:setPlayerStatus(info.status == 0 and -1 or info.status)
        --         _itemW["name"]:setString(info.name)
        --         _itemW["img_heimingdan"]:setVisible(info.isHeimingdan)
        --         icon:setIcon(info.userID, info.icon)
        --         icon:showZhiWei(info.userID)

        --         common.data = info
        --     end
        -- end
    end
end

function UI_MemberMgr:cleanMemberCommon(idx)
    self:showMemberCommonData(idx, nil)
    -- local common = self.cy_common_tab[idx]
    -- if common then
    --     local icon = common.icon
    --     local _itemW = common._itemW
    --     local item = common.item
    --     common.item:setVisible(false)
    --     icon:setPlayerStatus(-1)
    --     _itemW["name"]:setString("")
    --     _itemW["img_heimingdan"]:setVisible(false)
    --     icon:removeHeadImg()
    --     icon:showZhiWei(-1)
    --     common.data = nil

    -- end
end

function UI_MemberMgr:onClickMember(index)
    local common = self.cy_common_tab[index]
    if common and common.data then
        self:showMemberInfo(common.data)
    end
end

function UI_MemberMgr:invitePlayer()
    -- body
    cclog("invitePlayer")
    local cn = ClubManager:getInfo("clubName")
    local cid = ClubManager:getInfo("clubID")
    local cmn = ClubManager:getInfo("clubQunzhuName")

    
    local data = {}
    data.msg = string.format("会长[%s]邀请您加入俱乐部【%s】,俱乐部id：%s", cmn, cn, cid)
    data.stype = "俱乐部"
    data.params = {cid, cn,GlobalData.game_product}
    local str = GlobalFun:makeCopyStr(data)
    SDKController:getInstance():copy_To_Clipboard(str or "ERR")
    GlobalFun:showToast("复制邀请成功",Game_conf.TOAST_SHORT)
end

function UI_MemberMgr:showMemberInfo(info)
    -- body
    local scene = cc.Director:getInstance():getRunningScene()
    local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_MemberInfo")
    scene:addChild(ui.new(info))
end

function UI_MemberMgr:updateMemberInfo(res)
    -- body
    -- ex_clubHandler:requestMemberList(self.cur_cy_pageIdx)

    print_r(res)
    for k,v in pairs (self.cy_common_tab) do
        if v.data and v.data.userID == res.userID then
            -- v.data = res
            self:showMemberCommonData(k, res)
        end
    end
end

--设置申请列表红点(临时这么搞)
function UI_MemberMgr:resetRedPoint(_flag)
    if ClubManager:getInfo("clubJoinReqNum") > 0 then
        -- self.panel_sq_xiaoxi:setVisible(true)
        -- self.txt_sq_xiaoxiNum:setString(ClubManager:getInfo("clubJoinReqNum"))
    else
        -- self.panel_sq_xiaoxi:setVisible(false)
    end
end

--踢人结果
function UI_MemberMgr:recvKickResult()
    cclog("踢人后刷新结果")
    if self.cur_cy_pageMember == 1 then -- 踢的是最后一个
        ex_clubHandler:requestMemberList(self.cur_cy_pageIdx - 1 >0 and self.cur_cy_pageIdx - 1 or 1)
    else
        ex_clubHandler:requestMemberList(self.cur_cy_pageIdx)
    end
end

--================== 数据统计 ====================
--群数据统计翻页
function UI_MemberMgr:switchPageForTongJi(_num)
    local ret = self.cur_sj_pageIdx + _num
    if ret < 1 or ret > self.max_sj_pageIdx then
        return false
    end

    ex_clubHandler:toClubDataStatistics(ret)
end

--群数据统计清除
function UI_MemberMgr:clearDataForTongJi()
    ex_clubHandler:toClearClubDataForTongJi()
end

--刷新会员数据统计
function UI_MemberMgr:resetTongJiList(res)
    -- body
    cclog("UI_MemberMgr:resetTongJiList wtf")

    -- local res = {}
    -- res.maxPage = 10
    -- res.curPage = 1
    -- res.num = 50
    -- res.maxNumOfPage = 60
    -- res.curNumOfPage = 60



    -- res.pageData = {}
    -- for i = 1, 60 do
    --     table.insert(res.pageData, {
    --         index = #(res.pageData) + 1, 
    --         userName = "我是超级厉害玩家",
    --         userID = 987654,
    --         JuNum = 99,
    --         WinNum = 888,
    --         HuNum = 10,
    --         WLScore = -100})
    -- end

    self.max_sj_pageIdx = res.maxPage
    self.cur_sj_pageIdx = res.curPage
    self.max_sj_NumOfPage = res.maxNumOfPage
    self.data_sj_tb = res.pageData

    self.txt_sj_page:setString(res.curPage.."/"..res.maxPage)

    -- if self.tableView ~= nil then
    --     --self.tableView:removeFromParent()
    --     self.tongjiList:removeAllChildren()
    -- end

    

    -- local tongjiListItem = display.newCSNode("club/Item_flockdatadetail.csb"):getChildByName("itemLayout")
    -- self.tableView = ex_fileMgr:loadLua("app/Common/PPTableView").new(self.tongjiList, tongjiListItem, #(self.data_sj_tb), cc.size(990, 42), self)

    --local icon = ex_fileMgr:loadLua("app.views.club.NumIcon").new()
    --icon:setNum(1234)

    self.tongjiList:removeAllItems()
    local num = #res.pageData
    for index = 1, num do

        local layout = ccui.Layout:create()
        

        local item = display.newCSNode("club/Item_flockdatadetail.csb")
        local size = item:findChildByName("itemLayout"):getContentSize()
        item:setPosition(cc.p(0,0))
        item:setTag(668)
        item:addTo(layout)

        self:setTableViewCell(item, index)

        layout:setContentSize(size.width, size.height)
        self.tongjiList:pushBackCustomItem(layout)
    end

end

function UI_MemberMgr:setTableViewCell(_item, _index)
    --cclog("UI_MemberMgr:setTableViewCell  _index:".._index)
    -- local _itemW = self:loadChildrenWidget(_item)
    local data = self.data_sj_tb[_index]

    -- _item:findChildByName("item_1"):setString("")
    -- local icon = _item:findChildByName("item_1"):getChildByName("NumIcon")
    -- if icon == nil then
    --     icon = ex_fileMgr:loadLua("app.views.club.NumIcon").new()
    --     icon:addTo(_item:findChildByName("item_1"))
    --     icon:setScale(0.9)
    -- end

    -- icon:setNum(data.index + (self.cur_sj_pageIdx - 1) * self.max_sj_NumOfPage)

    local numb = data.index + (self.cur_sj_pageIdx - 1) * self.max_sj_NumOfPage

    if numb > 3 then
        _item:findChildByName("item_1"):setString(numb)
        _item:findChildByName("icon_bei"):setVisible(false)
    elseif numb >0 then
        _item:findChildByName("item_1"):setString("")
        local bei = _item:findChildByName("icon_bei")
        bei:setVisible(true)
        bei:loadTexture(string.format("image_club/com_icon/icon_bei%d.png", numb),1)
    end

    local a,b = math.modf(numb/2) 
    if b == 0 then
        _item:findChildByName("bg1"):setVisible(true)
    else
        _item:findChildByName("bg1"):setVisible(false)
    end

    _item:findChildByName("item_2"):setString(data.userName)
    _item:findChildByName("item_3"):setString(data.userID)
    _item:findChildByName("item_4"):setString(data.JuNum.."局")
    _item:findChildByName("item_5"):setString(data.WinNum.."次")
    _item:findChildByName("item_6"):setString(data.HuNum.."次")
    
    if data.WLScore >=0 then
        _item:findChildByName("item_7"):setColor(cc.c3b(252,106,34))
        _item:findChildByName("item_7"):setString("+" ..data.WLScore)
    else
        _item:findChildByName("item_7"):setColor(cc.c3b(0,131,254))
        _item:findChildByName("item_7"):setString(data.WLScore)
    end

end

return UI_MemberMgr
