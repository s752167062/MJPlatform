

local UI_ClubShenqingliebiao = class("UI_ClubShenqingliebiao", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local _w = nil
function UI_ClubShenqingliebiao:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_ClubShenqingliebiao.csb")
    self.root:addTo(self)

	UI_ClubShenqingliebiao.super.ctor(self)
	_w = self._childW
  
  	self:initUI()
	self:setMainUI()
end

function UI_ClubShenqingliebiao:onEnter()
    -- body   
    CCXNotifyCenter:listen(self,function(obj,key,data) self:resetShenqingList(data) end, "S2C_JoinList")
    CCXNotifyCenter:listen(self,function(obj,key,data) self:requestJoinList(data) end, "S2C_JoinResult")
    ex_clubHandler:C2S_JoinList(1)



    -- local res = {}
    -- res.total = 100
    -- res.onePageMax = 5
    -- res.maxPage = 20
    -- res.curPage = 1
    
    -- res.num =5
    -- res.joinList = {}
    -- for i=1,res.num do
    --     local info = {}
    --     info.id = 1111111
    --     info.userID = 1111111
    --     info.name = "aaa"
    --     info.icon = "http://192.168.1.200/zhuzhi_zhuzhijihe/ExternGameAssets/GameIcons/hongzhong1.png"
    --     info.time = "2018-10-10"
    --     res.joinList[#res.joinList+1] = info
    -- end
    -- self:resetShenqingList(res)
end

function UI_ClubShenqingliebiao:onExit()
    -- body
    CCXNotifyCenter:unListenByObj(self)
    -- ex_clubHandler:C2S_clubSetting()

     cc.AnimationCache:destroyInstance()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end

function UI_ClubShenqingliebiao:initUI()
	-- body
	self.shenqingList = _w["shenqingList"]

    self.txt_cy_page = _w["txt_cy_page"]
    self.cur_cy_pageIdx = 1
    self.max_cy_pageIdx = 100
    self.cur_cy_pageMember = 0
end

function UI_ClubShenqingliebiao:setMemberPage(cur, max)
    self.txt_cy_page:setString(string.format("%s/%s", cur, max))
    self.cur_cy_pageIdx = cur
    self.max_cy_pageIdx = max
    cclog("UI_MemberMgr:setMemberPage >>>", cur, max)
end

--主设置
function UI_ClubShenqingliebiao:setMainUI()
	
end

function UI_ClubShenqingliebiao:requestJoinList(data)
    -- body
    cclog("UI_ClubShenqingliebiao:requestJoinList >>>")
    print_r(data)
    if self.cur_cy_pageMember == 1 and data.isSucc then -- 列表有变动，最后这个人要被处理掉
        self.shenqingList:removeAllItems()
        ex_clubHandler:C2S_JoinList(self.cur_cy_pageIdx - 1 >0 and self.cur_cy_pageIdx - 1 or 1)
    else
        ex_clubHandler:C2S_JoinList(self.cur_cy_pageIdx)
    end
end

function UI_ClubShenqingliebiao:resetShenqingList(data)
	-- body
    if not data then
        cclog("resetShenqingList is nil")
        return
    end
    print_r(data)


    self:setMemberPage(data.curPage, data.maxPage)
    self.cur_cy_pageMember = data.num


	local listview = self.shenqingList
    listview:removeAllItems()

    local num = #data.joinList
    for index = 1, num do
        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(675,105))

        local item = display.newCSNode("club/Item_shenqingliebiao.csb")
        item:setPosition(cc.p(0,0))
        item:setTag(668)
        item:addTo(layout)

        local info = data.joinList[index]
        local _itemW = self:loadChildrenWidget(item)
        _itemW["name"]:setString(info.name or "")
        GlobalFun:uiTextCut(_itemW["name"])
        
        _itemW["id"]:setString(info.userID or "")
        _itemW["time"]:setString(info.time or "")


        _itemW["yitongyi"]:setVisible(false)
        _itemW["yijujue"]:setVisible(false)

        local icon = ex_fileMgr:loadLua("app.views.club.PlayerIcon").new()
        _itemW["node_icon"]:addChild(icon)
        icon:setScale(0.7)
        icon:setIcon(info.userID, info.icon)

        _itemW["btn_tongyi"]:setTouchEnabled(true)
        _itemW["btn_tongyi"]:addClickEventListener(function() self:onAgree(0, info) end)
        _itemW["btn_jujue"]:setTouchEnabled(true)
        _itemW["btn_jujue"]:addClickEventListener(function() self:onAgree(1, info) end)

        listview:pushBackCustomItem(layout)
    end
end

function UI_ClubShenqingliebiao:onUIClose()
    self:removeFromParent()
end

function UI_ClubShenqingliebiao:onClick(_sender)
	local name = _sender:getName()
	if name == "btn_close" then
		self:onUIClose()
    elseif name == "btn_cy_last" then --成员列表上一页
        if self.cur_cy_pageIdx -1 >0 then
            ex_clubHandler:C2S_JoinList(self.cur_cy_pageIdx -1)
        end
    elseif name == "btn_cy_next" then  --成员列表下一页
        if self.cur_cy_pageIdx +1 <= self.max_cy_pageIdx then
            ex_clubHandler:C2S_JoinList(self.cur_cy_pageIdx +1)
        end  
	end
end

--响应 1 拒绝 0 同意
function UI_ClubShenqingliebiao:onAgree(agree, info)
    -- body
    cclog("onAgree "..tostring(agree)..", id = "..tostring(info.id))
    if agree == 0 then
        
        ex_clubHandler:C2S_JoinResult({id=info.id, agree = agree})
    elseif agree == 1 then

        local function cb ()
            ex_clubHandler:C2S_JoinResult({id=info.id, agree = agree})
        end
        ClubGlobalFun:showError(string.format("你要拒绝id为【%s】的玩家【%s】加入俱乐部吗？", tostring(info.userID), info.name),cb,nil,2)
    end
end

return UI_ClubShenqingliebiao
