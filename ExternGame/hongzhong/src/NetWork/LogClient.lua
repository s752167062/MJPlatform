LogClient = {}

LogClient.server = nil

LogClient.isCloseActive = false

LogClient.gamePassToken = ""--游戏服passToken

LogClient.hbScheduler = nil
LogClient.hbSec = 0
LogClient.isHbReach = false

function LogClient:open(ip, port)
    -- if LogClient.server then
    --     LogClient:close()
    -- end
    -- -- 连接网络

    -- LogClient.server = GameNet:create(LogController)
    -- LogClient.server.listener[self] = self

    -- cclog("GameClient: try to connect " .. ip .. ":" .. port)
    -- LogClient.server:open(ip,port)
end

function LogClient:close()
    -- if LogClient.server ~= nil then
    --     LogClient.isCloseActive = true
    --     LogClient.server:close()
    -- end
    -- CCXNotifyCenter:unListenByObj(self)
end

function LogClient:onOpen(gn)
    -- cclog("GameClient opened ")
    -- LogClient.isCloseActive = false
    -- ex_roomHandler:sendSid()
end

function LogClient:onClose(gn) 
    -- if LogClient.server ~= nil then
    --     if LogClient.isCloseActive == true then
    --         cclog("close connection: GameClient")

    --         LogClient.server.listener[self] = nil
    --         LogClient.server = nil
    --     else
    --         cclog("lose connection: GameClient")
    --         CCXNotifyCenter:notify("onGameTryConnect",nil)
    --         LogClient:stopHeartBeat()
    --         LogClient.server.listener[self] = nil
    --         LogClient.server = nil
    --         LogClient.isCloseActive = true
    --         LogClient:closeNetWorkConnect()
    --         --[[
    --         local function gotoLogin()
    --             CCXNotifyCenter:notify("gotoLogin",nil)
    --         end
    --         GlobalFun:showNetWorkConnect("正在重新连接游戏…")

    --         if GlobalData.RoomRetryCnt == 0 then
    --             GlobalData.isRetryConnect = true
    --             GlobalData.RoomRetryCnt = GlobalData.RoomRetryCnt + 1
    --             LogClient:open(GlobalData.roomIP,GlobalData.roomPort)
    --             LogClient.retryScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(t)  

    --                     if GlobalData.RoomRetryCnt > 7 then
    --                         LogClient:cleanRetrySchedule()
    --                         GlobalFun:showError("网络故障，请检查网络重试",gotoLogin,nil,1)
    --                     else
    --                         cclog("尝试重连...")
    --                         if LogClient.server == nil then
    --                             LogClient:open(GlobalData.roomIP,GlobalData.roomPort)                                
    --                         end
    --                     end
    --                     GlobalData.RoomRetryCnt = GlobalData.RoomRetryCnt + 1
    --             end,5,false)
    --         end
    --         ]]
    --     end
    -- end
end

function LogClient:cleanRetrySchedule()
    -- if LogClient.retryScheduler then
    --     cc.Director:getInstance():getScheduler():unscheduleScriptEntry(LogClient.retryScheduler)
    --     LogClient.retryScheduler = nil
    -- end
end

function LogClient:startHeartBeat()

    -- local function requestHeartBeat()
    --     cclog("心跳发送")
    --     LogController.heartBeat()
    -- end

    -- if LogClient.server == nil then
    --     return
    -- end
    -- if LogClient.hbScheduler ~= nil then
    --     cclog("heart beat have started")
    --     return 
    -- end
    -- --requestHeartBeat()
    -- LogClient.isHbReach = false
    -- LogClient.hbSec = 0
    -- LogClient.hbScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(t)  
    --     if 40 - LogClient.hbSec <= 0 then
    --         if LogClient.server == nil then
    --             LogClient:stopHeartBeat()
    --             return
    --         end
    --         LogClient.hbSec = 0
    --         requestHeartBeat()
    --         cclog("请求心跳")

    --     end
    --     LogClient.hbSec = LogClient.hbSec + 1
    -- end,1,false)

end

function LogClient:onHeartBeat(res)
    -- cclog("当前时间:" .. os.date("%H:%M"))
end

function LogClient:stopHeartBeat()
    -- if LogClient.hbScheduler ~= nil then
    --     cc.Director:getInstance():getScheduler():unscheduleScriptEntry(LogClient.hbScheduler)
    --     LogClient.hbScheduler = nil
    -- end

end

function LogClient:onProtocolError(res)
    -- if res.closeNetWork then
    --     LogClient:cleanRetrySchedule()
    --     self:close()
    -- end
end

