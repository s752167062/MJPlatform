//
//  HttpUtils.hpp
//  GameChess
//
//  Created by yajing on 2018/6/25.
//

#ifndef HttpUtils_hpp
#define HttpUtils_hpp

#include "cocos2d.h"
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
#include <string>
#include <mutex>
#include <thread>
#include <queue>
#include "tolua_fix.h"
#include "CCLuaStack.h"
#include "CCLuaValue.h"
#include "CCLuaEngine.h"
#include "curl/curl.h"

using namespace std ;
USING_NS_CC ;

//用来接收服务器回应
struct MemoryStruct{
    char * memory;
    size_t size;
};
//上传的声音信息
struct UploadInfoStruct{
    char url[255];
    char fileName[255];
    char filePath[255];
    LUA_FUNCTION callback;
};

class HttpUtils{
public:
    static HttpUtils * getInstance();
    HttpUtils();
    virtual ~HttpUtils();
    
    
    size_t uploadVoice(const char* url, const char * fileName, const char * filePath , int _callback);
    virtual void bind(lua_State* ls);
    
    static int cpp_httpUploadVoice(lua_State* ls);
    //回调
    static void* httpPostRequest(void* obj);
    static size_t respond_callback(uint8_t * dataPtr, size_t size, size_t nmemb, void * user_p);
    static size_t progress_callback(void * clientp, double dltotal, double dlnow, double ultotal, double ulnow);
    
    void onComplateCallback(int code , const char * err , LUA_FUNCTION hanlder);
    
public:
    mutex m_Mutex;
    std::queue<UploadInfoStruct> m_Queue; //保存上传的声音信息的队列
    std::queue<LUA_FUNCTION> m_handlerQueue;
    UploadInfoStruct upstruct;
    bool isUploading ;
    bool threadend ;
    unsigned long number;
};
#endif

#endif /* HttpUtils_hpp */
