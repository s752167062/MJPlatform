
local dkj = require("Manager.ManagerDkjson")
local md5 = require "Manager.md5"

AM_CODE =  {
    [0] = "ERROR_NO_LOCAL_MANIFEST",
    [1] = "ERROR_DOWNLOAD_MANIFEST",
    [2] = "ERROR_PARSE_MANIFEST",
    [3] = "NEW_VERSION_FOUND",
    [4] = "ALREADY_UP_TO_DATE",
    [5] = "UPDATE_PROGRESSION",
    [6] = "ASSET_UPDATED",
    [7] = "ERROR_UPDATING",
    [8] = "UPDATE_FINISHED",
    [9] = "UPDATE_FAILED",
    [10] = "ERROR_DECOMPRESS",
    [11] = "DOWNLOAD_FINISHED",
    [12] = "DECOMPRESS_PROGRESSION",
}


HU_EVENT = {
    DESC = 1,   --描述
    LOGIN = 2,  --成功登陆
    UPDATE_PROGRESSION = 3,   --进度

    GET_PACKAGE = 4,   --下载新包
    NEW_VERSION_NUMB = 5,  --更新完的版本
    ERRO_INFO = 6,  --更新失败字符串信息
    TARGET_VERSION = 7,   --即将更新到的目标版本
    SURE_OVER_GAME = 8, --- 更新下载校验完成，提示玩家点击确认退出游戏
    EXTERN_UPERROR = 9,   --- 扩展包更新失败
}

HOT_UPDATE_NOTIFY = "HotUpdateManager"


local HotUpdateManager = {}
-- local HotUpdateManager = class("HotUpdateManager")

HotUpdateManager.UpdateType_platform = 1  --更新平台
HotUpdateManager.UpdateType_extern = 2    --更新扩展包

local print = release_print
local cclog = release_print

--[[

    self.sv = self.root:getChildByName("server_version")
    self.cv = self.root:getChildByName("cur_version")
    self.tv = self.root:getChildByName("target_version")
    self.sv:setString(server_version or "")
    self.cv:setString(Game_conf.Base_Version or "")
    local function hum_callback (data) 
        self.tips:setString(data.desc or "")
        release_print("data.event >>>>", data.event)
        if data.event == HU_EVENT.DESC then

        elseif data.event == HU_EVENT.TARGET_VERSION then  --即将更新的目标版本号
            -- data.version
            self.tv:setString(data.version or "")
        elseif data.event == HU_EVENT.LOGIN then
            self.loadingBar:setPercent(100)
            -- self:reload("Configure.Game_conf")
            self:gotoLogin()
        elseif data.event == HU_EVENT.UPDATE_PROGRESSION then
            self.loadingBar:setPercent(data.percentValue)
        elseif data.event == HU_EVENT.NEW_VERSION_NUMB then
            cclog(" HU_EVENT.NEW_VERSION_NUMB  >>>>>>>", data.version)
            Game_conf.Base_Version = data.version

        elseif data.event == HU_EVENT.GET_PACKAGE then


        elseif data.event == HU_EVENT.ERRO_INFO then
            --更新失败字符串信息，使用小弹窗显示他


        elseif data.event == HU_EVENT.SURE_OVER_GAME then
            GlobalFun:showError(data.desc,function () os.exit(1) end,nil,1)
        end

    end
    
        HotUpdateManager:create({server_version = server_version, cb = hum_callback, app_path = appPath, hot_update_path = hotUpdatePath, apk = "doudizhu110.apk", ipa = "doudizhu",
                        ios_manifest = "Manifests/project_ios.manifest", android_manifest = "Manifests/project_android.manifest"})
]]

-- function HotUpdateManager:static_get_game_cur_version()
    
-- end

-- local g_storage_path = cc.FileUtils:getInstance():getWritablePath() .. "update/"







function HotUpdateManager:create(param)
    self:destroy()

    self.update_type = param.update_type
    self.storage_path = param.storage_path

    self.server_version = param.server_version
    self.cb = param.cb
    self.app_path = param.app_path
    self.apk_name = param.apk
    self.hot_update_path = param.hot_update_path
    self.apk_package_url = string.format("http://%s/%s", self.app_path, param.apk)
    self.ipa_package_url = string.format("http://%s/%s/", self.app_path, param.ipa)
    -- self.ipa_package_url = string.format("http://%s/%s/", "download.hongzhongmajiang.com", param.ipa)
    self.ios_manifest = param.ios_manifest
    self.android_manifest = param.android_manifest

    self.redownload_count = 0
    self.is_check_update = false
	self.amex = nil
    self.version_local = nil
    self.version_remote = nil
    self.listener = nil
    self.animation_desc = ""
    self.animation_sid = nil
    self.error_info = {}
    self.try_again_lock = false
    self.is_check_version = false
    -- self.new_manifest = nil
    -- self.old_manifest = nil
    self.new_assets = {}

	


    self:start()
