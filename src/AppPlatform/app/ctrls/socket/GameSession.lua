--@会话
--@Author 	sunfan
--@date 	2018/03/29
local GameNet = require("app.ctrls.socket.GameSocket")
local GameSession = class("GameSession")
--默认重连次数
local RETRYTIMES = 0

function GameSession:ctor(params)
	--IP
	self._ip = params.ip
	--端口
	self._port = params.port
	--重试次数
	self._retryTimes = params.retryTimes or RETRYTIMES
	--消息处理器
	self._handler = params.handler
	self:_openNet()
end

function GameSession:_openNet()
	self._gameNet = GameNet.new({ip = self._ip,port = self._port,callback = self._handler})
end

function GameSession:_closeNet(msg)
	if self._gameNet then
		self._gameNet:onClose(msg)
	end
	self._gameNet = nil
end

function GameSession:netClose(msg)
	self:_closeNet(msg)
end

function GameSession:netReconnect()
	self:_openNet()
end

function GameSession:getNetState()
	if self._gameNet and (not self._gameNet:isClose()) then
		return GAME_SOCKET_STATE.SOCKET_STATE_NORMAL
	else
		return GAME_SOCKET_STATE.SOCKET_STATE_CLOSED
	end
end

function GameSession:update(dt)
	if self._gameNet then
		self._gameNet:update(dt)
		if self._gameNet:isClose() then
			if self._retryTimes > 0 then
				--重连
				self._retryTimes = self._retryTimes - 1
				self:_openNet()
			else
				self:_closeNet("No retryTimes")
			end
		end
	end
end

--发送数据
function GameSession:sendData(obj)
	if self._gameNet then
		self._gameNet:sendData(obj)
	end
end

--获取断开连接时的最终错误
function GameSession:getTheLastError()
	if self._gameNet then
		return self._gameNet:getTheLastError()
	end
	return "null"
end

return GameSession