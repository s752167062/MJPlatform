--平台提供给扩展游戏使用的类
--扩展游戏只能通过这个类的方法来获取平台提供的特定功能、数据
--平台与扩展游戏唯一交互的类，扩展游戏不可以调用除了这个类以外的平台相关数据



local PlatformExportMgr = class("PlatformExportMgr")

PlatformExportMgr.epType_gotoGameClub = 0   -- params = {clubId,clubSecndId}
PlatformExportMgr.enterParmas = {}   -- {epType, params}


PlatformExportMgr.Events_DidEnterBackground = 0
PlatformExportMgr.Events_WillEnterForeground = 1
PlatformExportMgr.Events_AppPause = 2
PlatformExportMgr.Events_AppResume = 3 

function PlatformExportMgr:ctor(param)
	self.md5 = require "Manager.md5"
	self.dkj = require("app.helper.dkjson")
	self.write = require("app.ctrls.socket.Write")
end

--===================== 管理 begin =============================

--注册全局变量
-- function PlatformExportMgr:registerGlobalValue(key, value)
-- 	externGameEnvMgr:registerExternGameGlobalValue(key, value)
-- end

function PlatformExportMgr:registerGlobal(callback)
	externGameEnvMgr:externGameGlobalValue(callback)
end

--注册该扩展游戏的协议监听
function PlatformExportMgr:registExternGameReceiveProtocol(handler)
	gameNetMgr:registReceiveHandler(handler)
end

--清除该扩展游戏的协议监听
function PlatformExportMgr:removeExternGameReceiveProtocol()
	gameNetMgr:removeReceiveHandler()
end

--获取本游戏的可写路径  游戏内不能用ccfileuitls获取可写路径
function PlatformExportMgr:getGameWriteDirPath(gameName)
	return externGameMgr:getGameEvnDirPath(gameName)
end


function PlatformExportMgr:getGameIconDir()
	return externGameMgr:getGameIconDir()
end

--扩展游戏告诉平台现在已经进入扩展游戏状态
function PlatformExportMgr:markExternGameState()
	gameState:changeState(GAMESTATE.STATE_HALL)
end



--返回登录界面
function PlatformExportMgr:returnAppPlatformLogin()
	-- local schedulerID = false
 --    local scheduler = cc.Director:getInstance():getScheduler()
 --    local function cb(dt)
 --        scheduler:unscheduleScriptEntry(schedulerID)
       
	-- 	gameState:gotoLoginScene()
 --    end
 --    schedulerID = scheduler:scheduleScriptFunc(cb, 0.00001,false) 
 
	gameState:changeState(GAMESTATE.STATE_LOADING)
 	gameState:gotoLoginScene()
end

--游戏返回平台
function PlatformExportMgr:returnAppPlatform()
	-- cclog("PlatformExportMgr:returnAppPlatform >>>")
	-- cclog(debug.traceback())
	-- externGameMgr:reqGotoPlatform()
	-- externGameMgr:exitGameByName(nil)

	-- local schedulerID = false
 --    local scheduler = cc.Director:getInstance():getScheduler()
 --    local function cb(dt)
 --        scheduler:unscheduleScriptEntry(schedulerID)
        
 --        externGameMgr:reqGotoPlatform()
	-- 	externGameMgr:exitGameByName(nil)
 --    end
 --    schedulerID = scheduler:scheduleScriptFunc(cb, 0.00001,false) 


 	gameState:changeState(GAMESTATE.STATE_LOADING)
 	externGameMgr:reqGotoPlatform()

end

--游戏进入其他游戏
-- 0-product   1-roomId
function PlatformExportMgr:reqGotoGame(gtype, value, eType, params)

	
	-- local schedulerID = false
 --    local scheduler = cc.Director:getInstance():getScheduler()
 --    local function cb(dt)
 --        scheduler:unscheduleScriptEntry(schedulerID)
        
 --        externGameMgr:reqGotoGame(gtype, value)
	-- 	-- externGameMgr:exitGameByName(nil) --从一个游戏去另一个游戏不应该使用这个函数来立即卸载环境，以为他有可能取消下载

	-- 	print_r(params)
	-- 	if eType ==  platformExportMgr.epType_gotoGameClub then
	-- 		platformExportMgr:setEnterParams(eType, {clubId = params.clubId, clubSecndId = params.clubSecndId})
	-- 	end
 --    end
 --    schedulerID = scheduler:scheduleScriptFunc(cb, 0.00001,false) 


     externGameMgr:reqGotoGame(gtype, value)
	-- externGameMgr:exitGameByName(nil) --从一个游戏去另一个游戏不应该使用这个函数来立即卸载环境，以为他有可能取消下载

	print_r(params)
	if eType ==  platformExportMgr.epType_gotoGameClub then
		platformExportMgr:setEnterParams(eType, {clubId = params.clubId, clubSecndId = params.clubSecndId})
	end
