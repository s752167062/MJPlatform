--@socket类
--@Author 	sunfan
--@date 	2018/03/28
local GameSocket = class("GameSocket")
--建立socket超时时间
local BUILD_SOCKET_TIMEOUT = 5
--协议校验超时时间
local CHECK_PRO_TIMEOUT = 5
--心跳间隔
local heartBeatCD = 3
--心跳超时
local heartBeatTimeOut = 6

local BUILD_SOCKET_STEP 		= 0		--建立网络阶段
local PROTO_ONE_SOCKET_STEP 	= 1		--业务第一次握手阶段
local PROTO_TWO_SOCKET_STEP 	= 2 	--业务第二次握手阶段
local PROTO_THREE_SOCKET_STEP 	= 3 	--业务第三次握手阶段
local PROTO_OVER_SOCKET_STEP 	= 4 	--网络校验完毕

local Read = require("app.ctrls.socket.Read")
-- local Write = require("app.ctrls.socket.Write")
function GameSocket:ctor(params)
	--IP
	self._ip 				= params.ip
	--端口
	self._port 				= params.port
	--断开连接时的最后错误(自定义逻辑错误)
	self._theLastError		= nil
	--接收回调
	self._receiveHandle 	= params.callback
	--是否已经收到服务器第一个包(密钥)
	self._isReceiveKey 		= false
	--是否已向服务器发送首包
	self._sendFirstPackage  = false
	--校验计时器
	self._socketCheckDt 	= 0
	--步骤
	self._checkStep 		= BUILD_SOCKET_STEP
	--socket是否关闭
	self._isClose 			= false
	--连接网络
	self:connectServer()
	--是否心跳开始
	self._isSendHeart = false
	--心跳发送计时器
	self._heartBeatSendCount = 0
	--心跳超时计时器
	self._heartBeatTimeOutCount = 0
end

--初始化网络
function GameSocket:connectServer()
	if self._ip and self._port then
		self._socketId = cpp_net_open(self._ip, self._port)
	end
end

--获取状态
function GameSocket:isClose()
	return self._isClose
end

--开始发送准备
function GameSocket:_sendStart(protoId)
	if protoId ~= 1 then 
		release_print("#############Send protoId id:"..protoId.."#############", gameNetMgr:getServerId(), self._socketId)
	end
	if self._socketId and self._socketId > 0 then
	    local buffId = cpp_buff_create()
	    cpp_buff_writeSerialNumAndProtocol(buffId,self._socketId,protoId,gameNetMgr:getServerId())
	    return buffId
	else
		return -1
	end
end

--发送结束
function GameSocket:_sendEnd(buffId)
	if self._socketId and self._socketId > 0 then
	    cpp_buff_encode(buffId)
	    cpp_net_send(self._socketId,buffId)
	    --有发送协议不需要发送心跳包
	    self._heartBeatSendCount = 0
	    cclog("GameSocket:_sendEnd >>>")
	end
end

--向服务器发送首包
function GameSocket:_sendFirstPack()
	self._checkStep = PROTO_ONE_SOCKET_STEP
	self._socketCheckDt = 0
	local buffId = self:_sendStart(8)
	if buffId >= 0 then
		LOG("######################SendFirstPackageOK#########################")
		self:_sendEnd(buffId)
	else
		LOG("######################SendFirstPackageFail#########################")
	end
end

--关闭网络链接
function GameSocket:onClose(msg)
	LOG(msg)
	self._isClose = true
	self._theLastError = msg
	self._isSendHeart = false
	if self._socketId then
		LOG("Close socket id:"..self._socketId)
		cpp_net_close(self._socketId)
		self._socketId = nil
	end
end

