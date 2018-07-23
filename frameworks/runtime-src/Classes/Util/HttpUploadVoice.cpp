#include "HttpUploadVoice.h"
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
#include "CCLuaEngine.h"
#include "curl/curl.h"

static HttpUploadVoice * instance = nullptr ;

HttpUploadVoice* HttpUploadVoice::getInstance(){
    if (instance == nullptr) {
        instance = new HttpUploadVoice();
    }
    return instance ;
}

HttpUploadVoice::HttpUploadVoice(){
    CCLOG("**** upload_ create *****\n");
    m_nFrame = 0;
    m_bFlag = false;
    m_nEndFlag = 0;
    m_strVoiceName = "";
    //创建监听线程
    thread t(&HttpUploadVoice::listener, this);
    t.detach();
    //创建发送声音线程
    thread t1(&HttpUploadVoice::httpPostRequest, this);
    t1.detach();
}

HttpUploadVoice::~HttpUploadVoice(){
    CCLOG("**** HttpUploadVoice  end *** \n");
    if(nullptr != instance){
        delete instance;
        instance = nullptr;
    }
}

void show_cur_time(int str)
{
    struct timeval now;
    struct tm *time;
    
    gettimeofday(&now, NULL);
    
    time = localtime(&now.tv_sec);      //microseconds: 微秒
    
    
    char date2[50] = {0};
    sprintf(date2, "%02d:%02d:%02d ", (int)time->tm_hour, (int)time->tm_min, (int)time->tm_sec);
    CCLOG("HttpUploadVoice %d>>> %s", str, date2);
}

size_t HttpUploadVoice::httpPostRequest_UploadVoice(const char* url, const char * fileName, const char * filePath){
    UploadInfoStruct st;
    strncpy(st.url, url, strlen(url) + 1);
    strncpy(st.fileName, fileName, strlen(fileName) + 1);
    strncpy(st.filePath, filePath, strlen(filePath) + 1);
    printf("HttpUploadVoice1:0,fileName=%s\n", fileName);
    
    m_Mutex.lock();
    m_Queue.push(st);
    m_Mutex.unlock();
    
    printf("HttpUploadVoice1:fileName=%s,st.fileName=%s,g_bFlag=%d\n", fileName, st.fileName, m_bFlag ? 1 : 0);
    return 0;
}

void HttpUploadVoice::listener(){
    while (1) {
 
        this_thread::sleep_for(chrono::milliseconds(100));
        m_nFrame++;
        if(m_nFrame > 10){
            //printf("HttpUploadVoice5:m_nFrame update\n");
            m_nFrame = 0;
            
            m_Mutex.lock();
            if(m_Queue.empty()){
                m_Mutex.unlock();
                continue;
            }
            m_Mutex.unlock();
            
            if(!m_bFlag && (m_nEndFlag == 0)){
                m_bFlag = true;
                printf("HttpUploadVoice5:thread\n");
            }
        }
    }
}

