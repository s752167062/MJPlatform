--ex_fileMgr:loadLua("app.views.LoginLogic")

HallClient = {}

HallClient.server = nil

HallClient.isCloseActive = false

HallClient.gamePassToken = ""--游戏服passToken

HallClient.hbScheduler = nil
HallClient.hbSec = 0
HallClient.isHbReach = false

HallClient.socketT = 0
HallClient.socketScheduler = nil
HallClient.socketState = 0

function HallClient:startSocketListen()
    -- if HallClient.socketScheduler then
    --     HallClient:closeSocketListen()
    -- end
    -- HallClient.socketT = 0
    -- HallClient.socketScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(t)  
    --     HallClient.socketT = HallClient.socketT + t
    --     if HallClient.socketT > 1 and HallClient.socketT < 1.3 then
    --         cclog("时间时间 状态:" .. HallClient.socketState)
    --     end
    --     if HallClient.socketT > 10 then
    --         cclog("超时-----------------------")
    --         if GlobalData.HallRetryCnt > 6 then
    --             if HallClient.server then
    --                 HallClient:close()
    --             end
    --             local function dealErr()
    --                 GlobalData.HallRetryCnt = 0
    --                 GlobalFun:closeNetWorkConnect()
    --                 if GlobalData.curScene == SceneType_Login then
    --                     CCXNotifyCenter:notify("ShowWecharLoginBtn",true)
    --                 else
    --                     CCXNotifyCenter:notify("gotoLogin",nil)
    --                 end
    --             end
    --             GlobalFun:showError("网络故障，请检查网络重试",dealErr,nil,1)
    --         else
    --             self:onClose()
    --         end
    --         --HallClient:cleanRetrySchedule()
    --         HallClient:closeSocketListen()
    --     end
    -- end,0,false)
end

function HallClient:closeSocketListen()
    -- if HallClient.socketScheduler ~= nil then
    --     cc.Director:getInstance():getScheduler():unscheduleScriptEntry(HallClient.socketScheduler)
    --     HallClient.socketScheduler = nil
    -- end
end

function HallClient:open(ip, port)
    
    -- if HallClient.server then
    --     HallClient:close()
    -- end
    -- -- 连接网络
    -- HallClient.isCloseActive = false
    -- HallClient.server = GameNet:create(HallClientController)
    -- HallClient.server.listener[self] = self

    -- cclog("HallClient: try to connect " .. ip .. ":" .. port)
    -- HallClient.server:open(ip,port)
    -- HallClient.socketState = 0
    -- HallClient:startSocketListen()
end

function HallClient:close()
    -- cclog(" HallClient close ********** ")
    -- if HallClient.server ~= nil then
    --     HallClient.isCloseActive = true
    --     HallClient.server:close()
    --     HallClient.server = nil
    -- end
    -- CCXNotifyCenter:unListenByObj(self)
end

function HallClient:onOpen(gn)
    -- cclog("HallClient opened ")
    -- ex_hallHandler:sendSid()
end

function HallClient:onClose(gn) 
    -- cclog(" HallClient onclose ********** ")
    -- local function reConnect()
    --     cclog("尝试重连...")

    --     if GlobalData.HallRetryCnt > 0 then
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

    --     if HallClient.server == nil then
    --         LineMgr:getLine()
    --         LoginLogic:onStart()
    --     end

    -- end
    -- if HallClient.server ~= nil then
    --     if HallClient.isCloseActive == true then
    --         cclog("close connection: HallClient")
    --         --HallClient.isCloseActive = false
    --         HallClient:stopHeartBeat()
    --         HallClient.server.listener[self] = nil

    --         HallClient:close()
    --         HallClient.server = nil
    --     else
    --         cclog("lose connection: HallClient")
    --         CCXNotifyCenter:notify("onHallTryConnect",nil)
    --         HallClient:stopHeartBeat()
    --         HallClient.server.listener[self] = nil
    --         HallClient:close()
    --         HallClient.server = nil

    --         local function gotoLogin()
    --             CCXNotifyCenter:notify("gotoLogin",nil)
    --             GlobalData.HallRetryCnt = 0
    --         end
    --         if GlobalData.HallRetryCnt > 6 then
    --             HallClient:closeSocketListen()
    --             GlobalFun:closeNetWorkConnect()
    --             GlobalFun:showError("网络故障，请检查网络重试",gotoLogin,nil,1)
    --         else
    --             reConnect()
    --         end
    --         GlobalData.HallRetryCnt = GlobalData.HallRetryCnt + 1
    --     end
    -- else
    --     reConnect()
    --     GlobalData.HallRetryCnt = GlobalData.HallRetryCnt + 1
    -- end
end

function HallClient:cleanRetrySchedule()
    -- if HallClient.retryScheduler then
    --     cc.Director:getInstance():getScheduler():unscheduleScriptEntry(HallClient.retryScheduler)
    --     HallClient.retryScheduler = nil
    -- end
end

