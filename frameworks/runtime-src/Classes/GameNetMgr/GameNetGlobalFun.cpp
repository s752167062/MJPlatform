/*
@网络层全局函数
@author sunfan
@date	2017/05/04
*/

#include "GameNetGlobalFun.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	#include "DataBuff.h"
#endif
#include "ToolBASE64.h"

GameNetGlobalFun* GameNetGlobalFun::m_instance = nullptr;

GameNetGlobalFun* GameNetGlobalFun::getInstance() 
{
	if (m_instance == nullptr) 
	{
		m_instance = new GameNetGlobalFun();
	}
	return m_instance;
}

void GameNetGlobalFun::bind(lua_State* ls) 
{
	this->ls = ls;

	lua_register(ls, "cpp_net_open", cpp_net_open);
	lua_register(ls, "cpp_net_close", cpp_net_close);
	lua_register(ls, "cpp_net_receive", cpp_net_receive);
	lua_register(ls, "cpp_net_send", cpp_net_send);
	lua_register(ls, "cpp_net_getStatu", cpp_net_getStatu);
	lua_register(ls, "cpp_net_buffer_in_size", cpp_net_buffer_in_size);
	lua_register(ls, "cpp_net_buffer_out_size", cpp_net_buffer_out_size);

	lua_register(ls, "cpp_buff_create", cpp_buff_create);
	lua_register(ls, "cpp_buff_delete", cpp_buff_delete);
	lua_register(ls, "cpp_buff_toString", cpp_buff_toString);
	lua_register(ls, "cpp_buff_encode", cpp_buff_encode);
	lua_register(ls, "cpp_buff_readByte", cpp_buff_readByte);
	lua_register(ls, "cpp_buff_readShort", cpp_buff_readShort);
	lua_register(ls, "cpp_buff_readInt", cpp_buff_readInt);
	lua_register(ls, "cpp_buff_readLong", cpp_buff_readLong);
	lua_register(ls, "cpp_buff_readString", cpp_buff_readString);
	lua_register(ls, "cpp_buff_readBoolean", cpp_buff_readBoolean);
	lua_register(ls, "cpp_buff_readLength", cpp_buff_readLength);
	lua_register(ls, "cpp_buff_readBytes", cpp_buff_readBytes);
	lua_register(ls, "cpp_buff_readJsonData", cpp_buff_readJsonData);

	lua_register(ls, "cpp_buff_writeByte", cpp_buff_writeByte);
	lua_register(ls, "cpp_buff_writeShort", cpp_buff_writeShort);
	lua_register(ls, "cpp_buff_writeInt", cpp_buff_writeInt);
	lua_register(ls, "cpp_buff_writeLong", cpp_buff_writeLong);
	lua_register(ls, "cpp_buff_writeString", cpp_buff_writeString);
	lua_register(ls, "cpp_buff_writeBoolean", cpp_buff_writeBoolean);
	lua_register(ls, "cpp_buff_writeLength", cpp_buff_writeLength);
	lua_register(ls, "cpp_buff_writeBytes", cpp_buff_writeBytes);
	lua_register(ls, "cpp_heard_param", cpp_heard_param);
	lua_register(ls, "cpp_buff_writeNewBean", cpp_buff_writeNewBean);
	lua_register(ls, "cpp_buff_writeBeanByte", cpp_buff_writeBeanByte);
	lua_register(ls, "cpp_buff_writeBeanShort", cpp_buff_writeBeanShort);
	lua_register(ls, "cpp_buff_writeBeanInt", cpp_buff_writeBeanInt);
	lua_register(ls, "cpp_buff_writeBeanLong", cpp_buff_writeBeanLong);
	lua_register(ls, "cpp_buff_writeBeanString", cpp_buff_writeBeanString);
	lua_register(ls, "cpp_buff_writeBeanBoolean", cpp_buff_writeBeanBoolean);
	lua_register(ls, "cpp_buff_writeBeanLength", cpp_buff_writeBeanLength);
	lua_register(ls, "cpp_buff_writeBeanBytes", cpp_buff_writeBeanBytes);
	lua_register(ls, "cpp_buff_testRestartRead", cpp_buff_testRestartRead);
	
	lua_register(ls, "cpp_net_serialNumber", cpp_net_serialNumber);
	lua_register(ls, "cpp_buff_writeSerialNumAndProtocol", cpp_buff_writeSerialNumAndProtocol);
	lua_register(ls, "cpp_getData_buff", cpp_getData_buff);
	lua_register(ls, "cpp_buffNew_writeString", cpp_buffNew_writeString);
	lua_register(ls, "cpp_buffNew_readString", cpp_buffNew_readString);
	lua_register(ls, "cpp_DataEnCodeType1", cpp_DataEnCodeType1);
	lua_register(ls, "cpp_getTheLastErrorCode", cpp_getTheLastErrorCode);
}
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
#pragma mark Socket
#endif