end

function HotUpdateManager:destroy()
    if self.listener then
        cc.Director:getInstance():getEventDispatcher():removeEventListener(self.listener)
        self.listener = nil
    end
    if self.amex then
        self.amex:release()
        self.amex = nil
    end

    cclog ("HotUpdateManager:destroy >> ", self.animation_sid)
    cclog(debug.traceback())
    if self.animation_sid then
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(self.animation_sid)
        self.animation_sid = nil
    end

    if self.md5_schedulerID then
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(self.md5_schedulerID)
        self.md5_schedulerID = nil
    end
    

    -- ManagerNotify:unListenByKey(HOT_UPDATE_NOTIFY)
    self.update_type = 0
    self.storage_path = ""
    self.server_version = nil
    self.cb = nil
    self.redownload_count = 0
    self.is_check_update = false
    self.amex = nil
    self.version_local = nil
    self.version_remote = nil
    self.listener = nil
    self.animation_desc = ""
    self.animation_sid = nil
    self:clear_error_info()
    self.try_again_lock = false
    self.is_check_version = false
    -- self.new_manifest = nil
    -- self.old_manifest = nil
    self.new_assets = {}

end

function HotUpdateManager:add_error_info(event, eventCode)
    local tab = {}
    tab.eventCode = eventCode or ""
    tab.CURLECode = event:getCURLECode() or ""
    tab.CURLMCode = event:getCURLMCode() or ""

    if tab.CURLECode == 0 and tab.CURLMCode == 0 then 
        tab.is_curl_error = true
    end

    tab.AssetId = event:getAssetId() or ""
    tab.Message = event:getMessage() or ""

    self.error_info[#self.error_info +1] = tab

end

function HotUpdateManager:clear_error_info()
    self.error_info = {}
end

function HotUpdateManager:check_error_info(eventCode)
    -- if self.update_type == HotUpdateManager.UpdateType_extern then  --扩展包不计重试次数
    --     self.redownload_count = 0
    -- end

    local is_try_end = self:try_again(eventCode)
    if is_try_end then
        self:show_error_info_win()
        self:checkApkUpdate()
    end

    -- local info = self.error_info[1]
    -- pt(self.error_info)
    -- if info and info.is_curl_error then
    --     -- if info.CURLMCode == 7 or info.CURLMCode == 404 then
    --     --     release_print("无法连接服务器，请检查网络")
    --     --     self:notify({desc = "无法连接服务器，请检查网络", event = HU_EVENT.DESC})
    --     --     self:try_again(eventCode)
    --     -- else

    --         -- local str = string.format("更新失败，正在尝试第%d次重连", self.redownload_count and self.redownload_count +1 or 1)
    --         -- release_print(str)
    --         -- self:notify({desc = str, event = HU_EVENT.DESC})
    --         local is_try_end = self:try_again(eventCode)
    --         if is_try_end then
    --             self:show_error_info_win()
    --             self:checkApkUpdate()
    --         end
    --     -- end
    -- elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FAILED  --非常特殊的没有错误信息，又有资源报错，直接去整包更新（基本没遇到，写个以防万一）
    --     or eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_NO_LOCAL_MANIFEST
    --     or eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_PARSE_MANIFEST
    --     or eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DECOMPRESS
    --     then  
    --     self:show_error_info_win()
    --     self:checkApkUpdate()
    -- end
    self:clear_error_info()
end

function HotUpdateManager:show_error_info_win()
    if self.error_info and type(self.error_info) == "table" then
        local idx = table.maxn(self.error_info)
        local tab = self.error_info[idx]
        if tab then
            local targetPlatform = cc.Application:getInstance():getTargetPlatform() 
            local tmp = targetPlatform == cc.PLATFORM_OS_ANDROID and "请确保网络畅通，将尝试整包下载" or "请确保网络畅通，将跳转到下载页面"

            local str = string.format("%s，ECode=%s,MCode=%s,AssetId=%s,Message=%s,eventCode=%s", tmp,
                tostring(tab.CURLECode), tostring(tab.CURLMCode), tostring(tab.AssetId), tostring(tab.Message), tostring(tab.eventCode))
            self:notify({desc = str, event = HU_EVENT.ERRO_INFO})
        end
    end
end

function HotUpdateManager:try_again(eventCode)
    local is_try_end = false
    local max_try_count = 3

    if not self.try_again_lock then
        self.redownload_count = self.redownload_count <= max_try_count and self.redownload_count +1 or 0
       
        release_print("try_again >>>>", self.redownload_count, eventCode) 
        if self.redownload_count <= max_try_count then
            if eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DECOMPRESS then
                is_try_end = true
            elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FAILED then --直接报错更新资源，则重新更新错误资源
                local function callback1()
                    release_print("try_again 111>>>>", self.redownload_count)
                    if not self.amex or self.redownload_count > max_try_count then
                        return 
                    end
                    release_print("try_again downloadFailedAssets >>>>")
                    self.amex:downloadFailedAssets()
                    self.try_again_lock = false
                end
                self.try_again_lock = true
                self:delay_callback(10, callback1)
            else
                  local function callback2()
                    release_print("try_again 222>>>>", self.redownload_count)
                    if not self.amex or self.redownload_count > max_try_count then
                        return 
                    end
                    

                    if self.is_check_version then  --如果已经检查版本了，那就是更新的错，尝试再次更新
                        release_print("try_again update >>>>")
                        self.amex:update()
                    else  -- 否则，就是检查版本的时候错，尝试再次版本检查
                        release_print("try_again checkUpdate >>>>")
                        self.amex:checkUpdate()
                    end
                    self.try_again_lock = false
                end
                self.try_again_lock = true
                self:delay_callback(10, callback2)
            end

        else
            is_try_end = true
        end
    end

    return is_try_end
end

function HotUpdateManager:animation(desc)
    self.animation_desc = desc

    if not self.animation_sid then
        local str = ""
        local count = 0
        local scheduler = cc.Director:getInstance():getScheduler()
        local function cb(dt)
            -- print " HotUpdateManager:animation"
            count = count > 3 and 1 or count +1
            if count == 1 then str = "."
            elseif count == 2 then str = ".."
            elseif count == 3 then str = "..." end
            self:notify({desc = self.animation_desc .. str, event = HU_EVENT.DESC}, true)


        end
        self.animation_sid  = scheduler:scheduleScriptFunc(cb, 0.5,false)
        -- print ("animation >> ", self.animation_sid)
        -- print (debug.traceback())
    end  
end


--[[
    @data
        data.desc
        data.event
]]
function HotUpdateManager:notify(data, is_animation)
    data = data or {}
    data.desc = data.desc or ""
    data.event = data.event or HU_EVENT.DESC
   
    if data.event == HU_EVENT.SURE_OVER_GAME then
       
        self:delay_destroy()
    end

    if  data.event == HU_EVENT.ERRO_INFO then
        if targetPlatform == cc.PLATFORM_OS_ANDROID or targetPlatform == cc.PLATFORM_OS_WINDOWS then
            data.desc = "[安装包正在下载，请稍后]" ..  data.desc
        else
            data.desc = "[即将跳转页面，请稍后]" ..  data.desc
        end
    end

    self.cb(data)

    if not is_animation then
        self:animation(data.desc)
    end

    
end

--事件内销毁自身需要延迟一下
function HotUpdateManager:delay_destroy()
     self:delay_callback(0.2, function()
                self:destroy()
            end)
end

function HotUpdateManager:start()

    release_print("HotUpdateManager:start() >>>")
    --不进行当前下到一半的版本的继续下载了，该版本重新下
    self:removeTempProjectManifest()

    -- if true then return end


	local am = nil
    local targetPlatform = cc.Application:getInstance():getTargetPlatform() 
    if targetPlatform == cc.PLATFORM_OS_ANDROID or targetPlatform == cc.PLATFORM_OS_WINDOWS then
        am = cc.AssetsManagerEx:create(self.android_manifest, self.storage_path, self.hot_update_path)      
    elseif targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD or targetPlatform == cc.PLATFORM_OS_MAC then
        am = cc.AssetsManagerEx:create(self.ios_manifest, self.storage_path, self.hot_update_path)
    end
    am:retain()
    self.amex = am



    self:notify({desc = "准备开始更新", percentValue = 0, event = HU_EVENT.UPDATE_PROGRESSION})


    local local_manifest = am:getLocalManifest():isLoaded()

    if not local_manifest then
        self:notify({desc = "加载本地版本失败，直接进入登录界面", event = HU_EVENT.LOGIN})
    else

        self.version_local = am:getLocalManifest():getVersion()
        -- GlobalData.version = self.versionlocal

        local function onUpdateEvent(event)
            local eventCode = event:getEventCode()
            release_print("HotUpdateManager:eventCode=" .. AM_CODE[eventCode], eventCode)

            self:add_error_info(event, AM_CODE[eventCode])

            if eventCode == cc.EventAssetsManagerEx.EventCode.NEW_VERSION_FOUND then
                self:notify({desc = "开始检查版本号", event = HU_EVENT.DESC})
                local manifest = am:getRemoteManifest()
                self.version_remote = manifest:getVersion()

                self:delay_callback(0.01, function () self:onCheckVersion(self.version_local, self.version_remote) end )

                self:notify({version = self.version_remote, event = HU_EVENT.TARGET_VERSION})

                
                

            elseif  eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_PROGRESSION then
                local assetId = event:getAssetId()
                local percent = event:getPercent()

                local strInfo = ""

                local percentValue = 0
                if assetId == cc.AssetsManagerExStatic.VERSION_ID then --下载version.manifest

                    percentValue = percent > 0 and math.ceil(percent / 100 * 2) or percentValue 

                elseif assetId == cc.AssetsManagerExStatic.MANIFEST_ID then --下载project.manifest

                    percentValue = percent > 0 and 2 + math.ceil(percent / 100 * 8) or 2

                else --下载资源

                    percentValue = percent > 0 and 10 + math.floor(percent / 100 * 90) or 10

                end
                if percentValue > 100 then
                    percentValue = 100
                end
                -- self.redownload_count = 0 

                strInfo = string.format("更新资源: %d%%", math.floor(percentValue))
                release_print(strInfo)
                self:notify({desc = strInfo, percentValue = percentValue, event = HU_EVENT.UPDATE_PROGRESSION})


             elseif eventCode == cc.EventAssetsManagerEx.EventCode.ALREADY_UP_TO_DATE then 

                if not self:server_and_project_and_version_compare() then return end

                local manifest = self.amex:getRemoteManifest()
                local project_version = manifest:getVersion()
                self:notify({version = project_version, event = HU_EVENT.TARGET_VERSION})
                self:notify({desc = "当前版本已经最新", event = HU_EVENT.LOGIN})
            elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FINISHED then
                
                
                release_print("cc.EventAssetsManagerEx.EventCode.UPDATE_FINISHED >>")
                -- self:remove_cache()
                -- local manifest = am:getLocalManifest()
                -- local version = manifest:getVersion()
                -- self:notify({version = version, event = HU_EVENT.NEW_VERSION_NUMB})
                -- self:notify({desc = "更新完成，准备进入游戏", event = HU_EVENT.LOGIN})

                 -- if not self:server_and_project_and_version_compare(true) then return end
                
                -- self:delay_callback(0.2, function () self:md5_check() end )

                
                 self:notify({desc = "更新完成", event = HU_EVENT.SURE_OVER_GAME})

            elseif eventCode == 11 then --DOWNLOAD_FINISHED

                if not self:server_and_project_and_version_compare(true) then return end
                self:delay_callback(0.2, function () self:md5_check() end )

            elseif eventCode == 12 then --DECOMPRESS_PROGRESSION

                local fc = event:get_zip_files_count()
                local ft = event:get_zip_files_tatal()
                local cz = event:get_cur_zip_count()
                local tz = event:get_total_zip_count()
                local filename = event:get_unzip_filename()
                -- cclog("filename >>>>>", filename)

                self:notify({desc = string.format("解压中, 压缩包进度(%d%%)，已完成(%d/%d)", math.floor(fc/ft*100), cz, tz), event = HU_EVENT.DESC})

            elseif eventCode == cc.EventAssetsManagerEx.EventCode.ASSET_UPDATED then
                local str = event:getAssetId()
                if str and str ~= "" then
                    self.new_assets[str] = true
                end

            
            elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FAILED then
                
                self:check_error_info(eventCode)

            ----------------------------  error ---------------------------------------

            elseif  eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_UPDATING then
                local str = self:get_error_str(event)
                release_print(str)

            elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_NO_LOCAL_MANIFEST then
                local str = self:get_error_str(event)
                release_print(str)
                self:check_error_info(eventCode)
                
            elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DOWNLOAD_MANIFEST or 
                eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_PARSE_MANIFEST then
                 local str = self:get_error_str(event)
                release_print(str)
                self:check_error_info(eventCode)

            elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DECOMPRESS then
                 local str = self:get_error_str(event)
                release_print(str)
                self:check_error_info(eventCode)
            end
        end

        self.listener = cc.EventListenerAssetsManagerEx:create(am,onUpdateEvent)
        cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.listener, 1)
        am:checkUpdate() 
        self.is_check_update = true
    end