end

--获取当前服务器类型
function PlatformExportMgr:doGameNetMgr_getServerTypeByCurrent()
	return gameNetMgr:getServerTypeByCurrent()
end

--通过服务器id获取该服务器类型
function PlatformExportMgr:doGameNetMgr_getServerTypeByServerId(serverID)
	return gameNetMgr:getServerTypeByServerId(serverID)
end

--去获取定义的服务器类型
function PlatformExportMgr:getGlobalGameSeverType(stype)
	if stype == "hall" then
		return GAME_SERVER_TYPE.SERVER_TYPE_HALL
	elseif stype == "room" then
		return GAME_SERVER_TYPE.SERVER_TYPE_ROOM
	elseif stype == "club" then
		return GAME_SERVER_TYPE.SERVER_TYPE_CLUB
	end
end

--获取游戏列表中的游戏分类
function PlatformExportMgr:getGameClassifyType(stype)
	if stype == "mj" then
		return externGameMgr.GameType_majiang
	elseif stype == "pk" then
		return externGameMgr.GameType_puke
	elseif stype == "phz" then
		return externGameMgr.GameType_paohuzi
	end
end


--===================== 管理 end =============================


--//////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////
--===================  事件 begin ============================


function PlatformExportMgr:registerListenerEvent(eventType, obj, callback)
	cclog("PlatformExportMgr:registerListenerEvent >>>", eventType)
	platformExportEventMgr:registerListener(eventType, obj, callback)
end

function PlatformExportMgr:cleanListener()
	platformExportEventMgr:cleanListener()
end

function PlatformExportMgr:removeListenerByObj(obj)
	platformExportEventMgr:removeListenerByObj(obj)
end

function PlatformExportMgr:removeListenerByEvent(eventType)
	platformExportEventMgr:removeListenerByEvent(eventType)
end

function PlatformExportMgr:dispathEvent(eventType, data)
	platformExportEventMgr:dispathEvent(eventType, data)
end


--===================  事件 end ============================


--//////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////
--===================  功能共享 begin ============================

--获取write模块
function PlatformExportMgr:getModel_Write()
	return self.write
end

--获取MD5算法模块
function PlatformExportMgr:getModel_MD5()
	return self.md5
end

--获取dkjson算法模块
function PlatformExportMgr:getModel_Dkjson()
	return self.dkj
end

function PlatformExportMgr:getModel_DownloadImageNode()
	return require("app.common.DownloadImageNode")
end




--===================  功能共享 end ============================


--//////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////
--===================  数据 begin ============================
--平台数据不应该被扩展游戏所改变，平台提供的给扩展的数据都应该是只读的

local gameConfMgr_extern = {
	voiceEffect = true,
	voiceValue = true,
}

function PlatformExportMgr:doGameConfMgr_setInfo(key, value)
	if gameConfMgr_extern[key] then -- 只开放这些key给扩展游戏
		gameConfMgr:setInfo(key,value)

	else
		cclog("----------------------------------------------------")
		cclog("Warning : do not set other key value >>>>")
		cclog(debug.traceback())
		cclog("----------------------------------------------------")

	end

	
end

function PlatformExportMgr:doGameConfMgr_getInfo(key)
	local v = gameConfMgr:getInfo(key)
	cclog("PlatformExportMgr:doGameConfMgr_getInfo >>>", key, v)
	return v
end

function PlatformExportMgr:doGameConfMgr_writeOne(key)
	if gameConfMgr_extern[key] then
		gameConfMgr:writeOne(key)
	else
		cclog("----------------------------------------------------")
		cclog("Warning : do not writeOne >>>>")
		cclog(debug.traceback())
		cclog("----------------------------------------------------")
	end
end


function PlatformExportMgr:setEnterParams(epType, params)
	PlatformExportMgr.enterParmas = {epType = epType, params = params}
end

function PlatformExportMgr:getEnterParams()
	cclog("PlatformExportMgr:getEnterParams >>>")
	local data = PlatformExportMgr.enterParmas
	PlatformExportMgr.enterParmas = {}

	print_r(data)
	return data
end


function PlatformExportMgr:getBaseWritablePath()
	return writePathManager:getAppPlatformWritePath()
end

function PlatformExportMgr:doExternGameMgr_isGameDirExist(game)
	return externGameMgr:isGameDirExist(game)
