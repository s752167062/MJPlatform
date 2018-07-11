#pragma once
/*
@ÍøÂç²ãÈ«¾Öº¯Êý
@author sunfan
@date	2017/05/04
*/

#ifndef GAME_SOCKET_H
#define GAME_SOCKET_H

#include <stdio.h>
#include "CCLuaEngine.h"
#include "GameSocket.h"


class GameNetGlobalFun
{
public:
	static GameNetGlobalFun* getInstance();
	lua_State* ls;

	virtual void bind(lua_State* ls);
	static int cpp_net_open(lua_State* ls);
	static int cpp_net_close(lua_State* ls);
	static int cpp_net_receive(lua_State* ls);
	static int cpp_net_send(lua_State* ls);
	static int cpp_net_getStatu(lua_State* ls);
	static int cpp_net_buffer_in_size(lua_State* ls);
	static int cpp_net_buffer_out_size(lua_State* ls);
	static int cpp_buff_create(lua_State* ls);
	static int cpp_buff_delete(lua_State* ls);
	static int cpp_buff_toString(lua_State* ls);
	static int cpp_buff_encode(lua_State* ls);
	static int cpp_buff_readByte(lua_State* ls);
	static int cpp_buff_readShort(lua_State* ls);
	static int cpp_buff_readInt(lua_State* ls);
	static int cpp_buff_readLong(lua_State* ls);
	static int cpp_buff_readString(lua_State* ls);
	static int cpp_buff_readBoolean(lua_State* ls);
	static int cpp_buff_readLength(lua_State* ls);
	static int cpp_buff_readBytes(lua_State* ls);
	static int cpp_buff_readJsonData(lua_State* ls);
	static int cpp_buff_writeByte(lua_State* ls);
	static int cpp_buff_writeShort(lua_State* ls);
	static int cpp_buff_writeInt(lua_State* ls);
	static int cpp_buff_writeLong(lua_State* ls);
	static int cpp_buff_writeString(lua_State* ls);
	static int cpp_buff_writeBoolean(lua_State* ls);
	static int cpp_buff_writeLength(lua_State* ls);
	static int cpp_buff_writeBytes(lua_State* ls);
	static int cpp_buff_writeNewBean(lua_State* ls);
	static int cpp_buff_writeBeanByte(lua_State* ls);
	static int cpp_buff_writeBeanShort(lua_State* ls);
	static int cpp_buff_writeBeanInt(lua_State* ls);
	static int cpp_buff_writeBeanLong(lua_State* ls);
	static int cpp_buff_writeBeanString(lua_State* ls);
	static int cpp_buff_writeBeanBoolean(lua_State* ls);
	static int cpp_buff_writeBeanLength(lua_State* ls);
	static int cpp_buff_writeBeanBytes(lua_State* ls);
	static int cpp_buff_testRestartRead(lua_State* ls);
	static int cpp_heard_param(lua_State* ls);
	static int cpp_net_serialNumber(lua_State* ls);
	static int cpp_buff_writeSerialNumAndProtocol(lua_State* ls);
	static int cpp_getData_buff(lua_State* ls);
	static int cpp_buffNew_writeString(lua_State* ls);
	static int cpp_buffNew_readString(lua_State* ls);
	static int cpp_DataEnCodeType1(lua_State* ls);
	static int cpp_getTheLastErrorCode(lua_State* ls);
private:
	static GameNetGlobalFun *m_instance;
};

#endif