end

function HotUpdateManager:get_error_str(event)
    local str = string.format("getCURLECode = %s, getCURLMCode = %s, getAssetId = %s, getMessage = %s", 
        tostring(event:getCURLECode()), tostring(event:getCURLMCode()), tostring(event:getAssetId()), tostring(event:getMessage()))
    return str
end

function HotUpdateManager:server_and_project_and_version_compare(is_finish)
    if self.server_version and self.server_version ~= "" and self.amex then

        -- 这里很特别，需要很清楚流程才知道
        -- local manifest = is_finish and self.amex:getLocalManifest() or self.amex:getRemoteManifest()
        -- local project_version = manifest:getVersion()

        local project_version = ""
        if is_finish then
            local manifest = self:get_manifest()
            project_version = manifest.version
        else
            local manifest = self.amex:getRemoteManifest()
            project_version = manifest:getVersion()
        end


        self.version_remote = self.version_remote and self.version_remote or project_version

        cclog("self.server_version ~= self.version_remote", self.server_version, self.version_remote, project_version)
        if self.server_version == self.version_remote and project_version == self.version_remote then

        else
            self:notify({desc = "版本号不匹配", event = HU_EVENT.ERRO_INFO})
            self:checkApkUpdate()
            return false
        end
    end

    return true
end

