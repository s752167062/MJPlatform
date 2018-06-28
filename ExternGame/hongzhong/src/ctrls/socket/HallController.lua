local HallController = class("HallController")

function HallController:ctor(params)
    self:inItProtocol()
end

function HallController:receiveMsg(obj)
    self:handlerProtocol(obj:getProId(),obj)
end

--协议处理
function HallController:handlerProtocol(proId,obj)
    proId = tonumber(proId)
    if self._proFuns[proId] then
        self._proFuns[proId](obj)
    else
        dump("HallController error,non-existent protocol ID:"..proId)
    end
end

function HallController:onError(obj)
    local res = {}
    res.errorCode =  obj:readByte()
    res.closeNetWork = obj:readBoolean()
    res.msg_err = obj:readString()
    dump(res)

    HallClient:onProtocolError(res)
end

--协议注册
function HallController:inItProtocol()
    self._proFuns = {}
    self._proFuns[999] = handler(self,self.onError)

    self._proFuns[0] = handler(self,self.onSendSid)
    self._proFuns[1] = handler(self,self.onHeartBeat)
    self._proFuns[1000] = handler(self,self.onConnectCheck)
    self._proFuns[1001] = handler(self,self.onReConnectCheck)
    self._proFuns[1002] = handler(self,self.onCreateRoom)
    self._proFuns[1003] = handler(self,self.onGotoRoom)
    self._proFuns[1004] = handler(self,self.onMatchingRoom)
    -- self._proFuns[999] = handler(self,self.onProtocolError)
    self._proFuns[1006] = handler(self,self.onCardUpdate)
    self._proFuns[1007] = handler(self,self.onGetProduct)
    self._proFuns[1009] = handler(self,self.onSendFeedBack)
    self._proFuns[1010] = handler(self,self.onNotifyString)
    self._proFuns[1011] = handler(self,self.onCanShopping)
    self._proFuns[1013] = handler(self,self.onGetMatchIP)
    self._proFuns[1015] = handler(self,self.onGetMatchTime)
    self._proFuns[1017] = handler(self,self.onNotifyBeganMatch)
    self._proFuns[1018] = handler(self,self.onServerNotifyTop)
    self._proFuns[1019] = handler(self,self.onCheckBestRecord)
    self._proFuns[1020] = handler(self,self.onSignDailyPVE)
    self._proFuns[1021] = handler(self,self.onNotifyHallGameStart)
    self._proFuns[1022] = handler(self,self.onUpdatePeopleNum)
    self._proFuns[1024] = handler(self,self.onSubmitPlayerInfo)
    self._proFuns[1025] = handler(self,self.onPVERankInfo)
    self._proFuns[1100] = handler(self,self.onCreateRoomList)--创建房间列表)
    self._proFuns[1101] = handler(self,self.onCreateRoomListOne)--创建房间列表单条)

    self._proFuns[1201] = handler(self,self.onSecndSureToGotoRoom)  --进入房间二次确认框
    self._proFuns[1102] = handler(self,self.onDeleteRoomItem)--删除房间列表单条)
    self._proFuns[1103] = handler(self,self.onMsgDataUpdate)
    self._proFuns[1104] = handler(self,self.onMsgData)
    self._proFuns[1105] = handler(self,self.onDimissRoom) --房主强制解散
    self._proFuns[1110] = handler(self,self.onGetResultData) --请求结算数据


    self._proFuns[1202] = handler(self,self.onShiMing)

    self._proFuns[1145] = handler(self,self.onH5Pay) --h5支付 获取

    --========================================  club begin =========================

    self._proFuns[1300] = handler(self,self.onGotoClub)
    self._proFuns[1301] = handler(self,self.onCreateClub) --创建俱乐部
    self._proFuns[1302] = handler(self,self.onSearchClub)   --搜索俱乐部
    self._proFuns[1303] = handler(self,self.onJoinClub)   --加入俱乐部
    self._proFuns[1304] = handler(self,self.onClubList)   --请求俱乐部列表
    self._proFuns[1305] = handler(self,self.onRequestJoinResult)   --请求加入俱乐部的结果

    self._proFuns[1306] = handler(self,self.onYaoQingJinFangTiShi)   --收到邀请进房

    self._proFuns[1310] = handler(self,self.onYaoQingJinJuLeBuTiShi)   --收到邀请进俱乐部
