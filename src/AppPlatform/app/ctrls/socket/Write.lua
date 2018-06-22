--@写buff
--@Author 	sunfan
--@date 	2017/03/29
local Write = class("Write")

function Write:ctor(params)
	self._protocolId = params
	self._buff = {}
end

function Write:getProtocolId()
	return self._protocolId
end

function Write:getBuff()
	return self._buff
end

function Write:writeByte(params)
	self._buff[#self._buff + 1] = {data = params,callback = cpp_buff_writeByte,type = "byte"}
end

function Write:writeShort(params)
	self._buff[#self._buff + 1] = {data = params,callback = cpp_buff_writeShort,type = "short"}
end

function Write:writeInt(params)
	self._buff[#self._buff + 1] = {data = params,callback = cpp_buff_writeInt,type = "int"}
end

function Write:writeLong(params)
	self._buff[#self._buff + 1] = {data = params,callback = cpp_buff_writeLong,type = "long"}
end

function Write:writeString(params)
	self._buff[#self._buff + 1] = {data = params,callback = cpp_buff_writeString,type = "string"}
end

function Write:writeBoolean(params)
	self._buff[#self._buff + 1] = {data = params,callback = cpp_buff_writeBoolean,type = "boolean"}
end

function Write:writeLength(params)
	self._buff[#self._buff + 1] = {data = params,callback = cpp_buff_writeLength,type = "length"}
end

function Write:writeBytes(params)
	self._buff[#self._buff + 1] = {data = params,callback = cpp_buff_writeBytes,type = "bytes"}
end

function Write:writeNewBean(params)
	self._buff[#self._buff + 1] = {data = params,callback = cpp_buff_writeNewBean,type = "newBean"}
end

function Write:writeBeanByte(params)
	self._buff[#self._buff + 1] = {data = params,callback = cpp_buff_writeBeanByte,type = "beanByte"}
end

function Write:writeBeanShort(params)
	self._buff[#self._buff + 1] = {data = params,callback = cpp_buff_writeBeanShort,type = "beanShort"}
end

function Write:writeBeanInt(params)
	self._buff[#self._buff + 1] = {data = params,callback = cpp_buff_writeBeanInt,type = "beanInt"}
end

function Write:writeBeanLong(params)
	self._buff[#self._buff + 1] = {data = params,callback = cpp_buff_writeBeanLong,type = "beanLong"}
end

function Write:writeBeanString(params)
	self._buff[#self._buff + 1] = {data = params,callback = cpp_buff_writeBeanString,type = "beanString"}
end

function Write:writeBeanBoolean(params)
	self._buff[#self._buff + 1] = {data = params,callback = cpp_buff_writeBeanBoolean,type = "beanBoolean"}
end

function Write:writeBeanLength(params)
	self._buff[#self._buff + 1] = {data = params,callback = cpp_buff_writeBeanLength,type = "beanLength"}
end

function Write:writeBeanBytes(params)
	self._buff[#self._buff + 1] = {data = params,callback = cpp_buff_writeBeanBytes,type = "beanBytes"}
end

function Write:send()
	gameNetMgr:sendData(self)
end

return Write