--扩展包遇到大版本时，删除自己的本地环境src res目录
function HotUpdateManager:resetExternDir()
    local utils = cc.FileUtils:getInstance()
    local path = self.storage_path
    local src_path = path .. "src/"
    local res_path = path .. "res/"
    if utils:isDirectoryExist(src_path) then
        if utils:removeDirectory(src_path) then
            cclog("delete src_path success!")
        else
            cclog("delete src_path fail!")
        end
    end
    if utils:isDirectoryExist(res_path) then
        if utils:removeDirectory(res_path) then
            cclog("delete res_path success!")
        else
            cclog("delete res_path fail!")
        end
    end
end

--整包下载
function HotUpdateManager:checkApkUpdate()

    if self.update_type == HotUpdateManager.UpdateType_extern then
        cclog(debug.traceback())
        self:delay_destroy()
        self:notify({desc = "扩展包更新失败,请检查网络", event = HU_EVENT.EXTERN_UPERROR})

        return 
    end


    --remove old update
    self:removeUpdateFile()
    

    -- local targetPlatform = cc.Application:getInstance():getTargetPlatform()  
    -- if targetPlatform == cc.PLATFORM_OS_ANDROID then
    --     --下载安装文件中...   动画   
    --     -- self:downloadApkAnimation_tips()
    --     -- self:downloadApkAnimation_progressbar()
    --     self:notify({desc = "下载安装文件中，请不要退出游戏，稍等片刻", event = HU_EVENT.GET_PACKAGE})
    --     local function callback()
    --         cclog("self.apk_package_url >>>>>>",self.apk_package_url)
    --         local args = {"DownPress" , self.apk_package_url }
    --         local packName = "org/cocos2dx/util/ApkDownloader"
    --         local a,b = LuaJavaBridge.callStaticMethod(packName,"Apkdownload",args,"(Ljava/lang/String;Ljava/lang/String;)Z")
    --         if a == true and b ~= nil then
    --             return b
    --         end
    --     end
    --     HotUpdateManager:delay_callback(3, callback)
        
    -- elseif targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD or targetPlatform == cc.PLATFORM_OS_MAC then
    --     self:notify({desc = "即将跳转到下载界面，苹果用户请从下载页面下载最新版本", event = HU_EVENT.GET_PACKAGE})

    --     local function callback()
    --          cclog("self.ipa_package_url >>>>>>",self.ipa_package_url)
    --         cpp_openSafari("DownPress" , self.ipa_package_url)
    --     end

    --     HotUpdateManager:delay_callback(3, callback)
    -- end

    --xxxxx
    --下载进度回调
    local function DownPress_callback(percent)
        -- cclog("DownPress_callback >>>>", percent)
        percent = percent *100
        local strInfo = string.format("下载进度: %d%%", percent)
        self:notify({desc = strInfo, percentValue = percent, event = HU_EVENT.UPDATE_PROGRESSION}) 
    end

    local targetPlatform = cc.Application:getInstance():getTargetPlatform()  
    if targetPlatform == cc.PLATFORM_OS_ANDROID or targetPlatform == cc.PLATFORM_OS_WINDOWS then
        self:notify({desc = "下载安装文件中，请不要退出游戏，稍等片刻", event = HU_EVENT.GET_PACKAGE})
        -- 延时
        local function callback()
            cclog("self.apk_package_url >>>>>>",self.apk_package_url)
            platformMgr:download_APK(self.apk_package_url , self.apk_name, DownPress_callback)
        end
        self:delay_callback(3, callback)

    else
        self:notify({desc = "即将跳转到下载界面，苹果用户请从下载页面下载最新版本", event = HU_EVENT.GET_PACKAGE})
        -- 延时
        local function callback()
            cclog("self.ipa_package_url >>>>>>",self.ipa_package_url)
            cpp_openSafari(self.ipa_package_url)
        end
        self:delay_callback(3, callback)
    end

    -- self:destroy()
