--@游戏启动配置
--@Author   sunfan
--@date     2018/04/27
local GameStar = class("GameStar")
function GameStar:ctor(params)
    local function registerGlobal()
        --文件管理类
        ex_fileMgr = lua_load("ctrls.FileMgr").new()
        --计时器管理类
        ex_timerMgr = ex_fileMgr:loadLua("ctrls.TimerMgr").new()
       
        --场景管理类
        ex_gameStateMgr = ex_fileMgr:loadLua("ctrls.GameStateMgr").new(ex_fileMgr:loadLua("app.MyApp"):create())
        
        ex_hallHandler = ex_fileMgr:loadLua("ctrls.socket.HallController").new()
        ex_roomHandler = ex_fileMgr:loadLua("ctrls.socket.ClientController").new()
        ex_clubHandler = ex_fileMgr:loadLua("ctrls.socket.ClubController").new()

        --接收回调
        ex_handlerMgr = ex_fileMgr:loadLua("ctrls.socket.HandlerManager"):new()

        ex_fileMgr:loadLua("ctrls.requireList")
         --声音管理类
        ex_audioMgr = ex_fileMgr:loadLua("ctrls.AudioMgr").new()
    end

    print("hongzhong gamestart >>>>>>>>>>>>>>")
    --注册玩法内全局变量
    platformExportMgr:registerGlobal(registerGlobal)
    platformExportMgr:registExternGameReceiveProtocol(ex_handlerMgr)



    platformExportMgr:registerListenerEvent(platformExportMgr.Events_WillEnterForeground, GlobalFun, GlobalFun.applicationWillEnterForeground)
    platformExportMgr:registerListenerEvent(platformExportMgr.Events_DidEnterBackground , GlobalFun, GlobalFun.applicationDidEnterBackground)
    platformExportMgr:registerListenerEvent(platformExportMgr.Events_AppPause , GlobalFun, GlobalFun.onGamePause)
    platformExportMgr:registerListenerEvent(platformExportMgr.Events_AppResume , GlobalFun, GlobalFun.onGameResume)


    dump(params)
    -- GlobalData.HallKey = params.key
    -- GlobalData.roomKey
    -- ClubClient.ClubKey

    Game_conf.Base_Version = params.version
    PlayerInfo.playerAccountID = platformExportMgr:doGameConfMgr_getInfo("account")
    PlayerInfo.playerUserID = params.userId
    PlayerInfo.nickname = platformExportMgr:doGameConfMgr_getInfo("playerName")
    PlayerInfo.headimgurl = platformExportMgr:doGameConfMgr_getInfo("playerHeadURL")
    --开始连接玩法服务器
    ex_handlerMgr:startConnect()
end

return GameStar
