--@读buff
--@Author 	sunfan
--@date 	2018/03/29
local Read = class("Read")

function Read:ctor(params)
	self._buffId = params.buffId
	self._proId = params.proId
	self._serverId = params.serverId
end

function Read:getServerId()
	return self._serverId
end

function Read:getProId()
	return self._proId
end

function Read:readByte()
	return cpp_buff_readByte(self._buffId)
end

function Read:readShort()
	return cpp_buff_readShort(self._buffId)
end

function Read:readInt()
	return cpp_buff_readInt(self._buffId)
end

function Read:readLong()
	return cpp_buff_readLong(self._buffId)
end

function Read:readString()
	return cpp_buff_readString(self._buffId)
end

function Read:readBoolean()
	return cpp_buff_readBoolean(self._buffId)
end

function Read:readLength()
	return cpp_buff_readLength(self._buffId)
end

function Read:readBytes()
	return cpp_buff_readBytes(self._buffId)
end

function Read:readJsonData(prams)
	return cpp_buff_readJsonData(self._buffId,prams)
end

return Read
