--带local是局部变量，不带local全局变量
ClubChatMgr = {}
ClubChatMgr._config = {}
ClubChatMgr._saveMsgNum = 50
ClubChatMgr._curClubID = -1
ClubChatMgr._isInit = false
ClubChatMgr._localPath = "chatPic/"
ClubChatMgr._netPath = "chatPic/"

function copyTable(_t1, _t2)
	local function func(t1, t2)
		for key, var in pairs(t1) do
			if type(var) == "table" then
				t2[key] = {}
				func(var, t2[key])
			else	
				t2[key] = var
			end
		end
	end
	if _t2 == nil then 
        _t2 = {} 
    end
	func(_t1, _t2)
	return _t2
end


ClubChatMgr.msgChannel = {
    hall = 1,
    private = 2,
    group = 3,
}

ClubChatMgr.msgType = {
--[[
    1：文本消息(支持图文混排)
    2：分享消息
    3：语音消息
    4：开放信息
    5：分享战绩
--]]
    common = 1,
    shareNotify = 2,
    voice = 3,
    openRoom = 4,
    shareResult = 5,
}

ClubChatMgr.msgData = {
    clubID = "",
    userID = "",
    userName = "",
    userIcon = "",
    msgChannel = 1, --以后扩展聊天频道
    msgType = 1,    --聊天消息类型
    msgTime = "",   --时间
    isMe = false,   --是否是自己
    isRead = false, --是否被读
    content = "",
    extraJson = {},
    notifyPeople = {},  --艾特的人群

    --开房信息
    openRoom = nil,
    --战绩分享
    shareResult = nil,
}

ClubChatMgr.openRoomData = {
    userID = "",
    roomID = "",
    round = "",
    desc = "",
    descJson = ""
}

ClubChatMgr.shareResult = {
    userID = "",
    roomID = "",
    curRound = "",
    sumRound = "",
    playerList = {
        [1] = {
            name = "",
            icon = "",
            score = 0,
        },
        [2] = {
            name = "",
            icon = "",
            score = 0,
        },
        [3] = {
            name = "",
            icon = "",
            score = 0,
        },
        [4] = {
            name = "",
            icon = "",
            score = 0,
        },
    },
    iconPath = "",
}

function ClubChatMgr:init()
    if ClubChatMgr._isInit == false then
        ClubChatMgr._isInit = true
        cclog("ClubChatMgr:init")
        self._config = {}
        self._config["msgList"] = {}

    	self:newClubMsgList(-1)  --测试

        self:setListen()
    end
end

function ClubChatMgr:newClubMsgList(_clubID)
    if self._config["msgList"][_clubID] == nil then
        self._config["msgList"][_clubID] = {}
        local mainTb = self._config["msgList"][_clubID]
        for i, v in pairs(ClubChatMgr.msgChannel) do
            mainTb[v] = {}
            --[[
            for j, w in pairs(ClubChatMgr.msgType) do
                mainTb[v][w] = {}
            end
            --]]
        end
    end
    if self._config["LAST_AITE_MAG"] == nil then
        self._config["LAST_AITE_MAG"] = {}
    end
end

function ClubChatMgr:getClubMsgList(_clubID)
    self:newClubMsgList(_clubID)
    return self._config["msgList"][_clubID]
end

--获取俱乐部是否有艾特我的信息
function ClubChatMgr:getLastAITEMsgForMe(_clubID, _isRemove)
    return self._config["LAST_AITE_MAG"][_clubID]
end

--获取俱乐部是否有艾特我的信息
function ClubChatMgr:removeLastAITEMsgForMe(_clubID)
    self._config["LAST_AITE_MAG"][_clubID] = nil
end

--存储当前俱乐部ID
function ClubChatMgr:setCurClubID(_clubID)
    cclog("setCurClubID  _clubID:".._clubID)
    ClubChatMgr._curClubID = _clubID
end

function ClubChatMgr:exit()
    CCXNotifyCenter:unListenByObj(self)
end

function ClubChatMgr:setListen()
    self:exit()
    CCXNotifyCenter:listen(self, function(obj,key,data) self:S2C_clubChatMsg(data) end, "S2C_clubChatMsg")
    CCXNotifyCenter:listen(self, function(obj,key,data) self:S2C_clubMemberList(data) end, "S2C_memberList")

end

function ClubChatMgr:getInfo(key)
    return self._config[key]
end

function ClubChatMgr:setInfo(key, value)
    self._config[key] = value
    --print(value , key)
end

--============================================================
--根据频道获取消息
function ClubChatMgr:getMsgByChannel(_channel)
    cclog("_curClubID："..ClubChatMgr._curClubID)
    local mainTb = self:getClubMsgList(ClubChatMgr._curClubID)
    return mainTb[_channel]
end
--根据频道，类型获取消息
function ClubChatMgr:getMsgByChannelAndType(_channel, _msgType)
    local mainTb = self:getClubMsgList(ClubChatMgr._curClubID)
    local tb = {}
    for i, v in ipairs(mainTb[_channel]) do
        if v.msgType == _msgType then
            table.insert(tb, v)
        end
    end
    return tb
end
--插入消息
function ClubChatMgr:insertMsgToChannel(_msg)
    cclog("新消息 clubID:".._msg.clubID.."  msgChannel:".._msg.msgChannel)
    local mainTb = self:getClubMsgList(_msg.clubID)
    local tb = mainTb[_msg.msgChannel]
    if #(tb) >= ClubChatMgr._saveMsgNum then
        table.remove(tb, 1)
    end
    table.insert(mainTb[_msg.msgChannel], _msg)

    --存储俱乐部最后一条艾特我的信息
    if _msg.msgType == ClubChatMgr.msgType.common then
        if ClubGlobalFun:judgeAITEMsgForMe(_msg.content) == true then
            cclog("wtf 插入一条艾特信息 @@@@@@")
            self._config["LAST_AITE_MAG"][_msg.clubID] = copyTable(_msg)
        end
    end