end

function PlatformExportMgr:doExternGameMgr_isNewVersion(game, version)
	
	return externGameMgr:isNewVersion(game, version)
end

function PlatformExportMgr:doExternGameMgrgetGameVersionByName(game)
	return externGameMgr:getGameVersionByName(game)
end

function PlatformExportMgr:getGameEvnDirPath(gameName)
	return externGameMgr:getGameEvnDirPath(gameName)
end
--===================  数据 end ============================


--=================== 系统接口 =============================
function PlatformExportMgr:startRecoder_audio(filename ,filedirectory ,default_callback , ismp3)
	platformMgr:startRecoder_audio(filename ,filedirectory ,default_callback , ismp3)
end
function PlatformExportMgr:endRecoder_audio(default_callback , ismp3)
	platformMgr:endRecoder_audio(default_callback , ismp3)
end
function PlatformExportMgr:play_audio(filename ,filedirectory ,default_callback)
	platformMgr:play_audio(filename ,filedirectory ,default_callback)
end
function PlatformExportMgr:stop_audio()
	platformMgr:stop_audio()
end

function PlatformExportMgr:setGameDirectory(directory)
	platformMgr:setGameDirectory(directory)
end
function PlatformExportMgr:copy_To_Clipboard(msg)
	platformMgr:copy_To_Clipboard(msg)
end
function PlatformExportMgr:parse_From_Clipboard()
	platformMgr:parse_From_Clipboard()
end
function PlatformExportMgr:get_Device_Power()
	return platformMgr:get_Device_Power()
end
function PlatformExportMgr:setAVAudioSessionCategoryAndMode(category,mode)
	platformMgr:setAVAudioSessionCategoryAndMode(category,mode)
end
function PlatformExportMgr:open_APP_WebView(URL)
	platformMgr:open_APP_WebView(URL)
end
function PlatformExportMgr:getShareUrl()
	return gameConfMgr:getInfo("shareUrl")
end
--支付的
function PlatformExportMgr:IAP_PAY(GOODSID)
	platformMgr:IAP_PAY(GOODSID)
end
function PlatformExportMgr:register_IAP_Callback(callback)
	platformMgr:register_IAP_Callback(callback)
end
function PlatformExportMgr:unRegister_IAP_Callback()
	platformMgr:unRegister_IAP_Callback()
end
function PlatformExportMgr:clean_IAP_Receipt()
	platformMgr:clean_IAP_Receipt()
end

--wechat
function PlatformExportMgr:weChatShareUrl(title_ , desc_ , url_ , share_type_ ,callback)
	SDKMgr:sdkUrlShare(title_ , desc_ , url_ , share_type_ ,callback)
end
function PlatformExportMgr:weChatShareImage(file_full_path , share_type , callback)
	SDKMgr:sdkImageShare(file_full_path , share_type , callback)
end
function PlatformExportMgr:weChatShareImageMergeByJson(JSON_STR , share_type ,callback )
	SDKMgr:sdkMergeImageShareByJSON(JSON_STR , share_type ,callback )
end
function PlatformExportMgr:weChatShareText(msg, share_type)
	SDKMgr:sdkTxtShare(msg, share_type)
end
function PlatformExportMgr:isWeChatClientExit()
	SDKMgr:isWeChatClientExit()
end
function PlatformExportMgr:weChatShareMiniProject(share_data,callback)
	SDKMgr:sdkShareMiniProject(share_data,callback)
end
function PlatformExportMgr:setWXLaunchCallBack(callback)--启动自动进房间游戏状态1未启动 ， 2在登录界面 ， 3在平台大厅 ， 4在平台俱乐部， 5在游戏大厅 ，6在游戏俱乐部，7在游戏中
	SDKMgr:setWXLaunchCallBack(callback)
end
--DD
function PlatformExportMgr:ddShareUrl(title_ , desc_ , url_ ,callback)
	SDKMgr:ddsdkUrlShare(title_ , desc_ , url_ ,callback)
end
function PlatformExportMgr:ddShareImage(file_full_path  , callback)
	SDKMgr:ddsdkImageShare(file_full_path  , callback)
end
function PlatformExportMgr:ddClientExits()
	SDKMgr:ddClientExits()
end
function PlatformExportMgr:ddApiSupport()
	SDKMgr:ddApiSupport()
end

--=================== 系统接口end ==========================

--一些通用的函数。
function PlatformExportMgr:uploadVoice(url_, firename_ , filedirectory_ , callback)
	comFunMgr:uploadVoice(url_, firename_ , filedirectory_ , callback)
end

return PlatformExportMgr










