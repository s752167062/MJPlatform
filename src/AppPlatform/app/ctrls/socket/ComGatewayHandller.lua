
--网关协议接收（基本是网关偏向业务类）

local dkj = require("app.helper.dkjson")

local ComGatewayHandller = class("ComGatewayHandller")

function ComGatewayHandller:ctor(params)
	self:inItProtocol()
end

function ComGatewayHandller:receiveMsg(obj)
    self:handlerProtocol(obj:getProId(),obj)
end

--协议处理
function ComGatewayHandller:handlerProtocol(proId,obj)
	cclog("ComGatewayHandller:handlerProtocol >>>", proId)
	proId = tonumber(proId)
	if self._proFuns[proId] then
		self._proFuns[proId](obj)
	else
		dump("error,non-existent protocol ID:"..proId)
	end
end

function ComGatewayHandller:inItProtocol()
	self._proFuns = {}
	self._proFuns[30005] = handler(self,self.recvMsgFromPlayer)
	self._proFuns[30006] = handler(self,self.recvCheckGotoGame)
	self._proFuns[30007] = handler(self,self.recvGotoGame)
end

function ComGatewayHandller:recvMsgFromPlayer(obj)
	local str = obj:readString()
	cclog(str)
	local res = dkj.decode(str)
	print_r(res)

	if res.game_event_type == "reqInviteJoinGroup" then
		res.game_event_type = "respInviteJoinGroup"

	elseif res.game_event_type == "reqInvteJoinRoom" then 
		res.game_event_type = "respInviteJoinRoom"
	end

	local function ok()
		res.respCode = true
		gatewaySendMgr:sendMsgToPlayer(res)
	end

	local function cancel()
		res.respCode = false
		gatewaySendMgr:sendMsgToPlayer(res)
	end
	msgMgr:showAskMsg(res.content or "", ok, cancel)

	cclog("ComGatewayHandller:recvMsgFromPlayer >> 222")
	print_r(res)
end


function ComGatewayHandller:recvCheckGotoGame(obj)
	local res = {}
    res.product = obj:readString()
    res.productType = obj:readString()
    res.name = obj:readString()
    res.game = obj:readString()
    res.version = obj:readString()
    res.icon = obj:readString()
    res.update_android = obj:readString()
    res.update_ios = obj:readString()
    res.shareUrl = obj:readString()
    res.roomId = obj:readInt()

    print_r(res)

    local targetPlatform = cc.Application:getInstance():getTargetPlatform() 
    if targetPlatform == cc.PLATFORM_OS_ANDROID or targetPlatform == cc.PLATFORM_OS_WINDOWS  then
        res.hotUpdate = res.update_android
    elseif targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD or targetPlatform == cc.PLATFORM_OS_MAC then
        res.hotUpdate = res.update_ios
    end

    res.download = ""  --没有真正意义的整更

  
    -- eventMgr:dispatchEvent("HallProtocol.recvUpdateOrDownGame",res) 
    --test
    -- res.hotUpdate = "download-test.qu188.com/zhuzhi_zhuzhijihe_demo/ExternGameAssets/hongzhong/hotUpdate/1.0.0b"

    local function callback_func(params, isDownload) 
        local version = externGameMgr:getGameVersionByName(res.game)
        cclog("ComGatewayHandller:recvCheckGotoGame update finish>>>", res.game, res.product, version)
        if isDownload then
	        local tmp = {}
	        tmp.product = res.product
	        tmp.game = res.game
	        tmp.name = res.name
	        tmp.version = version
	        tmp.icon = res.icon
	        tmp.productType = res.productType
	        externGameMgr:saveGameToLocalGameList(tmp)
	    end

        -- if res.roomId > 0 then 
            -- cclog("--- quick enter roomId", res.roomId)
            -- hallSendMgr:quickEnterRoom(res.roomId,false ,version) --返回 1102
        -- else                                                    
            -- hallSendMgr:sendEnterGame(res.product, version)
        -- end

        if gameNetMgr:isSessionOpen() then
            cclog("ComGatewayHandller:recvCheckGotoGame >>> socket is connent")
            gatewaySendMgr:sendGotoGame(res.product, version, res.roomId)
        else
            cclog("ComGatewayHandller:recvCheckGotoGame >>> socket is lost")
            gameState:changeState(GAMESTATE.STATE_LOGIN)

        end

    end

    local baseVersion = externGameMgr:getGameVersionByName(res.game)
    if baseVersion == res.version then 
        callback_func()
    else
        msgMgr:closeNetMsg("netJumpInfo")
        local function tips_func()
            launcherSceneMgr:setManage(downGameMgr)
            downGameMgr:updateStart(res.game, {down_url = res.download,updata_url = res.hotUpdate, server_version = res.version},
                        --更新完的回调函数
                        function(params) callback_func(params, true) end )
        end
        if platformMgr:get_Net_type() == 10010 then 
            tips_func()
        else
        	if res.roomId >0 then
        		msgMgr:showConfirmMsg(string.format("您已经在【%s】的（ID:%s）房间中，但当前网络不是Wifi，必须先下载该游戏方可进入", res.name, res.roomId),tips_func)
        	else
            	msgMgr:showAskMsg(string.format("当前网络不是Wifi，是否消耗流量下载游戏【%s】", res.name),tips_func)
            end
            
        end    
    end
end



function ComGatewayHandller:recvGotoGame(obj)
	cclog("ComGatewayHandller:recvGotoGame  >>>>>>>>")
    local res = {}
    res.key = obj:readString()
    res.product = obj:readString()
    res.version = obj:readString()
    res.game = obj:readString()
    res.userId = obj:readLong()  --玩家平台id
    cclog("res.userId >>>", res.userId)


    local function callback() 

        lua_load("gameStar").new(res)
    end
    externGameMgr:enterGameByName(res.game, callback)
end



return ComGatewayHandller







