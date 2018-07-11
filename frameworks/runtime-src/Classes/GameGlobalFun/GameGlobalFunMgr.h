
#ifndef GAME_GLOBAL_FUN_MGR_H
#define GAME_GLOBAL_FUN_MGR_H

#include <stdio.h>
#include "CCLuaEngine.h"
#include <string.h>


using namespace std;

class GameGlobalFunMgr {
public:
	static GameGlobalFunMgr* getInstance();

	GameGlobalFunMgr();

	~GameGlobalFunMgr();

	void bind(lua_State* ls);
    //Android检查
    static int Jni_CheckMethod(lua_State* ls);
	static int cpp_log(lua_State* ls);

	static int cpp_downloader(lua_State* ls);

	static int ccxApi_write(lua_State* ls);
	static int ccxApi_read(lua_State* ls);
	static int cpp_string_bit_xor(lua_State* ls);
	static int cpp_getFGroupName(lua_State* ls);
    
    static int cpp_uploadVoice(lua_State* ls);
    static int cpp_uploadVoice_getName(lua_State* ls);
    static int cpp_uploadVoice_getEndFlag(lua_State* ls);
    static int cpp_uploadVoice_resetEndFlag(lua_State* ls);
    
	void applicationWillEnterForeground();

//#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
//	static int cpp_createAudio(lua_State* ls);
//	static int cpp_createAudioEnd(lua_State* ls);
//	static int cpp_playAudio(lua_State* ls);
//	static int cpp_openSafari(lua_State* ls);
//#endif

private:
	void inIt();

private:
	lua_State* m_ls;
	static GameGlobalFunMgr* m_instance;
};

#endif