end

-- function DownPress(percent)
--     -- if percent >= 99 then
--     --     self.ui_process:setPercent(100)
--     -- end
--     local strInfo = string.format("下载进度: %d%%", math.floor(percent or 0))
--     HotUpdateManager:notify({desc = strInfo, percentValue = percent, event = HU_EVENT.UPDATE_PROGRESSION})
--     -- release_print("percent:" .. percent)
-- end

--删除更新文件
function HotUpdateManager:removeUpdateFile()
    local utils = cc.FileUtils:getInstance()

    local path = writePathManager:getAppPlatformWritePath()
    path = path .. "UDInfo.json"
    if utils:isFileExist(path) then
        if utils:removeFile(path) then
            release_print("UDInfo.json! success!")
        else
            release_print("UDInfo.json  fail!")
        end
    end



    -- local path = self.storage_path
    -- if cc.FileUtils:getInstance():isDirectoryExist(path) then
    --     if cc.FileUtils:getInstance():removeDirectory(path) then
    --         release_print("delete update success!")
    --     else
    --         release_print("delete update fail!")
    --     end
    -- end

end

function HotUpdateManager:removeTempProjectManifest()
    local path = self.storage_path
    path = path .. "project.manifest.temp"
    if cc.FileUtils:getInstance():isFileExist(path) then
        if cc.FileUtils:getInstance():removeFile(path) then
            release_print("removeTempProjectManifest! success!")
        else
            release_print("removeTempProjectManifest  fail!")
        end
    end

    local path = self.storage_path
    path = path .. "version.manifest.tmp"
    if cc.FileUtils:getInstance():isFileExist(path) then
        if cc.FileUtils:getInstance():removeFile(path) then
            release_print("removeTempProjectManifest! success!")
        else
            release_print("removeTempProjectManifest  fail!")
        end
    end
