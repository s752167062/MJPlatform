--@协议分发管理类
--@Author 	sunfan
--@date 	2018/03/29
local HandlerManager = class("HandlerManager")
function HandlerManager:ctor(params)
    self._proHandler = {}
    self._proHandler["gameNet"] = require("app.ctrls.socket.ComHallHandller").new()
    self._proHandler["gateway"] = require("app.ctrls.socket.ComGatewayHandller").new()
end

--注册协议处理者
function HandlerManager:registReceiveHandler(handler)
    self._proHandler["customer"] = handler
end

--移除协议处理者
function HandlerManager:removeReceiveHandler()
    self._proHandler["customer"] = nil
end

--所有协议下行出口
function HandlerManager:receiveMsg(obj)
	if obj then
		if obj:getProId() == 30002 then

			--更换服务器ID
			local serverID = obj:readShort()
			local isReConnect = (serverID == gameNetMgr:getServerId())
			release_print("HandlerManager:receiveMsg setServerId>>>", serverID)
			gameNetMgr:setServerId(serverID)
		    if gameNetMgr:getServerTypeByServerId(gameNetMgr:getServerId()) == GAME_SERVER_TYPE.SERVER_TYPE_COMMHALL then
		    	--平台直接发送进入平台协议
		    	if self._proHandler["gameNet"].changeServerId then
		    		self._proHandler["gameNet"]:changeServerId({serverID = serverID,isReConnect = isReConnect})
		    	else
		    		LOG("Error ,No handler changeServerId at gameNet")
		    	end
		    else
		    	if self._proHandler["customer"] and self._proHandler["customer"].changeServerId then
		    		self._proHandler["customer"]:changeServerId({serverID = serverID,isReConnect = isReConnect})
		    	else
		    		LOG("Error ,No handler changeServerId at customer")
		    	end
		    end
		    
		elseif obj:getProId() == 30003 then
			--服务器映射表
			gameNetMgr:saveServerIdArray(obj:readString())
		else

		    --分发
		    if obj:getProId() >= 30000 then
		    	self._proHandler["gateway"]:receiveMsg(obj)

		    elseif gameNetMgr:getServerTypeByServerId(obj:getServerId()) == GAME_SERVER_TYPE.SERVER_TYPE_COMMHALL then
		    	eventMgr:dispatchEvent("changeLoading_view--finish", {})
		    	self._proHandler["gameNet"]:receiveMsg(obj)
		    	
		    else
		    	eventMgr:dispatchEvent("changeLoading_view--finish", {gotoGame = true})
		    	if self._proHandler["customer"] then
		    		self._proHandler["customer"]:receiveMsg(obj)
		    	else
		    		LOG("Error ,No Customer handler:"..obj:getProId()..":"..obj:getServerId())
		    	end
		    	
		    end
		    
		end
	end
end

return HandlerManager