end
--根据频道移除消息
function ClubChatMgr:removeReadMsgWithChannel(_channel)
    local mainTb = self:getClubMsgList(ClubChatMgr._curClubID)

    local function func(tb)
        for j, w in ipairs(tb) do
            if w.isRead == true then
                table.remove(tb, j)
                return false
            else
                break
            end
        end
        return true
    end

    local tb = mainTb[_channel]
    while(func(tb) == false) do end
end
--根据频道，类型移除消息
function ClubChatMgr:removeReadMsgWithChannelAndType(_channel, _msgType)
    local mainTb = self:getClubMsgList(ClubChatMgr._curClubID)

     local function func(tb)
        for j, w in ipairs(tb) do
            if w.msgType == _msgType and w.isRead == true then
                table.remove(tb, j)
                return false
            else
                break
            end
        end
        return true
    end

    local tb = mainTb[_channel]
    while(func(tb) == false) do end
end
--============================================================

function ClubChatMgr:print()
	-- body
	print_r(self._config)
end

function ClubChatMgr:S2C_clubChatMsg(_data)
    cclog("ClubChatMgr:S2C_clubChatMsg")
    print_r(_data)
    local newMsg = copyTable(ClubChatMgr.msgData)
    newMsg.clubID = _data.clubID
    newMsg.userID = _data.userID
    if PlayerInfo.playerUserID == newMsg.userID then
        newMsg.isMe = true
    end
    if newMsg.userID == -1 then
        newMsg.userName = "筑志助手"
    end
    newMsg.msgType = _data.msgType

    if newMsg.msgType == ClubChatMgr.msgType.common then
        local c4 = '\003'..'\003'..'\003'
        local data = string.split(_data.content, c4)
        newMsg.content = data[1]
        newMsg.extraJson = json.decode(data[2])
        newMsg.userName = _data.userName
        newMsg.userIcon = _data.userIcon
    elseif newMsg.msgType == ClubChatMgr.msgType.shareNotify then

    elseif newMsg.msgType == ClubChatMgr.msgType.voice then

    elseif newMsg.msgType == ClubChatMgr.msgType.openRoom then
        newMsg.openRoom = _data.openRoom
        newMsg.openRoom.desc = GameRule:clubGameRuleText(newMsg.openRoom.descJson)
        newMsg.userName = "筑志助手"
    elseif newMsg.msgType == ClubChatMgr.msgType.shareResult then
        newMsg.shareResult = _data.shareResult
    end
    self:insertMsgToChannel(newMsg)
    cclog("插入一条新消息!!!")
    --print_r(newMsg)
    CCXNotifyCenter:notify("newClubChatMsg", newMsg)
    CCXNotifyCenter:notify("newClubChatMsg2", newMsg)
end

function ClubChatMgr:S2C_clubMemberList(_data)
    
end

--================聊天截图管理=================
--截图
function ClubChatMgr:ScreenShot(_picName, _scale)
    local fullLoaclPath = ex_fileMgr:getWritablePath()..ClubChatMgr._localPath
    if ex_fileMgr:isDirectoryExist(chatPath) == true then
        GlobalFun:ScreenShot(_picName, _scale)
    else
        if ex_fileMgr:createDirectory(chatPath) == false then
            cclog("不存在聊天存放图片路径")
            return
        end
        self:ScreenShot(_picName, _scale)
    end 
end
--上传
function ClubChatMgr:uploading(_picName)
    local fullLoaclPath = ex_fileMgr:getWritablePath()..ClubChatMgr._localPath
    if ex_fileMgr:isDirectoryExist(chatPath) == true then
        if ex_fileMgr:isFileExist(chatPath) == true then
            --提交
            local fullNetPath = ex_fileMgr:getWritablePath()..ClubChatMgr._netPath

        end
    else
        if ex_fileMgr:createDirectory(chatPath) == false then
            cclog("不存在聊天存放图片路径")
            return
        end
        self:uploading(_picName)
    end 
end
--下载
function ClubChatMgr:download(_picName)
    local fullLoaclPath = ex_fileMgr:getWritablePath()..ClubChatMgr._localPath
    if ex_fileMgr:isDirectoryExist(chatPath) == true then
        if ex_fileMgr:isFileExist(chatPath.._picName) == true then
            --删除本地
            ex_fileMgr:removeFile(chatPath.._picName)
        end
        --下载
        local fullNetPath = ex_fileMgr:getWritablePath()..ClubChatMgr._netPath

    else
        if ex_fileMgr:createDirectory(chatPath) == false then
            cclog("不存在聊天存放图片路径")
            return
        end
        self:download(_picName)
    end 
end
--删除网络(暂定)
function ClubChatMgr:deleteNet(_picName)
    local fullNetPath = ex_fileMgr:getWritablePath()..ClubChatMgr._netPath
    
end
--删除本地
function ClubChatMgr:deleteLocal(_picName)
    local fullLoaclPath = ex_fileMgr:getWritablePath()..ClubChatMgr._localPath
    if ex_fileMgr:isDirectoryExist(chatPath) == true then
        if ex_fileMgr:isFileExist(chatPath.._picName) == true then
            --删除本地
            ex_fileMgr:removeFile(chatPath.._picName)
        end
    else
        if ex_fileMgr:createDirectory(chatPath) == false then
            cclog("不存在聊天存放图片路径")
            return
        end
        self:deleteLocal(_picName)
    end 
end
--========================================