end

function HotUpdateManager:split(str, delimiter)
    if str==nil or str=='' or delimiter==nil then
        return nil
    end
    
    local result = {}
    for match in (str..delimiter):gmatch("(.-)%"..delimiter) do
        table.insert(result, match)
    end
    return result
end

function HotUpdateManager:getVersion(version)
    
    local result = self:split(version, ".")
    return result[1], result[2], result[3]
end

--是否开始下载
function HotUpdateManager:onCheckVersion(versionlocal, versionremote)
    --versionlocal, versionremote 相等是不会来这里的

    local a1,a2,a3 = self:getVersion(versionlocal)
    local b1,b2,b3 = self:getVersion(versionremote)
    release_print ("b1,b2,b3")
    release_print (a1,a2,a3)
    release_print (b1,b2,b3)
    release_print ("b1,b2,b3")

    self.is_check_version = true

    
    if tonumber(b1) and tonumber(a1) and tonumber(b2) and tonumber(a2) and tonumber(b3) and tonumber(a3) then
        local tmp_a = a3 + a2*10000 + a1*100000000
        local tmp_u = b3 + b2*10000 + b1*100000000
        if tmp_a > tmp_u then
            self:notify({desc = "下载到旧的版本清单", event = HU_EVENT.DESC})
            self:checkApkUpdate()
            return 
        end
    else
        self:notify({desc = "版本号类型非数字", event = HU_EVENT.DESC})
        self:checkApkUpdate()
        return
    end



    if b1 == a1 then
        if b2 == a2 then
            if b3 == a3 then --Do not need updateOPENID
                -- self.tips:setText("当前版本已经最新")
                -- self.ui_process:setPercent(100)
                -- self:gotoLogin()
                self:notify({desc = "当前版本已经最新", event = HU_EVENT.LOGIN})

            else --need update
                -- self.tips:setText("开始更新")
                -- self:onStartDownload()
                -- print ("开始更新 111>>>>>")
                -- self:notify({desc = "开始更新", event = HU_EVENT.DESC})
                -- local state = self.amex:getState()
                -- local isloaded = self.amex:getRemoteManifest():isLoaded()
                -- local url = self.amex:getLocalManifest():getManifestFileUrl()
                -- release_print("amex state >>", state, isloaded, url)


                --am有两种模式，一种只checkupdate（检查版本），一种update（检查然后紧跟着更新），两者都会检查版本，区别是，前一种检查完就停下了，后一种立马进入更新流程（增量更新）
                --所以二者都会来这里，但是当第一种检查版本后已经开始update的增量更新了，update的检查版本不应该再次进入这里，所以，加以self.is_check_update来判断
                if self.is_check_update then
                    self.is_check_update = false
                    print ("开始更新 >>>>>")
                   
                    self:notify({desc = "更新资源: %0", event = HU_EVENT.DESC})
                    self.amex:update()
                end
                -- local state = self.amex:getState()
                -- local isloaded = self.amex:getRemoteManifest():isLoaded()
                -- local url = self.amex:getLocalManifest():getManifestFileUrl()
                -- release_print("amex state >>", state, isloaded, url)

            end
        else --download apk
            if self.update_type == HotUpdateManager.UpdateType_extern then 
                
                if self.is_check_update then
                    self.is_check_update = false
                    print ("开始更新 >>>>>")
                    self:resetExternDir()
                    self:notify({desc = "更新资源: %0", event = HU_EVENT.DESC})
                    self.amex:update()
                end
            else
                self:checkApkUpdate()
            end
        end
    else --download apk
        
        
        if self.update_type == HotUpdateManager.UpdateType_extern then 
                
            if self.is_check_update then
                self.is_check_update = false
                print ("开始更新 >>>>>")
                self:resetExternDir()
                self:notify({desc = "更新资源: %0", event = HU_EVENT.DESC})
                self.amex:update()
            end
        else
            self:checkApkUpdate()
        end
    end