function HallClient:startHeartBeat()
    -- local function requestHeartBeat()

    --     ex_hallHandler:heartBeat()

    -- end

    -- if HallClient.server == nil then
    --     return
    -- end
    -- if HallClient.hbScheduler ~= nil then
    --     cclog("heart beat have started")
    --     return 
    -- end
    -- --requestHeartBeat()
    -- HallClient.isHbReach = false
    -- HallClient.hbSec = 0
    -- HallClient.hbScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(t)  
    --     if Game_conf.HeartBeatSec - HallClient.hbSec <= 0 then

            
            
    --         if HallClient.server == nil then
    --             HallClient:stopHeartBeat()
    --             return
    --         end
    --         HallClient.hbSec = 0
    --         requestHeartBeat()
    --         --cclog("请求心跳")
    --         --cpp_net_close(HallClient.server.sid)
    --     end
    --     HallClient.hbSec = HallClient.hbSec + 1
    -- end,1,false)
end
function HallClient:onHeartBeat(res)
    -- CCXNotifyCenter:notify("onHallHeart",nil)
end

function HallClient:onConnectCheck(res)
    
end

function HallClient:onCreateRoom(res)
    cclog("服务器创建成功回调")
--     -- GlobalData.serverID = res.serverID
--     -- local ip = Util.split(res.roomIP,";")
--     -- GlobalData.lineNet = res.roomIP--ip[1] .. ";" .. ip[2]
--     -- ip = Util.split(ip[Game_conf.YYSType],":")
--     -- GlobalData.roomIP = ip[1]--res.roomIP
--     -- GlobalData.roomPort = ip[2]--res.roomPort
--     -- GlobalData.roomKey = res.roomKey
--     -- if Game_conf.YYSType == 4 and Game_conf.isWX  then
--     --     GlobalData.roomIP = GlobalFun:getYunIP()
--     -- end
-- --    cclog("GO YUN ROOM onCreateRoom ".. GlobalData.roomIP);
    
--     -- cclog("roomIP " .. GlobalData.roomIP .. "  roomPort " .. GlobalData.roomPort)
--     -- GameClient:open(GlobalData.roomIP,GlobalData.roomPort)

--     GlobalData.connectRoomCNT = nil
--     GlobalData.connectRoomZhaMa = nil

--     GlobalFun:closeNetWorkConnect()
--     CCXNotifyCenter:notify("ProtocolSuccess",nil)
--     CCXNotifyCenter:notify("create_room_success",res)
--     CCXNotifyCenter:notify("createRoomCallback",nil)
end

function HallClient:onGotoRoom(res)
--     CCXNotifyCenter:notify("RoomNumberUISocketT",nil)
--     -- local ip = Util.split(res.roomIP,";")
--     -- GlobalData.lineNet = res.roomIP--ip[1] .. ";" .. ip[2]
--     -- ip = Util.split(ip[Game_conf.YYSType],":")
--     -- GlobalData.roomIP = ip[1]--res.roomIP
--     -- GlobalData.roomPort = ip[2]--res.roomPort


--     local ip,port = LineMgr:useLineNumbGetIp(res.roomIP)
--     GlobalData.roomIP = ip
--     GlobalData.roomPort = port
--     GlobalData.roomKey = res.roomKey
--     -- if Game_conf.YYSType == 4 and Game_conf.isWX  then
--     --     GlobalData.roomIP =  GlobalFun:getYunIP()
--     -- end
-- --    cclog("GO YUN onGotoRoom ".. GlobalData.roomIP);
    
--     GameClient:open(GlobalData.roomIP,GlobalData.roomPort)

--     --self:removeFromParentAndCleanup(true)
end

function HallClient:onReConnectCheck(res)
    -- if res._ok == false then
    --     self:close()
    -- end
end

function HallClient:onProtocolError(res)
    cclog("HallClient:onProtocolError >>>>>")
    print_r(res)
    GlobalFun:closeNetWorkConnect()
    
    -- HallClient:closeSocketListen()
    -- CCXNotifyCenter:notify("RoomNumberUISocketT",nil)
    if res.closeNetWork then
        -- CCXNotifyCenter:notify("onHallTryConnect",nil)
        -- self:close()
    end
    cclog("error   " , res.msg_err )
    cclog("error code " ,res.errorCode )
    -- if res.errorCode == 3  and GlobalData.isRoomToHall then--密匙错误不弹提示
    if res.errorCode == 3 then
        -- if GlobalData.isMatchRoom then
        --     CCXNotifyCenter:notify("gotoLogin",nil)
        -- end
        return
    end
    if res.errorCode == 46 then 
        --创建房间达上限 
        GlobalData.connectRoomCNT = nil
        GlobalData.connectRoomZhaMa = nil
        -- CCXNotifyCenter:notify("createRoomCallback",nil)
    end    
    
    local function gotoLogin()
        -- CCXNotifyCenter:notify("gotoLogin",nil)

        platformExportMgr:returnAppPlatform()
        GlobalData.HallRetryCnt = 0
    end
    
    local function shouldExit()
        --cc.Director:getInstance():endToLua()
        os.exit(0)
    end
    
    local func = nil
    if (res.errorCode == 3 or res.errorCode == 17) or res.closeNetWork then
        func = gotoLogin
    end
    if res.errorCode == 24 then
        func = shouldExit
    end
    
  
    if func == nil then
        GlobalFun:showToast(res.msg_err , Game_conf.TOAST_SHORT)
    else
        GlobalFun:showError(res.msg_err,func,nil,1)
    end
end

function HallClient:stopHeartBeat()
    -- if HallClient.hbScheduler ~= nil then
    --     cc.Director:getInstance():getScheduler():unscheduleScriptEntry(HallClient.hbScheduler)
    --     HallClient.hbScheduler = nil
    -- end
    
end

