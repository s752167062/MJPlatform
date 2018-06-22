--@游戏增量更新管理类
--@Author 	sunfan
--@date 	2017/05/13

--平台更新管理器
local UpdateMgr = class("UpdateMgr")

function UpdateMgr:ctor(params)
	require "Manager.__init"

	local HotUpdateManager  = require "Manager.HotUpdateManager"
	self.HotUpdateManager = HotUpdateManager

	print("UpdateMgr:ctor>>>>>>>>>>>>", HU_EVENT.LOGIN)
end

--增量更新开始
function UpdateMgr:updateStart(params,callback)
	local server_version = params.server_version
	local appPath = params.down_url
	local hotUpdatePath = params.updata_url
	self.server_version = server_version	
	self.appPath = appPath
	self.hotUpdatePath = hotUpdatePath
	self.callback = callback
	self.storage_path = writePathManager:getAppPlatformWritePath() .. "update/"
	self.update_type = self.HotUpdateManager.UpdateType_platform
	dump(params)


	gameState:changeState(GAMESTATE.STATE_UPDATE)
end

function UpdateMgr:getServerUpdateData()
	return self.server_version, self.appPath, self.hotUpdatePath, self.callback
end

function UpdateMgr:getCurVersion()
	local version = self.HotUpdateManager:get_cur_version(__platformHomeDir .."Manifests/project_ios.manifest", __platformHomeDir .. "Manifests/project_android.manifest",
														 writePathManager:getAppPlatformWritePath() .. "update/")

	return version
end

function UpdateMgr:getStoragePath()
	return self.storage_path
end

function UpdateMgr:getGameName()
	return ""
end


function UpdateMgr:getBaseManifest()
	return __platformHomeDir .."Manifests/project_ios.manifest", __platformHomeDir .."Manifests/project_android.manifest"
end

function UpdateMgr:getUpdateType()
	return self.update_type
end



return UpdateMgr
