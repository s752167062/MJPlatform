/*
@游戏LUA交互全局函数管理类
@author sunfan
@date	2017/05/03
*/

#include "GameGlobalFunMgr.h"
#include "Util/HttpDownloader.h"
//#include "Util/HttpUploadVoice.h"
#include "cocos2d.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "platform/android/jni/JniHelper.h"
#endif

USING_NS_CC;

GameGlobalFunMgr* GameGlobalFunMgr::m_instance = nullptr;

GameGlobalFunMgr* GameGlobalFunMgr::getInstance()
{
	if (m_instance != nullptr)
		return m_instance;
	m_instance = new GameGlobalFunMgr();
	m_instance->inIt();
	return m_instance;
}

GameGlobalFunMgr::GameGlobalFunMgr() 
{

}

void GameGlobalFunMgr::bind(lua_State *ls)
{
	this->m_ls = ls;
    lua_register(ls, "Jni_CheckMethod", Jni_CheckMethod);
	lua_register(ls, "cpp_log", cpp_log);
	lua_register(ls, "cpp_downloader", cpp_downloader);
	lua_register(ls, "ccx_write", ccxApi_write);
	lua_register(ls, "ccx_read", ccxApi_read);
	lua_register(ls, "cpp_string_bit_xor", cpp_string_bit_xor);
	lua_register(ls, "cpp_getFGroupName", cpp_getFGroupName);

//    lua_register(ls, "cpp_uploadVoice"        , cpp_uploadVoice);
//    lua_register(ls, "cpp_uploadVoice_getName", cpp_uploadVoice_getName);
//    lua_register(ls, "cpp_uploadVoice_getEndFlag"  , cpp_uploadVoice_getEndFlag);
//    lua_register(ls, "cpp_uploadVoice_resetEndFlag", cpp_uploadVoice_resetEndFlag);
    
//#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
//	lua_register(ls, "cpp_createAudio", cpp_createAudio);
//	lua_register(ls, "cpp_createAudioEnd", cpp_createAudioEnd);
//	lua_register(ls, "cpp_playAudio", cpp_playAudio);
//	lua_register(ls, "cpp_openSafari", cpp_openSafari);
//#endif

}

void GameGlobalFunMgr::inIt() 
{

}

int GameGlobalFunMgr::Jni_CheckMethod(lua_State* ls){
#if (CC_TARGET_PLATFORM==CC_PLATFORM_ANDROID)
    string packname = lua_tostring(ls, 1);
    string method = lua_tostring(ls, 2);
    string parm = lua_tostring(ls, 3);
    
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(minfo,packname.c_str(),method.c_str(),parm.c_str());
#else
    bool isHave = false;
#endif
    lua_settop(ls, 0);
    lua_pushboolean(ls, isHave);
    return 1;
}

int GameGlobalFunMgr::cpp_getFGroupName(lua_State *ls)
{
	string name = "first.u5u8j17i1v.aliyungf.com";
	lua_settop(ls, 0);
	lua_pushstring(ls, name.c_str());
	return 1;
}
//
//int GameGlobalFunMgr::cpp_uploadVoice(lua_State *ls){
//    const char* url = lua_tostring(ls, 1);
//    const char* fileName = lua_tostring(ls, 2);
//    const char* filePath = lua_tostring(ls, 3);
//#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
////    HttpUploadVoice::getInstance()->httpPostRequest_UploadVoice(url, fileName, filePath);
//#endif
//    return 0;
//}
//
//int GameGlobalFunMgr::cpp_uploadVoice_getName(lua_State *ls){
//#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
////    std::string name = HttpUploadVoice::getInstance()->getVoiceName();
////    lua_settop(ls, 0);
////    lua_pushstring(ls,name.c_str());
//#endif
//    return 1;
//}

