local ClubController = class("ClubController")
local dkj = ex_fileMgr:loadLua("app.helper.dkjson")

function ClubController:ctor(params)
    self:inItProtocol()
end

function ClubController:receiveMsg(obj)
    self:handlerProtocol(obj:getProId(),obj)
end

--协议处理
function ClubController:handlerProtocol(proId,obj)
    proId = tonumber(proId)
    if self._proFuns[proId] then
        self._proFuns[proId](obj)
    else
        dump("error,non-existent protocol ID:"..proId)
    end
end

--协议注册
function ClubController:inItProtocol()
    self._proFuns = {}

    self._proFuns[0] = handler(self,self.onSendSid)
    self._proFuns[1] = handler(self,self.onHeartBeat)
    self._proFuns[1000] = handler(self,self.onConnectCheck)
    self._proFuns[999] = handler(self,self.onProtocolError)

    self._proFuns[1405] = handler(self,self.onClubGotoHall)
    self._proFuns[1410] = handler(self,self.onGotoRoom)

    --self._proFuns[1400] = handler(self,self.onEntryClub)               --登陆到俱乐部
    self._proFuns[1401] = handler(self,self.S2C_JoinList)         --請求加入列表  
    self._proFuns[1402] = handler(self,self.S2C_JoinResult)      --响应加入俱樂部請求
    self._proFuns[1403] = handler(self,self.onOpenRoomList)            --开房列表
    self._proFuns[1404] = handler(self,self.onModifyGameSetting)       --修改游戏配置
    self._proFuns[1406] = handler(self,self.onRoomCardStatistics)      --房卡统计
    self._proFuns[1407] = handler(self,self.onPersonCombatGains)       --个人战绩
    self._proFuns[1408] = handler(self,self.S2C_updateClubSetting)       --修改俱乐部配置
    self._proFuns[1409] = handler(self,self.S2C_clubSetting)             --设置界面
    self._proFuns[1411] = handler(self,self.onRequestCreateRoom)       --请求创建房间
    self._proFuns[1412] = handler(self,self.onDismissRoom)             --解散房间
    self._proFuns[1413] = handler(self,self.S2C_KickOut)              --踢人
    self._proFuns[1415] = handler(self,self.onUpdateRoomInfo)          --更新单条房间信息 如果房间不存在则添加 存在则修改
    self._proFuns[1416] = handler(self,self.onDeleteRoom)              --删除房间
    self._proFuns[1419] = handler(self,self.onGameSetting)             --读取游戏配置
    self._proFuns[1414] = handler(self,self.S2C_memberList)          --成员列表
    self._proFuns[1423] = handler(self,self.S2C_updateMemberInfo)      --更新单个成员信息
    self._proFuns[1420] = handler(self,self.S2C_DismissClub)      --解散俱乐部
    self._proFuns[1421] = handler(self,self.S2C_ExitClub)      --离开俱乐部
    self._proFuns[1424] = handler(self,self.onDeleteSetting)      --删除游戏快速开房的配置
    self._proFuns[1427] = handler(self,self.onGotoClub)      --进入俱乐部
    self._proFuns[1428] = handler(self,self.onClubList)      --请求俱乐部列表
    self._proFuns[1430] = handler(self,self.onChatRoomMsg)   --收到聊天信息


    self._proFuns[1433] = handler(self,self.onYaoQingJinFangTiShi)   --收到邀请进房

    self._proFuns[1431] = handler(self,self.onRedPoint)   --红点消息
    self._proFuns[1434] = handler(self,self.onClubDataStatistics)   --群数据统计
    self._proFuns[1432] = handler(self,self.onAppointManager)   --任命管理员


    self._proFuns[1435] = handler(self,self.onRequestJoinClub)  --请求加入俱乐部

    self._proFuns[1436] = handler(self,self.onXiuGaiBeiZhu)  --修改成员备注

    self._proFuns[1440] = handler(self,self.onInviteMemberToClub)   --邀请玩家进俱乐部(一式一份)
    self._proFuns[1441] = handler(self,self.onYaoQingJinJuLeBuTiShi)   --收到邀请进俱乐部(一式两份)
    self._proFuns[1442] = handler(self,self.onSearchPlayer)   --查询用户(一式一份)


    self._proFuns[1439] = handler(self,self.onTextHint)   --文字提示

    self._proFuns[1437] = handler(self,self.onOperateBlackList)   --加入/移出黑名单
    --self._proFuns[9999] = handler(self,self.onApplyForRoomCard)  --申请房卡(群成员)
    self._proFuns[1438] = handler(self,self.onSendRoomCard)  --发送房卡(群主)
    self._proFuns[1443] = handler(self,self.onGiveRoomCardRecord)  --查看房卡赠送记录

    self._proFuns[1444] = handler(self,self.onClearClubDataForTongJi)  --群统计数据清除
    self._proFuns[1445] = handler(self,self.onQuickMatching)  --俱乐部快速匹配
    self._proFuns[1446] = handler(self,self.onNotice)  --俱乐部公告

    self._proFuns[1447] = handler(self,self.onPlayingList) --俱乐部游戏玩法列表

    self._proFuns[1449] = handler(self,self.onRemovePlaying) --删除游戏玩法

    self._proFuns[1448] = handler(self,self.onAddGamePlaying) --添加游戏玩法

    self._proFuns[1450] = handler(self,self.onGameList) --游戏列表

end

function ClubController:sendSid()
	cclog("ClubController:sendSid >>>>>")
    local obj = Write.new(0)
    obj:send()
    ClubClient.socketState = 1
    ClubClient.socketT = 0
end

function ClubController:onSendSid()

	cclog("ClubController:onSendSid >>>>>")
    -- if GlobalData.isRoomToHall == false then
    --     cclog(" 1000 "..GlobalData.HallKey) 
    --     ClubController:connectCheck()
    -- else
        ClubController:connectCheck()
    -- end
    ClubClient.socketState = 2
    ClubClient.socketT = 0
end

function ClubController:getPid(protol)
    local obj = Write.new(protol)
    return obj