int GameNetGlobalFun::cpp_net_open(lua_State* ls) 
{
	const char* ip = lua_tostring(ls, 1);
	int port = lua_tointeger(ls, 2);
	int sid = GameSocket::openSocket(ip, port);
	lua_settop(ls, 0);
	lua_pushinteger(ls, sid);
	return 1;
}

int GameNetGlobalFun::cpp_net_close(lua_State* ls) 
{
	int sid = lua_tointeger(ls, 1);
	GameSocket::closeSocket(sid);
	return 0;
}

int GameNetGlobalFun::cpp_net_receive(lua_State* ls) 
{
	int sid = lua_tointeger(ls, 1);
	lua_settop(ls, 0);
	GameSocket* so = GameSocket::getSocket(sid);
	if (so == nullptr) 
	{
		lua_pushinteger(ls, -1);
		return 1;
	}
	int pid = so->getDataBuff_in();
	lua_pushinteger(ls, pid);
	return 1;
}

int GameNetGlobalFun::cpp_net_send(lua_State* ls)
{
	int sid = lua_tointeger(ls, 1);
	GameSocket* so = GameSocket::getSocket(sid);
	if (so == nullptr) 
	{
		return 0;
	}
	int pid = lua_tointeger(ls, 2);
	so->putDataBuff_out(pid);
	return 0;
}

int GameNetGlobalFun::cpp_net_getStatu(lua_State* ls) 
{
	int sid = lua_tointeger(ls, 1);
	lua_settop(ls, 0); 
	GameSocket* so = GameSocket::getSocket(sid);
	if (so == nullptr) 
	{
		lua_pushinteger(ls, -1);
	}
	else 
	{
		int statu = so->getStatu();
		lua_pushinteger(ls, statu);
	}
	return 1;
}

int GameNetGlobalFun::cpp_net_buffer_in_size(lua_State* ls)
{
	int sid = lua_tointeger(ls, 1);
	lua_settop(ls, 0);
	GameSocket* so = GameSocket::getSocket(sid);
	if (so == nullptr) 
	{
		lua_pushinteger(ls, -1);
	}
	else 
	{
		lua_pushinteger(ls, so->getDataBuff_in_size());
	}
	return 1;
}

int GameNetGlobalFun::cpp_net_buffer_out_size(lua_State* ls) 
{
	int sid = lua_tointeger(ls, 1);
	lua_settop(ls, 0);
	GameSocket* so = GameSocket::getSocket(sid);
	if (so == nullptr) 
	{
		lua_pushinteger(ls, -1);
	}
	else 
	{
		lua_pushinteger(ls, so->getDataBuff_out_size());
	}
	return 1;
}
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
	#pragma mark DataBuff
#endif 

int GameNetGlobalFun::cpp_buff_create(lua_State* ls) 
{
	int pid = DataBuff::createBuffer();
	lua_settop(ls, 0);
	lua_pushinteger(ls, pid);
	return 1;
}

int GameNetGlobalFun::cpp_buff_delete(lua_State* ls) 
{
	int pid = lua_tointeger(ls, 1);
	DataBuff::deleteBuffer(pid);
	return 0;
}

int GameNetGlobalFun::cpp_buff_toString(lua_State* ls)
{
	int pid = lua_tointeger(ls, 1);
	DataBuff* buff = DataBuff::getDataBuffer(pid);
	if (buff == nullptr) 
	{
		return 0;
	}
	std::string str = buff->toString();
	lua_settop(ls, 0);
	lua_pushstring(ls, str.c_str());
	return 1;
}

int GameNetGlobalFun::cpp_buff_encode(lua_State* ls) 
{
	int pid = lua_tointeger(ls, 1);
	DataBuff* buff = DataBuff::getDataBuffer(pid);
	if (buff == nullptr) 
	{
		return 0;
	}
	buff->encode();
	return 0;
}