//int GameGlobalFunMgr::cpp_uploadVoice_getEndFlag(lua_State *ls){
//#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
//    int flag = HttpUploadVoice::getInstance()->getEndFlag();
//    lua_settop(ls, 0);
//    lua_pushinteger(ls, flag);
//#endif
//    return 1;
//}
//
//
//int GameGlobalFunMgr::cpp_uploadVoice_resetEndFlag(lua_State *ls){
//#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
//    HttpUploadVoice::getInstance()->resetEndFlag();
//#endif
//    return 0;
//}


int GameGlobalFunMgr::cpp_log(lua_State* ls)
{
	const char* str = lua_tostring(ls, 1);
	return 0;
}

int GameGlobalFunMgr::cpp_downloader(lua_State* ls)
{
	const char* callfunc = lua_tostring(ls, 1);
	const char* filename = lua_tostring(ls, 2);
	const char* url = lua_tostring(ls, 3);
	HttpDownloader::getInstance()->HttpDownloadFile(callfunc, filename, url);
	return 0;
}

int GameGlobalFunMgr::ccxApi_write(lua_State *ls)
{
	const char* path = lua_tostring(ls, 1);
	const char* str = lua_tostring(ls, 2);
	long len = strlen(str);

	FILE *fp = fopen(path, "wb");
	fwrite(str, len, 1, fp);
	fflush(fp);
	fclose(fp);
	return 0;
}

int GameGlobalFunMgr::ccxApi_read(lua_State *ls)
{
	const char* path = lua_tostring(ls, 1);

	string data = FileUtils::getInstance()->getStringFromFile(path);
	lua_settop(ls, 0);
	lua_pushstring(ls, data.c_str());
	return 1;
}

int GameGlobalFunMgr::cpp_string_bit_xor(lua_State *ls)
{
	const char* str_in = lua_tostring(ls, 1);
	const char key = lua_tointeger(ls, 2);
	int len = strlen(str_in);
	char *str_out = (char*)malloc(len + 1);
	for (int i = 0; i<len; i++) {
		str_out[i] = str_in[i] ^ key;
	}
	lua_pushstring(ls, str_out);
	free(str_out);
	return 1;
}

void GameGlobalFunMgr::applicationWillEnterForeground()
{

	lua_settop(m_ls, 0);
	lua_getglobal(m_ls, "applicationWillEnterForeground");
	lua_call(m_ls, 0, 0);
}



//#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
////录音
//bool isRecording = NO;
//char * filename = nullptr;
//static audioController *audio = [[audioController alloc] init];// 初始化对象
//
//int YJGameLuaAPI::cpp_createAudio(lua_State* ls) 
//{
//	const char* name = lua_tostring(ls, 1);
//	filename = (char*)name;
//
//	[audio AudioRecording];
//	CCLOG("CPP CREATE AUDIO");
//	return 0;
//}
//
//int YJGameLuaAPI::cpp_createAudioEnd(lua_State* ls) 
//{
//	const char* name = lua_tostring(ls, 1);
//	filename = (char*)name;
//
//	[audio AudioRecording];
//	CCLOG("CPP CREATE AUDIO END");
//	return 0;
//}
//
//int YJGameLuaAPI::cpp_playAudio(lua_State* ls) 
//{
//	const char* name = lua_tostring(ls, 1);
//	filename = (char*)name;
//
//	[audio playAudio];
//	CCLOG("CPP PLAY AUDIO");
//	return 0;
//}
//
//int YJGameLuaAPI::cpp_openSafari(lua_State* ls) 
//{
//	CCLOG("open Safari ");
//	const char* callfunc = lua_tostring(ls, 1);
//	const char* url = lua_tostring(ls, 2);
//
//	[[UIApplication sharedApplication] openURL:[NSURL URLWithString : [NSString stringWithUTF8String : url]]];
//	return 0;
//}
//#endif

GameGlobalFunMgr::~GameGlobalFunMgr()
{
	if (m_instance) 
	{
		free(m_instance);
		m_instance = nullptr;
	}
}

