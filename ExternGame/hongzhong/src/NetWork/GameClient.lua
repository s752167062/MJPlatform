--ex_fileMgr:loadLua("app.views.LoginLogic")

GameClient = {}

GameClient.server = nil

GameClient.isCloseActive = false

GameClient.gamePassToken = ""--游戏服passToken

GameClient.hbScheduler = nil
GameClient.hbSec = 0
GameClient.isHbReach = false

GameClient.socketT = 0
GameClient.socketScheduler = nil
GameClient.socketState = 0

function GameClient:startSocketListen()
    -- if GameClient.socketScheduler then
    --     GameClient:closeSocketListen()
    -- end
    -- GameClient.socketT = 0
    -- local ccx = cc.Director:getInstance():getRunningScene():getChildByTag(NETConnect_TAG)
    -- if ccx == nil then
    --     GlobalFun:showNetWorkConnect("正在直连房间...")
    -- end
    -- cclog("开启网络监听....")
    -- GameClient.socketScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(t)  
    --     GameClient.socketT = GameClient.socketT + t
    --     if GameClient.socketT > 1 and GameClient.socketT < 1.3 then
    --         cclog("时间时间 状态:" .. GameClient.socketState .. "      时间：" .. GameClient.socketT)
    --     end
    --     cclog("时间时间 状态:" .. GameClient.socketState .. "      时间：" .. GameClient.socketT)
    --     if GameClient.socketT > 8 then
    --         cclog("超时-----------------------")
    --         if GlobalData.RoomRetryCnt > 6 then
    --             if GameClient.server then
    --                 GameClient:close()
    --             end
    --             local function dealErr()
    --                 GlobalData.RoomRetryCnt = 0
    --                 GlobalFun:closeNetWorkConnect()
    --                 CCXNotifyCenter:notify("gotoLogin",nil)
    --             end
    --             GlobalFun:showError("网络故障，请检查网络重试",dealErr,nil,1)
    --         else
    --             self:onClose()
    --         end
    --         GameClient:closeSocketListen()
    --     end
    -- end,0,false)
end

function GameClient:closeSocketListen()
    -- if GameClient.socketScheduler ~= nil then
    --     cc.Director:getInstance():getScheduler():unscheduleScriptEntry(GameClient.socketScheduler)
    --     GameClient.socketScheduler = nil
    -- end
end

function GameClient:open(ip, port)
    -- if GameClient.server then
    --     GameClient:close()
    -- end
    -- -- 连接网络
    -- GameClient.isCloseActive = false

    -- GameClient.server = GameNet:create(ClientController)
    -- GameClient.server.listener[self] = self

    -- cclog("GameClient: try to connect " .. ip .. ":" .. port)
    -- --GameClient.server:open("120.76.208.34",9529)
    -- GameClient.server:open(ip,port)
    -- GameClient.socketState = 0
    -- GameClient:startSocketListen() 
end

function GameClient:close()
    -- if GameClient.server ~= nil then
    --     GameClient.isCloseActive = true
    --     GameClient.server:close()
    -- end
    -- CCXNotifyCenter:unListenByObj(self)
end

function GameClient:onOpen(gn)
    -- cclog("GameClient opened ")
    -- ex_roomHandler:sendSid()
end

