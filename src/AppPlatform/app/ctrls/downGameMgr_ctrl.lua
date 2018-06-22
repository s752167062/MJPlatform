
--扩展游戏更新与下载管理器
local DownGameMgr = class("DownGameMgr")

function DownGameMgr:ctor(params)
	require "Manager.__init"

	local HotUpdateManager  = require "Manager.HotUpdateManager"
	self.HotUpdateManager = HotUpdateManager

	print("DownGameMgr:ctor>>>>>>>>>>>>", HU_EVENT.LOGIN)
end

--游戏更新、下载开始
function DownGameMgr:updateStart(gameName, params,callback)
	local server_version = params.server_version
	local appPath = params.down_url
	local hotUpdatePath = params.updata_url
	self.server_version = server_version	
	self.appPath = appPath
	self.hotUpdatePath = hotUpdatePath
	self.callback = callback

	self.storage_path = externGameMgr:getGameStoragePath(gameName)
	self.gameName = gameName
	dump(params)
	self.update_type = self.HotUpdateManager.UpdateType_extern


	gameState:changeState(GAMESTATE.STATE_UPDATE, nil, nil, true)
	-- gameState:lockState(GAMESTATE.STATE_UPDATE)
end

function DownGameMgr:getServerUpdateData()
	return self.server_version, self.appPath, self.hotUpdatePath, self.callback
end

function DownGameMgr:getCurVersion(gameName)
	local path = externGameMgr:getGameBaseVersionDirPath(gameName)
	cclog("DownGameMgr:getCurVersion >>>", path)
	local storagePath = externGameMgr:getGameStoragePath(gameName)
	local version = self.HotUpdateManager:get_cur_version(path .. "project_ios.manifest", path .."project_android.manifest", storagePath)

	return version
end

function DownGameMgr:getStoragePath()
	return self.storage_path
end

function DownGameMgr:getGameName()
	return self.gameName
end

function DownGameMgr:getBaseManifest(gameName)
	local path = externGameMgr:getGameBaseVersionDirPath(gameName)
	cclog("DownGameMgr:getCurVersion >>>", path)
	return path .. "project_ios.manifest", path .."project_android.manifest"
end

function DownGameMgr:getUpdateType()
	return self.update_type
end

return DownGameMgr







