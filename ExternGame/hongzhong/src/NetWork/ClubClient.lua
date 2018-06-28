--ex_fileMgr:loadLua("app.views.LoginLogic")

ClubClient = {}

ClubClient.server = nil

ClubClient.isCloseActive = false

ClubClient.gamePassToken = ""--游戏服passToken

ClubClient.hbScheduler = nil
ClubClient.hbSec = 0
ClubClient.isHbReach = false

ClubClient.socketT = 0
ClubClient.socketScheduler = nil
ClubClient.socketState = 0

ClubClient.RetryCnt = 0


ClubClient.ClubKey = ""
ClubClient.ClubIP = ""
ClubClient.ClubPort = 0
-- ClubClient.ClubID = 0



PATH_CLUB_LUA = "app/views/club/"

function ClubClient:startSocketListen()
    
    -- if ClubClient.socketScheduler then
    --     ClubClient:closeSocketListen()
    -- end
    -- ClubClient.socketT = 0
    -- ClubClient.socketScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(t)  
    --     ClubClient.socketT = ClubClient.socketT + t
    --     if ClubClient.socketT > 1 and ClubClient.socketT < 1.3 then
    --         cclog("时间时间 状态:" .. ClubClient.socketState)
    --     end
    --     cclog("ClubClient >>", ClubClient.socketT)
    --     if ClubClient.socketT > 8 then
    --         cclog("超时-----------------------")
    --         if ClubClient.RetryCnt > 4 then
    --             if ClubClient.server then
    --                 ClubClient:close()
    --             end
    --             local function dealErr()
    --                 ClubClient.RetryCnt = 0
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
    --         --ClubClient:cleanRetrySchedule()
    --         ClubClient:closeSocketListen()
    --     end
    -- end,0,false)
end

function ClubClient:closeSocketListen()
    -- if ClubClient.socketScheduler ~= nil then
    --     cclog("lubClient:closeSocketListen >>>>")
    --     -- cclog(debug.traceback())
    --     cc.Director:getInstance():getScheduler():unscheduleScriptEntry(ClubClient.socketScheduler)
    --     ClubClient.socketScheduler = nil
    -- end
end

function ClubClient:open(ip, port)
    
    -- if ClubClient.server then
    --     ClubClient:close()
    -- end
    -- -- 连接网络
    -- ClubClient.isCloseActive = false
    -- ClubClient.server = GameNet:create(ClubController)
    -- ClubClient.server.listener[self] = self

    -- cclog("ClubClient: try to connect " .. ip .. ":" .. port)
    -- ClubClient.server:open(ip,port)
    -- ClubClient.socketState = 0
    -- ClubClient:startSocketListen()
end

function ClubClient:createAndJoinClub(_data, _type)
    --打开创建界面,获取当前scene
    -- local scene = cc.Director:getInstance():getRunningScene()
    -- local ui = ex_fileMgr:loadLua(PATH_CLUB_LUA.."UI_ClubEntry")
    -- _data.app = nil
    -- _data.socketType = _type
    -- scene:addChild(ui.new(_data))
end

function ClubClient:close()
    -- cclog(" ClubClient close ********** ")
    -- if ClubClient.server ~= nil then
    --     ClubClient.isCloseActive = true
    --     ClubClient.server:close()
    --     ClubClient.server = nil
    -- end
    -- CCXNotifyCenter:unListenByObj(self)
end

function ClubClient:onOpen(gn)
    -- cclog("ClubClient opened ")
    -- ex_clubHandler:sendSid()
    -- ClubClient:startSocketListen()
end