end

function ClubController:onProtocolError(obj)--所有错误都集合到这里来
    local res = {}
    res.errorCode =  obj:readByte()
    res.closeNetWork = obj:readBoolean()
    res.msg_err = obj:readString()
    
    local str = "错误不在错误列表里"
    if Error_conf[res.errorCode] then
        str = Error_conf[res.errorCode]
    end
    
    --res.msg_err = str .. "\n" .. res.msg_err
    -- CCXNotifyCenter:notify("onProtocolError",res)

    ClubClient:onProtocolError(res)
end

--这里的产品号和版本要注意
function ClubController:connectCheck()--连接校验 
    --协议号1000
    cclog("ClubController:connectCheck >>>>>")

    local server_type = platformExportMgr:doGameNetMgr_getServerTypeByCurrent()
    if server_type ~= platformExportMgr:getGlobalGameSeverType("club")  then
        GlobalFun:showError("网络故障，目标服务器id异常，点击确定返回平台",function ()
            platformExportMgr:returnAppPlatform()
            end,nil,1)
        return false
    end


    local obj = Write.new(1000)
    obj:writeString("hz")
    obj:writeString(platformExportMgr:doGameConfMgr_getInfo("hostKey"))
    obj:writeLong( ClubManager:getClubSecndID())
    obj:writeLong( PlayerInfo.playerUserID)
    obj:writeString( PlayerInfo.nickname)
    obj:writeString( PlayerInfo.headimgurl)
    --obj:writeString(Game_conf.Base_Version)--服务器那边没有读版本
    obj:send()

    -- GlobalFun:showNetWorkConnect("进入俱乐部中...")
    return true
end

function ClubController:onConnectCheck(obj)
	cclog("ClubController:onConnectCheck >>>>>>")

	-- ClubClient:closeSocketListen()
    GlobalFun:closeNetWorkConnect()

    --初始化俱乐部
    ClubManager:init()

    --连上俱乐部之后，初始化俱乐部的信息
    ClubManager:setInfo("clubName",obj:readString())--俱乐部名字
    ClubManager:setInfo("clubSecndId",obj:readLong())--俱乐部游戏玩法id 小id
    
    ClubManager:setInfo("clubIcon",obj:readString())--俱乐部图标
    ClubManager:setInfo("playerID",obj:readLong())--玩家ID
    ClubManager:setInfo("clubPeopleNum",obj:readShort())--俱乐部成员数
    ClubManager:setInfo("clubPeopleMaxNum",obj:readShort())--俱乐部最大成员数
    ClubManager:setInfo("clubQunzhuName",obj:readString())--会长名字
    ClubManager:setInfo("clubQunzhuID",obj:readLong())--会长ID
    ClubManager:setInfo("clubGuanliyuanName",obj:readString())--管理员名字
    ClubManager:setInfo("clubGuanliyuanID",obj:readLong())--管理员ID
    ClubManager:setInfo("clubID",obj:readLong())--俱乐部id 大组id

    cclog("ClubManager:getClubID() >>>", ClubManager:getClubID())
    ClubManager:print()
    -- CCXNotifyCenter:notify("onConnectCheck",res)

    ClubClient:onConnectCheck(res)
end

function ClubController:heartBeat()--心跳
    cclog("ClubController:heartBeat >>>>")
    local obj = Write.new(1)
    obj:send()
end

function ClubController:onHeartBeat(obj)--心跳
    cclog("ClubController:onHeartBeat >>>>")
    local res = {}
    CCXNotifyCenter:notify("onHeartBeat",res)
end

function ClubController:reqClubGotoHall()
    local obj = Write.new(1405)  
    obj:send()
end

function ClubController:onClubGotoHall(obj)
    ClubClient:closeSocketListen()

    local data = {}
    local res = data
    data.key = obj:readString()
    data.host = obj:readString()

    cclog("res.host:"..res.host)
    -- local ip,port = LineMgr:useLineNumbGetIp(res.host)
    -- GlobalData.HallKey = res.key
    -- GlobalData.HallIP = ip
    -- GlobalData.HallPort = port

    -- cclog("ClubScene:onClubGotoHall >>>>")
    -- cclog(res.key, res.host)
    -- cclog(ip,port)

    -- HallClient:open(GlobalData.HallIP,GlobalData.HallPort)
    
    -- CCXNotifyCenter:notify("onClubGotoHall", data)

    platformExportMgr:returnAppPlatform()
end

-- 进入请求房间,创建房间或者xxx之后，获取到房间id，就可以调用本接口创建房间socket并进入房间啦
-- is_sure 跟观战有关的二次确认，目前俱乐部应该不用传参的，我觉得
function ClubController:gotoRoom(roomID, is_sure)--请求进入房间
    local obj = Write.new(1410)

    cclog("ClubManager:getClubID >>", ClubManager:getClubSecndID(), roomID)
    obj:writeLong(ClubManager:getClubSecndID())
    obj:writeInt(roomID)
    obj:writeByte( is_sure and is_sure or 0)
    obj:send()
end

--进入房间回调
function ClubController:onGotoRoom(obj)
    local res = {}
    res.roomIP = obj:readString()
    --res.roomPort = obj:readInt()
    res.roomKey = obj:readString()
    -- CCXNotifyCenter:notify("onGotoRoom",res)

    ex_roomHandler:connectCheck()
end

--請求加入列表 
function ClubController:C2S_JoinList(pageIdx)
    cclog("wtf ClubController:C2S_JoinList  clubID:"..tostring(ClubManager:getClubID()), pageIdx)
    local obj = Write.new(1401)
    obj:writeLong( ClubManager:getClubID())
    obj:writeByte( pageIdx)
    obj:send()
end