end

function HallController:connectCheck()--连接校验 
    -- cclog("HallController:connectCheck >>>>")
    -- cclog(debug.traceback())
    --协议号1000

    local server_type = platformExportMgr:doGameNetMgr_getServerTypeByCurrent()
    if server_type ~= platformExportMgr:getGlobalGameSeverType("hall")  then
        GlobalFun:showError("网络故障，目标服务器id异常，点击确定返回平台",function ()
            platformExportMgr:returnAppPlatform()
            end,nil,1)
        return false
    end

    local obj = Write.new(1000)
    obj:writeString("hz")
    obj:writeString(platformExportMgr:doGameConfMgr_getInfo("hostKey"))
    obj:writeString(Game_conf.Base_Version)
    obj:writeLong(PlayerInfo.playerUserID)
    obj:writeString(tostring(PlayerInfo.playerAccountID))

    cclog("PlayerInfo.playerUserID >>", PlayerInfo.playerUserID)
    cclog("PlayerInfo.playerAccountID >>", PlayerInfo.playerAccountID)
    local json = SDKController:getInstance():getPushMsgJson()
    obj:writeString(json)
    obj:send()

    -- GlobalFun:showNetWorkConnect("进入游戏大厅中...")
    return true
end

function HallController:onConnectCheck(obj)
    -- HallController:ShiMing(1)

    if Game_conf.isWX then
        --ActivityManager:init_require()--活动请求
    end
    
    local res = {}
    res.userID = obj:readLong()
    PlayerInfo.playerUserID = res.userID

--    res._ok = obj:readBoolean() -- ID :long  ,  CAR :int 
    res.nickname = obj:readString()
    res.cart = obj:readInt()
    res.goldnum = obj:readInt()
    cclog("金币数量：     " ,res.goldnum)
    res.isRoom = obj:readBoolean()
    if res.isRoom then--判断到在房间里则下发这个
        res.room = {}
        res.room.key = obj:readString()
        res.room.ip = obj:readString()
        --res.room.port = obj:readInt()
    end
    cclog(" >>>>>>>>>>>>>> ",res.isRoom)
    --res.isMatch = false

    -- GlobalData.roomKey = GlobalData.HallKey--obj:readString()
    local iszcbs = obj:readBoolean() --比赛服已经注册进来了
    GlobalData.iszcbs = iszcbs
    -- if iszcbs then
    --     local ips = obj:readString()
    --     -- local ip = Util.split(ips,";")
    --     -- ip = Util.split(ip[Game_conf.YYSType],":")
    --     -- GlobalData.roomIP = ip[1]
    --     -- GlobalData.roomPort = ip[2]

    --     local ip,port = LineMgr:useLineNumbGetIp(ips)
    --     GlobalData.roomIP = ip
    --     GlobalData.roomPort = port

    --     res.isMatch = obj:readBoolean()
    --     GlobalData.isSign = obj:readBoolean()
    --     if GlobalData.isSign then
    --         cclog("已经报名了")
    --     else
    --         cclog("没报名")
    --     end
    --     if res.isMatch then
    --         GlobalData.isSign = false--在房间里了就不需要记录已经报名了这个参数
    --         GlobalData.roomKey = obj:readString()
    --         cclog("房间key " .. GlobalData.roomKey)
    --     end
    --     cclog("key         " ..  GlobalData.roomKey)
    -- else
    --     res.isMatch = false --不在比赛
    -- end
    GlobalData.game_product = obj:readString()--游戏的唯一标识（给平台用）

    print_r(res, "onConnectCheck")
    CCXNotifyCenter:notify("reconnect_rec_list",nil);
    CCXNotifyCenter:notify("onConnectCheck",res)



