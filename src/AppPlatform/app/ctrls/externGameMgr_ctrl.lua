--扩展游戏管理器
local dkj = require("app.helper.dkjson")

local ExternGameMgr = class("ExternGameMgr")

ExternGameMgr.GameType_majiang = 0
ExternGameMgr.GameType_puke = 1
ExternGameMgr.GameType_paohuzi = 2

function ExternGameMgr:ctor(params)
	self.dirPath = writePathManager:getAppPlatformWritePath() .. externGameEnvMgr.dir
	self.iconDirPath = self.dirPath .. "GameIcons/"
	self.baseVersionDir = "BaseVersion/"
	self.localGameListFile = self.dirPath .. "localGameListFile"
end

--获取扩展游戏包的写入路径
function ExternGameMgr:getGameEvnDirPath(gameName)
	if not gameName then return end
	local game_dir = string.format("%s%s/", self.dirPath, gameName)
	return game_dir
end

--创建一个玩法目录
function ExternGameMgr:createGameDirByName(gameName)
	if not gameName then return end

	local utils = cc.FileUtils:getInstance()
	local game_dir = self:getGameEvnDirPath(gameName)
	cclog("ExternGameMgr:createGameDirByName >>>", game_dir)
	if not utils:isDirectoryExist(game_dir) then
        utils:createDirectory(game_dir)
    end

    local version_dir = string.format("%s%s", game_dir, self.baseVersionDir)
	cclog("ExternGameMgr:createGameDirByName >>>", version_dir)
	if not utils:isDirectoryExist(version_dir) then
        utils:createDirectory(version_dir)
    end



	local base_ios = __platformHomeDir .. "Manifests/project_ios.manifest"
	local fname = string.format("%sproject_ios.manifest", version_dir)
    if not utils:isFileExist(fname) then

		local manifest = ""
		manifest = utils:getStringFromFile(base_ios)
		local manifest_tb = dkj.decode(manifest)
		manifest_tb.version = "0.0.0"
		local manifest_str = dkj.encode(manifest_tb)
		local fname = string.format("%sproject_ios.manifest", version_dir)
		local file = io.open( fname, "w")
	    file:write(manifest_str)
	    io.close(file)
	end

	local base_android = __platformHomeDir .. "Manifests/project_android.manifest"
	local fname = string.format("%sproject_android.manifest", version_dir)
	if not utils:isFileExist(fname) then
		local manifest = ""
	    manifest = utils:getStringFromFile(base_android)
		local manifest_tb = dkj.decode(manifest)
		manifest_tb.version = "0.0.0"
		local manifest_str = dkj.encode(manifest_tb)
		local fname = string.format("%sproject_android.manifest", version_dir)
		local file = io.open( fname, "w")
	    file:write(manifest_str)
	    io.close(file)
	end
end

--删除一个玩法目录
function ExternGameMgr:deleteGameDirByName(gameName)

	local utils = cc.FileUtils:getInstance()
	local game_dir = self:getGameEvnDirPath(gameName)
	cclog("ExternGameMgr:deleteGameDirByName >>>", game_dir)
	local flag = true
	if utils:isDirectoryExist(game_dir) then
        flag = utils:removeDirectory(game_dir)
        self:removeGameFormLocalGameList(gameName)
    end

    self:createGameDirByName(gameName)
    return flag
end

--判断玩法是否存在于本地
function ExternGameMgr:isGameDirExist(gameName)
	if not gameName then return false end

	local flag = false
	local utils = cc.FileUtils:getInstance()
	local game_dir = self:getGameEvnDirPath(gameName)
	if utils:isDirectoryExist(game_dir) and utils:isFileExist(game_dir .. "project.manifest") then  --目录存在并且存在版本号文件才算
		flag = true
	end

	return flag
end

--获取游戏图标目录
function ExternGameMgr:getGameIconDir()
	local utils = cc.FileUtils:getInstance()
	if not utils:isDirectoryExist(self.iconDirPath) then
        utils:createDirectory(self.iconDirPath)
    end
	return self.iconDirPath
end

--获取某个扩展游戏包的当前版本
function ExternGameMgr:getGameVersionByName(gameName)
	if not gameName then return end

	if self:isGameDirExist(gameName) then

	else
		self:createGameDirByName(gameName)  --创建目录并且创建基础版本文件
	end

	local version = downGameMgr:getCurVersion(gameName)
	cclog("ExternGameMgr:getGameVersionByName >>>", gameName,version)
	return version
end

--判断某个扩展游戏包是否有新版本
function ExternGameMgr:isNewVersion(gameName, version)
	local flag = false
	local local_version = self:getGameVersionByName(gameName)
	if local_version ~= version then
		flag = true
	end
	return flag
end






--hotupdate的下载指向目录
function ExternGameMgr:getGameStoragePath(gameName)
	if not gameName then return end

	local game_dir = self:getGameEvnDirPath(gameName) .. "update/"
	return game_dir
	
