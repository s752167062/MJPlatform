
local ClientController = class("ClientController")

function ClientController:ctor(params)
    self:inItProtocol()
end

function ClientController:receiveMsg(obj)
    self:handlerProtocol(obj:getProId(),obj)
end

--协议处理
function ClientController:handlerProtocol(proId,obj)
    proId = tonumber(proId)
    if self._proFuns[proId] then
        self._proFuns[proId](obj)
    else
        dump("error,non-existent protocol ID:"..proId)
    end
end

--协议注册
function ClientController:inItProtocol()
    self._proFuns = {}

    -- 绑定协议号
    self._proFuns[0] = handler(self,self.onSendSid)
    self._proFuns[1] = handler(self,self.onHeartBeat)
    self._proFuns[999] = handler(self,self.onProtocolError)
    self._proFuns[1114] = handler(self,self.onFengHuCards)
    self._proFuns[1301] = handler(self,self.onServerGetAllPlayersGps)
    self._proFuns[1300] = handler(self,self.onRequestLocation)
    self._proFuns[1113] = handler(self,self.onRoomOwnerDimissRoom)
    self._proFuns[1111] = handler(self,self.onHandUp)
    self._proFuns[1087] = handler(self,self.onCardUpdate)
    self._proFuns[1086] = handler(self,self.onGetProduct)
    self._proFuns[1085] = handler(self,self.onGivePlayerGif)
    self._proFuns[1084] = handler(self,self.onGifList)
    self._proFuns[1083] = handler(self,self.onNotifyInOrOutWatch)
    self._proFuns[1081] = handler(self,self.onExitWatch)
    self._proFuns[1080] = handler(self,self.onWatchList)
    self._proFuns[1061] = handler(self,self.onMatchOver)
    self._proFuns[1060] = handler(self,self.onCheckRankInfo)
    self._proFuns[1059] = handler(self,self.onWaitMatchOver)
    self._proFuns[1058] = handler(self,self.onNotifyHallGameStart)
    self._proFuns[1054] = handler(self,self.onServerNotifyTop)
    self._proFuns[1053] = handler(self,self.onNotifyBeganMatch)
    self._proFuns[1052] = handler(self,self.onUpdateMatchPeople)
    self._proFuns[1049] = handler(self,self.onWaitJoinMatch)
    self._proFuns[1048] = handler(self,self.onEliminated)
    self._proFuns[1047] = handler(self,self.onJoinMatch)
    self._proFuns[1040] = handler(self,self.onVideoData)
    self._proFuns[1039] = handler(self,self.onRoomJoinBaseInfo)
    self._proFuns[1037] = handler(self,self.onNotifyPlayerCard)
    self._proFuns[1035] = handler(self,self.onNotifyString)
    self._proFuns[1034] = handler(self,self.onUserRequireShowBNT)
    self._proFuns[1033] = handler(self,self.onUserPass)
    self._proFuns[1031] = handler(self,self.onNotifyUserOnAnOff)
    self._proFuns[1030] = handler(self,self.onNotifyQuitRoomUserID)
    self._proFuns[1029] = handler(self,self.onUserRequestExit)
    self._proFuns[1028] = handler(self,self.onNotifyUserDisMiss)
    self._proFuns[1027] = handler(self,self.onNotifyUserRefusedDisMiss)
    self._proFuns[1025] = handler(self,self.onRoomServerNotifyUserGang)
    self._proFuns[1024] = handler(self,self.onSendEmoticon)
    self._proFuns[1023] = handler(self,self.onServerNotifyCanHu)
    self._proFuns[1021] = handler(self,self.onServerBrocastDraw)
    self._proFuns[1020] = handler(self,self.onServerBrocastPeng)
    self._proFuns[1019] = handler(self,self.onServerBrocastMingGang)
    self._proFuns[1018] = handler(self,self.onServerBrocastAnGang)
    self._proFuns[1017] = handler(self,self.onAskDismissRoom)
    --self._proFuns[1016] = handler(self,self.onRequireDismissRoom)
    self._proFuns[1015] = handler(self,self.onServerNotifyUserPick)
    self._proFuns[1014] = handler(self,self.onUserAnGang)
    self._proFuns[1013] = handler(self,self.onUserMingGang)
    self._proFuns[1012] = handler(self,self.onUserPeng)
    self._proFuns[1011] = handler(self,self.onServerNotifyCanGang)
    self._proFuns[1010] = handler(self,self.onServerNotifyCanPeng)
    self._proFuns[1009] = handler(self,self.onServerPickCard)
    self._proFuns[1008] = handler(self,self.onUserOutCard)
    self._proFuns[1007] = handler(self,self.onReadyState)
    self._proFuns[1006] = handler(self,self.onServerNotifyHU)
    self._proFuns[1005] = handler(self,self.onListenCard)
    self._proFuns[1004] = handler(self,self.onGameBeganNotify)
    self._proFuns[1003] = handler(self,self.onMahjongInit)
    self._proFuns[1002] = handler(self,self.onReConnectRoom)
    self._proFuns[1001] = handler(self,self.onReqEnterRoom)
    self._proFuns[1000] = handler(self,self.onEnterRoomAndGetRoomID)

    self._proFuns[1145] = handler(self,self.onH5Pay) --h5支付 获取
    --========================================   club begin ==========================================
    self._proFuns[1090] = handler(self,self.onChengYuanList)
    self._proFuns[1115] = handler(self,self.onClubRoomNotifyUserDisMiss)
    --========================================   club end ==========================================
    self._proFuns[1116] = handler(self,self.onlistenCanHuCard)
end

-- 获取当前协议号
-- function ClientController:getProtocol()
--     return  1057
-- end

-- function ClientController:sendSid()
--     local obj = Write.new(0)
--     obj:send()

--     if GlobalData.log == nil then
--         GlobalData.log = ""
--     end
--     local sendlog = os.date("%H:%M:%S") ..":send Server Sid=" .. GameClient.server.sid
--     GlobalData.log = GlobalData.log .. "\n" .. sendlog
--     GameClient.socketState = 1
--     GameClient.socketT = 0
-- end

-- function ClientController:onSendSid()
--     GameClient.isCloseActive = false
--     if GlobalData.matchReqire then
--         GlobalData.matchReqire = nil
--         ClientController:joinMatch()
--     else
--         ClientController:reqEnterRoom(GlobalData.roomKey)
--         cclog("key         " ..  GlobalData.roomKey)
--     end
--     GameClient.socketState = 2
--     GameClient.socketT = 0
-- end