end

function HotUpdateManager:delay_callback(time, callback)
    local schedulerID = false
    local scheduler = cc.Director:getInstance():getScheduler()
    local function cb(dt)
        scheduler:unscheduleScriptEntry(schedulerID)
        callback()
    end
    schedulerID = scheduler:scheduleScriptFunc(cb, time,false, "platform") 
end

function HotUpdateManager:remove_cache()
    -- cc.FileUtils:getInstance():purgeCachedEntries()
    -- package.loaded["Manager.cfg.hot_update_cfg"] = nil
    -- local cfg = require "Manager.cfg.hot_update_cfg"
    -- for k,v in pairs(cfg.lua_path) do
    --     local tmp = v
    --     local path = string.gsub(tmp,"/","%.")
    --     if package.loaded[path] then
    --         package.loaded[path] = nil
    --     end
    --     path = string.gsub(tmp,"%.","/")
    --     if package.loaded[path] then
    --         package.loaded[path] = nil
    --     end
    -- end

    
    -- cc.AnimationCache:destroyInstance()
    -- cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
    -- cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end



function HotUpdateManager:get_cur_version(ios_manifest, android_manifest, storage_path)
    local am = nil

    local targetPlatform = cc.Application:getInstance():getTargetPlatform() 
    cclog("get_cur_version　>>>",storage_path)
    if targetPlatform == cc.PLATFORM_OS_ANDROID or targetPlatform == cc.PLATFORM_OS_WINDOWS then
        am = cc.AssetsManagerEx:create(android_manifest, storage_path, "")      
    elseif targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD or targetPlatform == cc.PLATFORM_OS_MAC then
        am = cc.AssetsManagerEx:create(ios_manifest, storage_path, "")
    end
    local str = ""
    if am then
        str = am:getLocalManifest():getVersion()
    end

    if str == "" or not str then
        str = "1.0.0"
    end
    
    cclog("HotUpdateManager:get_cur_version", str)
    return str
end