void HttpUploadVoice::httpPostRequest(){
    while(1){

        this_thread::sleep_for(chrono::milliseconds(100)); //空转会导致cpu占用狂飙，所以sleep一下
        if(!m_bFlag)
            continue;
        //获取本地声音文件
        m_Mutex.lock();
        if(m_Queue.empty()){
            m_bFlag = false;
            if(m_nEndFlag == 0){
                m_nEndFlag = 1;
                m_strVoiceName = "";
            }
            m_Mutex.unlock();
            continue;
        }
        UploadInfoStruct st = m_Queue.front();
        m_Queue.pop();
        m_Mutex.unlock();
        string url1 = st.url;
        string file1 = st.filePath;
        string file2 = st.fileName;
        m_strVoiceName = file2;
        string file = file1  + file2;
        if(url1.length() <= 0 || file2.length() <= 0 || file1.length() <= 0 ){
            printf("HttpUploadVoice2:name length error!!!!!!!!!!!!\n");
            m_bFlag = false;
            continue;
        }
        printf("HttpUploadVoice2:fileName=%s\n",st.fileName);
        
        try{
            CURL* _curl;
            CURLcode res;
            curl_httppost *m_formPost = 0;
            curl_httppost *m_lastPost = 0;
            
            _curl = curl_easy_init();
            printf("HttpUploadVoice-curl:0\n");
            if (_curl){
                curl_formadd(&m_formPost, &m_lastPost,
                             CURLFORM_COPYNAME, "name",
                             CURLFORM_COPYCONTENTS, file2.c_str(),
                             CURLFORM_END);
                
                curl_formadd(&m_formPost, &m_lastPost,
                             CURLFORM_COPYNAME, "post",   //这里发送的文件名字必须为“post”
                             CURLFORM_FILE, file.c_str(),
                             CURLFORM_END);
                printf("HttpUploadVoice-curl:1\n");
                curl_easy_setopt(_curl, CURLOPT_HEADER, 0);
                curl_easy_setopt(_curl, CURLOPT_URL, url1.c_str());
                curl_easy_setopt(_curl, CURLOPT_NOSIGNAL, 1L);
                curl_easy_setopt(_curl, CURLOPT_CONNECTTIMEOUT, 5L);
                curl_easy_setopt(_curl, CURLOPT_TIMEOUT, 10L);
                curl_easy_setopt(_curl, CURLOPT_FORBID_REUSE, 1);
                curl_easy_setopt(_curl, CURLOPT_HTTPPOST, m_formPost);
                curl_easy_setopt(_curl, CURLOPT_WRITEFUNCTION, respond_callback);
                curl_easy_setopt(_curl, CURLOPT_PROGRESSFUNCTION, progress_callback);
                curl_easy_setopt(_curl, CURLOPT_NOPROGRESS, 0L);
                curl_easy_setopt(_curl, CURLOPT_SSL_VERIFYPEER, 0);
                printf("HttpUploadVoice-curl:2\n");
                res = curl_easy_perform(_curl);
                printf("HttpUploadVoice-curl:3\n");
                if (res != CURLE_OK){ //上传文件失败
                    fprintf(stderr, "%s\n", curl_easy_strerror(res));
                    curl_formfree(m_formPost);
                    
                    m_bFlag = false;
                    m_nEndFlag = 1;
                    m_strVoiceName = "";
                    printf("HttpUploadVoice3:fileName=%s\n", st.fileName);
                    
                    continue;
                }
                printf("HttpUploadVoice-curl:4\n");
                curl_easy_cleanup(_curl);
                printf("HttpUploadVoice-curl:5\n");
                
                m_bFlag = false;
                m_nEndFlag = 1;
                printf("HttpUploadVoice3:fileName=%s\n",st.fileName);
            }
        }catch(...){
            m_bFlag = false;
            printf("HttpUploadVoice-httpPostRequest:error!!!!!!!!!!!!!!!!!!!\n");
        }
    }
}

size_t HttpUploadVoice::respond_callback(uint8_t * dataPtr, size_t size, size_t nmemb, void * user_p){
    printf("HttpUploadVoice:send end!size=%ld,nmemb=%ld\n", size, nmemb);
    size_t realsize = size * nmemb;

    //lua_State* L = cocos2d::LuaEngine::getInstance()->getLuaStack()->getLuaState();
    //lua_getglobal(L, "uploadVoiceCompled");
    //lua_pushstring(L, g_strVoiceName.c_str());
    //lua_call(L, 1, 0);
    //printf("HttpUploadVoice:send end!==========%s\n",g_strVoiceName.c_str());
    
    return realsize;
}

size_t HttpUploadVoice::progress_callback(void * clientp, double dltotal, double dlnow, double ultotal, double ulnow){
    //CCLOG("HttpUploadVoice:progress_callback!ultotal=%f,ulnow=%f",ultotal,ulnow);
    return 0;
}

#endif