function GameSocket:update(dt)
	--socket存在,开始检测状态
	if self._socketId then
		--检测socket状态
	    local statu = cpp_net_getStatu(self._socketId)
	    if statu == 1 then--连接成功
	        if not self._isReceiveKey then
	            local serial = cpp_net_serialNumber(self._socketId)
	            --先检测是否收到序列号
	            if serial ~= -1 then
	                self._isReceiveKey = true
	                --连接校验
	                self:_checkConnect_one()
	            else
	            	--客户端主动发首包
	            	if not self._sendFirstPackage then
	            		self:_sendFirstPack()
	            		self._sendFirstPackage = true
	            	end
	            end
	        else
	        	--收到密钥后正常接收
	            local buffId = tonumber(cpp_net_receive(self._socketId))
	            while buffId ~= -1 do
	            	--接收数据
	                self:onReceive(buffId)
	                buffId = cpp_net_receive(self._socketId)
	            end
	        end
	    elseif statu == -1 then--连接失败或者socket丢失
	    	--网络层底层错误
	    	local m_sysError = ""
	    	if cpp_getTheLastErrorCode then
		    	m_sysError = cpp_getTheLastErrorCode()
		    	if m_sysError then
		    		m_sysError = ":"..m_sysError
		    	end
		    end
	        self:onClose(msgMgr:getMsg("NONET_CANUSE_OUTOFTIME")..m_sysError)
	    end
	    self:_updateCheckConnect(dt)
	    if self._isSendHeart then
	    	self._heartBeatSendCount = self._heartBeatSendCount + dt
	    	if self._heartBeatSendCount >= heartBeatCD then
	    		self._heartBeatSendCount = 0
	    		self:sendHeartBeat()
	    	end
	    	self._heartBeatTimeOutCount = self._heartBeatTimeOutCount + dt
	    	if self._heartBeatTimeOutCount >= heartBeatTimeOut then
	    		self._heartBeatTimeOutCount = 0
	    		self:onClose(msgMgr:getMsg("HEARTBEAT_OUTOFTIME"))
	    	end
		end
	end
end

function GameSocket:sendHeartBeat()
	Write.new(1):send()
end

--socket校验
function GameSocket:_updateCheckConnect(dt)
	if self._checkStep == PROTO_OVER_SOCKET_STEP then
		return
	end
	self._socketCheckDt = self._socketCheckDt + dt
	if self._checkStep 	== BUILD_SOCKET_STEP then
		if self._socketCheckDt > BUILD_SOCKET_TIMEOUT then
		    --建立socket超时,关闭
		    self:onClose(msgMgr:getMsg("BUILD_NET_OUTOFTIME"))
		end
	elseif self._checkStep <= PROTO_THREE_SOCKET_STEP then
		if self._socketCheckDt >= CHECK_PRO_TIMEOUT then
			--协议校验超时
		    self:onClose(msgMgr:getMsg("PROTOCOL_OUTOFTIME")..":"..self._checkStep)
		end
	end
end

--接收数据
function GameSocket:onReceive(buffId)
	--协议号(包头)
    local proId = cpp_buff_readShort(buffId)
    
    --socketId
    local socketId = cpp_buff_readShort(buffId)
    --序列号
    local serinum = cpp_buff_readInt(buffId)
    --服务器ID
    local serverId = cpp_buff_readShort(buffId)

    
    if proId ~= 1 then
    	release_print("############Receive Package:"..proId.."############", serverId)
    end
    if proId == nil then
        self:onClose(msgMgr:getMsg("RECIVE_PROTOCOL_FAIL"))
        return
    end
    if proId == 0 then
    	self:_checkConnect_two()
    elseif proId == 1 then
    	--心跳回复协议,不管
    	release_print("############Receive Package:"..proId.."############", serverId)
    elseif proId == 30001 then
    	self:_checkConnect_three(Read.new({buffId = buffId,proId = proId,serverId = serverId}))
    else
	    self._receiveHandle:receiveMsg(Read.new({buffId = buffId,proId = proId,serverId = serverId}))
	end
	--只要收到协议心跳超时计时器就重置
	self._heartBeatTimeOutCount = 0
	cpp_buff_delete(buffId)
end

--连接校验(一
function GameSocket:_checkConnect_one()
	self._checkStep = PROTO_TWO_SOCKET_STEP
	self._socketCheckDt = 0
	Write.new(0):send()
	LOG("校验1")
end

--连接校验(二)
function GameSocket:_checkConnect_two()
	self._checkStep = PROTO_THREE_SOCKET_STEP
	self._socketCheckDt = 0
	local write = Write.new(30001)
	write:writeShort(gameNetMgr:getServerId())
	write:writeString(gameConfMgr:getInfo("Ip"))
	write:writeString(gameConfMgr:getInfo("hostKey"))
	write:writeLong(gameConfMgr:getInfo("userId"))
	write:send()
	LOG("校验2")
end

--连接校验(三)
function GameSocket:_checkConnect_three(obj)
	self._checkStep = PROTO_OVER_SOCKET_STEP
	self._socketCheckDt = -1
	self._isSendHeart = true
    LOG("校验3")
    msgMgr:closeNetMsg("GAME_CHANGE_LINE")
end

--发送协议数据
function GameSocket:sendData(obj)
	if self._socketId and self._socketId > 0 then
	    local buffId = self:_sendStart(obj:getProtocolId())
	    local data = obj:getBuff()
	    for loop = 1,#data do
	    	data[loop].callback(buffId,data[loop].data)
	    end
	    self:_sendEnd(buffId)
	end
end

--获取断开连接时的最终错误
function GameSocket:getTheLastError()
	return self._theLastError
end







return GameSocket