function ClubClient:onClose(gn) 
    -- cclog(" ClubClient onclose ********** ")
    -- local function reConnect()
    --     cclog("尝试重连...")

    --      if ClubClient.server == nil then
    --         ClubClient.ClubIP = LineMgr:getClubLine()
    --         ClubClient:open(ClubClient.ClubIP,ClubClient.ClubPort)
    --     end

    --     if ClubClient.RetryCnt > 0 then
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
    
    -- if ClubClient.server ~= nil then
    --     if ClubClient.isCloseActive == true then
    --         cclog("close connection: ClubClient")
    --         --ClubClient.isCloseActive = false
    --         ClubClient:stopHeartBeat()
    --         ClubClient.server.listener[self] = nil

    --         ClubClient:close()
    --         ClubClient.server = nil
    --     else
    --         cclog("lose connection: ClubClient")
    --         CCXNotifyCenter:notify("onClubTryConnect",nil)      
    --         ClubClient:stopHeartBeat()
    --         ClubClient.server.listener[self] = nil
    --         ClubClient:close()
    --         ClubClient.server = nil

    --         -- if ClubClient.socketT > 3 or ClubClient.socketScheduler == nil then
    --             ClubClient.RetryCnt = ClubClient.RetryCnt + 1
    --         -- end

    --         local function gotoLogin()
    --             CCXNotifyCenter:notify("gotoLogin",nil)
    --             ClubClient.RetryCnt = 0
    --         end
    --         if ClubClient.RetryCnt > 4 then
    --             ClubClient:closeSocketListen()
    --             GlobalFun:closeNetWorkConnect()
    --             GlobalFun:showError("网络故障，请检查网络重试",gotoLogin,nil,1)
    --         else
    --             reConnect()
    --         end
    --         -- ClubClient.RetryCnt = ClubClient.RetryCnt + 1
    --     end
    -- else
    --     reConnect()
    --     ClubClient.RetryCnt = ClubClient.RetryCnt + 1
    -- end
end

-- function ClubClient:cleanRetrySchedule()
--     if ClubClient.retryScheduler then
--         cc.Director:getInstance():getScheduler():unscheduleScriptEntry(ClubClient.retryScheduler)
--         ClubClient.retryScheduler = nil
--     end
-- end

function ClubClient:startHeartBeat()
    -- local function requestHeartBeat()

    --     ex_clubHandler:heartBeat()

    -- end

    -- if ClubClient.server == nil then
    --     return
    -- end
    -- if ClubClient.hbScheduler ~= nil then
    --     cclog("heart beat have started")
    --     return 
    -- end

    -- ClubClient.isHbReach = false
    -- ClubClient.hbSec = 0
    -- ClubClient.hbScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(t)  
    --     if Game_conf.HeartBeatSec - ClubClient.hbSec <= 0 then

            
            
    --         if ClubClient.server == nil then
    --             ClubClient:stopHeartBeat()
    --             return
    --         end
    --         ClubClient.hbSec = 0
    --         requestHeartBeat()

    --     end
    --     ClubClient.hbSec = ClubClient.hbSec + 1
    -- end,1,false)
end
function ClubClient:onHeartBeat(res)
    -- CCXNotifyCenter:notify("onClubHeart",nil)    
end

function ClubClient:onConnectCheck(res)
    cclog("ClubClient:onConnectCheck")
    -- ClubClient:startHeartBeat()
    -- ClubClient.RetryCnt = 0
    GlobalFun:closeNetWorkConnect()

    ex_fileMgr:loadLua("app.views.club.ClubChatMgr")
    ClubChatMgr:init()
    

    if GlobalData.curScene == SceneType_Game then
        -- if GlobalData.suammaryToHall == false then
            CCXNotifyCenter:notify("closeServerRoom",res)
        -- else
            -- GlobalData.suammaryToHall = false
        -- end
    end


    if GlobalData.curScene == SceneType_Club then
        CCXNotifyCenter:notify("ClubClient.onConnectCheck--reConnect",nil)
    else
        ex_gameStateMgr:changeState(ex_gameStateMgr.GAMESTATE.STATE_CLUB)
    end

    -- CCXNotifyCenter:notify("canGotoClub",nil)

end