function GameClient:onClose(gn)
    -- local function reConnect()
    --     cclog("尝试重连...")
    --     if GameClient.server == nil then
    --         GlobalData.roomIP = LineMgr:getRoomLine()
    --         GameClient:open(GlobalData.roomIP,GlobalData.roomPort)
    --     end

        
    --     if GlobalData.RoomRetryCnt > 0 then
    --         local msg = "您的网络不稳定，正在重新连接"
        
    --         if Game_conf.YYSType == 1 then
    --             msg = msg .. "(1)"
    --         elseif Game_conf.YYSType == 2 then
    --             msg = msg .. "(2)"
    --         elseif Game_conf.YYSType == 3 then
    --             msg = msg .. "(3)"
    --         else
    --             msg = msg .. "(4)"
    --         end
    --         GlobalFun:showNetWorkConnect(msg)
    --     else
    --         GlobalFun:showNetWorkConnect("正在重新连接游戏…" .. "(" .. tostring(Game_conf.YYSType) ..")" )
    --     end
    -- end
    -- if GameClient.server ~= nil then
    --     if GameClient.isCloseActive == true then
    --         cclog("close connection: GameClient")
    --         GameClient:stopHeartBeat()
    --         GameClient.server.listener[self] = nil
    --         GameClient.server:close()
    --         GameClient.server = nil
    --     else
    --         cclog("lose connection: GameClient------------------------------")
    --         CCXNotifyCenter:notify("onGameTryConnect",nil)
    --         GameClient:stopHeartBeat()
    --         GameClient.server.listener[self] = nil
    --         GameClient.server:close()
    --         GameClient.server = nil

    --         --GlobalFun:closeNetWorkConnect()
    --         local function gotoLogin()
    --             CCXNotifyCenter:notify("gotoLogin",nil)
    --             GlobalData.RoomRetryCnt = 0
    --         end
    --         if GameClient.socketT > 6 or GameClient.socketScheduler == nil then
    --             GlobalData.RoomRetryCnt = GlobalData.RoomRetryCnt + 1
    --         end
    --         if GlobalData.RoomRetryCnt >  6 then
    --             GameClient:closeSocketListen()
    --             GlobalFun:closeNetWorkConnect()
    --             GlobalFun:showError("网络故障，请检查网络重试",gotoLogin,nil,1)
    --         else
    --             if GameClient.socketT > 6 or GameClient.socketScheduler == nil then
    --                 reConnect()
    --             end
    --         end
    --     end
    -- else
    --     if GameClient.socketT > 6 or GameClient.socketScheduler == nil then
    --         reConnect()
    --         GlobalData.RoomRetryCnt = GlobalData.RoomRetryCnt + 1
    --     end
    -- end
end

function GameClient:cleanRetrySchedule()
    -- if GameClient.retryScheduler then
    --     cc.Director:getInstance():getScheduler():unscheduleScriptEntry(GameClient.retryScheduler)
    --     GameClient.retryScheduler = nil
    -- end
end

function GameClient:openWithUserVersion(ip, port, callback)
    -- GameClient:open(ip, port, function(flag)
    --     if flag == true then
    --         CCXNotifyCenter:listen(self,function(obj, key, data) 
    --             if callback ~= nil then
    --                 callback(data[1])
    --             end
    --         end,"gameClient_platVersion")
    --         local obj = ex_roomHandler:UserVersion(Game_conf.version .. "." .. ex_roomHandler:getProtocol())
    --         GameClient.server:send(obj)
    --     else
    --         if callback ~= nil then
    --             callback(flag)
    --         end
    --     end

    -- end)
end

function GameClient:onUserVersion(res)
    -- cclog("onUserVersion")
    -- if res._ok== 1 then
    --     CCXNotifyCenter:notify("gameClient_platVersion",{true})
    -- else
    --     cclog("onUserVersion error, _ok:" .. res._ok)
    --     if res._errorMsg ~= nil then
    --         cclog("err:" .. res._errorMsg)
    --     end
    --     CCXNotifyCenter:notify("gameClient_platVersion",{false})
    -- end    
    -- CCXNotifyCenter:unListen(self,"gameClient_platVersion")
end

function GameClient:startHeartBeat()

    -- local function requestHeartBeat()
    --     cclog("心跳发送")
    --     ex_roomHandler:heartBeat()
    -- end

    -- if GameClient.server == nil then
    --     return
    -- end
    -- if GameClient.hbScheduler ~= nil then
    --     cclog("heart beat have started")
    --     return 
    -- end
    -- --requestHeartBeat()
    -- GameClient.isHbReach = false
    -- GameClient.hbSec = 0
    -- GameClient.hbScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(t)  
    --     if Game_conf.HeartBeatSec - GameClient.hbSec <= 0 then
    --         if GameClient.server == nil then
    --             GameClient:stopHeartBeat()
    --             return
    --         end
    --         GameClient.hbSec = 0
    --         requestHeartBeat()
    --         cclog("请求心跳")

    --     end
    --     GameClient.hbSec = GameClient.hbSec + 1
    -- end,1,false)
    
end