int GameNetGlobalFun::cpp_buff_readByte(lua_State* ls) 
{
	int pid = lua_tointeger(ls, 1);
	DataBuff* buff = DataBuff::getDataBuffer(pid);
	if (buff == nullptr) 
	{
		return 0;
	}
	unsigned char res = buff->readByte();
	lua_settop(ls, 0);
	lua_pushinteger(ls, res);
	return 1;
}

int GameNetGlobalFun::cpp_buff_readShort(lua_State* ls) 
{
	int pid = lua_tointeger(ls, 1);
	DataBuff* buff = DataBuff::getDataBuffer(pid);
	if (buff == nullptr) 
	{
		return 0;
	}
	int res = buff->readShort();
	lua_settop(ls, 0);
	lua_pushinteger(ls, res);
	return 1;
}

int GameNetGlobalFun::cpp_buff_readInt(lua_State* ls) 
{
	int pid = lua_tointeger(ls, 1);
	DataBuff* buff = DataBuff::getDataBuffer(pid);
	if (buff == nullptr) 
	{
		return 0;
	}
	int res = buff->readInt();
	lua_settop(ls, 0);
	lua_pushinteger(ls, res);
	return 1;
}

int GameNetGlobalFun::cpp_buff_readLong(lua_State* ls) 
{
	int pid = lua_tointeger(ls, 1);
	DataBuff* buff = DataBuff::getDataBuffer(pid);
	if (buff == nullptr) 
	{
		return 0;
	}
	long long res = buff->readLong();
	lua_settop(ls, 0);
	lua_pushnumber(ls, res);
	return 1;
}

int GameNetGlobalFun::cpp_buff_readString(lua_State* ls) 
{
	int pid = lua_tointeger(ls, 1);
	DataBuff* buff = DataBuff::getDataBuffer(pid);
	if (buff == nullptr) 
	{
		return 0;
	}
	std::string res = buff->readString();
	lua_settop(ls, 0);
	lua_pushstring(ls, res.c_str());
	return 1;
}

int GameNetGlobalFun::cpp_buff_readJsonData(lua_State* ls) 
{
	int pid = lua_tointeger(ls, 1);
	int len = lua_tointeger(ls, 2);
	DataBuff* buff = DataBuff::getDataBuffer(pid);
	if (buff == nullptr) 
	{
		return 0;
	}
	std::string res = buff->readJsonString(len);
	lua_settop(ls, 0);
	lua_pushstring(ls, res.c_str());
	return 1;
}

int GameNetGlobalFun::cpp_buff_readBoolean(lua_State* ls) 
{
	int pid = lua_tointeger(ls, 1);
	DataBuff* buff = DataBuff::getDataBuffer(pid);
	if (buff == nullptr) 
	{
		return 0;
	}
	bool res = buff->readBoolean();
	lua_settop(ls, 0);
	lua_pushboolean(ls, res);
	return 1;
}

int GameNetGlobalFun::cpp_buff_readLength(lua_State* ls) 
{
	int pid = lua_tointeger(ls, 1);
	DataBuff* buff = DataBuff::getDataBuffer(pid);
	if (buff == nullptr) 
	{
		return 0;
	}
	int res = buff->readLength();
	lua_settop(ls, 0);
	lua_pushinteger(ls, res);
	return 1;
}

int GameNetGlobalFun::cpp_buff_readBytes(lua_State* ls) 
{
	return 0;
}

int GameNetGlobalFun::cpp_buff_writeByte(lua_State* ls) 
{
	int pid = lua_tointeger(ls, 1);
	unsigned char data = lua_tointeger(ls, 2);
	DataBuff* buff = DataBuff::getDataBuffer(pid);
	if (buff == nullptr) 
	{
		return 0;
	}
	buff->writeByte(data);
	return 0;
}

int GameNetGlobalFun::cpp_buff_writeShort(lua_State* ls) 
{
	int pid = lua_tointeger(ls, 1);
	short data = lua_tointeger(ls, 2);
	DataBuff* buff = DataBuff::getDataBuffer(pid);
	if (buff == nullptr) 
	{
		return 0;
	}
	buff->writeShort(data);
	return 0;
}

int GameNetGlobalFun::cpp_buff_writeInt(lua_State* ls) 
{
	int pid = lua_tointeger(ls, 1);
	int data = lua_tointeger(ls, 2);
	DataBuff* buff = DataBuff::getDataBuffer(pid);
	if (buff == nullptr) 
	{
		return 0;
	}
	buff->writeInt(data);
	return 0;
}