function ClientController:onProtocolError(obj)--所有错误都集合到这里来
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
    GameClient:onProtocolError(res)
end

function ClientController:enterRoomAndGetRoomID(key)
    cclog("进入房间请求")
    local obj = Write.new(1000)
    obj:writeString(key)
    obj:send()
end

function ClientController:onEnterRoomAndGetRoomID(obj)
    local res = {}
    cclog("拿到了请求")
    res.roomID = obj:readInt()
    CCXNotifyCenter:notify("onEnterRoomAndGetRoomID",res)
end

--房间重连时请求这个协议
function ClientController:connectCheck()

    ClientController:reqEnterRoom()
end

function ClientController:reqEnterRoom(key)--请求进入房间
    cclog("请求进入房间 ",PlayerInfo.ip)

    local server_type = platformExportMgr:doGameNetMgr_getServerTypeByCurrent()
    if server_type ~= platformExportMgr:getGlobalGameSeverType("room")  then
        GlobalFun:showError("网络故障，目标服务器id异常，点击确定返回平台",function ()
            platformExportMgr:returnAppPlatform()
            end,nil,1)
        return false
    end


    
    local obj = Write.new(1001)
    obj:writeString(platformExportMgr:doGameConfMgr_getInfo("hostKey"))
    obj:writeString(Game_conf.Base_Version)
    obj:writeString(PlayerInfo.ip) --把自己的IP发送到房间服

    obj:send()
    GlobalData.isReqRoom = true
    --LogController.sendLog(sendlog)
    GlobalData.ROOMKEY = key

    -- GlobalFun:showNetWorkConnect("进入房间中...")

    return true
end