function GameClient:onHeartBeat(res)
    -- cclog("当前时间:" .. os.date("%H:%M"))
    -- CCXNotifyCenter:notify("onGameHeart",nil)
end

function GameClient:stopHeartBeat()
    -- if GameClient.hbScheduler ~= nil then
    --     cc.Director:getInstance():getScheduler():unscheduleScriptEntry(GameClient.hbScheduler)
    --     GameClient.hbScheduler = nil
    -- end
    
end

function GameClient:onReqEnterRoom(res)
    -- GameClient:startHeartBeat()
    -- GlobalData.RoomRetryCnt = 0
    -- GameClient:cleanRetrySchedule()
    -- GameClient:closeSocketListen()
    GlobalData.connectRoomCNT = nil
    GlobalData.connectRoomZhaMa = nil
    GlobalData.connectRoomNumber = nil

    if GlobalData.curScene == SceneType_Hall then --如果在大厅里
        GlobalData.roomData = res
        CCXNotifyCenter:notify("AcceptRoom",nil)
        
    elseif GlobalData.curScene == SceneType_Login then
        GlobalData.roomData = res
        CCXNotifyCenter:notify("AcceptRoom",nil)
    elseif GlobalData.curScene == SceneType_Match then
        GlobalData.roomData = res
        CCXNotifyCenter:notify("gotoMatchScene",nil)
    elseif GlobalData.curScene == SceneType_Club then
        GlobalData.roomData = res
        CCXNotifyCenter:notify("AcceptRoom",nil)
    else
        GlobalData.roomData = res
        ex_gameStateMgr:changeState(ex_gameStateMgr.GAMESTATE.STATE_ROOM)
        CCXNotifyCenter:notify("RetryGame",nil)
        CCXNotifyCenter:notify("onUserEnterRoom",res)
    end
    GlobalData.isMatch = nil
end

function GameClient:onProtocolError(res)
    cclog("GameClient:onProtocolError >>>>>")
    print_r(res)
    GlobalFun:closeNetWorkConnect()
    
    GlobalData.connectRoomCNT = nil
    GlobalData.connectRoomZhaMa = nil
    GlobalData.connectRoomNumber = nil
    -- GameClient:closeSocketListen()
    --GlobalData.isMatchRoom = false
    if res.closeNetWork then
        -- GameClient:cleanRetrySchedule()
        -- self:close()
    end
    if res.errorCode == 13 then
        CCXNotifyCenter:notify("IllegalOutCart",nil)
    end

    if res.errorCode == 2 then
        GlobalData.connectRoomNumber = nil
        GlobalData.hasTry = true
        -- LoginLogic:onStart()
        platformExportMgr:returnAppPlatform()
    end 

    if res.errorCode == 5 and GlobalData.isRetryConnect then--房间不存在
        --重连的时候
        GlobalData.connectRoomNumber = nil
        GlobalData.hasTry = true
        -- LoginLogic:onStart()
        platformExportMgr:returnAppPlatform()
        return
    end
    local function gotoLogin()
        -- CCXNotifyCenter:notify("gotoLogin",nil)

        platformExportMgr:returnAppPlatform()
    end

    local function shouldExit()
        --cc.Director:getInstance():endToLua()
        os.exit(0)
    end
    
    local function gotoHall()
        -- GlobalData.isRoomToHall = true
        -- LoginLogic:onStart()
        platformExportMgr:returnAppPlatform()
    end
    
    local func = nil
    if res.errorCode == 3 then
        func = gotoLogin
    end
    
    if res.errorCode == 9 and GlobalData.curScene == SceneType_Game then
        func = gotoHall
    end
    
    if res.errorCode == 24 then
        func = shouldExit
    end



    cclog("error   " .. res.msg_err)
    cclog("errorCode   " .. res.errorCode)

    if func == nil then
        GlobalFun:showToast(res.msg_err , Game_conf.TOAST_SHORT)
    else
        GlobalFun:showError(res.msg_err,func,nil,1)
    end
end

function GameClient:onEnterRoomAndGetRoomID(res)
    -- GlobalData.roomID = res.roomID
    -- GlobalFun:closeNetWorkConnect()
    -- HallClient:close()
    -- CCXNotifyCenter:notify("CanEnterRoom",nil)
    -- --
end

