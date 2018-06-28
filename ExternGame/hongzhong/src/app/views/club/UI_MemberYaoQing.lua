
local UI_MemberYaoQing = class("UI_MemberYaoQing", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_MemberYaoQing:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_MemberYaoQing.csb")
    self.root:addTo(self)

    UI_MemberYaoQing.super.ctor(self)
    _w = self._childW

    self:initUI()
end

function UI_MemberYaoQing:initUI()

    self.memberList = _w["memberList"]

    -- self.panel_chengyuan = _w["panel_chengyuan"]

    self.txt_cy_page = _w["txt_cy_page"]
    self.cur_cy_pageIdx = 1
    self.max_cy_pageIdx = 100
    -- self.cur_cy_pageMember = 0

    self.txt_renshu = _w["txt_renshu"]
    self.select_tab= {}
    self.max_sel = 3000000
    self:setYaoQingCount(0)

    self.yaoqing_time = 3*60

    self.one_second = 0  --1秒计数变量
    ex_timerMgr:register(self) 

    self.cy_common_tab = {}

    -- self:resetMemberList(res)
end

function UI_MemberYaoQing:onEnter()
    CCXNotifyCenter:listen(self,function(obj,key,data) self:resetMemberList(data) end, "ROOM:onChengYuanList")


    ex_roomHandler:chengYuanList(self.cur_cy_pageIdx)
end

function UI_MemberYaoQing:update(dt)
    self.one_second = self.one_second + dt
    if self.one_second >= 1 then
        cclog("UI_MemberYaoQing:update >>>")
        self.one_second = 0
    end
end

function UI_MemberYaoQing:onExit()
    CCXNotifyCenter:unListenByObj(self)
    ex_timerMgr:unRegister(self)

    cc.AnimationCache:destroyInstance()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end

function UI_MemberYaoQing:onUIClose()
    self:removeFromParent()
end

function UI_MemberYaoQing:onClick(_sender)
	local name = _sender:getName()
    cclog("UI_MemberYaoQing name:"..name)
    if name == "btn_back" then
        self:closeUI()

    elseif name == "btn_yaoqing" then
        self:onBtnYaoQing()
    elseif name == "btn_cy_last" then --成员列表上一页
        if self.cur_cy_pageIdx -1 >0 then
            ex_roomHandler:chengYuanList(self.cur_cy_pageIdx -1)
        end
    elseif name == "btn_cy_next" then  --成员列表下一页
        if self.cur_cy_pageIdx +1 <= self.max_cy_pageIdx then
            ex_roomHandler:chengYuanList(self.cur_cy_pageIdx +1)
        end

    elseif name == "btn_shuaxin" then
        if not self.shuaxin_lock then
            self.shuaxin_lock = true
            local schedulerID = false
            local scheduler = cc.Director:getInstance():getScheduler()
            local function cb(dt)
                cclog("self.shuaxin_lock  false")
                scheduler:unscheduleScriptEntry(schedulerID)
                self.shuaxin_lock = false
            end
            schedulerID = scheduler:scheduleScriptFunc(cb, 5,false) 
            ex_roomHandler:chengYuanList(self.cur_cy_pageIdx)
        else
            GlobalFun:showToast("刷新过于频繁，请稍后再刷新" , 3)
        end
    end    
end


function UI_MemberYaoQing:setMemberPage(cur, max)
    self.txt_cy_page:setString(string.format("%s/%s", cur, max))
    self.cur_cy_pageIdx = cur
    self.max_cy_pageIdx = max
    cclog("UI_MemberYaoQing:setMemberPage >>>", cur, max)
end


function UI_MemberYaoQing:createChengYuanCommon(res)

    if next(self.cy_common_tab) then return end



    local contentSize = self.memberList:getContentSize()
    local data = res.data
    local num = #res.data
    local row = 7--排数
    local col = math.ceil(num/row)--行数
    local w, h = 100, 110
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
            pos_x = 5 
            pos_y = pos_y - offset_y +8
        else
            pos_x = pos_x + offset_x + 10
        end
        uiIndex = uiIndex + 1

        local layout = ccui.Layout:create()
        local size = cc.size(w,h)
        layout:setContentSize(size)
        layout:setPosition(cc.p(pos_x,pos_y))

        -- local item = display.newCSNode("club/Item_chengyuan.csb")
        -- local _itemW = self:loadChildrenWidget(item)
        -- item:setPosition(cc.p(pos_x,pos_y))
        -- item:addTo(layout)

        -- local icon = ex_fileMgr:loadLua("app.views.club.PlayerIcon").new()

        -- _itemW["node_icon"]:addChild(icon)

        local icon = ex_fileMgr:loadLua("app.views.club.PlayerIcon").new()
        local _itemW = self:loadChildrenWidget(icon)
        icon:setScale(0.65)
        icon:setPosition(size.width/2, size.height/2)
        icon:addTo(layout)

        _itemW["name"]:setVisible(true)
        _itemW["btn_add"]:setVisible(false)


        GlobalFun:uiTextCut(_itemW["name"])




        icon:setClickFunc(function() self:onSetSelect(index) end)


        self.memberList:addChild(layout)

        self.cy_common_tab[index] = {item = layout, _itemW = _itemW, icon = icon, data = nil}
    end
    local innerSize = self.memberList:getInnerContainer():getContentSize()
    self.memberList:setInnerContainerSize(cc.size(innerSize.width,totalHeight))
end

function UI_MemberYaoQing:showChengYuan(res)
    for k = 1, res.maxNumb do
        self:cleanChengYuanCommon(k)

        local info = res.data[k]
        local common = self.cy_common_tab[k]
        if info then
            if common then
                local icon = common.icon
                local _itemW = common._itemW
                local item = common.item
                common.item:setVisible(true)
                -- icon:setPlayerStatus(info.status)
                _itemW["name"]:setString(info.name)
                -- _itemW["img_heimingdan"]:setVisible(info.isHeimingdan)
                icon:setIcon(info.userID, info.icon)
                -- icon:showZhiWei(info.userID)

                common.data = info

                self:showSelect(k)
            end
        end
    end
end

function UI_MemberYaoQing:cleanChengYuanCommon(idx)
    local common = self.cy_common_tab[idx]
    if common then
        local icon = common.icon
        local _itemW = common._itemW
        local item = common.item
        common.item:setVisible(false)
        icon:setPlayerStatus(-1)
        _itemW["name"]:setString("")
        _itemW["img_heimingdan"]:setVisible(false)
        icon:removeHeadImg()
        icon:showSelect(false)
        icon:showYiYaoQing(false)

        common.data = nil

    end
end



function UI_MemberYaoQing:resetMemberList(res)
    -- body
    -- print_r(res)
    -- cclog("UI_MemberYaoQing:resetMemberList >>>", res.num, #res.data)
    -- self.memberList:removeAllChildren()



    -- local res = {
    --     maxPage = 10,
    --     curPage = 1,
    --     maxNumb = 21,
    --     count = 21,
    --     data = {},
    -- }

    -- for i=1, res.count do
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



    self:setMemberPage(res.curPage, res.maxPage)
    self:createChengYuanCommon(res)
    self:showChengYuan(res)
end

function UI_MemberYaoQing:showSelect(idx)

    local common = self.cy_common_tab[idx]
    if not common or not common.data then return end



    local info = common.data
    local icon = common.icon


    for k,v in pairs(self.select_tab) do
        if v.userID == info.userID then
            icon:showSelect(true)
        end
    end

    local ytime = ClubManager:getYaoQingJinFang(info.userID)
    -- cclog("UI_MemberYaoQing:showSelect >>>", idx, ytime)
    if ytime and os.time() - ytime <= self.yaoqing_time then
        icon:showYiYaoQing(true)
    else
        icon:showYiYaoQing(false)
    end
end

function UI_MemberYaoQing:onSetSelect(idx)
    cclog("onSetSelect >>>>", idx)
    local common = self.cy_common_tab[idx]
    if not common or not common.data then return end

    local info = common.data
    local icon = common.icon
    cclog("onSetSelect >>>>", info.userID)

    local isFind = nil
    for k,v in pairs(self.select_tab) do
        if v.userID == info.userID then
            isFind = k

        end
    end

    if #self.select_tab == self.max_sel and not isFind then
        -- GlobalFun:showToast("邀请人数!", 1)
        return
    end



    if isFind then
        table.remove(self.select_tab, isFind)
        icon:showSelect(false)
        self:setYaoQingCount(#self.select_tab)
    else

        local ytime = ClubManager:getYaoQingJinFang(info.userID)
        if ytime and os.time() - ytime <= self.yaoqing_time then
            GlobalFun:showToast(string.format("%d分钟内不能重复邀请", self.yaoqing_time/60), 2)
            return 
        end

        table.insert(self.select_tab, info)
        self:setYaoQingCount(#self.select_tab)
        icon:showSelect(true)
    end

    
end

function UI_MemberYaoQing:setYaoQingCount(numb)
    -- self.txt_renshu:setString(string.format("已选中：%d/%d", numb, self.max_sel))
    self.txt_renshu:setString(string.format("已选中：%d", numb))
end

function UI_MemberYaoQing:doYaoQingJinFang(uid)
    local ytime = ClubManager:getYaoQingJinFang(uid)

    local isYaoQing = false
    if ytime then
        if os.time() - ytime > self.yaoqing_time then
            ClubManager:setYaoQingJinFang(uid, os.time())  --记录邀请时间
            isYaoQing = true
        else

        end
    else
        ClubManager:setYaoQingJinFang(uid, os.time())  --记录邀请时间
        isYaoQing = true
    end

    
    if isYaoQing then
        cclog("I_MemberYaoQing:oYaoQingJinFang can >>>", uid)
    else
        cclog("I_MemberYaoQing:oYaoQingJinFang not >>>", uid)
    end

    return isYaoQing
end



function UI_MemberYaoQing:onBtnYaoQing()
    local list = {}
    for k,v in pairs(self.select_tab) do
        if self:doYaoQingJinFang(v.userID) then
            list[#list+1] = v.userID
        end
    end

    if next(list) then
        GlobalFun:showToast("已发送邀请~！", 3)
        local str = ""
        for k,v in ipairs(list) do
            if str ~= "" then
                str = str .. "," .. tostring(v)
            else
                str = tostring(v)
            end
        end
        ex_roomHandler:yaoQingClubMember(str)

        self:closeUI()
    else
        GlobalFun:showToast("未选择邀请对象~！", 3)
    end
end

return UI_MemberYaoQing