function ClientController:onReqEnterRoom(obj)
    cclog("进入房间")
    GlobalData.roomCreateID = 0 
    --cclog("sid = " .. GameClient.server.sid)
    local res = {}
    res.roomID = obj:readInt()
    GlobalData.roomID = res.roomID
    res.zhama = obj:readByte()
    res.gamecnt = obj:readByte()
    res.currPass = obj:readByte() + 1
    res.surplusNum = obj:readByte()
    --obj:readShort()
    res.player = {}
    local num = obj:readShort()

    cclog ("ClientController:onReqEnterRoom >>>>> num", num)
    for i=1,num do
        res.player[i] = {}
        obj:readShort()
        
        
        res.player[i].id = obj:readLong()
        res.player[i].isBanker = obj:readBoolean()
        res.player[i].name = obj:readString()
        res.player[i].pos = obj:readByte()
        res.player[i].iconURL = obj:readString()
        res.player[i].sex = obj:readByte()
        res.player[i].score = obj:readShort()
        --当掉线重连的时候
        local play_num = obj:readShort()
        local cards = {}
        --cclog("重进服务器牌面值")
        for i=1,play_num do
            cards[#cards + 1] = {}
            obj:readShort()
            cards[#cards].type = obj:readByte()
            local  vv = obj:readInt()
            
            cards[#cards].value = GlobalFun:ServerCardToLocalCard(vv)
            --cclog("下发的数据  " .. vv)
            
            cards[#cards].num = obj:readByte()
        end
        res.player[i].isReady = obj:readBoolean()
        res.player[i].ipAddr =  obj:readString()
        res.player[i].isLine = obj:readBoolean()
        
        res.player[i].discards = {}
        res.player[i].mingpai = {}
        res.player[i].handcard = {}
        res.player[i].listencard = {}
        
        local function AddToTable(tb,num,value,flag)
            for n=1,num do
                tb[#tb+1] = {}
                tb[#tb].value = value
                tb[#tb].flag = flag
                
                --cclog("--------------add to table : "..value)
            end
        end
        
        if #cards > 0 then--有牌
            for m=1,#cards do
                if cards[m].type == 7 then--出掉的牌
                    AddToTable(res.player[i].discards,cards[m].num,cards[m].value,0)
                elseif cards[m].type == 6 then--手牌
                    AddToTable(res.player[i].handcard,cards[m].num,cards[m].value,0)
                elseif cards[m].type == 5 or cards[m].type == 2 or cards[m].type == 3 or cards[m].type == 1 then--明牌堆里的牌
                    res.player[i].mingpai[#res.player[i].mingpai+1]= {}
                    if cards[m].type == 5 then--暗杠的牌
                        AddToTable(res.player[i].mingpai[#res.player[i].mingpai],cards[m].num,cards[m].value,1)
                    elseif cards[m].type == 2 or cards[m].type == 3 or cards[m].type == 1 then
                        AddToTable(res.player[i].mingpai[#res.player[i].mingpai],cards[m].num,cards[m].value,0)
                    end
                elseif cards[m].type == 8 then--监听的牌
                    res.player[i].listencard[#res.player[i].listencard + 1] = cards[m].value
                else
                    --cclog("*---")
                end
            end
        end
    end
    --res.player.id = obj:readLong()
    --res.player.name = obj:readString()
    res.outCardID = obj:readLong()
    res.disTime = obj:readInt()--解散房间剩余时间
    


    --观战

    GlobalData.roomCreateID = obj:readLong()    --房主  
    GlobalData.roomCreateName = obj:readString() -- name
    GlobalData.roomCreateImgUrl = obj:readString() -- image
    res.canWatch = obj:readByte()
    res.isQiXiaoDui = obj:readByte()
    res.isMiLuoHongZhong = obj:readByte()

    GameRule.canDaiKai = obj:readBoolean()

    GlobalData.notIP = obj:readBoolean() -- true为关闭IP检测功能
    res.isGPS = obj:readBoolean() -- true为关闭GPS检测功能


    cclog(" ********** 房主id " ,GlobalData.roomCreateID)
    cclog(" ********** 房主name " ,GlobalData.roomCreateName)
    cclog(" ********** 房主url " ,GlobalData.roomCreateImgUrl)
    cclog(" ********** 代开 " ,GameRule.canDaiKai)
    cclog("  IP警报不开放",GlobalData.notIP)
    cclog("  GPS信息不开放",GlobalData.isGPS)
    
    res.clubId = obj:readLong()
    res.isThisClub = obj:readBoolean()
    res.originType = obj:readByte()   -- 0普通 1 俱乐部
    res.originKey = obj:readInt() -- 细分到大分类originType下面的小分类
    cclog("res.originType, res.originKey >>>", res.originType, res.originKey)

    --新增规则参数
    GameRule.PLAY_EIGHT = obj:readBoolean()
    GameRule.PLAY_CONNON = obj:readBoolean()
    GameRule.PLAY_AK_ONE_ALL = obj:readBoolean()
    GameRule.isGPS = res.isGPS

    GlobalFun:setCardSum(GameRule.PLAY_EIGHT == true and 116 or 112)



    --CCXNotifyCenter:notify("onReqEnterRoom",res)
    GameClient:onReqEnterRoom(res)
end

function ClientController:getPid(protol)
    local obj = Write.new(protol)
    cclog("protol  " .. protol)
    if GlobalData.isMatchRoom == true then
        cclog("发送了key")
       obj:writeString(GlobalData.roomKey) 
    end
    
    return obj
end

function ClientController:reConnectRoom(id)--重连
    local obj = Write.new(1002)
    --obj:writeString(GlobalData.roomKey)
    obj:writeLong(id)
    obj:send()
end

function ClientController:onReConnectRoom(obj)
    local res = {}
    res._ok = obj:readBoolean()
    CCXNotifyCenter:notify("onReConnectRoom",res)
end

function ClientController:onMahjongInit(obj)--服务器初始化麻将
    local res = {}
    cclog("麻将初始化")
    local cardnum = obj:readShort()
    res.cards = {}
    local logcards = ""
    for i=1,cardnum do
        res.cards[i] = obj:readInt()
        logcards = logcards .. res.cards[i] .. ","
    end
    
    res.BankerID = obj:readLong()

  
    CCXNotifyCenter:notify("onMahjongInit",res)
end

function ClientController:onGameBeganNotify(obj)--通知开牌
    local res = {}
    res._ok = true
    
    CCXNotifyCenter:notify("onGameBeganNotify",res)
end

function ClientController:onListenCard(obj)--
    local res = {}
    
    local cardnum = obj:readShort()
    res.cards = {}
    local logcards = ""
    for i=1,cardnum do
        res.cards[i] = obj:readInt()
        logcards = logcards .. res.cards[i] .. ","
    end

    
    if GlobalData.roomData ~= nil  then
        local tmp_tb = {}
        for i=1,#res.cards do
            tmp_tb[#tmp_tb + 1] = GlobalFun:ServerCardToLocalCard(res.cards[i])
        end
        GlobalData.roomData.listen =  tmp_tb
    end
    
    CCXNotifyCenter:notify("onListenCard",res)
end

function ClientController:onServerNotifyHU(obj)
    local res = {}
    
    obj:readShort()
    res.huPaiType = obj:readByte()--胡牌类型
    local winnum = obj:readShort()
    res.winBean = {}
    res.winValue = nil
    res.fangpao_player = 0
    for i=1,winnum do
        obj:readShort()
        res.winBean[i] = obj:readLong()
        res.winValue = GlobalFun:ServerCardToLocalCard(obj:readInt())
        res.fangpao_player = obj:readLong()
    end
    
    res.zhamaBean = {}
    local zmnum = obj:readShort()
    for i=1,zmnum do
        res.zhamaBean[i] = GlobalFun:ServerCardToLocalCard(obj:readInt())
    end
    res.player = {}
    local beannum = obj:readShort()
    
    local function moveCardsToTable(cards,tb)
        tb.handcard = {}
        tb.mingpai = {}
        tb.isFanggang = false
        for i=1,#cards do
            if cards[i].type < 7 and cards[i].type > 0 then
                if cards[i].type == 6 then
                    for j = 1,cards[i].num do
                        tb.handcard[#tb.handcard+1] = cards[i].value
                    end
                else
                    if cards[i].type == 4 then
                        tb.isFanggang = true
                    else
                        tb.mingpai[#tb.mingpai + 1] = {}
                        for j=1,cards[i].num do
                            tb.mingpai[#tb.mingpai][#tb.mingpai[#tb.mingpai] + 1] = {}
                            tb.mingpai[#tb.mingpai][#tb.mingpai[#tb.mingpai]].cardnum = cards[i].value
                            tb.mingpai[#tb.mingpai][#tb.mingpai[#tb.mingpai]].flag = cards[i].type
                            
                            --if cards[i].type == 3 then
                            --    tb.mingpai[#tb.mingpai][#tb.mingpai[#tb.mingpai]].flag = 1
                            --else
                            --    tb.mingpai[#tb.mingpai][#tb.mingpai[#tb.mingpai]].flag = 0
                            --end
                        end
                    end
                end
            end
        end
    end
    
    for i=1,beannum do
        local tmpbean = {}
        obj:readShort()
        tmpbean.playerid = obj:readLong()
        local cardnum = obj:readShort()
        tmpbean.cards = {}
        for i=1,cardnum do
            obj:readShort()
            local card = {}
            card.type = obj:readByte()
            card.value = GlobalFun:ServerCardToLocalCard(obj:readInt())
            card.num = obj:readByte()
            tmpbean.cards[#tmpbean.cards+1] = card
        end
        res.player[#res.player + 1] = {}
        res.player[#res.player].playerid = tmpbean.playerid
        moveCardsToTable(tmpbean.cards,res.player[#res.player])
    end
    
    local scorenum = obj:readShort()
    local scoreBean = {}
    for i=1,scorenum do
        obj:readShort()
        scoreBean[#scoreBean+1] = {}
        scoreBean[#scoreBean].playerid = obj:readLong()
        scoreBean[#scoreBean].score = obj:readInt()
    end
    
    --合bean
    for i=1,#scoreBean do
        for j=1,#res.player do
            if scoreBean[i].playerid == res.player[j].playerid then
                res.player[j].score = scoreBean[i].score
            end
        end
    end
    
    local tmpnum = obj:readShort()
    res.remaining = {}
    for i=1,tmpnum do
        res.remaining[#res.remaining + 1] = GlobalFun:ServerCardToLocalCard(obj:readInt())
    end
    if GlobalData.log == nil then
        GlobalData.log = ""
    end


    --{[1] = {userid = ?, info = {[1] = {hu_type = ?}, ... }},  ... }  目前胡牌特效需要这样的类型
    local tmp = {}
    local numb = obj:readByte()
    for i =1, numb do
        local userid = obj:readLong()
        local count = obj:readByte()
        tmp[i] = {userid = userid}
        local info = {}
        for j = 1, count do
            local hu_type = obj:readByte()
            info[j] = {hu_type = hu_type}
        end
        tmp[i].info = info
    end
    res.player_hu_info = tmp




    


    CCXNotifyCenter:notify("onServerNotifyHU",res)
end

function ClientController:ReadyState()
    local obj = Write.new(1007)
    --obj:writeString(GlobalData.roomKey)
    
    obj:send()

end

function ClientController:onReadyState(obj)
    local res = {}
    res.readyID = obj:readLong()
    if GlobalData.log == nil then
        GlobalData.log = ""
    end

    CCXNotifyCenter:notify("onReadyState",res)
end

function ClientController:userOutCard(index,value)
    local obj = Write.new(1008)
    --obj:writeString(GlobalData.roomKey)
    obj:writeByte(index)
    obj:writeInt(value)
    obj:send()
end

function ClientController:onUserOutCard(obj)
    local res = {}
    res.userID = obj:readLong()
    res.index = obj:readByte()
    res.value = obj:readInt()

    CCXNotifyCenter:notify("onUserOutCard",res)
end

function ClientController:onServerPickCard(obj)
    local res = {}
    res.cardnum = obj:readInt()
    CCXNotifyCenter:notify("onServerPickCard",res)
end

function ClientController:onServerNotifyCanPeng(obj)
    local res = {}
    res.userID = obj:readLong()
    res.index = obj:readByte()
    res.value = obj:readInt()
    cclog ("ClientController:onServerNotifyCanPeng >>>>>", res.userID)
    CCXNotifyCenter:notify("onServerNotifyCanPeng",res)
end

function ClientController:onServerNotifyCanGang(obj)
    local res = {}
    res.userID = obj:readLong()
    res.index = obj:readByte()
    res.value = obj:readInt()
    
    CCXNotifyCenter:notify("onServerNotifyCanGang",res)
end

function ClientController:userPeng(outUserID,value)
    local obj = Write.new(1012)
    --obj:writeString(GlobalData.roomKey)
    obj:writeLong(outUserID)
    obj:writeInt(value)
    obj:send()
end

function ClientController:onUserPeng(obj)
    local res = {}
    res.pengID = obj:readLong()
    res.outID = obj:readLong()
    res.value = obj:readInt()
    CCXNotifyCenter:notify("onUserPeng",res)
end

function ClientController:userMingGang(outUserID,value)
    local obj = Write.new(1013)
    --obj:writeString(GlobalData.roomKey)
    obj:writeLong(outUserID)
    obj:writeInt(value)
    obj:send()
end

function ClientController:onUserMingGang(obj)
    local res = {}
    CCXNotifyCenter:notify("onUserMingGang",res)
end

function ClientController:userAnGang(value)
    local obj = Write.new(1014)
    --obj:writeString(GlobalData.roomKey)
    obj:writeInt(value)
    
    
    obj:send()

end

function ClientController:onUserAnGang(obj)
    local res = {}
    CCXNotifyCenter:notify("onUserAnGang",res)
end

function ClientController:onServerNotifyUserPick(obj)
    local res = {}
    res.userid = obj:readLong()
   
    CCXNotifyCenter:notify("onServerNotifyUserPick",res)
end

function ClientController:requireDismissRoom()
    local obj = Write.new(1016)
    --obj:writeString(GlobalData.roomKey)
    
    
    obj:send()

end

function ClientController:askDismissRoom(b)
    cclog("ClientController:askDismissRoom >>>>", b, PlayerInfo.playerUserID)
    -- cclog(debug.traceback())



    local obj = Write.new(1017)
    --obj:writeString(GlobalData.roomKey)
    obj:writeBoolean(b)
    
    
    obj:send()
  
end

function ClientController:onAskDismissRoom(obj)
    local res = {}
    res.reqID = obj:readLong()
   

    MessageCache:setCache("ROOM:onAskDismissRoom", res)
    CCXNotifyCenter:notify("onAskDismissRoom",res)
end

function ClientController:onServerBrocastAnGang(obj)
    local res = {}
    res.userID = obj:readLong()
    res.value = obj:readInt()
    
    CCXNotifyCenter:notify("onServerBrocastAnGang",res)
end

function ClientController:onServerBrocastMingGang(obj)
    local res = {}
    res.gangID = obj:readLong()
    res.outID = obj:readLong()
    res.cardnum = obj:readInt()
   
    CCXNotifyCenter:notify("onServerBrocastMingGang",res)
end

function ClientController:onServerBrocastPeng(obj)
    local res = {}
    res.pengID = obj:readLong()
    res.outID = obj:readLong()
    res.value = obj:readInt()
    
    CCXNotifyCenter:notify("onServerBrocastPeng",res)
end

function ClientController:onServerBrocastDraw(obj)
    local res = {}
    CCXNotifyCenter:notify("onServerBrocastDraw",res)
end

function ClientController:confirmHu(b)--确定是否胡牌
    local obj = Write.new(1022)
    --obj:writeString(GlobalData.roomKey)
    obj:writeBoolean(b)
    
   
    obj:send()
 
end

function ClientController:onServerNotifyCanHu()--服务器通知可以胡牌
    local res = {}
    
    CCXNotifyCenter:notify("onServerNotifyCanHu",res)
end

function ClientController:sendEmoticon(_type,emoid)
    cclog("------------- sendEmoticon ")
    local obj = Write.new(1024)
    --obj:writeString(GlobalData.roomKey)
    obj:writeByte(_type)
    obj:writeString(emoid)
    obj:send()
end

function ClientController:onSendEmoticon(obj)
    local res = {}
    res.playid = obj:readLong()
    res.type = obj:readByte()
    res.emoid = obj:readString()
    
    CCXNotifyCenter:notify("onSendEmoticon",res)
end

function ClientController:onRoomServerNotifyUserGang(obj)
	local res = {}
	local num = obj:readShort()
	res.cards = {}
	local logcards = ""
	for i=1,num do
        res.cards[#res.cards + 1] = GlobalFun:ServerCardToLocalCard(obj:readInt())
        logcards = logcards .. GlobalFun:localCardToServerCard(res.cards[#res.cards]) .. ","
    end
    
    CCXNotifyCenter:notify("onRoomServerNotifyUserGang",res)
end

-- function ClientController:heartBeat()--心跳
--     local obj = Write.new(1)
--     --obj:writeString(GlobalData.roomKey)
    
    
--     obj:send()
--     --LogController.sendLog(sendlog)
-- end

-- function ClientController:onHeartBeat(obj)--心跳
--     local res = {}

--     --LogController.sendLog(sendlog)
--     CCXNotifyCenter:notify("onHeartBeat",res)
-- end

function ClientController:onNotifyUserRefusedDisMiss(obj)
    local res = {}

    local numb = obj:readByte()
    for i =1, numb do
        local tmp = {}
        tmp.isAgree = obj:readByte() == 1 and true or false
        tmp.refusedID = obj:readLong()
        res[i] = tmp
    end

    MessageCache:setCache("ROOM:onNotifyUserRefusedDisMiss", res)
    CCXNotifyCenter:notify("onNotifyUserRefusedDisMiss",res)
end

function ClientController:onNotifyString(obj)
    local res = {}
    res.msg = obj:readString()
    
    CCXNotifyCenter:notify("onNotifyString",res)
end

function ClientController:onRoomOwnerDimissRoom(obj)
    cclog(" ///////// onRoomOwnerDimissRoom  房主强制关闭房间")
    local res = obj:readString();
    -- 提示房主强制关闭房间
    local node = display.newCSNode("CreateRoom/CUIDissmisRoom.csb")
    local root = node:getChildByName("node")

    local btn_close      = root:getChildByName("btn_close")
    local btn_ok         = root:getChildByName("btn_ok")
    local txt_msg        = root:getChildByName("txt_msg")

    txt_msg:setString(res or "房主强制关闭了房间!" )

    btn_ok:addClickEventListener(function()
                        node:setVisible(false)
                    end)
    btn_close:addClickEventListener(function()
                        node:setVisible(false)
                    end)    
    node:addTo(cc.Director:getInstance():getRunningScene())
end

function ClientController:onNotifyUserDisMiss(obj)--解散房间
    cclog("///////// onNotifyUserDisMiss   解散房间")
    local res = {}
    local loginfo = ""
    res.loginKey = obj:readString()
    loginfo = loginfo .. " hallKey :" .. res.loginKey .. "   "
    local num = obj:readShort()
    res.players = {}
    for i=1,num do
        obj:readShort()
        res.players[#res.players + 1] = {}
        res.players[#res.players].playerID = obj:readLong()
        res.players[#res.players].hpcnt = obj:readShort()
        res.players[#res.players].mgcnt = obj:readShort()
        res.players[#res.players].agcnt = obj:readShort()
        res.players[#res.players].zmcnt = obj:readShort()
        res.players[#res.players].score = obj:readShort()
        res.players[#res.players].name = obj:readString()
        loginfo = loginfo .. "[" .. res.players[#res.players].playerID .. "," .. res.players[#res.players].hpcnt .. "," .. res.players[#res.players].mgcnt .. "," .. res.players[#res.players].agcnt .. "," .. res.players[#res.players].zmcnt .. "," .. res.players[#res.players].score .. "]" .. ","
    end

    
    CCXNotifyCenter:notify("onNotifyUserDisMiss",res)
end

function ClientController:userRequestExit()
    local obj = Write.new(1029)
    --obj:writeString(GlobalData.roomKey)
    
    
    obj:send()

end

function ClientController:onUserRequestExit(obj)
    local res = {}
    res.isQuit = obj:readBoolean()
    if res.isQuit then
        res.loginKey = obj:readString()
        local s = obj:readByte()
        res.rtype = s
        if s == 0 then

            
        elseif s == 1 then
            res.clubId = obj:readLong()
            -- res.clubHost = obj:readString()
            -- local ip,port = LineMgr:useLineNumbGetIp(res.clubHost)
            -- res.clubIP, res.ClubPort = ip,port
            -- ClubClient.ClubKey = res.loginKey
            -- ClubClient.ClubIP = ip
            -- ClubClient.ClubPort = port
            -- ClubManager:setInfo("clubID", res.clubId)
        end
      
    end

    cclog("ClientController:onUserRequestExit >>>")
    print_r(res)
    CCXNotifyCenter:notify("onUserRequestExit",res)
end

function ClientController:onNotifyQuitRoomUserID(obj)--退出房间的玩家id
    local res = {}
    res.quitID = obj:readLong()
    
    CCXNotifyCenter:notify("onNotifyQuitRoomUserID",res)
end

function ClientController:onNotifyUserOnAnOff(obj)--玩家掉线或上线
    local res = {}
    res.flag = obj:readByte()
    res.userid = obj:readLong()
    
    CCXNotifyCenter:notify("onNotifyUserOnAnOff",res)
end

function ClientController:userPass()--玩家点击过
    local obj = Write.new(1033)
    --obj:writeString(GlobalData.roomKey)
    
    
    obj:send()

end

function ClientController:onUserPass(obj)
    CCXNotifyCenter:notify("BtnCleanAll",nil)
end

function ClientController:userRequireShowBTN()--游戏重连之后是否要显示button（碰杠胡）
    local obj = Write.new(1034)
    --obj:writeString(GlobalData.roomKey)
    
    
    obj:send()

end

function ClientController:onUserRequireShowBNT(obj)
    local res = {}
    local loginfo = ""
    if obj:readBoolean() then
        res.pgvalue = obj:readInt()
        loginfo = loginfo .. " can peng value:" .. res.pgvalue
    end
    if obj:readBoolean() then
        res.mgvalue = obj:readInt()
        res.mgoutID = obj:readLong()
        loginfo = loginfo .. "  can mgang  mgoutid:" .. res.mgoutID .. "  value:" .. res.mgvalue
    end
    res.an = {}
    local num = obj:readShort()
    if num > 0 then
        loginfo = loginfo .. "  can an gang："
    end
    for i=1,num do
        res.an[#res.an+1] = obj:readInt()
        loginfo = loginfo .. res.an[#res.an] .. ","
    end
    
    res.hu = obj:readBoolean()
    loginfo = loginfo .. (res.hu and "  can hu" or "  not hu")
    
    if obj:readBoolean() then
        res.pengvalue = obj:readInt()
        res.pengOutID = obj:readLong()
        
        loginfo = loginfo .. "   can peng outid:" .. res.pengOutID .. "  value:" .. res.pengvalue
    end
    
    CCXNotifyCenter:notify("onUserRequireShowBNT",res)
end

function ClientController:clientUpLoadCards(str,cards)--上传服务端校验数据
    if #cards < 1 then
        return
    end
    local obj = Write.new(1036)
    --obj:writeString(GlobalData.roomKey)
    obj:writeString(str)
    obj:writeByte(#cards)
    local logcards = ""
    for i=1,#cards do
        obj:writeInt(cards[i])
        logcards = logcards .. cards[i] .. ","
    end
    
    
    obj:send()
 
end

function ClientController:notifyPlayerCard()--客户端校验到牌不对的时候跟服务器重新获取手牌
    if true then
        return
    end
    local obj = Write.new(1037)
    --obj:writeString(GlobalData.roomKey)
    

    
    obj:send()

end

function ClientController:onNotifyPlayerCard(obj)
    local res = {}
    
    local num = obj:readShort()
    local logcards = ""
    for i=1,num do
        res[i] = GlobalFun:ServerCardToLocalCard(obj:readInt())
        logcards = logcards .. GlobalFun:localCardToServerCard(res[i]) .. ","
    end

    
    CCXNotifyCenter:notify("onNotifyPlayerCard",res)
end

function ClientController:onRoomJoinBaseInfo(obj)--玩家进入房间
    local res = {}
    --[[
     id-long ,用户ID 
     *      isBanker-bool，是否是庄家
     *      name-string ，昵称 
     *      ordinal-byte ，进入房间的序号
     *      ico-String ，头像 
     *      sex-byte ，性别 
     *      score-short ，当前玩家分数 
     *      isReady-bool ，是否准备
     *      ip-string ，ip
     *      isOnline-bool ，是否在线
     ]]
     
     res.id = obj:readLong()
     res.isBanker = obj:readBoolean()
     res.name = obj:readString()
     res.pos = obj:readByte()
     res.iconURL = obj:readString()
     res.sex = obj:readByte()
     res.score = obj:readShort()
     res.isReady = obj:readBoolean()
     res.ipAddr = obj:readString()
     --res.isLine = obj:readBoolean()

     cclog("onRoomJoinBaseInfo >>>>>>>>>>>>>>>>>>>>")
     print_r(res)
     
    CCXNotifyCenter:notify("onRoomJoinBaseInfo",res)
end

function ClientController:onVideoData(obj)--录像回放
    local res = {}
    
    while true do
    	local state = obj:readByte()

        if #res > 0 then
            if state <= 0 or state > 16 then--数据解析出错
                cclog("onVideoData state  >>>>>>>>>>>>>>>>>>>", state)
                res = nil
                break
            end
        end
        res[#res + 1] = {}
        res[#res].state = state
        if state == 0 then--开始
            obj:readShort()
            res[#res].roomid = obj:readInt()
            res[#res].curr = obj:readByte() + 1
            res[#res].mainID = obj:readLong()
            res[#res].banker = obj:readLong()
            --[[local num = obj:readShort()
            local remaining = {}
            for k=1,num do
                remaining[#remaining+1] = obj:readInt()
            end
]]
            local num = obj:readShort()
            local player = {}
            for k=1,num do
                player[k] = {}
                obj:readShort()
                player[k].playerId = obj:readLong()
                player[k].sex = obj:readByte()--性别 不需要保存
                player[k].nickname = obj:readString()
                player[k].imgurl = obj:readString()
                local hcards = {}
                local c_num = obj:readShort()
                for j=1,c_num do
                    hcards[j] = obj:readInt()
                end
                player[k].handcard = hcards

                local lcards = {}
                c_num = obj:readShort()
                for j=1,c_num do
                    lcards[j] = obj:readInt()
                end
                if #lcards == 0 then
                    lcards = nil
                end
                player[k].listen = lcards
                
                player[k].pos = obj:readByte()
                player[k].score = obj:readShort()
            end
            res[#res].isQiXiaoDui = obj:readByte()
            res[#res].isMiLuoHongZhong = obj:readByte()

            res[#res].player = player
        elseif state == 1 then--出牌
            res[#res].userid = obj:readLong()
            res[#res].value = obj:readInt()

            local num = obj:readShort()
            local cards = {}
            for k=1,num do
                cards[k] = obj:readInt()
            end
            if #cards == 0 then
                cards = nil
            end
            res[#res].listen = cards
        elseif state == 2 then--摸牌
            res[#res].userid = obj:readLong()
            res[#res].value = obj:readInt()
        elseif state == 3 or state == 4 or state == 5 then--碰牌 杠牌  明杠
            res[#res].userid = obj:readLong()
            res[#res].outid = obj:readLong()
            res[#res].value = obj:readInt()

            local num = obj:readShort()
            local cards = {}
            for k=1,num do
                cards[k] = obj:readInt()
            end
            if #cards == 0 then
                cards = nil
            end
            res[#res].listen = cards
            --[[elseif state == 4 then--杠牌

            elseif state == 5 then--明杠]]

        elseif state == 6 then--暗杠
            res[#res].userid = obj:readLong()
            res[#res].value = obj:readInt()

            local num = obj:readShort()
            local cards = {}
            for k=1,num do
                cards[k] = obj:readInt()
            end
            if #cards == 0 then
                cards = nil
            end
            res[#res].listen = cards
        elseif state == 7 then--过
            res[#res].userid = obj:readLong()

        elseif state == 8 then--解散
            cclog("state == 8 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
            res = nil
        
            break
            --CCXNotifyCenter:notify("onVideoData",nil)
        elseif state == 9 then--流局
            break
        elseif state == 10 then--胡
            res[#res].huPaiType = obj:readByte()
            local count = obj:readByte()
            local tmp = {}
            for i = 1, count do
                tmp[i] = obj:readLong()
            end
            res[#res].userid = tmp


            local numb = obj:readByte()
            local tmp = {}
            for i =1, numb do
                tmp[i] = obj:readByte()
            end
            res[#res].hu_types = tmp

            res[#res].fangpao_player = obj:readLong()

            break
        elseif state == 11 then--抢杠胡
            local num = obj:readShort()
            local winid = {}
            for k=1,num do
                winid[k] = obj:readLong()
            end
            res[#res].winid = winid
            break

        elseif state == 12 then
            
        elseif state == 13 then
            
            res[#res].userid = obj:readLong()
            res[#res].outid = obj:readLong()
            res[#res].value = obj:readInt()

        elseif state == 14 then
            
            res[#res].userid = obj:readLong()
            res[#res].outid = obj:readLong()
            res[#res].value = obj:readInt()

        elseif state == 15 then
            
            res[#res].userid = obj:readLong()

        elseif state == 16 then
            res[#res].userid = obj:readLong()
            
            local cards = {}
            local num = obj:readShort()
            for i = 1, num do
                cards[i] = obj:readInt()
            end

            res[#res].feng_cards = cards


        end
    end


    cclog("xxxxxxxxxxxxxxxxxxxx >>>>>>>>>")
    cclog("xxxxxxxxxxxxxxxxxxxx >>>>>>>>>", res, #res)
    CCXNotifyCenter:notify("onVideoData",res)
end

function ClientController:joinMatch()
    local obj = Write.new(1047)
    --obj:writeString(GlobalData.roomKey)
    obj:send()
end

function ClientController:onJoinMatch(obj)
    local res = {}
    CCXNotifyCenter:notify("enrollSuccess",nil)
    --CCXNotifyCenter:notify("onJoinMatch",res)
end

function ClientController:onEliminated(obj)--被淘汰
    local res = {}
    CCXNotifyCenter:notify("onEliminated",res)
end

function ClientController:onWaitJoinMatch(obj)--等待玩家进入比赛
    local res = {}
    cclog("等待玩家进入")
    CCXNotifyCenter:notify("onReqEnterRoom",nil)
end

function ClientController:onNotifyBeganMatch(obj)--通知开始比赛了 
    local res = {}
    res.msg = "麻将比赛已经开始，快来参与吧.."
    CCXNotifyCenter:notify("onNotifyString",res)
end

function ClientController:onUpdateMatchPeople(obj)
    local res = {}
    res.count = obj:readInt()
    CCXNotifyCenter:notify("updatePeopleCnt",res)
    --CCXNotifyCenter:notify("onUpdateMatchPeople",res)
end

function ClientController:onServerNotifyTop(obj)--广播比赛前4的玩家
    local res = {}
    local num = obj:readShort()
    local data = {}
    for i=1,num do
        data[i] = {}
        obj:readShort()
        data[i].playerId = obj:readLong()
        data[i].nickname = obj:readString()
        data[i].score = obj:readInt()
    end
    for i=1,#data-1 do
        local max = i
        for j=i+1,#data do
            if data[j].score > data[max].score then
                max = j
            end
        end
        if max ~= i then
            local tmp = data[i]
            data[i] = data[max]
            data[max] = tmp
        end
    end
    res.msg = ""
    for i=1,#data do
        res.msg = res.msg .. "恭喜玩家" .. data[i].nickname .. "在比赛中获得第" .. i .. "的成绩"
        if i ~= #data then
            res.msg = res.msg .. "   "
        end
    end
    CCXNotifyCenter:notify("onNotifyString",res)
end

function ClientController:onNotifyHallGameStart(obj)--报了名的玩家才可以收到
    local function gotoMatchGame()
        
    end
    GlobalFun:showError("麻将比赛已经开始,是否进入比赛?",gotoMatchGame,nil,2)
end

function ClientController:onWaitMatchOver(obj)
    local res = {}
    
    res.total = obj:readInt()
    res.remaining = obj:readInt()
    if GlobalData.roomData ~= nil  then
        GlobalData.roomData.isWaitOver = true
        GlobalData.roomData.total = res.total
        GlobalData.roomData.remaining = res.remaining
    end
    CCXNotifyCenter:notify("onWaitMatchOver",res)
end

function ClientController:checkRankInfo()
    local obj = Write.new(1060)
    obj:writeString(GlobalData.roomKey)
    obj:send()
end

function ClientController:onCheckRankInfo(obj)
    local res = {}
    res.matchCnt = obj:readInt()
    res.rank = obj:readInt()
    CCXNotifyCenter:notify("onCheckRankInfo",res)
end

function ClientController:onMatchOver(obj)
    local res = {}
    res.matchCnt = obj:readInt()
    res.rank = obj:readInt()
    CCXNotifyCenter:notify("onMatchOver",res)
end

function ClientController:watchList()
    cclog("ClientController:watchList   >>>>>>>>>>>>")
    local obj = Write.new(1080)
    obj:send()
end

function ClientController:onWatchList(obj)
    cclog("ClientController:onWatchList   >>>>>>>>>>>>")
    local res = {}
    local num = obj:readShort()
    res.watchList = {}
    for i=1,num do
        res.watchList[i] = {}
        res.watchList[i].id = obj:readLong()
        res.watchList[i].img = obj:readString()
    end
    CCXNotifyCenter:notify("onWatchList",res)
end

function ClientController:exitWatch()
    local obj = Write.new(1081)
    obj:send()
end

function ClientController:onExitWatch(obj)--退出观众区跟房间房间
    local res = {}
    res.canExit = obj:readBoolean()
    res.key = obj:readString()
    CCXNotifyCenter:notify("onExitWatch",res)
end

function ClientController:changeSitOrUp(state)--站起 坐下切换
    local obj = Write.new(1082)
    obj:writeByte(state)
    obj:send()
end

function ClientController:onNotifyInOrOutWatch(obj)--广播观战玩家进入或退出
    cclog("ClientController:onNotifyInOrOutWatch   >>>>>>>>>>>>")
    local res = {}
    res.flag = obj:readByte()
    res.id = obj:readLong()
    res.img = obj:readString()
    CCXNotifyCenter:notify("onNotifyInOrOutWatch",res)
end

function ClientController:gifList()
    local obj = Write.new(1084)
    obj:send()
end

function ClientController:onGifList(obj)--获取礼物列表
    local res = {}
    local num = obj:readShort()
    for i=1,num do
        res[i] = {}
        res[i].id = obj:readByte()
        res[i].price = obj:readInt()
    end
    CCXNotifyCenter:notify("onGifList",res)
end

function ClientController:givePlayerGif(data)--赠送礼物
    local obj = Write.new(1085)
    obj:writeLong(data.playerid)
    obj:writeByte(data.gifid)
    obj:writeInt(data.num)
    obj:send()
end

function ClientController:onGivePlayerGif(obj)
    local res = {}
    res.giveid = obj:readLong()
    res.givename = obj:readString()
    res.reciveid = obj:readLong()
    res.gifid = obj:readByte()
    res.num = obj:readInt()
    CCXNotifyCenter:notify("onGivePlayerGif",res)
end

function ClientController:GetProduct()--请求获取商品列表
    local obj = Write.new(1086)
    obj:writeByte(0)
    obj:send()
end

function ClientController:onGetProduct(obj)
    local res = {}
    local size = obj:readShort()
    for index = 1 , size do
        local data = {}
        data.thingsid = obj:readInt()
        data.platf = obj:readInt()
        data.type = obj:readInt()
        data.money = obj:readInt()
        data.card = obj:readInt()
        res[#res +1] = data
    end
    CCXNotifyCenter:notify("onGetProduct",res)
end

function ClientController:onCardUpdate(obj)--通知房卡更新
    cclog(" Hall Client 通知房卡更新")
    local res = {}
    res.card = obj:readInt()     --改变的卡
    res.currCard = obj:readInt() --当前卡总数
    res.type = obj:readByte() --0房卡  1金币
    CCXNotifyCenter:notify("onCardUpdate",res)
end

function ClientController:handUp()--取消挂机
    local obj = Write.new(1111)
    --obj:writeString(GlobalData.roomKey)
    obj:send()
end

function ClientController:onHandUp(obj)
    local res = {}
    res.flag = obj:readBoolean()--true是挂机状态  false不是挂机状态
    if GlobalData.roomData ~= nil  then
        GlobalData.roomData.isgj =  res.flag
    end
    CCXNotifyCenter:notify("onHandUp",res)
end

--------------gps start-------------------------
-- gps定位系统
-- 进入房间通知gps位置
-- location json.encode({经,纬})
function ClientController:requestLocation(location)
    -- cclog("requestLocation",location,styte)
    local obj = Write.new(1300)
    obj:writeString(location)
    
    
    obj:send()

end 

function ClientController:onRequestLocation(obj)
    local res = {}
    CCXNotifyCenter:notify("onRequestLocation",res) 
end

-- 玩家点击gps按钮刷新数据
function ClientController:getAllPlayersGps()
    cclog("longma getAllPlayersGps")
    local obj = Write.new(1301)
    obj:send()
end 

-- 通知玩家定位
function ClientController:onServerGetAllPlayersGps(obj)
    cclog("longma onServerGetAllPlayersGps",onServerNotifyGps)
    local res = {}
    local num = obj:readShort()
    for i = 1,num do
        res[i] = {}
        res[i].playerid = obj:readLong()
        res[i].location = obj:readString()
    end 
    CCXNotifyCenter:notify("onServerGetAllPlayersGps",res)
end

function ClientController:onFengHuCards(obj)
    local cards = {}
    local num = obj:readShort()
    for i = 1, num do
        cards[i] = obj:readInt()
    end
    MessageCache:setCache("ROOM:onFengHuCards", cards)
    CCXNotifyCenter:notify("onFengHuCards",cards)
end

------ h5支付 获取
function ClientController:h5Pay(paymode , goodsid)
    local obj = Write.new(1145)
    obj:writeInt(goodsid)    -- 商品ID
    obj:writeString(paymode) -- 支付模式 "WXPAY" or "ALIPAY"
    obj:send()
end

function ClientController:onH5Pay(obj)
    CCXNotifyCenter:notify("ReSetPayClick",nil)--解开二次点击限制

    local bool= obj:readBoolean()
    cclog(" ------ bool pay url" , bool)
    if bool then      
        local url = obj:readString()
        if url and url ~= "" then 
            cclog("  url ", url)
            CCXNotifyCenter:notify("Hall_doH5Pay" , url)
        else
            GlobalFun:showError("支付地址不存在",nil,nil,1)
        end  
    else
        local msg = obj:readString()
        cclog(" ----- err msg ", msg)
        GlobalFun:showError(msg or "请求支付异常",nil,nil,1)
    end  
end
--========================================   club begin ==========================================

function ClientController:yaoQingClubMember(members)
    local obj = Write.new(1091)
    obj:writeString(members)
    local str = string.format("玩家[%s]邀请您加入[红中麻将]的房间(ID:%s)", PlayerInfo.nickname, GlobalData.roomID)
    cclog("ClientController:yaoQingClubMember >>>", str)
    obj:writeString(str)
    obj:send()
end

function ClientController:chengYuanList(pageNumb)
    local obj = Write.new(1090)
    obj:writeByte( pageNumb)
    obj:send()
end

function ClientController:onChengYuanList(obj)
    local res = {}
    res.maxPage = obj:readByte()
    res.curPage = obj:readByte()
    res.maxNumb = obj:readByte()

    res.count = obj:readByte()
    res.data = {}
    for k =1, res.count do
        local tab = {}
        tab.userID = obj:readLong()
        tab.name = obj:readString()
        tab.icon = obj:readString()

        res.data[#res.data +1] = tab
    end
    CCXNotifyCenter:notify("ROOM:onChengYuanList",res)
end

function ClientController:onClubRoomNotifyUserDisMiss(obj)
    local res = {}
    local loginfo = ""
    res.loginKey = obj:readString()
    res.clubId = obj:readLong()
    res.clubHost = obj:readString()
    

    -- local ip,port = LineMgr:useLineNumbGetIp(res.clubHost)
    -- res.clubIP, res.ClubPort = ip,port
    -- ClubClient.ClubKey = res.loginKey
    -- ClubClient.ClubIP = ip
    -- ClubClient.ClubPort = port

    local num = obj:readShort()
    res.players = {}
    for i=1,num do
        obj:readShort()
        res.players[#res.players + 1] = {}
        res.players[#res.players].playerID = obj:readLong()
        res.players[#res.players].hpcnt = obj:readShort()
        res.players[#res.players].mgcnt = obj:readShort()
        res.players[#res.players].agcnt = obj:readShort()
        res.players[#res.players].zmcnt = obj:readShort()
        res.players[#res.players].score = obj:readShort()
        res.players[#res.players].name = obj:readString()
        loginfo = loginfo .. "[" .. res.players[#res.players].playerID .. "," .. res.players[#res.players].hpcnt .. "," .. res.players[#res.players].mgcnt .. "," .. res.players[#res.players].agcnt .. "," .. res.players[#res.players].zmcnt .. "," .. res.players[#res.players].score .. "]" .. ","
    end
    CCXNotifyCenter:notify("onClubRoomNotifyUserDisMiss",res)
end

function ClientController:onlistenCanHuCard(obj)
    cclog("ClientController:onlistenCanHuCard")
    local res = {}
    local canListenNum = obj:readShort()
    for i = 1, canListenNum do
        local tmp = {}
        tmp.card = GlobalFun:ServerCardToLocalCard(obj:readInt())
        tmp.listenData = {}
        local len = obj:readShort()
        for j = 1, len do
            local card = GlobalFun:ServerCardToLocalCard(obj:readInt())
            table.insert(tmp.listenData, card)
        end
        table.insert(res, tmp)
    end
    CCXNotifyCenter:notify("ROOM:onlistenCanHuCard",res)
end

return ClientController