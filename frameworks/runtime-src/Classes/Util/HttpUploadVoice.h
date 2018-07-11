
#ifndef HttpUploadVoice_h
#define HttpUploadVoice_h
#include "cocos2d.h"
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
#include <string>
#include <mutex>
#include <thread>
#include <queue>

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
};

class HttpUploadVoice{
public:
    static HttpUploadVoice * getInstance();
    HttpUploadVoice();
    virtual ~HttpUploadVoice();
    size_t httpPostRequest_UploadVoice(const char* url, const char * fileName, const char * filePath);
    void listener();
    void httpPostRequest();
    static size_t respond_callback(uint8_t * dataPtr, size_t size, size_t nmemb, void * user_p);
    static size_t progress_callback(void * clientp, double dltotal, double dlnow, double ultotal, double ulnow);
    void resetEndFlag() { m_nEndFlag = 0; m_strVoiceName = "";};
    int getEndFlag() {return m_nEndFlag;};
    string getVoiceName() { return m_strVoiceName; };
public:
    mutex m_Mutex;
    std::queue<UploadInfoStruct> m_Queue; //保存上传的声音信息的队列
    int m_nFrame; //时间帧
    volatile bool m_bFlag; //正在上传声音的标记(false当前没有正在上传的声音，true当前有正在上传的声音)
    volatile int m_nEndFlag; //结束标记(0开始上传声音，1上传声音结束等待Lua获得声音名字，2Lua已经获得声音名字(在Lua中设置为0))
    string m_strVoiceName;
};
#endif
#endif /* HttpUploadVoice_hpp */