end

--扩展游戏的基础版本目录
function ExternGameMgr:getGameBaseVersionDirPath(gameName)
	if not gameName then return end

	local version_dir = string.format("%s%s", self:getGameEvnDirPath(gameName), self.baseVersionDir)
	return version_dir
end


function ExternGameMgr:removeGameFormLocalGameList(gameName)
	local list = self:getLocalGameList()
	list[gameName] = nil
	luaFileUtils:saveToFile(list, self.localGameListFile)
end

function ExternGameMgr:saveGameToLocalGameList(data)
	cclog("ExternGameMgr:saveLocalGameList >>>")
	local list = self:getLocalGameList()
	list[data.game] = data 
	luaFileUtils:saveToFile(list, self.localGameListFile)

	-- print_r(list)
end

function ExternGameMgr:getLocalGameList()
	cclog("ExternGameMgr:getLocalGameList >>>")
	local tab = luaFileUtils:readFromFile(self.localGameListFile)
	-- print_r(tab)
	return tab
end








--请求返回平台
function ExternGameMgr:reqGotoPlatform()
	cclog("ExternGameMgr:reqGotoPlatform >>>>")
	local params = {}
	params.serverType = GAME_SERVER_TYPE.SERVER_TYPE_COMMHALL
	params.product = ""
	gatewaySendMgr:changePlatformOrGame(params)

	-- gameState:changeState(GAMESTATE.STATE_COMMHALL)
end


--请求进入游戏
-- 0-product   1-roomId
function ExternGameMgr:reqGotoGame(gtype, value)
	cclog("ExternGameMgr:reqGotoGame >>>>")
	cclog(debug.traceback())
	gatewaySendMgr:sendCheckGotoGame(gtype, value)
end




--调用游戏内的控件，该控件应该是最简单的控件只包含普通数据，不应该包含各种游戏相关逻辑
function ExternGameMgr:callGameCommonByName(gameName, commonName)
	cclog("ExternGameMgr:enterGameByName >>>", gameName)
	externGameEnvMgr:addEnv(gameName)

	-- local res = {}
	-- lua_load("gameStar").new(res)


	local ui = lua_load("toPlatform/" .."UI_GameSetting")
	local data = {}
	local obj = ui.new(data)
	local scene = cc.Director:getInstance():getRunningScene()
	scene:addChild(obj)

	
	obj:registerScriptHandler(function(state)
        if state == "enter" then
            cclog("callGameCommonByName 1>>>")
        elseif state == "exit" then
            cclog("callGameCommonByName 2>>>")
            externGameMgr:exitGameCommon()
        elseif state == "enterTransitionFinish" then
       
        elseif state == "exitTransitionStart" then
        
        elseif state == "cleanup" then
        
        end
    end)
end

function ExternGameMgr:exitGameCommon(callback)
	cclog("ExternGameMgr:exitGameByName >>>")
	
	globalTimerManager:delExternGlobalTimer()
	externGameEnvMgr:delEnv()

	if callback then
		callback()
	end
end










--进入一个玩法
function ExternGameMgr:enterGameByName(gameName, callback)
	
	cclog("ExternGameMgr:enterGameByName >>>", gameName)

	externGameMgr:exitGameByName()

	externGameEnvMgr:addEnv(gameName)

	if self:isGameDirExist(gameName) then

	else
		self:createGameDirByName(gameName)  --创建目录并且创建基础版本文件
	end

	
	gameState:changeState(GAMESTATE.STATE_HALL)
	if callback then
		xpcall(function() 
				viewMgr:show("changeLoading_view")
				callback()
			end,
		 function(msg)
		 	--处理错误
		 	self:reqGotoPlatform()

		 	
		 	--输出错误问题 
		 	release_print("----------------------------------------")
		    release_print("LUA ERROR: " .. tostring(msg) .. "\n")
		    release_print(debug.traceback())
		    release_print("----------------------------------------")
		 end)
		
	end


end

--退出一个玩法
--此方法已经会移除场景精灵，此方法调用后不应该紧接着存在精灵的remove，这样会产生双重remve导致闪退
--例如 一个确认提示窗的确认按钮会回调默认会把自己移除出节点，如果在这个确认按钮回调调用此方法，将会发生双重移除~！
--你可以在确认这种回调加一个延时调用就好了
function ExternGameMgr:exitGameByName(callback)
	cclog("ExternGameMgr:exitGameByName >>>")
	
	globalTimerManager:delExternGlobalTimer()
	cc.Director:getInstance():getRunningScene():unscheduleUpdate()
	cc.Director:getInstance():getRunningScene():removeAllChildren()
	viewMgr:show("changeLoading_view")

	externGameEnvMgr:delEnv()

	if callback then
		callback()
	end
end



return ExternGameMgr