---------------------------------------------------------------------------------------------
    cclog("HallClient:onConnectCheck >>>", GlobalData.isRoomToHall, GlobalData.curScene)

    GlobalData.HallRetryCnt = 0
    PlayerInfo.nickname = res.nickname

    if res.cart then
        GlobalData.CartNum = res.cart
        CCXNotifyCenter:notify("onConnectrefCard",nil)
    end
    PlayerInfo.goldnum = res.goldnum


    local enterParams = platformExportMgr:getEnterParams()
    if res.isRoom then
        GlobalData.isRetryConnect = true
        GlobalData.roomKey = res.room.key
        
        ex_roomHandler:connectCheck()
        return 
    end

    if next(enterParams) then 
        cclog("enterParams >>>>>")
        print_r(enterParams)
        if enterParams.epType == platformExportMgr.epType_gotoGameClub then
            
            HallController:gotoClub(enterParams.params.clubId, enterParams.params.clubSecndId)
        end
        
        return  
    end

    ex_gameStateMgr:changeState(ex_gameStateMgr.GAMESTATE.STATE_HALL)
    GlobalFun:closeNetWorkConnect()
    -- if GlobalData.curScene == SceneType_Game then
    --     CCXNotifyCenter:notify("closeServerRoom",res)
    -- else
    --     if GlobalData.curScene ~= SceneType_Hall and GlobalData.curScene ~= SceneType_Match then
    --         CCXNotifyCenter:notify("gotoHall",res)
    --         ex_gameStateMgr:changeState(ex_gameStateMgr.GAMESTATE.STATE_HALL)
    --     else
    --         CCXNotifyCenter:notify("onReListen",nil)
    --         if GlobalData.connectRoomNumber then--加房间
    --             HallController:gotoRoom(GlobalData.connectRoomNumber)
    --         elseif GlobalData.connectRoomCNT and GlobalData.connectRoomZhaMa then--新建房间
    --             cclog("onConnectCheck ****************** onCreateRoom")
    --             HallController:createRoom(GlobalData.connectRoomCNT,GlobalData.connectRoomZhaMa,GlobalData.json_enter or "")
    --         end
    --     end
    -- end
end

-------------------代开房间-------------------------
-------------------start---------------------------

function HallController:askCreateRoomList()
    local obj = Write.new(1100)
    
    obj:send()
    cclog("请求开房数据............................................")
