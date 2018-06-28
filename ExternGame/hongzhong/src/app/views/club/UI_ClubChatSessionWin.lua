
local UI_ClubChatSessionWin = class("UI_ClubChatSessionWin", ex_fileMgr:loadLua(PATH_CLUB_LUA.."LUIView"))

local c1 = "@"
local c2 = '\001'.." "	--取id用
local c3 = '\002'.." "	--取名字用
local c4 = '\003'..'\003'..'\003'

local _w = nil
function UI_ClubChatSessionWin:ctor(data)
    self.app = data.app
    self.root = display.newCSNode("club/UI_ClubChatSessionWin.csb")
    self.root:addTo(self)
    
	UI_ClubChatSessionWin.super.ctor(self)
	_w = self._childW

	self:initUI()
	self:setMainUI()
end

function UI_ClubChatSessionWin:onEnter()
	-- body
	self.inputLimit = 140
	self.inputContent = ""
	self.actualContent = ""
	self.AITE_TB = {}
	self.isCanSend = 0
	self.synchronousData = {}
	self.listViewLineData = {}
	self.listViewLineData["sumHeight"] = 0
	self.listViewLineData["showHeight"] = 480
	self.listViewLineData["list"] = {}
	self.iconCache = nil

	self.TF_input:addEventListenerTextField(
		function(_sender, _type)
		   if _type == 2 or _type == 3 then   --输入字符状态/删除状态
		   		self:updateCheckCNum()	--检查字数
		   		self:updateCheckAITE()	--检查艾特
		   end
		end)

	CCXNotifyCenter:listen(self, function(obj,key,data) self:newClubChatMsg(data) end, "newClubChatMsg")

	ClubChatMgr:setCurClubID(tonumber(ClubManager:getInfo("clubID")))

	self.notifyPanel:setVisible(false)

	self.title:setString(ClubManager:getInfo("clubName").."俱乐部 ("..ClubManager:getInfo("clubPeopleNum").."/"..ClubManager:getInfo("clubPeopleMaxNum").."人)") 

	-- self.chatList2:setVisible(false)
	--填充默认聊天历史数据
	self.chatList:removeAllItems()
	local tb = ClubChatMgr:getMsgByChannel(ClubChatMgr.msgChannel.hall)
	cclog("填充默认聊天历史数据  #tb:"..#tb)
	for i, v in ipairs(tb) do
		self:newClubChatMsg(v)
	end

	self:updateCheckCNum()

	--打开界面显示最后艾特我消息
	local lastMsg = ClubChatMgr:getLastAITEMsgForMe(tonumber(ClubManager:getInfo("clubID")), true)
	if lastMsg ~= nil then
		cclog("打开界面显示最后艾特我消息")
		ClubChatMgr:removeLastAITEMsgForMe(tonumber(ClubManager:getInfo("clubID")))
		self:showNotifyMsg(lastMsg)
	end
end

function UI_ClubChatSessionWin:onExit()
    CCXNotifyCenter:unListenByObj(self)
    
end

function UI_ClubChatSessionWin:update(dt)

end


function UI_ClubChatSessionWin:initUI()
	-- body
	self.title = _w["title"]
	self.chatList = _w["chatList"]
	-- self.chatList2 = _w["chatList2"]
	self.TF_input = _w["TF_input"]
	self.txt_cNum = _w["txt_cNum"]
	self.notifyPanel = _w["notifyPanel"]
	self.notifyMsg = _w["notifyMsg"]

end

--主设置
function UI_ClubChatSessionWin:setMainUI()


end


function UI_ClubChatSessionWin:onClick(_sender)
	local name = _sender:getName()
	cclog("UI_ClubChatSessionWin:onClick name:"..name)
	if name == "btn_back" then
		self:_closeUI()
	elseif name == "btn_send" then
		self:sendMsg()

		-- local res = {}
	 --    local str = "1111@club" --俱乐部id/来源id
	 --    local data = string.split(str, "@")
	 --    if #data > 1 and data[2] == "club" then        --俱乐部
	 --        res.clubID = 222222
	 --        res.userID = 11111
	 --        -- res.userID = PlayerInfo.playerUserID
	 --    else                        
	 --        res.clubID = -1
	 --        res.userID = tonumber(data[1])
	 --    end
	 --    res.msgType = 5
	 --    --[[
	 --        1：文本消息(支持图文混排)
	 --        2：分享消息
	 --        3：语音消息
	 --        4：开放信息
	 --        5：分享战绩
	 --    --]]
	 --    if res.msgType == 1 then
	 --        res.content = self.TF_input:getString()
	 --        res.userName = "aa"
	 --        res.userIcon = "b"
	 --    elseif res.msgType == 4 then
	 --        local res2 = {}
	 --        res2.roomID = 11
	 --        res2.round = 2
	 --        res2.descJson = '{"playerNum":4,"gameType":"hz","PLAY_LEILUO":true,"PLAY_7D":true,"PLAY_EIGHT":true,"PLAY_CONNON":true,"PLAY_AK_ONE_ALL":true,"za":0}'
	 --        res2.descJson = '{"PLAY_LEILUO":true,"za":0,"playerNum":4,"gameType":"hz"}'
	 --        res.openRoom = res2
	 --    elseif res.msgType == 5 then
	 --        local res2 = {}
	 --        res2.roomID = 1111111
	 --        res2.sumRound = 2
	 --        res2.curRound = 2
	 --        res2.memberNum = 3
	 --        res2.playerList = {}
	 --        for i = 1, res2.memberNum do
	 --            local user = {}
	 --            user.name = "aaa"
	 --            user.icon = "s"
	 --            user.score = 1
	 --            table.insert(res2.playerList, user)
	 --        end
	 --        res.shareResult = res2
	 --    end
		-- ClubChatMgr:S2C_clubChatMsg(res)
		-- self:sendMsg()
	end
end

function UI_ClubChatSessionWin:onTouch(_sender, _type)
	local name = _sender:getName()
--	cclog("UI_ClubChatSessionWin:onTouch name:"..name.."  _type:".._type)
	if _type == 2 and name == "RoomCard_panel" then
		_w["RoomCard_panel"]:setVisible(false)
	end
end

function UI_ClubChatSessionWin:onListViewEvent(_sender, _type)
	local name = _sender:getName()
	--cclog("UI_ClubChatSessionWin:onListViewEvent name:"..name.."  _type:".._type)

end

function UI_ClubChatSessionWin:updateCheckCNum()
    local content = self.TF_input:getString()
    local count = self:utf8len(content)
    if count <= self.inputLimit then
        self.txt_cNum:setString(count.."/"..self.inputLimit)
        self.txt_cNum:setTextColor(cc.c3b(26, 26, 26))
        self.isCanSend = 0
        if count == 0 then
        	self.isCanSend = -1
        	self.inputContent = ""
			self.actualContent = ""
			self.AITE_TB = {}
        end
    else
        self.txt_cNum:setString(count.."/"..self.inputLimit)
        self.txt_cNum:setTextColor(cc.c3b(255, 0, 0))
        self.isCanSend = -2
    end
end

function UI_ClubChatSessionWin:updateCheckAITE()
	local content = self.TF_input:getString()
	--local newContent = self:AllNameToID(content)
	local data = string.split(content, c1)
	if #data <= 1 then
		--cclog("检查艾特 fuck content:"..content)
		self.AITE_TB = {}
		return
	end 

	local aite_TB = {}

	

	print_r(data)
	local newStr = data[1]
	for i, v in ipairs(data) do
		if i > 1 then
			local lineData = string.split(v, c3)
			if #lineData > 1 then
				local ID = self:getIDWithName(lineData[1])
				aite_TB[ID] = true
			end
		end
	end

	local function isExist(ID)
		return aite_TB[ID] or false
	end
	local flag = true
	while(flag) do
		local flag2 = false
		for i, v in pairs(self.AITE_TB) do
			if isExist(i) == false then
				self.AITE_TB[i] = nil
				flag2 = true
				break
			end
		end
		flag = flag2
	end

end

function UI_ClubChatSessionWin:getIDWithName(_Name)
		cclog("UI_ClubChatSessionWin getIDWithName")
		print_r(self.AITE_TB)
		for i, v in pairs(self.AITE_TB) do
			if v == _Name then
				return i
			end
		end
		cclog("fuck not find Name:".._Name)
		return -1
	end

function UI_ClubChatSessionWin:newClubChatMsg(_msg)
	cclog("@@@@@@@@  newClubChatMsg", _msg.msgChannel, ClubChatMgr.msgChannel.hall)
	if _msg.msgChannel == ClubChatMgr.msgChannel.hall then
		
		local items = self.chatList:getItems()
		local count = #items
		if count >= ClubChatMgr._saveMsgNum then
			--超了,移除
			local layout = self.chatList:getItem(0)
			self.synchronousData[layout:getTag()] = nil
			self.chatList:removeItem(0)
		end
		self:pushMsg(self.chatList, _msg)

		--[[
		local count = self.chatList2:getChildrenCount()
		if count >= ClubChatMgr._saveMsgNum then
			--超了,移除
		
		end
		self:pushMsg(self.chatList2, _msg)
		--]]
		
		
	end
end

local curTag = 0
function UI_ClubChatSessionWin:newTag()
	curTag = curTag + 1
	if curTag > 5000 then
		curTag = 1
	end
	return curTag
end

function UI_ClubChatSessionWin:showNotifyMsg(_msg)
	local flag = self:checkAITEWithMe(_msg.content)
	if flag == true and _msg.isRead == false then
		_msg.isRead = true
		ClubChatMgr:removeLastAITEMsgForMe(tonumber(ClubManager:getInfo("clubID")))
		self.notifyPanel:setVisible(true)

		local newContent = self:AllIDToName(_msg.content)
		self.notifyMsg:setString(_msg.userName.." 说: "..newContent)

		GlobalFun:uiTextCut(self.notifyMsg)

		local a1 = cc.DelayTime:create(5)
		local a2 = cc.CallFunc:create(function()
			self.notifyPanel:setVisible(false)
		end)  
		self.notifyPanel:runAction(cc.Sequence:create(a1, a2))
	end
end

function UI_ClubChatSessionWin:pushMsg(_listView, _msg)
	--检测有艾特人,上方面板进行显示
	cclog("UI_ClubChatSessionWin:pushMsg >>>>")
	self:showNotifyMsg(_msg)

	local layout = ccui.Layout:create()
    local item = nil
    if _msg.msgType == ClubChatMgr.msgType.common then
    	if _msg.isMe == false then
		    item = display.newCSNode("club/Item_chatpanel.csb")
		else
			item = display.newCSNode("club/Item_chatpanel2.csb")
		end
		layout:setContentSize(cc.size(1100, 100))
	elseif _msg.msgType == ClubChatMgr.msgType.openRoom then
	    item = display.newCSNode("club/Item_chatpanel3.csb")
	    layout:setContentSize(cc.size(1100, 140))
	elseif _msg.msgType == ClubChatMgr.msgType.shareResult then
	    item = display.newCSNode("club/Item_chatpanel4.csb")
	    layout:setContentSize(cc.size(1100, 170))
	end
    item:addTo(layout)

    local tag = self:newTag()
    self.synchronousData[tag] = self:copyTable(_msg)
    layout:setTag(tag)
	layout:setTouchEnabled(true)
	layout:setSwallowTouches(false)
	layout:setAnchorPoint(cc.p(0, 0))
	layout:addTouchEventListener(function(sender, type)
    	if type == 2 then
        	cclog("item type:"..type.. "   tag:"..sender:getTag())
        	local msg = self.synchronousData[tag]
        	if msg ~= nil then
        		--print_r(msg)
			    if msg.msgType == ClubChatMgr.msgType.openRoom then
					--开房信息
					cclog("开房信息  roomID:"..msg.openRoom.roomID)
					ex_clubHandler:gotoRoom(msg.openRoom.roomID)

				elseif msg.msgType == ClubChatMgr.msgType.shareResult then
					--分享战绩
					cclog("分享战绩")

				end
        	else
        		cclog("消息为空,有问题!")
        	end
        end
    end)

    local _itemW = self:loadChildrenWidget(item)
    --头像响应事件
    _itemW["icon"]:setTag(tag)
    _itemW["icon"]:setTouchEnabled(true)
    _itemW["icon"]:addTouchEventListener(function(sender, type)
    	if type == 0 then
    		cclog("icon type:"..type.. "   tag:"..sender:getTag())
    		local tag = sender:getTag()
    		self.iconCache = {["tag"] = tag, ["flag"] = true}
			local a1 = cc.DelayTime:create(0.6)
			local a2 = cc.CallFunc:create(function()
				if self.iconCache ~= nil then
					if self.iconCache["flag"] == true then
						local msg = self.synchronousData[tag]
			        	if msg ~= nil then
			        		if msg.msgType == ClubChatMgr.msgType.common then --只有一般消息才能艾特
				        		--print_r(msg)
						   		--添加@
						   		self:addAITE(msg)
						   	end
			        	else
			        		cclog("消息为空,有问题!")
			        	end
					end
				end
			end)  
			sender:runAction(cc.Sequence:create(a1, a2))

        elseif type == 2 then
        	self.iconCache["flag"] = false
        	self.iconCache = nil
        elseif type == 3 then
        	self.iconCache["flag"] = false
        	self.iconCache = nil
        end
    end)
    cclog("111111")
    --_itemW["icon"]:loadTexture("")
    if _msg.userName == nil or _msg.userName == "" then
    	_msg.userName = self:IDToName(_msg.userID)
    	_itemW["name"]:setString(_msg.userName)

   	else
   		_itemW["name"]:setString(_msg.userName)
    end
	
    if _msg.msgType == ClubChatMgr.msgType.common then
    	local newContent = self:AllIDToName(_msg.content)
	    _itemW["content"]:setString(newContent)
	    cclog("content:".._msg.content)
	    self:adaptiveWidget(layout, _itemW["content"])
	    GlobalFun:uiTextCut(_itemW["content"])

	    local iconSize = _itemW["icon"]:getContentSize()
	    local icon = ex_fileMgr:loadLua("app.views.club.PlayerIcon").new()
	    _itemW["node_icon"]:addChild(icon)



	    local _itemW2 = self:loadChildrenWidget(icon:getRootView())
	    -- _itemW2["defaultIcon"]:loadTexture("image2/club/icon/defaultIcon.png")
	    -- _itemW2["icon"]:loadTexture("image2/club/icon/defaultIcon.png")
	    -- _itemW2["defaultIcon"]:setContentSize(iconSize.width, iconSize.height)
	    -- _itemW2["icon"]:setContentSize(iconSize.width + 10, iconSize.height + 10)
	    -- _itemW2["panel"]:setTouchEnabled(false)

	    local ds = _itemW2["defaultIcon"]:getContentSize()
	    icon:setScale(iconSize.width/ds.width+0.2)
	    icon:setIcon(_msg.userID, _msg.userIcon)

	elseif _msg.msgType == ClubChatMgr.msgType.openRoom then
		if _msg.openRoom ~= nil then
			 cclog("33333")
			_itemW["icon"]:loadTexture("image2/club/icon/assistantIcon.png")
			_itemW["roomID"]:setString(_msg.openRoom.roomID)
			_itemW["round"]:setString(_msg.openRoom.round.."局")
			_itemW["way"]:setString(_msg.openRoom.desc)
		end
	elseif _msg.msgType == ClubChatMgr.msgType.shareResult then
		if _msg.shareResult ~= nil then
			if _msg.userID == -1 then
				_itemW["icon"]:loadTexture("image2/club/icon/assistantIcon.png")
			end
			_itemW["roomID"]:setString(_msg.shareResult.roomID)
			_itemW["round"]:setString(_msg.shareResult.curRound.."/".._msg.shareResult.sumRound.."局")
			local list = _msg.shareResult.playerList
			for i = 1, 4 do 
				_itemW["playerContent_"..i]:setVisible(list[i] ~= nil)
				_itemW["playerContent_"..i.."_2"]:setVisible(list[i] ~= nil)
				if list[i] ~= nil then
					_itemW["playerContent_"..i]:setString(list[i].name)
					_itemW["playerContent_"..i.."_2"]:setString(list[i].score.."分")
					if tonumber(list[i].score) > 0 then
						_itemW["playerContent_"..i.."_2"]:setString("+"..list[i].score.."分")
						_itemW["playerContent_"..i.."_2"]:setTextColor(cc.c3b(0, 128, 0))
					elseif tonumber(list[i].score) == 0 then
						_itemW["playerContent_"..i.."_2"]:setTextColor(cc.c3b(0, 0, 0))
					else
						_itemW["playerContent_"..i.."_2"]:setTextColor(cc.c3b(255, 0, 0))
					end
				end
			end
		end
	end

	_msg.isRead = true
	_listView:pushBackCustomItem(layout)
	_listView:jumpToBottom()

	--[[
	local lineData = {}
	lineData.height = layout:getContentSize().height
	lineData.sender = layout
	table.insert(self.listViewLineData["list"], lineData)
	self.listViewLineData["sumHeight"] = self.listViewLineData["sumHeight"] + lineData.height

	if self.listViewLineData["sumHeight"] > self.listViewLineData["showHeight"] then
		 local size = _listView:getInnerContainerSize()
		_listView:setInnerContainerSize(cc.p(size.width, self.listViewLineData["sumHeight"]))
	end

	_listView:addChild(layout)
	layout:setPosition(cc.p(0, self.listViewLineData["sumHeight"] - lineData.height))

	--更新之前所有控件的高度
	local function updateChildPos()
		local countHeight = 0
		for i, v in ipairs(self.listViewLineData["list"]) do
			v.sender:setPosition(cc.p(0, self.listViewLineData["sumHeight"] - lineData.height - countHeight))
			countHeight = countHeight + lineData.height
		end
	end
	updateChildPos()

	_listView:jumpToBottom()
	cclog("testSize lineData.height:"..lineData.height.."  sumHeight:"..self.listViewLineData["sumHeight"])
	local testSize = _listView:getInnerContainerSize()
	cclog("testSize width:"..testSize.width.."  height:"..testSize.height)
	--]]
end

--关闭ui
function UI_ClubChatSessionWin:_closeUI()
	--处理一些消息
	CCXNotifyCenter:notify("resetRedPoint_chat", nil)
	self:closeUI()
end

--聊天内容自适配
function UI_ClubChatSessionWin:adaptiveWidget(_root, _text)
	cclog("UI_ClubChatSessionWin:adaptiveWidget")
	if _root == nil or _text == nil then return end







	-- self.txt_jieshao:setTextAreaSize(cc.size(375, 0))
	-- self.txt_jieshao:ignoreContentAdaptWithSize(false)
	-- local size = self.txt_jieshao:getVirtualRendererSize()
	-- rlabel:setLineBreakWithoutSpace(true)

	local w_size = _text:getSize()
	local str = _text:getString()
	if str == "" then return end
	local base_size = _text:getVirtualRendererSize()
	local width_rule = 0
	if base_size.width >800 then
		width_rule = 800
	elseif base_size.width <30 then
		width_rule = 30
	else
		width_rule = base_size.width
	end


	_text:setTextAreaSize(cc.size(width_rule < 30 and base_size.width or width_rule, 0))
	_text:ignoreContentAdaptWithSize(false)
	-- _text:setLineBreakWithoutSpace(true)
	local size = _text:getVirtualRendererSize()
	_text:setTextAreaSize(size)


	local items = self:loadChildrenWidget(_root)
	-- items["itemLayout"]:setContentSize(size.width, size.height)
	-- items["bgNew"]:setContentSize(size.width, size.height)

	items["icon"]:setPositionY(items["icon"]:getPositionY() +size.height -5)
	items["name"]:setPositionY(items["name"]:getPositionY() +size.height)
	-- items["angle"]:setPositionY(items["angle"]:getPositionY() +size.height)
	items["bg2"]:setPositionY(items["bg2"]:getPositionY() +size.height)

	items["bg2"]:setContentSize(width_rule +60, size.height +40)
	items["content"]:setAnchorPoint(cc.p(0,0.5))
	local tmp_s = items["bg2"]:getContentSize()
	items["content"]:setPosition(30, tmp_s.height/2)

	local tmp_s = _root:getContentSize()
	_root:setContentSize(tmp_s.width, size.height +20 +80)
	items["itemLayout"]:setContentSize(tmp_s.width, size.height +20 +80)
	items["bgNew"]:setContentSize(tmp_s.width, size.height +20 +80)


	-- if true then return end






	-- local str = _text:getString()
	-- --计算有多少个艾特
	-- local ATData = string.split(str, c1)
	-- --local len = self:strlen(str)
	-- --local num = math.ceil(len / 29)
	-- local len = ClubGlobalFun:calculateStringLen(str, _text:getFontSize())
	-- if len <= 2 then len = 2 end --至少给个5长度
	-- local num = math.ceil(len / 630)
	-- --default width = 630  height = 75  大概29个字一行,25像素高度一行
	-- local items = self:loadChildrenWidget(_root)
	-- local contentSize = items["content"]:getContentSize()
	-- local dValue = num * 28 - contentSize.height
	-- cclog("num:"..num.."  dValue:"..dValue.."  contentSize.height:"..contentSize.height)
	-- if dValue == 0 then return end
	-- local function setSize(w, height)
	-- 	local size = w:getContentSize()
	-- 	w:setContentSize(size.width, size.height + height)
	-- end
	-- local function setPos(w, height)
	-- 	local posY = w:getPositionY()
	-- 	cclog("posY:"..posY.."  height:"..height)
	-- 	w:setPosition(w:getPositionX(), posY + height)
	-- end
	-- local function setSizeX(w, width)
	-- 	local size = w:getContentSize()
	-- 	w:setContentSize(size.width - width + 20 * (#ATData), size.height)
	-- end

	-- if dValue > 0 then
	-- 	setSize(_root, dValue)
	-- 	setSize(items["itemLayout"], dValue)
	-- 	setSize(items["bgNew"], dValue)

	-- 	setPos(items["icon"], dValue)
	-- 	setPos(items["name"], dValue)
	-- 	setPos(items["angle"], dValue)

	-- 	setPos(items["bg2"], dValue)
	-- end

	
	-- setSize(items["bg2"], dValue)

	-- setPos(items["content"], dValue)
	-- setSize(items["content"], dValue)

	-- if num == 1 then
	-- 	setSizeX(items["bg2"], 630 - len)
	-- 	setSizeX(items["content"], 630 - len)
	-- end

	-- local function printD(w)
	-- 	local size = w:getContentSize()
	-- 	local x = w:getPositionX()
	-- 	local y = w:getPositionY()
	-- 	cclog("name:"..w:getName().."  width:"..size.width.."  height:"..size.height.."  x:"..x.."  y:"..y)
	-- end
	
	-- printD(items["content"])
end

--特殊计算字符长度规则
function UI_ClubChatSessionWin:strlen(_str)
	local count = self:utf8len(_str)


	return count
end

--添加艾特
function UI_ClubChatSessionWin:addAITE(_msg)
	if _msg.userID == PlayerInfo.playerUserID then
		GlobalFun:showToast("不能添加自己!", 2)
		return
	end

	--先相加之后是否超长度
	-- @ char(8197)
	local content = self.TF_input:getString() 
	self.inputContent = content
	--名字转换id
	self.actualContent = self:AllNameToID(content)

	local newStr = self.actualContent..c1.._msg.userID..c2
	local newLen = self:strlen(newStr)
	if newLen > self.inputLimit then
		GlobalFun:showToast("超过限定字数,@失败!", 2)
		return
	end
	if self.AITE_TB[_msg.userID] ~= nil then
		cclog("已添加该玩家 ID:".._msg.userID)
		GlobalFun:showToast("已添加该玩家!", 2)
		return 
	end

	local name = _msg.userName
	if name == nil or name == "" then
		name = self:IDToName(_msg.userID)
	end

	local newStr2 = self.inputContent..c1..name..c3
	cclog("self.actualContent:"..self.actualContent)
	cclog("self.inputContent:"..self.inputContent)
	cclog("newStr2:"..newStr2)
	self.actualContent = newStr
	self.inputContent = newStr2

	self.AITE_TB[_msg.userID] = name
	self.TF_input:setString(newStr2)
	self:updateCheckCNum()
	cclog("新增玩家ID userID:".._msg.userID.."  name:"..name)
end

--判断名字是否在table表存在
function UI_ClubChatSessionWin:judgeNameAtIDTable(_name)

end

--id转化为名称
function UI_ClubChatSessionWin:IDToName(_userID)
	local tb = ClubChatMgr:getMsgByChannel(ClubChatMgr.msgChannel.hall)
	for i, v in ipairs(tb) do
		if v.msgType == ClubChatMgr.msgType.common then --只有一般消息才能艾特
			if v.userID == _userID then
				if v.userName == nil or v.userName == "" then
					cclog("111 IDToName ID:".._userID)
					return "玩家".._userID
				end
				return v.userName
			end
		end
	end
	cclog("222 IDToName ID:".._userID)
	return "玩家".._userID
end

--聊天内容中id翻译成名字
function UI_ClubChatSessionWin:AllIDToName(_content)
	local data = string.split(_content, c1)
	if #data <= 1 then
		return _content
	end 

	--_content = "@123456"..c2.."你@123456"..c2.."还有你 @123456"..c2.."你们过来吃饭啊"
	cclog("wtf _content:".._content)
	--print_r(data)
	local newStr = data[1]
	for i, v in ipairs(data) do
		if i > 1 then
			local lineData = string.split(v, c2)
			if #lineData > 1 then
				--ID转玩家名
				local userName = self:IDToName(tonumber(lineData[1]))
				newStr = newStr..c1..userName..c3
				--再拼接剩余的文字
				for j = 2, #lineData do
					newStr = newStr .. lineData[j]
				end
			else
				newStr = newStr..c1..v
			end
		end
	end
	cclog("wtf newStr:"..newStr)
	return newStr
end

function UI_ClubChatSessionWin:AllNameToID(_content)
	local data = string.split(_content, c1)

	cclog("#data:"..#data)
	print_r(data)

	local IDNameTb = {}
	local newStr = data[1]
	for i, v in ipairs(data) do
		if i > 1 then
			local lineData = string.split(v, c3)
			if #lineData > 1 then
				--ID转玩家名
				local ID = self:getIDWithName(lineData[1])
				cclog("AllNameToID lineData[1]:"..lineData[1].."  ID:"..ID)
				if ID ~= -1 then
					newStr = newStr..c1..ID..c2
					IDNameTb[ID] = lineData[1]
					--再拼接剩余的文字
					for j = 2, #lineData do
						newStr = newStr .. lineData[j]
					end
				else
					newStr = newStr..c1..v
				end
			else
				newStr = newStr..c1..v	
			end
		end
	end
	return newStr, IDNameTb
end

function UI_ClubChatSessionWin:checkAITEWithMe(_content)
	local data = string.split(_content, c1)
	if #data <= 1 then
		return false
	end 

	cclog("wtf _content:".._content)
	--print_r(data)
	local newStr = data[1]
	for i, v in ipairs(data) do
		if i > 1 then
			local lineData = string.split(v, c2)
			if #lineData > 1 then
				--ID转玩家名
				local id = tonumber(lineData[1])
				if id ~= nil and id == PlayerInfo.playerUserID then
					return true
				end
			end
		end
	end
	cclog("wtf newStr:"..newStr)
	return false
end

--发送消息
function UI_ClubChatSessionWin:sendMsg()
	

	if self.isCanSend == 0 then
		local content = self.TF_input:getString()
		--名字转换id
		local IDNameTb = {}
		self.actualContent, IDNameTb = self:AllNameToID(content)
		cclog("content:"..content)
		cclog("actualContent:"..self.actualContent)
		local res = {}
		res.clubID = ClubManager:getClubID()--ClubChatMgr._curClubID
		--res.content = content
		--extra消息
		IDNameTb["PPP"] = 1 
		local jsonStr = json.encode(IDNameTb)
		--jsonStr = "{}"
		res.content = self.actualContent..c4..jsonStr
		print_r(res)
		ex_clubHandler:toSendChatRoomMsg(res)

		self.TF_input:setString("")
		self.inputContent = ""
		self.actualContent = ""
		self.AITE_TB = {}
		self:updateCheckCNum()
	elseif self.isCanSend == -1 then
		GlobalFun:showToast("内容不能为空", 2)
	elseif self.isCanSend == -2 then
		GlobalFun:showToast("超过限定字数,请重新输入", 2)
	end
    
end

return UI_ClubChatSessionWin
