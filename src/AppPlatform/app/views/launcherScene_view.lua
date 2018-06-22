

local LauncherScene = class("LauncherScene", cc.load("mvc").ViewBase)

LauncherScene.RESOURCE_FILENAME = __platformHomeDir .."ui/layout/LauncherScene.csb"

function LauncherScene:onCreate()

end





function LauncherScene:onEnter()
    self:init()
end

function LauncherScene:onExit()
    gameState:unlockState(GAMESTATE.STATE_UPDATE)
    self.HotUpdateManager:destroy()
end


function LauncherScene:init()
    local HotUpdateManager  = require "Manager.HotUpdateManager"
    self.HotUpdateManager = HotUpdateManager

    local managerCtrl = launcherSceneMgr:getManage()

    local update_type = managerCtrl:getUpdateType()
    local gameName = managerCtrl:getGameName()
    local ios_manifest,android_manifest = managerCtrl:getBaseManifest(gameName)
    
    local storage_path = managerCtrl:getStoragePath()
    local cur_version = managerCtrl:getCurVersion(gameName)
    local server_version, appPath, hotUpdatePath, callback = managerCtrl:getServerUpdateData()

    self.tips = self:getUIChild("tips")
    self.loadingBar = self:getUIChild("updateLoadingBar")

    self.sv = self:getUIChild("server_version")
    self.cv = self:getUIChild("cur_version")
    self.tv = self:getUIChild("target_version")
    self.sv:setString(server_version or "")
    self.cv:setString(cur_version or "")
    local function hum_callback (data) 
        self.tips:setString(data.desc or "")
        print("data.event >>>>", data.event, data.desc)
        if data.event == HU_EVENT.DESC then

        elseif data.event == HU_EVENT.TARGET_VERSION then  --即将更新的目标版本号
            -- data.version
            self.tv:setString(data.version or "")
        elseif data.event == HU_EVENT.LOGIN then
            self.loadingBar:setPercent(100)

        elseif data.event == HU_EVENT.UPDATE_PROGRESSION then
            self.loadingBar:setPercent(data.percentValue)
        elseif data.event == HU_EVENT.NEW_VERSION_NUMB then
            -- print(" HU_EVENT.NEW_VERSION_NUMB  >>>>>>>", data.version)
            -- Game_conf.Base_Version = data.version

        elseif data.event == HU_EVENT.GET_PACKAGE then


        elseif data.event == HU_EVENT.ERRO_INFO then
            --更新失败字符串信息，使用小弹窗显示他
        elseif data.event == HU_EVENT.EXTERN_UPERROR then

           gameState:unlockState(GAMESTATE.STATE_UPDATE)
            local function queding()
                 -- gameState:changeState(GAMESTATE.STATE_COMMHALL)
                 gameState:changeState(GAMESTATE.STATE_LOGIN)
                 
            end
            msgMgr:showConfirmMsg("下载失败，请检查网络并重新下载",queding)


        elseif data.event == HU_EVENT.SURE_OVER_GAME then
            gameState:unlockState(GAMESTATE.STATE_UPDATE)
            -- GlobalFun:showError(data.desc,function () os.exit(1) end,nil,1)
            callback({desc = data.desc})
        end

    end
    
        self.HotUpdateManager:create({storage_path = storage_path, server_version = server_version, cb = hum_callback, app_path = appPath, hot_update_path = hotUpdatePath,
                                    apk = "zhuzhi_zhuzhijihe.apk", ipa = "zhuzhi_zhuzhijihe", update_type = update_type,
                                    ios_manifest = ios_manifest, android_manifest = android_manifest})

end



return LauncherScene