end
function HallController:onCreateRoomList(obj)
    cclog("收到开房数据............................................")
    local res = {}
    local maxnum   = obj:readByte()  -- 每页最大数
    local currpage = obj:readShort() -- 当前页数
    local maxpage  = obj:readShort() -- 最大页数   
    local count    = obj:readShort()
    cclog(count)
    for i = 1,count do
        obj:readShort()
        local info = {}
        info.roomId = obj:readInt()
        info.roomKey = obj:readString()
        info.roomState = obj:readByte()
        info.remainTime = obj:readInt()
        info.remainTime = info.remainTime/1000
        info.playerCount = obj:readByte()
        info.playerMax = obj:readByte()
        info.createTime = obj:readLong()
        info.endTime = obj:readLong()
        info.roomType = obj:readString()
        info.round = obj:readByte()
        info.za = obj:readByte()
        info.roommainid = obj:readLong()
        info.roomCreateName = obj:readString() -- name
        info.roomCreateImgUrl = obj:readString() -- image
        info.curRound = obj:readByte() -- 进行到几局了
        cclog("@@@@@@@@@ " ,info.roomCreateName  , info.roomState)
        cclog("@@@@@@@@@ " ,info.roomCreateImgUrl)
        -- local hasResult = obj:readByte()
        -- if hasResult == 1 then 
        --     --结算数据
        -- end

        --已经入的玩家数据
        info.players_data = {}
        local pnum = obj:readShort()
        cclog(" +++ p count ", pnum)
        for i=1,pnum do
            obj:readShort()
            info.players_data[#info.players_data + 1] = {}
            info.players_data[#info.players_data].id        = obj:readLong() --玩家id
            info.players_data[#info.players_data].accountid = obj:readString() --玩家账号ID
            info.players_data[#info.players_data].p_name    = obj:readString() --玩家名
        end

        if info.roomState ~= 0 or info.remainTime > 0 then
            res[#res+1] = info
        end
    end

    local data = {}
    data.res = res;
    data.maxnum = maxnum
    data.roomMaxPage = maxpage
    data.roomIndexPage = currpage;

    -- print_r(data)
    CCXNotifyCenter:notify("rec_room_list",data)
end
function HallController:onCreateRoomListOne(obj)
    cclog("收到单条开房数据...")
    obj:readShort()
    local info = {}
    info.roomId = obj:readInt()
    info.roomKey = obj:readString()
    info.roomState = obj:readByte()
    info.remainTime = obj:readInt()
    info.remainTime = info.remainTime/1000
    info.playerCount = obj:readByte()
    info.playerMax = obj:readByte()
    info.createTime = obj:readLong()
    info.endTime = obj:readLong()
    info.roomType = obj:readString()
    info.round = obj:readByte()
    info.za = obj:readByte()
    info.roommainid = obj:readLong()
    info.roomCreateName = obj:readString() -- name
    info.roomCreateImgUrl = obj:readString() -- image
    info.curRound = obj:readByte() -- 进行到几局了
    cclog("@@@@@@@@@ " ,info.roomCreateName , info.roomState)
    cclog("@@@@@@@@@ " ,info.roomCreateImgUrl)
    -- local hasResult = obj:readByte()
    -- if hasResult == 1 then   
    --    --结算数据
    -- end
    
    --已经入的玩家数据
    info.players_data = {}
    local pnum = obj:readShort()
    cclog(" +++ p count ", pnum)
    for i=1,pnum do
        obj:readShort()
        info.players_data[#info.players_data + 1] = {}
        info.players_data[#info.players_data].id        = obj:readLong() --玩家id
        info.players_data[#info.players_data].accountid = obj:readString() --玩家账号ID
        info.players_data[#info.players_data].p_name    = obj:readString() --玩家名
    end

    -- print_r(info)
    CCXNotifyCenter:notify("rec_room_list_one",info)
end

--删除
function HallController:deleteRoomItem(roomId)
    -- print_r(roomId)
    local obj = Write.new(1102)
    obj:writeInt(roomId)
    
    obj:send()
    cclog("请求删除单条的开房数据...",roomId)
end

function HallController:onDeleteRoomItem(obj)
    local roomid = obj:readInt()
    cclog("收到服务器删除房间列表项 ", roomid)
    CCXNotifyCenter:notify("dele_roomlist_item",roomid)
end

function HallController:dimissRoom(roomId)
    -- print_r(roomId)
    local obj = Write.new(1105)
    obj:writeInt(roomId)
    
    obj:send()
    cclog("请求解散房间...",roomId)
end

function HallController:onDimissRoom(obj)
    local roomid = obj:readInt()
    cclog("收到服务器解散房间 ", roomid)
    CCXNotifyCenter:notify("onDimiss_Room",roomid)
end

function HallController:getResultData(roomId)
    -- print_r(roomId)
    local obj = Write.new(1110)
    obj:writeInt(roomId)
    
    obj:send()
    cclog("请求结算数据...",roomId)
end

function HallController:onGetResultData(obj)
    local num = obj:readShort()
    local players = {}
    for i=1,num do
        obj:readShort()
        players[#players + 1] = {}
        players[#players].playerID = obj:readLong()
        players[#players].hpcnt = obj:readShort()
        players[#players].mgcnt = obj:readShort()
        players[#players].agcnt = obj:readShort()
        players[#players].zmcnt = obj:readShort()
        players[#players].score = obj:readShort()
        players[#players].name  = obj:readString()
    end
    cclog("收到结算数据 ")
    CCXNotifyCenter:notify("onGetResult_Data",players)
end
---------------------end---------------------------
-------------------代开房间-------------------------

function HallController:createRoom(gamecnt,macnt,str)--请求创建房间
    cclog("大厅请求创建房间")
    local obj = Write.new(1002)
    obj:writeByte(gamecnt)
    obj:writeByte(macnt)
    if str then
        obj:writeString(str)
    end
    obj:send()
end

function HallController:onCreateRoom(obj)
    local res = {}
    res.serverID = obj:readInt()
    res.roomIP = obj:readString()
    --res.roomPort = obj:readInt()
    res.roomKey = obj:readString()
    res.roomId = obj:readInt()
    res.canDaiKai = obj:readBoolean()
    
    cclog("大厅请求创建房间 返回")
    CCXNotifyCenter:notify("onCreateRoom",res)
end

function HallController:gotoRoom(roomID, is_sure)--请求进入房间
    cclog("大厅请求进入房间")
    local obj = Write.new(1003)
    obj:writeInt(roomID)
    obj:writeByte( is_sure and is_sure or 0)
    obj:send()
end

function HallController:onGotoRoom(obj)
    cclog("大厅请求进入房间 返回")
	local res = {}
    res.roomIP = obj:readString()
    --res.roomPort = obj:readInt()
    res.roomKey = obj:readString()
    CCXNotifyCenter:notify("onGotoRoom",res)
end

function HallController:onSecndSureToGotoRoom(obj)
    local res = {}
    res.num = obj:readInt()
    res.desc = obj:readString()

     GlobalFun:showError2(res.desc,function ()
        HallController:gotoRoom(res.num, 1)
      end,nil,1)

    CCXNotifyCenter:notify("onSecndSureToGotoRoom",res)
end

function HallController:matchingRoom()--请求进入房间  匹配房
    local obj = Write.new(1004)
    obj:send()
end

function HallController:onCardUpdate(obj)--通知房卡更新
    cclog(" Hall Client 通知房卡更新")
    local res = {}
    res.card = obj:readInt()     --改变的卡
    res.currCard = obj:readInt() --当前卡总数
    res.type = obj:readByte() --0房卡  1金币
    
    CCXNotifyCenter:notify("onCardUpdate" , res)
end

function HallController:onMatchingRoom(obj)
    local res = {}
    res.roomIP = obj:readString()
    res.roomPort = obj:readInt()
    res.roomKey = obj:readString()
    CCXNotifyCenter:notify("onMatchingRoom",res)
end

function HallController:GetProduct()--请求获取商品列表
    local obj = Write.new(1007)
    obj:send()
end

function HallController:onGetProduct(obj)
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

function HallController:heartBeat()--心跳
    local obj = Write.new(1)
    
    obj:send()
end

function HallController:onHeartBeat(obj)--心跳
    local res = {}
    CCXNotifyCenter:notify("onHeartBeat",res)
end


function HallController:onSendFeedBack(msg)--发送反馈
    local obj = Write.new(1009)
    obj:writeString(msg) 
    
    obj:send()
end

function HallController:onNotifyString(obj)
    local res = {}
    res.msg = obj:readString()
    CCXNotifyCenter:notify("onNotifyString",res)
end

function HallController:CanShopping()
    local obj = Write.new(1011)
    obj:send()
end

function HallController:onCanShopping(obj)
    local res = {}
    res.canShop = obj:readByte()
    CCXNotifyCenter:notify("onCanShopping",res)
end

function HallController:getMatchTime()
    local obj = Write.new(1015)
    obj:send()
end

function HallController:onGetMatchTime(obj)
    local res = {}
    local days = {}
    local num = obj:readShort()
    for i=1,num do
        days[#days + 1] = obj:readString()
    end
    
    num = obj:readShort()
    local weeks = {}
    for i=1,num do
        weeks[#weeks + 1] = obj:readString()
    end
    res.days = days
    res.weeks = weeks
    return "onGetMatchTime", res
end

function HallController:onGetMatchIP(obj)
    local res = {}
    res.key = obj:readString()
    res.ips = obj:readString()
    res.isMatch = obj:readBoolean()

    -- local ip = Util.split(res.ips,";")
    -- ip = Util.split(ip[Game_conf.YYSType],":")
    -- GlobalData.roomIP = ip[1]
    -- GlobalData.roomPort = ip[2]

    local ip,port = LineMgr:useLineNumbGetIp(res.ips)
    GlobalData.roomIP = ip
    GlobalData.roomPort = port
    GlobalData.roomKey = res.key
    
    if res.isMatch then
        local function gotoMatchGame()
            GlobalData.isMatch = true
            GameClient:open(GlobalData.roomIP,GlobalData.roomPort)
        end
        GlobalFun:showError("麻将比赛正在进行,是否进入比赛?",gotoMatchGame,nil,2)
    end
end

function HallController:onNotifyBeganMatch(obj)--广播比赛开始了  是否开始比赛了
    --[[local function gotoMatchGame()
        GlobalData.isMatch = true
        GameClient:open(GlobalData.roomIP,GlobalData.roomPort)
    end]]
    --GlobalFun:showError("麻将比赛现在开始接受报名，参加比赛请到比赛大厅报名参加",nil,nil,1)
    local res = {}
    res.msg = "麻将比赛已经开始，快来参与吧.."
    CCXNotifyCenter:notify("onNotifyString",res)
end

function HallController:onServerNotifyTop(obj)--广播比赛前4的玩家
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

function HallController:checkBestRecord(id)
    local obj = Write.new(1019)
    obj:send()
end

function HallController:onCheckBestRecord(obj)--查看玩家记录
    local res = {}
    cclog("玩家记录回调")
    res.daily_game_cnt = obj:readInt()
    res.daily_best_score = obj:readInt()
    res.daily_best_rank = obj:readInt()
    
    res.binary_game_cnt = obj:readInt()
    res.binary_best_score = obj:readInt()
    res.binary_best_rank = obj:readInt()
    
    res.nba_game_cnt = obj:readInt()
    res.nba_best_score = obj:readInt()
    res.nba_best_rank = obj:readInt()
    
    CCXNotifyCenter:notify("onCheckBestRecord",res)
end

function HallController:signDailyPVE()
    local obj = Write.new(1020)
    
    obj:send()
end

function HallController:onSignDailyPVE(obj)
    CCXNotifyCenter:notify("enrollSuccess",nil)
    --local res = {}
    --CCXNotifyCenter:notify("onSignDailyPVE",res)
end

function HallController:onNotifyHallGameStart(obj)--报了名的玩家才可以收到
    local function gotoMatchGame()
        GlobalData.isMatch = true
        GlobalData.isMatchRoom = true
        GameClient:open(GlobalData.roomIP,GlobalData.roomPort)
    end
    GlobalFun:showError("麻将比赛已经开始,是否进入比赛?",gotoMatchGame,nil,2)
end

function HallController:onUpdatePeopleNum(obj)--更新报名人数
    GlobalData.MatchAllNum = obj:readInt()
    GlobalData.MatchCurrNum = obj:readInt()
    CCXNotifyCenter:notify("updatePeopleCnt",nil)
end

function HallController:submitPlayerInfo(flag,data)--上传玩家信息  flag=0上传  1查看
    local obj = Write.new(1024)
    obj:writeByte(flag)
    if flag == 0 then
        obj:writeString(data.name)
        obj:writeString(data.tel)
        obj:writeString(data.addr)
    end
    
    obj:send()
end

function HallController:onSubmitPlayerInfo(obj)
    local res = {}
    res.flag = obj:readByte()
    res.isSuccess = obj:readBoolean()
    if res.isSuccess then
        res.name = obj:readString()
        res.tel = obj:readString()
        res.addr = obj:readString()
    end
    CCXNotifyCenter:notify("onSubmitPlayerInfo",res)
end

function HallController:pveRankInfo(data)--获取玩家排名信息
    local obj = Write.new(1025)
    obj:writeByte(data.week)
    obj:writeShort(data.cnt)
    obj:writeShort(data.rankObj)
    
    obj:send()
end

function HallController:onPVERankInfo(obj)
    local res = {}
    local cnt = obj:readShort()
    res.bean = {}
    for i=1,cnt do
        obj:readShort()
        res.bean[i] = {}
        res.bean[i].id = obj:readLong()
        --res.bean[i].rank = obj:readShort()
        res.bean[i].nickname = obj:readString()
        res.bean[i].score = obj:readShort()
        res.bean[i].reward = obj:readString()
        res.bean[i].selfRank = obj:readShort()--自己的排名
    end
    CCXNotifyCenter:notify("onPVERankInfo",res)
end

function HallController:msgData()--大厅房卡消息
    local obj = Write.new(1104)
    
    obj:send()
end

function HallController:onMsgData(obj)
    local num = obj:readShort()
    cclog("************* num ", num)
    local data = {}
    for i=1,num do
        obj:readShort()
        local msg = obj:readString() -- 不能用\t
        data[#data +1] = msg
        cclog(" *********************** onMsgData ",msg)
    end
    CCXNotifyCenter:notify("onMSGData" , table.concat( data, "\n", 1, #data ))
end

function HallController:onMsgDataUpdate(obj)
    local msg = obj:readString()
    cclog(" *********************** onMsgDataUpdate ",msg)
    CCXNotifyCenter:notify("onMSGDataUpdate" , msg)
end

-- function HallController:onProtocolError(obj)--所有错误都集合到这里来
--     local res = {}
--     res.errorCode =  obj:readByte()
--     res.closeNetWork = obj:readBoolean()
--     res.msg_err = obj:readString()
    
--     local str = "错误不在错误列表里"
--     if Error_conf[res.errorCode] then
--         str = Error_conf[res.errorCode]
--     end
    
--     --res.msg_err = str .. "\n" .. res.msg_err
--     CCXNotifyCenter:notify("onProtocolError",res)
-- end

function HallController:ShiMing(reqType, data)

    local obj = Write.new(1202)

    --reqType  1获取数据  2 请求保存
    obj:writeByte( reqType)
    if reqType == 1 then
        
    elseif reqType == 2 then
        obj:writeString(data.name)
        obj:writeString(data.id)
    end

    
    obj:send()
end

function HallController:onShiMing(obj)

    local reqType = obj:readByte()
    local isSuccess = obj:readByte() == 1 and true
    GlobalData.shiming_success = isSuccess

         --reqType  1获取数据  2 请求保存
    if reqType == 1 then
        GlobalData.shiming_name = obj:readString()
        GlobalData.shiming_id = obj:readString()
    elseif reqType == 2 then
        local msg = obj:readString()
        if isSuccess then
            GlobalData.shiming_name = obj:readString()
            GlobalData.shiming_id = obj:readString()
        end
        GlobalFun:showError3(msg or "", nil, nil, 1)
    end
    
    cclog("GlobalData.shiming_success   >>>", reqType, GlobalData.shiming_success)
    CCXNotifyCenter:notify("onShiMing")
end

--============================== 俱乐部 begin ================================
--请求去俱乐部
function HallController:gotoClub(_clubID, clubSecndId)
    cclog("HallController:gotoClub >>>>")
    local obj = Write.new(1300)
    obj:writeLong( _clubID)
    obj:writeLong( clubSecndId)
    obj:send()
end

--1300
function HallController:onGotoClub(obj)

    local isCanOpenClub = obj:readBoolean()
    cclog("isCanOpenClub:"..tostring(isCanOpenClub))
    if isCanOpenClub == true then
        local host = obj:readString()
        local key = obj:readString()
        ClubManager:setInfo("clubSecndId",obj:readLong())
        cclog("wtf ClubManager:getClubSecndID():"..ClubManager:getClubSecndID())

         -- local ip,port = LineMgr:useLineNumbGetIp(host)
         -- ClubClient.ClubKey = key
         -- ClubClient.ClubIP = ip
         -- ClubClient.ClubPort = port
         -- ClubClient:open(ClubClient.ClubIP,ClubClient.ClubPort)
         -- cclog("HallController:onGotoClub >>", ClubClient.ClubKey,ClubClient.ClubIP,ClubClient.ClubPort)

         
         ex_clubHandler:connectCheck()
    else
        --创建or加入
        --GlobalFun:closeNetWorkConnect()
        --ClubClient:createAndJoinClub()
    end 

    CCXNotifyCenter:notify("HALL:onGotoClub", nil)   
end

--创建俱乐部
function HallController:toCreateClub(data)
    cclog("HallController:toCreateClub >>>>")
	--HallController:toCreateClub({clubName = "123", clubIcon = "456"})
    local obj = Write.new(1301)
	obj:writeString(data.clubName)
    obj:writeString(data.clubIcon)
    
    obj:send()

    cclog("data.clubIcon",data.clubIcon)

end

--1301
function HallController:onCreateClub(obj)
 --    local res = {}
	-- res.statusCode = obj:readByte()  --状态码 0 成功
 --    res.tipContent = obj:readString() --提示语句


 --    if res.statusCode == 2 then
 --        cclog(res.tipContent)
 --        local tb = Util.split(res.tipContent, "|")
 --        if tb and #tb == 3 then
 --            GlobalFun:showError(string.format("\t%s\n\n%s\n%s",tb[1], tb[2], tb[3]),nil,nil,2)
 --        else
 --            GlobalFun:showError("玩家必须联系客服，通过后台激活代理权限，才能创建俱乐部。",nil,nil,2)
 --        end
 --        return
 --    end




 --    if res.statusCode == 0 then
 --        res.clubID = obj:readLong()
 --        ClubManager:setInfo("clubID", res.clubID)
 --        cclog("clubID:"..res.clubID)
 --    end
 --    cclog("statusCode:"..res.statusCode.."  tipContent:"..res.tipContent)

 --    local status = res.statusCode or 1
 --    if status == 0 then--创建成功
 --        local function callBack()
 --            -- body
 --            local clubID = ClubManager:getInfo("clubID")
 --            cclog("wtf 进入俱乐部ID:"..clubID)
 --            HallController:gotoClub(tonumber(clubID))
 --        end
 --        local scene = cc.Director:getInstance():getRunningScene()
 --        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_CreateClubSuccess")
 --        scene:addChild(ui.new({app = nil, callBack = callBack, msg = res.tipContent}))
 --    else
 --        local scene = cc.Director:getInstance():getRunningScene()
 --        local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_CreateClubFail")
 --        scene:addChild(ui.new({app = nil, msg = res.tipContent}))
 --    end
 --    CCXNotifyCenter:notify("onCreateClub", res)
end

--搜索俱乐部
function HallController:toSearchClub(data)
    cclog("HallController:toSearchClub >>>>  data:"..data)
    local obj = Write.new(1302)
    obj:writeLong( data)
    
    obj:send()
end

--1302
function HallController:onSearchClub(obj)
    local res = {}
    local json = obj:readString()
    cclog("json:"..json)
    res = ex_fileMgr:loadLua("app.helper.dkjson").decode(json)
    CCXNotifyCenter:notify("onSearchClub", res)
end   

--加入俱乐部
function HallController:toJoinClub(data)
    cclog("HallController:toJoinClub >>>>  data:"..data)
    local obj = Write.new(1303)
    obj:writeLong( data)
    
    obj:send()
end

--1303
function HallController:onJoinClub(obj)
    local res = {}
	res.statusCode = obj:readByte()	--状态码 0 成功 1失败
    res.tipContent = obj:readString()	--提示语句
	cclog("statusCode:"..res.statusCode.."  tipContent:"..res.tipContent)

    local status = res.statusCode
    if status == 0 then--创建成功
        GlobalFun:showError(res.tipContent,nil,nil,2)
    else
        GlobalFun:showError(res.tipContent,nil,nil,2)
    end
    CCXNotifyCenter:notify("onJoinClub", res)
end

function HallController:toClubList()
    cclog("HallController:toClubList >>>> ")
    local obj = Write.new(1304)
    
    obj:send()
end

function HallController:onClubList(obj)
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
    --ClubClient:createAndJoinClub(res, "hall")
    res.socketType = "hall"
    CCXNotifyCenter:notify("onClubList", res)
end

--收到这个协议，就重新请求俱乐部列表
function HallController:onRequestJoinResult(obj)
    -- body
    cclog("HallController:onRequestJoinResult")
    local res = {}
    CCXNotifyCenter:notify("onRequestJoinResult", res)
end

function HallController:onYaoQingJinFangTiShi(obj)
    local res = {}
    res.clubId = obj:readLong()
    res.roomId = obj:readInt()
    res.name = obj:readString()
    res.clubName = obj:readString()

    cclog("HallController:onYaoQingJinFangTiShi>>>>")
    print_r(res)
    local function cb()
        HallController:gotoRoom(res.roomId)
    end
    ClubGlobalFun:showError(string.format("【%s】俱乐部的玩家[%s]邀请您进入房间(%s)进行游戏", res.clubName, res.name, res.roomId),cb,nil,2)

end

--收到邀请进俱乐部
function HallController:toYaoQingJinJuLeBuTiShi(_clubID, _userID, _flag) --回复同意还是拒绝
    cclog("HallController:toYaoQingJinJuLeBuTiShi >>>> _flag:".._flag)
    local obj = Write.new(1310)
    obj:writeLong( _clubID)
    obj:writeLong( _userID)
    obj:writeInt( _flag)
    
    obj:send()
end

function HallController:onYaoQingJinJuLeBuTiShi(obj)
    cclog("HallController:onYaoQingJinJuLeBuTiShi")
    local res = {}
    res.clubName = obj:readString()
    res.clubID = obj:readLong()
    res.userName = obj:readString()
    res.userID = obj:readLong()
    res.address = obj:readString()
    res.socketType = "Hall"
    
    print_r(res)
    ClubGlobalFun:showInviteMsg(res)
end

------ h5支付 获取
function HallController:h5Pay(paymode , goodsid)
    local obj = Write.new(1145)
    obj:writeInt(goodsid)    -- 商品ID
    obj:writeString(paymode) -- 支付模式 "WXPAY" or "ALIPAY"
    
    obj:send()
end

function HallController:onH5Pay(obj)
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

return HallController