int GameNetGlobalFun::cpp_buff_writeLong(lua_State* ls) 
{
	int pid = lua_tointeger(ls, 1);
	long data = lua_tointeger(ls, 2);
	DataBuff* buff = DataBuff::getDataBuffer(pid);
	if (buff == nullptr) 
	{
		return 0;
	}
	buff->writeLong(data);
	return 0;
}

int GameNetGlobalFun::cpp_buff_writeString(lua_State* ls) 
{
	int pid = lua_tointeger(ls, 1);
	const char* data = lua_tostring(ls, 2);
	DataBuff* buff = DataBuff::getDataBuffer(pid);
	if (buff == nullptr) 
	{
		return 0;
	}
	buff->writeString(data);
	return 0;
}

int GameNetGlobalFun::cpp_buff_writeBoolean(lua_State* ls) 
{
	int pid = lua_tointeger(ls, 1);
	bool data = lua_toboolean(ls, 2);
	DataBuff* buff = DataBuff::getDataBuffer(pid);
	if (buff == nullptr) 
	{
		return 0;
	}
	buff->writeBoolean(data);
	return 0;
}

int GameNetGlobalFun::cpp_buff_writeLength(lua_State* ls) 
{
	int pid = lua_tointeger(ls, 1);
	int data = lua_tointeger(ls, 2);
	DataBuff* buff = DataBuff::getDataBuffer(pid);
	if (buff == nullptr) 
	{
		return 0;
	}
	buff->writeLength(data);
	return 0;
}

int GameNetGlobalFun::cpp_buff_writeBytes(lua_State* ls) 
{
	return 0;
}


int GameNetGlobalFun::cpp_buff_writeNewBean(lua_State* ls) 
{
	int pid = lua_tointeger(ls, 1);
	DataBuff* buff = DataBuff::getDataBuffer(pid);
	if (buff == nullptr) 
	{
		return 0;
	}
	buff->writeNewBean();
	return 0;
}

int GameNetGlobalFun::cpp_buff_writeBeanByte(lua_State* ls) 
{
	int pid = lua_tointeger(ls, 1);
	unsigned char data = lua_tointeger(ls, 2);
	DataBuff* buff = DataBuff::getDataBuffer(pid);
	if (buff == nullptr) 
	{
		return 0;
	}
	buff->writeBeanByte(data);
	return 0;
}

int GameNetGlobalFun::cpp_buff_writeBeanShort(lua_State* ls) 
{
	int pid = lua_tointeger(ls, 1);
	short data = lua_tointeger(ls, 2);
	DataBuff* buff = DataBuff::getDataBuffer(pid);
	if (buff == nullptr) 
	{
		return 0;
	}
	buff->writeBeanShort(data);
	return 0;
}

int GameNetGlobalFun::cpp_buff_writeBeanInt(lua_State* ls) 
{
	int pid = lua_tointeger(ls, 1);
	int data = lua_tointeger(ls, 2);
	DataBuff* buff = DataBuff::getDataBuffer(pid);
	if (buff == nullptr) 
	{
		return 0;
	}
	buff->writeBeanInt(data);
	return 0;
}

int GameNetGlobalFun::cpp_buff_writeBeanLong(lua_State* ls) 
{
	int pid = lua_tointeger(ls, 1);
	long data = lua_tointeger(ls, 2);
	DataBuff* buff = DataBuff::getDataBuffer(pid);
	if (buff == nullptr) 
	{
		return 0;
	}
	buff->writeBeanLong(data);
	return 0;
}

int GameNetGlobalFun::cpp_buff_writeBeanString(lua_State* ls) 
{
	int pid = lua_tointeger(ls, 1);
	const char* data = lua_tostring(ls, 2);
	DataBuff* buff = DataBuff::getDataBuffer(pid);
	if (buff == nullptr) 
	{
		return 0;
	}
	buff->writeBeanString(data);
	return 0;
}

int GameNetGlobalFun::cpp_buff_writeBeanBoolean(lua_State* ls) 
{
	int pid = lua_tointeger(ls, 1);
	bool data = lua_toboolean(ls, 2);
	DataBuff* buff = DataBuff::getDataBuffer(pid);
	if (buff == nullptr) 
	{
		return 0;
	}
	buff->writeBeanBoolean(data);
	return 0;
}

