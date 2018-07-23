
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
    
	self._proFuns[30005] = handler(self,self.recvMsgFromPlayer) --收到玩家发送的消息
	self._proFuns[30006] = handler(self,self.recvCheckGotoGame) --下发版本信息给客户端校验版本
	self._proFuns[30007] = handler(self,self.recvGotoGame) -- 请求进游戏返回
    self._proFuns[30008] = handler(self,self.recvHint)  --服务器提示信息
    self._proFuns[30009] = handler(self,self.recvEroor)  --服务器错误提示
end

function ComGatewayHandller:recvEroor(obj)
    --0 平台 
    --1 进入扩展游戏大厅失败  
    --2 扩展游戏俱乐部失败  
    --3 扩展游戏房间失败
    local errorCode = obj:readByte()
    local msg = obj:readString()

    cclog("ComGatewayHandller:recvEroor", errorCode, msg)
    -- gameState:gotoLoginScene()
    externGameMgr:reqGotoPlatform()
    msgMgr:showToast(msg, 3) 




    -- 如果是状态在扩展游戏，则此处不处理，而是交由扩展游戏自己的错误处理机制
    -- local cur_serverId = gameNetMgr:getServerId()
    -- local cur_serverType = gameNetMgr:getServerTypeByServerId(cur_serverId)

    -- if errorCode == 0 then

    -- elseif errorCode == 1 then
    -- elseif errorCode == 2 then
    --     --判断是否是在扩展游戏的大厅服，扩展游戏的大厅服是入口，该大厅服去俱乐部失败
    --     if cur_serverType == GAME_SERVER_TYPE.SERVER_TYPE_HALL then
    --         externGameMgr:reqGotoPlatform()
    --         msgMgr:showToast(msg, 3) 
    --     end
    -- elseif errorCode == 3 then
    --     --判断是否是在扩展游戏的大厅服，扩展游戏的大厅服是入口，该大厅服去房间失败
    --     if cur_serverType == GAME_SERVER_TYPE.SERVER_TYPE_HALL then
    --         externGameMgr:reqGotoPlatform()
    --         msgMgr:showToast(msg, 3) 
    --     end
    -- end

    

end

--服务器提示信息
function ComGatewayHandller:recvHint(obj)
    local str = obj:readString()
    local res = dkj.decode(str)
    print_r(res)
    msgMgr:showToast(res.msg, 3)

    if gameState:isState(GAMESTATE.STATE_LOADING) or gameState:isState(GAMESTATE.STATE_UPDATE) then
        externGameMgr:reqGotoPlatform()
    end
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
    res.isInRoom = obj:readByte()  -- 0不在 1 在， 有房间号玩家未必就在房间里面

    

    local targetPlatform = cc.Application:getInstance():getTargetPlatform() 
    if targetPlatform == cc.PLATFORM_OS_ANDROID or targetPlatform == cc.PLATFORM_OS_WINDOWS  then
        res.hotUpdate = res.update_android
    elseif targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD or targetPlatform == cc.PLATFORM_OS_MAC then
        res.hotUpdate = res.update_ios
    end

    res.download = ""  --没有真正意义的整更

  
    -- eventMgr:dispatchEvent("HallProtocol.recvUpdateOrDownGame",res) 
    --test
    -- res.hotUpdate = string.format("192.168.1.200/zhuzhi_zhuzhijihe/ExternGameAssets/%s/hotUpdate/1.0.0a", res.game)
    res.hotUpdate = string.format("192.168.1.59/%s/hotUpdate/1.0.0a", res.game)


    print_r(res)

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
            if isDownload then --如果是更新完回调就再次校验版本
                
                local e_data = platformExportMgr:getEnterParams()
                if res.roomId >0 then
                    gatewaySendMgr:sendCheckGotoGame(1, res.roomId)
                else
                    gatewaySendMgr:sendCheckGotoGame(0, res.product)
                end
                if e_data then
                    platformExportMgr:setEnterParams(e_data.epType, e_data.params)
                end
            else  --如果是非更新完回调，直接请求进入游戏
                gatewaySendMgr:sendGotoGame(res.product, version, res.roomId)
            end
        else
            cclog("ComGatewayHandller:recvCheckGotoGame >>> socket is lost")
            -- gameState:changeState(GAMESTATE.STATE_LOGIN)
            gameState:gotoLoginScene()

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

        local str = "当前网络不是Wifi，是否消耗流量下载游戏"
        if platformMgr:get_Net_type() == 10010 then
            str = "是否下载游戏"
        end

        if res.isInRoom == 1 then
            msgMgr:showConfirmMsg(string.format("您已经在【%s】的（ID:%s）房间中，%s",res.name, res.roomId, str),tips_func)
        else
            cclog("gameState:isState(GAMESTATE.STATE_LOGIN)", gameState:isState(GAMESTATE.STATE_LOGIN))
            if gameState:isState(GAMESTATE.STATE_LOGIN) then
                msgMgr:showConfirmMsg(string.format("%s【%s】",str, res.name),tips_func)
            else
                msgMgr:showAskMsg(string.format("%s【%s】",str, res.name),tips_func)
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
    -- externGameMgr:enterGameByName(res.game, callback)
    gameState:changeState(GAMESTATE.STATE_LOADING)
    gameState:setEnterParams(GAMESTATE.STATE_LOADING, {gameName = res.game}, callback)
end



return ComGatewayHandller