function ClubClient:onProtocolError(res)
    cclog("ClubClient:onProtocolError >>>>>>>>")
    GlobalFun:closeNetWorkConnect()
    ClubClient:closeSocketListen()
    print_r(res)

    if res.closeNetWork then
        -- ClubClient:closeSocketListen()
        -- self:close()
        return
    end


    GlobalFun:showToast(res.msg_err or "未知错误" , Game_conf.TOAST_SHORT)

    if res.errorCode == 1 then  --断了服务器通知去登陆
        ClubClient:stopHeartBeat()
        ClubClient.server.listener[self] = nil
        ClubClient:close()
        ClubClient.server = nil
        ClubClient.RetryCnt = 0
        

        GlobalFun:showError("网络故障，请检查网络重试",function()
                -- CCXNotifyCenter:notify("gotoLogin",nil)
                platformExportMgr:returnAppPlatform()
            end,nil,1)
    end

    -- -- if res.errorCode == 2 then  --断了服务器通知去大厅
    -- --     ClubClient:stopHeartBeat()
    -- --     ClubClient.server.listener[self] = nil
    -- --     ClubClient:close()
    -- --     ClubClient.server = nil
    -- --     ClubClient.RetryCnt = 0
        

    -- --     LoginLogic:onStart()
    -- -- end


    -- -- CCXNotifyCenter:notify("RoomNumberUISocketT",nil)
    -- -- if res.closeNetWork then
    -- --     CCXNotifyCenter:notify("onClubTryConnect",nil)
    -- --     self:close()
    -- -- end
    -- -- cclog("error   " , res.msg_err )
    -- -- cclog("error code " ,res.errorCode )
    -- -- if res.errorCode == 3 then--密匙错误不弹提示
        
    -- --     CCXNotifyCenter:notify("gotoLogin",nil)

    -- --     return
    -- -- end
    -- -- if res.errorCode == 46 then 
    -- --     --创建房间达上限 
    -- --     GlobalData.connectRoomCNT = nil
    -- --     GlobalData.connectRoomZhaMa = nil
    -- --     CCXNotifyCenter:notify("createRoomCallback",nil)
    -- -- end    
    
    -- -- local function gotoLogin()
    -- --     CCXNotifyCenter:notify("gotoLogin",nil)
    -- --     GlobalData.HallRetryCnt = 0
    -- -- end
    
    -- -- local function shouldExit()
    -- --     --cc.Director:getInstance():endToLua()
    -- --     os.exit(0)
    -- -- end
    
    -- -- local func = nil
    -- -- if (res.errorCode == 3 or res.errorCode == 17) or res.closeNetWork then
    -- --     func = gotoLogin
    -- -- end
    -- -- if res.errorCode == 24 then
    -- --     func = shouldExit
    -- -- end
    -- -- GlobalFun:closeNetWorkConnect()
  
    -- -- if func == nil then
    -- --     GlobalFun:showToast(res.msg_err , Game_conf.TOAST_SHORT)
    -- -- else
    -- --     GlobalFun:showError(res.msg_err,func,nil,1)
    -- -- end
end

function ClubClient:stopHeartBeat()
    -- if ClubClient.hbScheduler ~= nil then
    --     cc.Director:getInstance():getScheduler():unscheduleScriptEntry(ClubClient.hbScheduler)
    --     ClubClient.hbScheduler = nil
    -- end
    
end


function ClubClient:onGotoRoom(res)
    -- -- 不知道用不用这样写一个，这个是输入房间号请求进入房间超时判断用的，你可以搜一下
    -- -- CCXNotifyCenter:notify("RoomNumberUISocketT",nil)

    -- local ip,port = LineMgr:useLineNumbGetIp(res.roomIP)
    -- GlobalData.roomIP = ip
    -- GlobalData.roomPort = port
    -- GlobalData.roomKey = res.roomKey

    
    -- GameClient:open(GlobalData.roomIP,GlobalData.roomPort)

end