function HotUpdateManager:md5_check()
    -- if not self.old_manifest or not self.new_manifest then 
    --     return 
    -- end

    --关闭md5校验
    -- if true then 
    --     local manifest = self.amex:getLocalManifest()
    --     self.version_remote = manifest:getVersion()
    --     self:notify({version = self.version_remote, event = HU_EVENT.NEW_VERSION_NUMB})
    --     self:notify({desc = "更新完成，准备进入游戏", event = HU_EVENT.LOGIN})
    --     return 
    -- end


    if not self.new_assets or not next(self.new_assets) then
        cclog("ssss .>", not self.new_assets, not next(self.new_assets))
        self:notify({desc = "md5 校验失败" , event = HU_EVENT.ERRO_INFO})
        self:checkApkUpdate()
        return
    end

    local new_manifest = self:get_manifest()
    if not new_manifest or not new_manifest.assets or not next(new_manifest.assets) then
        cclog("aaa .>", not new_manifest, not new_manifest.assets, next(new_manifest.assets))
        self:notify({desc = "md5 校验失败", event = HU_EVENT.ERRO_INFO})
        self:checkApkUpdate()
        return 
    end

    self:notify({desc = "正在进行MD5校验", event = HU_EVENT.DESC})


    local utils = cc.FileUtils:getInstance()
    local function get_md5(filename)   
        filename = self.storage_path .. filename   
        if utils:isFileExist(filename) then
            local chunk = utils:getStringFromFile(filename)
            return md5.sumhexa(chunk)
        end
    end

    local total = 0
    for k,v in pairs(self.new_assets) do
        total = total +1
    end

    local index = next(self.new_assets)
    local schedulerID = false
    local scheduler = cc.Director:getInstance():getScheduler()
    local count = 0
    local continue_check = true
    self:notify({desc = string.format("正在进行MD5校验(%d/%d)", count, total), event = HU_EVENT.DESC})
    local function cb(dt)
        if continue_check then
            continue_check = false
        
            if index then
                count = count +1
                self:notify({desc = string.format("正在进行MD5校验(%d/%d)", count, total), event = HU_EVENT.DESC})

                local new = new_manifest.assets[index]
                if new then
                    local tmp = get_md5(index)
                    if tmp ~= new.check_md5 then
                        scheduler:unscheduleScriptEntry(schedulerID)
                        self.md5_schedulerID = nil

                        print ("md5 校验不匹配", index)
                        self:notify({desc = "md5 校验不匹配: " .. index .. tmp .. ";" .. new.check_md5, event = HU_EVENT.ERRO_INFO})
                        self:checkApkUpdate()
                        return
                    end
                else
                    scheduler:unscheduleScriptEntry(schedulerID)
                    self.md5_schedulerID = nil

                    print ("md5 校验失败，两张文件清单有遗漏", index)
                    self:notify({desc = "md5 校验失败，遗漏: " .. index, event = HU_EVENT.ERRO_INFO})
                    self:checkApkUpdate() --切换到整包更新
                    return
                end
            else
                scheduler:unscheduleScriptEntry(schedulerID)
                self.md5_schedulerID = nil

                print ("md5 校验成功")
                -- local manifest = self.amex:getLocalManifest()
                -- local version = manifest:getVersion()
                -- self:notify({version = version, event = HU_EVENT.NEW_VERSION_NUMB})
                -- self:notify({desc = "更新完成，准备进入游戏", event = HU_EVENT.LOGIN})

                -- self:notify({desc = "更新完成，请重新进入游戏", event = HU_EVENT.SURE_OVER_GAME})
                if self.amex then
                    self:notify({desc = "开始解压", event = HU_EVENT.DESC})
                    self.amex:updateFinish()

                end
                return 
            end


            index = next(self.new_assets, index)
            continue_check = true
        end


    end
    schedulerID = scheduler:scheduleScriptFunc(cb, 0.1,false, "platform")
    self.md5_schedulerID = schedulerID


end

--借助了创建AssetsManagerEx时，loadLocalManifest函数进行版本比对后，才能用
--不明白原理不要轻易使用
function HotUpdateManager:get_manifest()
    local tab = nil
    xpcall(function ()

        local filename = self.storage_path .. "project.manifest.temp"
        local utils = cc.FileUtils:getInstance()
        if utils:isFileExist(filename) then
            local chunk = utils:getStringFromFile(filename)
            tab = dkj.decode(chunk)
        else
            local targetPlatform = cc.Application:getInstance():getTargetPlatform() 
            if targetPlatform == cc.PLATFORM_OS_ANDROID or targetPlatform == cc.PLATFORM_OS_WINDOWS  then
                if utils:isFileExist(self.android_manifest) then
                    local chunk = utils:getStringFromFile(self.android_manifest)
                    tab = dkj.decode(chunk)
                end
            elseif targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD or targetPlatform == cc.PLATFORM_OS_MAC then
                if utils:isFileExist(self.ios_manifest) then
                    local chunk = utils:getStringFromFile(self.ios_manifest)
                    tab = dkj.decode(chunk)
                end
            end
        end
        
    end, __G__TRACKBACK__)
   

    return tab
end


return HotUpdateManager