--1401
function ClubController:S2C_JoinList(obj)          
    -- local res = {}

    -- res.total = obj:readShort()
    -- res.maxPage = obj:readShort()
    -- res.curPage = obj:readShort()
    -- res.onePageMax = obj:readByte()


    -- res.num = obj:readByte()--每页条数
    -- res.joinList = {}
    -- for i=1,res.num do
    --     local info = {}
    --     info.id = obj:readLong()--id
    --     info.userID = obj:readLong()--申请人id
    --     info.name = obj:readString()--申请人名字
    --     info.icon = obj:readString()--申请人图标
    --     info.time = obj:readString()--申请时间
    --     res.joinList[#res.joinList+1] = info
    -- end

    local str = obj:readString()
    local res = ex_fileMgr:loadLua("app.helper.dkjson").decode(str)
    print_r(res)
    CCXNotifyCenter:notify("S2C_JoinList", res)
end

--同意or拒绝加入请求
function ClubController:C2S_JoinResult(data)
    -- body
    cclog("ClubController:C2S_JoinResult")
    local obj = Write.new(1402)
    obj:writeLong( ClubManager:getClubID())
    obj:writeLong( data.id or "")
    obj:writeByte( data.agree or 0)
    obj:send()
end

--申请加入俱乐部的结果返回 
function ClubController:S2C_JoinResult(obj)
    -- local res = {}
    -- res.isReset = obj:readByte()
    -- res.total = obj:readShort()
    -- res.msg = obj:readString()

    local str = obj:readString()
    local res = ex_fileMgr:loadLua("app.helper.dkjson").decode(str)

    if res.msg and res.msg~="" then
        GlobalFun:showToast(res.msg , 3)
    end
    print_r(res)
    CCXNotifyCenter:notify("S2C_JoinResult", res)
end
 
--请求开房列表
function ClubController:gotoOpenRoomList(_type, pageIdx)
    cclog("wtf ClubController:gotoOpenRoomList  _type:".._type)
    local obj = Write.new(1403)
    obj:writeLong( ClubManager:getClubSecndID())
    obj:writeByte( _type)   --0 未开始   2已结束
    obj:writeByte( pageIdx)
    obj:send()
end


function ClubController:parseOneRoomList(obj)
    -- body
    cclog("ClubController:parseOneRoomList >>>")
    local item = {}
    item.id = obj:readInt()
    item.status = obj:readByte()
    item.surplusTime = obj:readInt()/1000
    item.curPeopleNum = obj:readByte()
    item.maxPeopleNum = obj:readByte()
    item.createTime = obj:readLong()/1000
    item.endTime = obj:readLong()/1000
    item.roundNum = obj:readByte()
    item.zhaNum = obj:readByte()
    item.roomOwnerID = obj:readLong()   --被扣卡的人
    item.roomOwnerName = obj:readString()
    item.roomOwnerIcon = obj:readString()
    item.finishRoundNum = obj:readByte()
    item.deskIdx = obj:readShort()
    item.startDeskUserID = obj:readLong()   --开这个房的人
    item.startDeskUserName = obj:readString()

    item.joinRoomPeopleNum = obj:readByte()
    item.playerTb = {}
    for j = 1, item.joinRoomPeopleNum do
        local item2 = {}
        item2.playerID = obj:readLong()
        item2.playerWXID = obj:readString()
        item2.playerName = obj:readString()
        item2.iconUrl = obj:readString()   
        item2.score = obj:readShort()
        item2.isOnline = obj:readBoolean()

        table.insert(item.playerTb, item2)
    end  
    item.canDismiss = obj:readBoolean()--是否可以解散
    item.isNewMa = obj:readBoolean()
    return item
end

function ClubController:onOpenRoomList(obj)            --开房列表
    cclog("wtf ClubController:onOpenRoomList")
    local res = {}
    res.roomType = obj:readByte()
    res.pageMax = obj:readByte()
    res.pageIdx = obj:readByte()
    res.deskNumb = obj:readByte()

    if res.roomType == 2 then --已结束的才有以下数据，桌子列表的话，没有以下数据并且根据服务器自己下发1415来设置桌子信息
        res.roomNum = obj:readShort()
        res.roomTb = {}
        for i = 1, res.roomNum do
            local item = ClubController:parseOneRoomList(obj)
            table.insert(res.roomTb, item)
        end
    end

    print_r(res)
    CCXNotifyCenter:notify("res_onOpenRoomList", res)
end

--请求修改游戏配置
function ClubController:gotoModifyGameSetting(_data)
    cclog("wtf ClubController:gotoModifyGameSetting  _data.model:".._data.model)
    local obj = Write.new(1404)
    obj:writeLong( ClubManager:getClubSecndID())
    obj:writeByte( _data.model)
    if _data.model == 0 then        --开房权限
        obj:writeByte( _data.value)
    elseif _data.model == 1 then    --扣卡选项
        obj:writeByte( _data.value)
    elseif _data.model == 2 then    --加入房间条件
        obj:writeByte( _data.value)
    elseif _data.model == 3 then    --游戏选项
        obj:writeString(_data.valueJson)  --游戏配置对应参数
        obj:writeByte( _data.operationCode)    -- 0添加  1修改  2删除
    end
    obj:send()
end

function ClubController:onModifyGameSetting(obj)        --修改游戏配置
    cclog("wtf ClubController:onModifyGameSetting")
    local res = {}
    res.model = obj:readByte()
    res.result = obj:readByte()

    CCXNotifyCenter:notify("res_onModifyGameSetting", res)
end

--请求房卡统计
function ClubController:gotoRoomCardStatistics(_beginTime, _endTime, _pageNum)
    cclog("wtf ClubController:gotoRoomCardStatistics")
    local obj = Write.new(1406)
    obj:writeLong( ClubManager:getClubSecndID())
    obj:writeString(_beginTime)
    obj:writeString(_endTime)
    obj:writeShort( _pageNum)
    obj:send()
end

function ClubController:onRoomCardStatistics(obj)      --房卡统计
    local res = {}
    res.FKTJMaxPage = obj:readShort()   --最大页数
    res.FKTJCurPage = obj:readShort()   --当前页码
    res.FKTJPageObjMaxNum = obj:readByte()   --每页展示的最大数量
    res.FKTJPageObjCurNum = obj:readByte()   --该页显示的真实数量

    ClubManager:setInfo("FKTJMaxPage", res.FKTJMaxPage)
    ClubManager:setInfo("FKTJCurPage", res.FKTJCurPage)
    ClubManager:setInfo("FKTJPageObjMaxNum", res.FKTJPageObjMaxNum)
    ClubManager:setInfo("FKTJPageObjCurNum", res.FKTJPageObjCurNum)

    res.roomTb = {}
    for i = 1, res.FKTJPageObjCurNum do
        local item = {}
        item.id = obj:readLong()
        item.roomID = obj:readInt()
        item.consumeCardNum = obj:readByte()
        item.playerMaxNum = obj:readByte()
        item.finishedInning = obj:readByte()
        item.sumInning = obj:readByte()
        item.openRoomTime = obj:readString()
        item.homeownerName = obj:readString()
        item.creatorName = obj:readString()


        item.bigWinnerNum = obj:readByte()
        item.bigWinnerTb = {}
        for j = 1, item.bigWinnerNum do
            local item2 = {}
            item2.uID = obj:readLong()
            item2.name = obj:readString()
            item2.iconUrl = obj:readString()
            item2.score = obj:readShort()
            table.insert(item.bigWinnerTb, item2)
        end

        item.otherPlayerNum = obj:readByte()
        item.otherPlayerTb = {}
        for j = 1, item.otherPlayerNum do
            local item2 = {}
            item2.uID = obj:readLong()
            item2.name = obj:readString()
            item2.iconUrl = obj:readString()
            item2.score = obj:readShort()
            table.insert(item.bigWinnerTb, item2)
        end
        item.serveRule = obj:readString()

        table.insert(res.roomTb, item)
    end

    res.qunzhuConsumeCard = obj:readInt()
    res.chengyuanConsumeCard = obj:readInt()

    cclog("ClubController:onRoomCardStatistics wtf")
    print_r(res)

    CCXNotifyCenter:notify("res_onRoomCardStatistics", res)
end
 
function ClubController:onPersonCombatGains(obj)       --个人战绩
    local res = {}
    res.FKTJMaxPage = obj:readShort()   --最大页数
    res.FKTJCurPage = obj:readShort()   --当前页码
    res.FKTJPageObjMaxNum = obj:readByte()   --每页展示的最大数量
    res.FKTJPageObjCurNum = obj:readByte()   --该页显示的真实数量


    CCXNotifyCenter:notify("onPersonCombatGains",res) 
end
 
function ClubController:C2S_updateClubSetting(data)
    -- body
    local obj = Write.new(1408)
    obj:writeLong( ClubManager:getClubID())
    cclog("ClubManager:getClubID() >>>", ClubManager:getClubID())

    --type 修改的内容 0 表示修改俱乐部名字 1 表示修改介绍  2 表示修改公告 3 俱乐部加入条件 4修改俱乐部图标
    obj:writeByte( data.type)
    if data.type == 0 then
        ClubManager:setInfo("clubNameTemp",data.param)
        obj:writeString(data.param)
    elseif data.type == 1 then
        ClubManager:setInfo("clubDescTemp",data.param)
        obj:writeString(data.param)
    elseif data.type == 2 then
        ClubManager:setInfo("clubNoticeTemp",data.param)
        obj:writeString(data.param)
    elseif data.type == 3 then
        ClubManager:setInfo("clubConditionTemp",data.param)
        obj:writeByte( data.param)
    elseif data.type == 4 then
        ClubManager:setInfo("clubIconTemp",data.param)
        obj:writeString(data.param)
    end
    obj:send()
end

function ClubController:S2C_updateClubSetting(obj)       --修改俱乐部配置
    local res = {}
    res.msgType = "modifyClubSetting"
    res.status = obj:readBoolean()--是否修改成功
    res.type = obj:readByte()--对应修改的类型
    res.content = obj:readString()--提示弹框内容
    cclog("res.content >>>", res.content)

    if res.type == 0 then--表示修改俱乐部名字
        if res.status == true then
            ClubManager:setInfo("clubName",ClubManager:getInfo("clubNameTemp"))
        end
    elseif res.type == 1 then--表示修改介绍
        if res.status == true then
            ClubManager:setInfo("clubDesc",ClubManager:getInfo("clubDescTemp"))
        end
    elseif res.type == 2 then--表示修改公告
        if res.status == true then
            ClubManager:setInfo("clubNotice",ClubManager:getInfo("clubNoticeTemp"))
        end
    elseif res.type == 3 then--俱乐部加入条件
        ClubManager:setInfo("clubCondition",ClubManager:getInfo("clubConditionTemp"))
    elseif res.type == 4 then--修改俱乐部图标
        ClubManager:setInfo("clubIcon",ClubManager:getInfo("clubIconTemp"))
    end

    ClubGlobalFun:showError(res.content,nil,nil,1)
    CCXNotifyCenter:notify("S2C_updateClubSetting", res)
end

--请求设置界面
function ClubController:C2S_clubSetting()--请求获取设置参数
    cclog("wtf ClubController:requestSettingInfo")
    local obj = Write.new(1409)
    obj:writeLong( ClubManager:getClubID())
    obj:send()
end

--设置界面
function ClubController:S2C_clubSetting(obj) 
    ClubManager:setInfo("clubID",obj:readLong())--俱乐部id
    ClubManager:setInfo("clubName",obj:readString())--俱乐部名字
    ClubManager:setInfo("clubQunzhuName",obj:readString())--会长名字
    ClubManager:setInfo("clubQunzhuID",obj:readLong())--会长ID
    ClubManager:setInfo("clubIcon",obj:readString())--俱乐部图标
    ClubManager:setInfo("clubDesc",obj:readString())--俱乐部宣言
    ClubManager:setInfo("clubNotice",obj:readString())--俱乐部公告
    ClubManager:setInfo("clubCreateTime",obj:readString())--俱乐部创建时间
    ClubManager:setInfo("clubCondition",obj:readByte())--俱乐部进入条件
    ClubManager:setInfo("clubAdress",obj:readString())--俱乐部地址
    ClubManager:setInfo("clubJoinReqNum",obj:readShort())--申请列表个数
    ClubManager:setInfo("clubGuanliyuanID",obj:readLong())--管理员ID
    ClubManager:setInfo("clubGuanliyuanName",obj:readString())--管理员名字

    CCXNotifyCenter:notify("S2C_clubSetting", res)
end
 
 --请求创建房间
function ClubController:gotoRequestCreateRoom(index, deskIdx, ju) 
    cclog("ClubController:gotoRequestCreateRoom >>>.", index -1)     
    local obj = Write.new(1411)
    obj:writeLong( ClubManager:getClubSecndID())
    obj:writeByte( index -1)
    obj:writeShort( deskIdx)
    obj:writeByte( ju)
    obj:send()
end

function ClubController:onRequestCreateRoom(obj)       --请求创建房间

    
    local str = obj:readString()

    cclog("ClubController:onRequestCreateRoom >>>>>", str)
    local info = ex_fileMgr:loadLua("app.helper.dkjson").decode(str)


    GlobalFun:showToast(info.msg, 3)
    --待定
    CCXNotifyCenter:notify("CLUB:onRequestCreateRoom", info)
end

function ClubController:dismissRoom(roomID, roomOwnerID)
    cclog("ClubController:dismissRoom >>>", ClubManager:getClubSecndID(), roomID, roomOwnerID)
    
    local obj = Write.new(1412)
    obj:writeLong( ClubManager:getClubSecndID())
    obj:writeLong( roomOwnerID)
    obj:writeInt( roomID)
    obj:send()
end
 
function ClubController:onDismissRoom(obj)             --解散房间
    local res = {}
    local info = obj:readString()
    GlobalFun:showToast(info, 3)
    
end

function ClubController:onDeleteRoom(obj)              --删除房间
    local res = {}
    res.roomID = obj:readInt()
    CCXNotifyCenter:notify("CLUB:onDeleteRoom", res)
end

--踢人
function ClubController:C2S_KickOut(data)
    -- body
    local obj = Write.new(1413)
    obj:writeLong( ClubManager:getClubID())
    obj:writeLong( data.userID)
    obj:writeLong( data.id)
    obj:send()
end

function ClubController:S2C_KickOut(obj)              
    local res = {}
    CCXNotifyCenter:notify("S2C_KickOut", res)
end
 
function ClubController:requestMemberList(pageIdx)
    -- body
    cclog("ClubController:requestMemberList >>", ClubManager:getClubID(), pageIdx)
    local obj = Write.new(1414)
    obj:writeLong( ClubManager:getClubID())
    obj:writeByte( pageIdx)
    obj:send()
end

function ClubController:parseOneMember(obj)
    -- body
    local info = clone(ClubManager.memberInfo)
    info.id               = obj:readLong() --玩家唯一id
    info.userID           = obj:readLong() --玩家id
    info.name             = obj:readString()--玩家名字
    info.icon             = obj:readString()--玩家头像
    info.jiarutime        = obj:readString()--加入时间
    info.beizhu           = obj:readString()--备注
    info.isHeimingdan     = obj:readBoolean()--是否黑名单
    info.status =  obj:readByte()  -- 0离线 1在线 2 游戏中
    return info
end

--成员列表
function ClubController:S2C_memberList(obj)          
    local res = {}
    res.total = obj:readShort()
    res.maxPage = obj:readByte()
    res.curPage = obj:readByte()
    res.curShowNum = obj:readByte()

    res.num = obj:readByte()
    res.data = {}
    for i=1,res.num  do --成员个数
        local info = ClubController:parseOneMember(obj)
        res.data[#res.data+1] = info
    end
    -- ClubManager:setMemberList(res)
    CCXNotifyCenter:notify("S2C_memberList", res)
end

--更新单个成员信息
function ClubController:S2C_updateMemberInfo(obj)
    -- body
    local res = ClubController:parseOneMember(obj)
    -- ClubManager:updateMemberInfo(res)
    CCXNotifyCenter:notify("S2C_updateMemberInfo", res)
end
 
function ClubController:onUpdateRoomInfo(obj)          --更新单条房间信息 如果房间不存在则添加 存在则修改
    local res = {}
    res = ClubController:parseOneRoomList(obj)
    CCXNotifyCenter:notify("CLUB:onUpdateRoomInfo", res)
end
 
 --请求下发游戏配置
function ClubController:gotoGameSetting()   
    cclog("wtf ClubController:gotoGameSetting")
    local obj = Write.new(1419)
    obj:writeLong( ClubManager:getClubSecndID())
    obj:send()
end

function ClubController:onGameSetting(obj)              --游戏配置
    local res = {}
    cclog("wtf ClubController:onGameSetting")
    res.type_1 = obj:readByte()
    res.type_2 = obj:readByte()
    res.type_3 = obj:readByte()
    res.playRuleNum = obj:readByte()
    res.playRuleTb = {}
    for i = 1, res.playRuleNum do
        local item = obj:readString()
        table.insert(res.playRuleTb, item)
    end

    GameRule.GameSetting.type_1 = res.type_1
    GameRule.GameSetting.type_2 = res.type_2
    GameRule.GameSetting.type_3 = res.type_3

    ClubManager:setInfo("game_setting",res)
    
    CCXNotifyCenter:notify("res_onGameSetting", res)


    

    CCXNotifyCenter:notify("onGameSetting",res) 
end

function ClubController:deleteSetting(clubSecndId, index)
    cclog("ClubController:deleteSetting >>>.", index -1)
    local obj = Write.new(1424)
    obj:writeLong( clubSecndId)
    obj:writeByte( index -1)
    obj:send()
end

function ClubController:onDeleteSetting(obj)
    
    local state = obj:readByte()
    local str = obj:readString()
    GlobalFun:showToast(str, 3)

    cclog("ClubController:onDeleteSetting >>>", state, str)
    if state == 0 then --  删除成功
        CCXNotifyCenter:notify("CLUB:onDeleteSetting")
    end
end

--请求去俱乐部
function ClubController:gotoClub(_clubID)
    cclog("ClubController:gotoClub >>>>")
    local obj = Write.new(1427)
    obj:writeLong( _clubID)
    obj:send()
end

function ClubController:onGotoClub(obj)
    cclog("ClubController:onGotoClub")
    local isCanOpenClub = obj:readBoolean()
    cclog("isCanOpenClub:"..tostring(isCanOpenClub))
    if isCanOpenClub == true then
        local host = obj:readString()
        local key = obj:readString()
        ClubManager:setInfo("clubID",obj:readLong())
        cclog("wtf ClubManager:getClubID():"..ClubManager:getClubID())

         local ip,port = LineMgr:useLineNumbGetIp(host)
         ClubClient.ClubKey = key
         ClubClient.ClubIP = ip
         ClubClient.ClubPort = port
         --ClubClient:open(ClubClient.ClubIP,ClubClient.ClubPort)
         --cclog("HALL:onGotoClub >>", ClubClient.ClubKey,ClubClient.ClubIP,ClubClient.ClubPort)

         CCXNotifyCenter:notify("canGotoClub",nil)
    else
        --创建or加入
        --GlobalFun:closeNetWorkConnect()
        --ClubClient:createAndJoinClub()
    end 

    CCXNotifyCenter:notify("HALL:onGotoClub", nil)   
end

function ClubController:toClubList()
    cclog("ClubController:toClubList >>>> ")
    local obj = Write.new(1428)
    obj:send()
end

function ClubController:onClubList(obj)
    local res = {}
    res.clubNum = obj:readByte() --俱乐部数量
    res.clubTb = {}
    cclog("wtf res.clubNum:"..res.clubNum)
    for i = 1, res.clubNum do
        local json = obj:readString() --俱乐部info
        local jsonTb = ex_fileMgr:loadLua("app.helper.dkjson").decode(json)
        table.insert(res.clubTb, jsonTb)
        --print_r(res.clubTb)
    end
    GlobalFun:closeNetWorkConnect()
    --ClubClient:createAndJoinClub(res, "club")
    res.socketType = "club"
    CCXNotifyCenter:notify("onClubList", res)
end

function ClubController:toSendChatRoomMsg(_data)
    cclog("ClubController:toSendChatRoomMsg >>>> ")
    local obj = Write.new(1429)
    obj:writeString(_data.clubID.."@club")
    obj:writeByte( 1)
    obj:writeString(_data.content)
    obj:send()
end

function ClubController:onChatRoomMsg(obj)
    local res = {}
    local str = obj:readString() --俱乐部id/来源id
    local data = string.split(str, "@")
    if #data > 1 and data[2] == "club" then        --俱乐部
        res.clubID = tonumber(data[1])
        res.userID = obj:readLong()
    else                        
        res.clubID = -1
        res.userID = tonumber(data[1])
    end
    res.msgType = obj:readByte()
    --[[
        1：文本消息(支持图文混排)
        2：分享消息
        3：语音消息
        4：开放信息
        5：分享战绩
    --]]
    if res.msgType == 1 then
        res.content = obj:readString()
        res.userName = obj:readString()
        res.userIcon = obj:readString()
    elseif res.msgType == 4 then
        local res2 = {}
        res2.roomID = obj:readInt()
        res2.round = obj:readInt()
        res2.descJson = obj:readString()
        res.openRoom = res2
    elseif res.msgType == 5 then
        local res2 = {}
        res2.roomID = obj:readInt()
        res2.sumRound = obj:readInt()
        res2.curRound = obj:readInt()
        res2.memberNum = obj:readShort()
        res2.playerList = {}
        for i = 1, res2.memberNum do
            local user = {}
            user.name = obj:readString()
            user.icon = obj:readString()
            user.score = obj:readInt()
            table.insert(res2.playerList, user)
        end
        res.shareResult = res2
    end
    cclog("wtf")
    print_r(res)
    CCXNotifyCenter:notify("S2C_clubChatMsg", res)
end

function ClubController:C2S_DismissClub()
    -- body
    local obj = Write.new(1420)
    cclog("ClubManager:getClubID() >>>", ClubManager:getClubID())
    obj:writeLong( ClubManager:getClubID())
    obj:send()
end

function ClubController:S2C_DismissClub(obj)
    local res = {}
    CCXNotifyCenter:notify("S2C_DismissClub", res)
end

function ClubController:C2S_ExitClub()
    -- body
    local obj = Write.new(1421)
    obj:writeLong( ClubManager:getClubID())
    obj:send()
end

function ClubController:S2C_ExitClub(obj)
    -- body
    local res = {}
    CCXNotifyCenter:notify("S2C_ExitClub", res)
end

function ClubController:onRedPoint(obj)  --红点
    local res = {}
    -- 0 申请列表的红点
    res.rp_type = obj:readByte()
    res.isRed = obj:readBoolean()

    cclog("ClubController:onRedPoint >>>>")
    print_r(res)

    CCXNotifyCenter:notify("CLUB:onRedPoint", res)
end


function ClubController:onYaoQingJinFangTiShi(obj)
    local res = {}
    res.clubId = obj:readLong()
    res.roomId = obj:readInt()
    res.name = obj:readString()
    res.clubName = obj:readString()

    cclog("ClubController:onYaoQingJinFangTiShi >>>>>")
    print_r(res)
    local function cb()
        ClubController:gotoRoom(res.roomId)
    end
    ClubGlobalFun:showError(string.format("【%s】俱乐部的玩家[%s]邀请您进入房间(%s)进行游戏", res.clubName, res.name, res.roomId),cb,nil,2)

end


--群数据统计
function ClubController:toClubDataStatistics(_curPage)
    cclog("ClubController:toClubDataStatistics _curPage:".._curPage)
    local obj = Write.new(1434)
    obj:writeLong( ClubManager:getClubID())
    obj:writeShort( _curPage)
    obj:writeLong( ClubManager:getClubSecndID())
    obj:send()
end

function ClubController:onClubDataStatistics(obj)
    local res = {}
    res.sum = obj:readShort()
    res.maxPage = obj:readShort()
    res.curPage = obj:readShort()
    res.maxNumOfPage = obj:readByte()
    res.curNumOfPage = obj:readByte()
    res.pageData = {}
    for i = 1, res.curNumOfPage do
        local member = {}
        member.index = i
        member.id = obj:readLong()
        member.userID = obj:readLong()
        member.userName = obj:readString()
        member.JuNum = obj:readInt()
        member.WinNum = obj:readInt()
        member.HuNum = obj:readInt()
        member.WLScore = obj:readInt()
        table.insert(res.pageData, member)
    end
    cclog("ClubController:onClubDataStatistics >>>>")
    print_r(res)

    CCXNotifyCenter:notify("S2C_onClubDataStatistics", res)
end

--邀请好友加入俱乐部
function ClubController:toInviteMemberToClub(_userID)
    cclog("ClubController:toInviteMemberToClub _userID:".._userID)
    local obj = Write.new(1440)
    obj:writeLong( ClubManager:getClubID())
    obj:writeLong( _userID)
    obj:writeString(string.format("玩家【%s】邀请你加入俱乐部【%s】(ID:%s)", PlayerInfo.nickname, 
                    ClubManager:getInfo("clubName"), ClubManager:getClubID()))
    obj:send()
end

function ClubController:onInviteMemberToClub(obj)
    -- local res = {}
    -- res.status = obj:readByte()
    -- res.clubMemberNum = obj:readShort()
    -- res.tips = obj:readString()
    --CCXNotifyCenter:notify("S2C_onInviteMemberToClub", res)
    cclog("ClubController:onInviteMemberToClub")

    local str = obj:readString()
    local res = dkj.decode(str)
    print_r(res)
    -- ClubGlobalFun:showError(res.tips, nil,nil,2)
    GlobalFun:showToast(res.msg, 2)
end

--任命管理员
function ClubController:toAppointManager(_userID)
    cclog("ClubController:toAppointManager _userID:".._userID)
    local obj = Write.new(1432)
    obj:writeLong( ClubManager:getClubID())
    obj:writeLong( _userID)
    obj:send()
end

function ClubController:onAppointManager(obj)
    local res = {}
    res.clubID = obj:readLong()
    res.amID = obj:readLong()
    res.amName =  obj:readString()

    print_r(res)
    ClubManager:setInfo("clubGuanliyuanID",res.amID)--管理员ID
    ClubManager:setInfo("clubGuanliyuanName",res.amName)--管理员名字


    CCXNotifyCenter:notify("S2C_onAppointManager", res)
end

--搜索玩家
function ClubController:toSearchPlayer(_userID, isSearchInClub)
    cclog("ClubController:toSearchPlayer _userID:".._userID)
    local obj = Write.new(1442)
    obj:writeLong( ClubManager:getClubID())
    obj:writeLong( _userID)
    obj:writeBoolean( isSearchInClub)  --是否俱乐部内搜索
    obj:send()
end

function ClubController:onSearchPlayer(obj)
    local res = {}
    res.status = obj:readByte() --0成功 1为空
    res.userID = obj:readLong()
    res.userName = obj:readString() --用户名
    res.icon = obj:readString()

    CCXNotifyCenter:notify("S2C_onSearchPlayer", res)
end


function ClubController:requestJoinClub(clubID)
    local obj = Write.new(1435)
    obj:writeLong( clubID)
    obj:send()
end

function ClubController:onRequestJoinClub(obj)
    local stat = obj:readByte()
    local msg = obj:readString()

    GlobalFun:showToast(msg or "", 3)
end


--收到邀请进俱乐部
function ClubController:toYaoQingJinJuLeBuTiShi(_clubID, _userID, _flag) --回复同意还是拒绝
    cclog("ClubController:toYaoQingJinJuLeBuTiShi >>>> _flag:".._flag)
    local obj = Write.new(1441)
    obj:writeLong( _clubID)
    obj:writeLong( _userID)
    obj:writeInt( _flag)   --0同意 -1拒绝
    obj:send()
end

function ClubController:onYaoQingJinJuLeBuTiShi(obj)
    cclog("ClubController:onYaoQingJinJuLeBuTiShi")
    local res = {}
    res.clubName = obj:readString()
    res.clubID = obj:readLong()
    res.userName = obj:readString()
    res.userID = obj:readLong()
    res.address = obj:readString()
    res.socketType = "Club"

    print_r(res)
    ClubGlobalFun:showInviteMsg(res)
end

function ClubController:xiuGaiBeiZhu(clubID, playerID, str)
    local obj = Write.new(1436)
    obj:writeLong( clubID)
    obj:writeLong( playerID)
    obj:writeString(str or "")
    obj:send()
end


function ClubController:onXiuGaiBeiZhu(obj)
    local stat = obj:readByte()  -- 0成功 1失败
    GlobalFun:showToast(stat == 0 and "修改成功" or "修改失败", 3)
end

function ClubController:onTextHint(obj)
    local htype = obj:readByte()
    local msg = obj:readString()
    GlobalFun:showToast(msg, 3)
end

--加入/移出黑名单
function ClubController:toOperateBlackList(_clubID, _userID, _flag)
    cclog("ClubController:onOperateBlackList >>>> _flag:".._flag)
    local obj = Write.new(1437)
    obj:writeLong( _clubID)
    obj:writeLong( _userID)
    obj:writeByte( _flag)
    obj:send()
end

function ClubController:onOperateBlackList(obj)
    local str = obj:readString()
    local res = ex_fileMgr:loadLua("app.helper.dkjson").decode(str)

    print_r(res)
    GlobalFun:showToast(res.msg or "", 3)
end

--申请房卡(群成员)
-- function ClubController:toApplyForRoomCard(_clubID, _userID, _flag) --回复同意还是拒绝
--     cclog("ClubController:toYaoQingJinJuLeBuTiShi >>>> _flag:".._flag)
--     local obj = Write.new(9999)
--     obj:writeLong( _clubID)
--     
--     obj:send()
-- end

-- function ClubController:onApplyForRoomCard(obj)
--     local htype = obj:readByte()

--     CCXNotifyCenter:notify("S2C_onSearchPlayer", res)
-- end

--发送房卡(群主)
function ClubController:toSendRoomCard(_clubID, _userID, _num)
    cclog("ClubController:toSendRoomCard >>>> _num:".._num)
    local obj = Write.new(1438)
    obj:writeLong( _clubID)
    obj:writeLong( _userID)
    obj:writeInt( _num)
    obj:send()
end

function ClubController:onSendRoomCard(obj)
    cclog("ClubController:onSendRoomCard >>>>")
    local ret = obj:readByte()    --0成功 1失败
    local tips = obj:readString()    --提示

    --CCXNotifyCenter:notify("S2C_onSendRoomCard", res)
    --GlobalFun:showToast(ret == 0 and "发送成功" or "发送失败", 3)
    --GlobalFun:showToast(tips, 3)
    ClubGlobalFun:showError(tips, nil, nil, 1)
end

--赠送房卡记录
function ClubController:toGiveRoomCardRecord(_clubID, _curPage)
    local obj = Write.new(1443)
    obj:writeLong( _clubID)
    obj:writeShort( _curPage)
    obj:send()
end

function ClubController:onGiveRoomCardRecord(obj)
    local res = {}
    res.maxPage = obj:readShort()
    res.curPage = obj:readShort()
    res.maxNumOfPage = obj:readByte()
    res.curNumOfPage = obj:readByte()
    res.pageData = {}
    for i = 1, res.curNumOfPage do
        local item = {}
        item.time = obj:readString()
        item.recvName = obj:readString()
        item.recvID = obj:readLong()
        item.sendName = obj:readString()
        item.sendID = obj:readLong()
        item.recvNum = obj:readInt()
        table.insert(res.pageData, item)
    end
    print_r(res)
    CCXNotifyCenter:notify("S2C_onGiveRoomCardRecord", res)
end

--群数据清除
function ClubController:toClearClubDataForTongJi()
    cclog("ClubController:toClearClubDataForTongJi")
    local obj = Write.new(1444)
    obj:writeLong( ClubManager:getClubSecndID())
    -- obj:writeShort( _curPage)
    obj:send()
end

function ClubController:onClearClubDataForTongJi(obj)
    cclog("ClubController:onClearClubDataForTongJi >>>>")
end

--俱乐部快速匹配
function ClubController:toQuickMatching()
 --   cclog("ClubController:toQuickMatching")
    local obj = Write.new(1445)
    obj:writeLong( ClubManager:getClubSecndID())
    obj:send()
end

function ClubController:onQuickMatching(obj)
--    cclog("ClubController:onQuickMatching >>>>")
    CCXNotifyCenter:notify("S2C_onQuickMatching", {})
end

function ClubController:onNotice(obj)
    cclog("ClubController:S2C_onNotice >>>>")
    local res = {}
    res.noticeContent = obj:readString()
    -- CCXNotifyCenter:notify("S2C_onNotice", res)
    ClubManager:setInfo("showNoticeOnce", res.noticeContent)
end

function ClubController:sendPlayingList()
    local obj = Write.new(1447)
    obj:writeLong( ClubManager:getClubID())
    obj:send()
end

function ClubController:onPlayingList(obj)
    cclog("ClubController:onPlayingList >>>")
    local res = {}
    res.canSetNumb = obj:readByte()
    res.list = {}
    local numb = obj:readByte()
    for i = 1, numb do
        local tab = {}
        tab.clubSecndId = obj:readLong()
        tab.product = obj:readString()
        tab.name = obj:readString()
        tab.game = obj:readString()
        tab.version = obj:readString()
        res.list[i] = tab
    end

    print_r(res)

    CCXNotifyCenter:notify("ClubController.onPlayingList", res)
end

function ClubController:sendRemovePlaying(clubId, clubSecndId)
    cclog("ClubController:sendRemovePlaying >>>", clubId, clubSecndId)
    local obj = Write.new(1449)
    obj:writeLong(clubId)
    obj:writeLong(clubSecndId)
    obj:send()
end

function ClubController:onRemovePlaying(obj)
    local str = obj:readString()
    cclog("HallProtocol:onRemovePlaying >>>", str)
    local res = dkj.decode(str)
    GlobalFun:showToast(res.msg or "", 3)
end

--获取游戏列表
function ClubController:sendGameList(gtype, pageNumb)
    cclog("ClubController:sendGameList >>>", gtype, pageNumb)
    -- cclog(debug.traceback())
    local obj = Write.new(1450)
    obj:writeInt(gtype)
    obj:writeInt(pageNumb)
    obj:send()
end

--获取游戏列表
function ClubController:onGameList(obj)
    local res = {}

    res.url = obj:readString()

    res.curPage = obj:readInt()
    res.maxPage = obj:readInt()
    res.curShowNum = obj:readInt()
    res.totalCount = obj:readInt()

    local count = obj:readShort()
    res.data = {}
    for i =1, count do
        local tab = {}
        obj:readShort()
        tab.product = obj:readString()
        tab.name = obj:readString()
        tab.game = obj:readString()
        tab.icon = obj:readString()
        tab.version = obj:readString()
        tab.showState = obj:readInt() -- 1热门 2推荐
        res.data[i] = tab
    end

    print_r(res)

    
    CCXNotifyCenter:notify("ClubController.onGameList",res) 
end

--添加游戏玩法
function ClubController:sendAddGamePlaying(clubId, product)
    local obj = Write.new(1448)
      obj:writeLong(clubId)
    obj:writeString(product)

    obj:writeByte(0)
    obj:writeByte(0)
    obj:writeByte(0)
    obj:writeString("")
    obj:send()
end

function ClubController:onAddGamePlaying(obj)
    local res = {}

    local str = obj:readString()
    res = dkj.decode(str)

    print_r(res)
    GlobalFun:showToast(res.msg or "", 3)
    CCXNotifyCenter:notify("ClubController.onAddGamePlaying",res) 
end

return ClubController