int GameNetGlobalFun::cpp_buff_writeBeanLength(lua_State* ls) 
{
	int pid = lua_tointeger(ls, 1);
	int data = lua_tointeger(ls, 2);
	DataBuff* buff = DataBuff::getDataBuffer(pid);
	if (buff == nullptr) 
	{
		return 0;
	}
	buff->writeBeanLength(data);
	return 0;
}

int GameNetGlobalFun::cpp_buff_writeBeanBytes(lua_State* ls) 
{
	return 0;
}

int GameNetGlobalFun::cpp_buff_testRestartRead(lua_State* ls) 
{
	int pid = lua_tointeger(ls, 1);
	DataBuff* buff = DataBuff::getDataBuffer(pid);
	if (buff == nullptr) 
	{
		return 0;
	}
	buff->_index = 4;
	return 0;
}

int GameNetGlobalFun::cpp_heard_param(lua_State* ls)
{
	//YJGameSocket::_can_delegale_sendHeart = lua_tointeger(ls, 1);
	return 0;
}

int GameNetGlobalFun::cpp_net_serialNumber(lua_State* ls) 
{
	int sid = lua_tointeger(ls, 1);
	lua_settop(ls, 0);
	GameSocket* so = GameSocket::getSocket(sid);
	if (so == nullptr) 
	{
		lua_pushinteger(ls, -1);
	}
	else 
	{
		int serialNumber = so->getStaticSerialNumber();
		lua_pushinteger(ls, serialNumber);
	}
	return 1;
}

int GameNetGlobalFun::cpp_buff_writeSerialNumAndProtocol(lua_State* ls) 
{
	int pid = lua_tointeger(ls, 1);
	int sid = lua_tointeger(ls, 2);
	int protocol = lua_tointeger(ls, 3);
	int serverId = lua_tointeger(ls, 4);
	lua_settop(ls, 0);
	if (true) 
	{
		GameSocket* so = GameSocket::getSocket(sid);
		if (so == nullptr) 
		{

		}
		else 
		{
			int serialNumber = so->getSerialNumber();
			DataBuff* buff = DataBuff::getDataBuffer(pid);
			if (buff == nullptr) 
			{
				return 0;
			}
			buff->writeShort(protocol);
			buff->writeShort(sid);
			buff->writeInt(serialNumber);
			buff->writeShort(serverId);
		}
	}
	return 0;
}

int GameNetGlobalFun::cpp_getData_buff(lua_State* ls) 
{
	/*int pid = lua_tointeger(ls, 1);
	DataBuff* buff = DataBuff::getDataBuffer(pid);
	if (buff == nullptr) {
	return 0;
	}
	buff->testWrite();
	std::string str;
	str.append((const char *)(buff->_buff + 10), buff->_length - 10);
	*/
	//lua_pushstring(ls,"1111");
	//int pid = lua_tointeger(ls, 1);

	return 0;
}

int GameNetGlobalFun::cpp_buffNew_writeString(lua_State* ls) 
{
	int pid = lua_tointeger(ls, 1);
	const char* data = lua_tostring(ls, 2);
	DataBuff* buff = DataBuff::getDataBuffer(pid);
	if (buff == nullptr) 
	{
		return 0;
	}
	buff->writeString(data);
	buff->encode();
	return 0;
}

int GameNetGlobalFun::cpp_buffNew_readString(lua_State* ls) 
{
	int pid = lua_tointeger(ls, 1);
	DataBuff* buff = DataBuff::getDataBuffer(pid);
	if (buff == nullptr) 
	{
		return 0;
	}
	std::string res = buff->readNewString();
	lua_settop(ls, 0);
	lua_pushstring(ls, res.c_str());
	return 1;
}

int GameNetGlobalFun::cpp_DataEnCodeType1(lua_State* ls) 
{
	int type = lua_tointeger(ls, 1);//1加密2解密
	const char* data = lua_tostring(ls, 2);
	std::string res = "";
	if (type == 1) 
	{
		res = ToolBASE64::base64_encode(data, strlen(data));
	}
	else 
	{
		res = ToolBASE64::base64_decode(data, strlen(data));
	}
	lua_settop(ls, 0);
	lua_pushstring(ls, res.c_str());
	return 1;
}

int GameNetGlobalFun::cpp_getTheLastErrorCode(lua_State* ls)
{
	lua_settop(ls, 0);
	lua_pushstring(ls,"NO MESSAGE");
	return 1;
}

