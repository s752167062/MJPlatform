//
//  HttpUtils.cpp
//  GameChess
//
//  Created by yajing on 2018/6/25.
//

#include "HttpUtils.h"

#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)

static HttpUtils * instance = nullptr ;
HttpUtils* HttpUtils::getInstance(){
    if (instance == nullptr) {
        instance = new HttpUtils();
    }
    return instance ;
}

HttpUtils::HttpUtils(){
    log("**** 创建文件上传线程 ****");
    isUploading = false;
    threadend = true;
    number = m_Queue.size();
    //创建发送声音线程
}

void HttpUtils::bind(lua_State *ls)
{
    lua_register(ls, "cpp_httpUploadVoice"        , cpp_httpUploadVoice);
}

int HttpUtils::cpp_httpUploadVoice(lua_State *ls){
    const char* url = lua_tostring(ls, 1);
    const char* fileName = lua_tostring(ls, 2);
    const char* filePath = lua_tostring(ls, 3);
    
    tolua_Error toerror;
    LUA_FUNCTION hanlder = 0;
    if(!toluafix_isfunction(ls, 4, "LUA_FUNCTION", 0, &toerror)){
        tolua_error(ls, "# LUA ERR FUNCTION IN HttpUtils ", &toerror);
        log("**** ");
    }else{
        hanlder = (toluafix_ref_function(ls, 4, 0));
        log(">>>>> handler set: %d" , hanlder);
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
        HttpUtils::getInstance()->uploadVoice(url, fileName, filePath , hanlder);
#endif
    }
    
    return 0;
}

HttpUtils::~HttpUtils(){
    log("**** HTTP Utils 释放 ****");
    if(nullptr != instance){
        delete instance;
        instance = nullptr;
    }
}

size_t HttpUtils::uploadVoice(const char* url, const char * fileName, const char * filePath , LUA_FUNCTION _callback){
    UploadInfoStruct st;
    strncpy(st.url, url, strlen(url) + 1);
    strncpy(st.fileName, fileName, strlen(fileName) + 1);
    strncpy(st.filePath, filePath, strlen(filePath) + 1);
    st.callback = _callback;
    
    log("**** Add uploadVoice : %s ", fileName );
    log("**** Add uploadVoice handler : %d ", _callback);
    log("**** Add uploadVoice st.callback : %d " , st.callback);
    m_Mutex.lock();
    m_Queue.push(st);
    m_handlerQueue.push(_callback);
    number = m_Queue.size();
    m_Mutex.unlock();
    
    if(threadend == true){
        log("**** CREATE THE UPLOAD THREAD");
        pthread_t th;
        pthread_create(&th, NULL, (void*(*)(void*))&HttpUtils::httpPostRequest, this);
        pthread_detach(th);
        threadend = false;
    }
    return 0;
}

void* HttpUtils::httpPostRequest(void *obj) {
    HttpUtils* httpuitl = (HttpUtils*)obj;
    log("**** %lu" , httpuitl->number);

    while(httpuitl->number > 0){//
        if(httpuitl->isUploading == true){
            continue;
        }
        //获取本地声音文件
        httpuitl->m_Mutex.lock();
        if(httpuitl->m_Queue.empty()){
            httpuitl->m_Mutex.unlock();
            continue;
        }
        UploadInfoStruct st = httpuitl->m_Queue.front();
        httpuitl->m_Queue.pop();
        LUA_FUNCTION handler = httpuitl->m_handlerQueue.front();
        httpuitl->m_handlerQueue.pop();
        httpuitl->m_Mutex.unlock();

        httpuitl->number = httpuitl->m_Queue.size();
        string url1 = st.url;
        string file1 = st.filePath;
        string file2 = st.fileName;

        log(">>>>> thread run handler : %d" , st.callback);
        log(">>>>> thread run handler : %d" , handler);
        string file = file1  + file2;
        if(url1.length() <= 0 || file2.length() <= 0 || file1.length() <= 0 ){
            log("**** Upload Data Length error!!!!!!!!!!!! ");
            continue;
        }
        log("**** Star uploadVoice : %s ",  st.fileName);
        try{
            CURL* _curl;
            CURLcode res;
            curl_httppost *m_formPost = 0;
            curl_httppost *m_lastPost = 0;
            
            _curl = curl_easy_init();
            if (_curl){
                curl_formadd(&m_formPost, &m_lastPost,
                             CURLFORM_COPYNAME, "name",
                             CURLFORM_COPYCONTENTS, file2.c_str(),
                             CURLFORM_END);
                
                curl_formadd(&m_formPost, &m_lastPost,
                             CURLFORM_COPYNAME, "post",   //这里发送的文件名字必须为“post”
                             CURLFORM_FILE, file.c_str(),
                             CURLFORM_END);
                
                log("**** Curl Upload Setting !");
                httpuitl->isUploading = true;
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
                res = curl_easy_perform(_curl);
                if (res != CURLE_OK){ //上传文件失败
                    curl_formfree(m_formPost);
                    log("**** upload err : %s , err: %s", st.fileName , curl_easy_strerror(res));
                    //Callback
                    httpuitl->onComplateCallback(0,curl_easy_strerror(res) , handler);
                    continue;
                }
                
                curl_easy_cleanup(_curl);
                log("**** upload end !! ");
                httpuitl->onComplateCallback(1, "" , handler);
            }
            else{
                log("**** CURL init ERR ");
                //Callback
                httpuitl->onComplateCallback(0,"CURL init ERR" , handler);
            }
        }catch(...){
            log("**** Upload Request Err !!!! ");
            //Callback
            httpuitl->onComplateCallback(0,"Upload Request Err" , handler);
        }
    }
    httpuitl->threadend = true;
    log("***** THREAD END !");
}

void HttpUtils::onComplateCallback(int code , const char * err , LUA_FUNCTION hanlder){
    log(">>>>> handler %d" , hanlder);
    std::string e_str = err;
    isUploading = false;

    Director::getInstance()->getScheduler()->performFunctionInCocosThread([=]{
                lua_State* ls = cocos2d::LuaEngine::getInstance()->getLuaStack()->getLuaState();
                lua_settop(ls, 0);
                lua_pushinteger(ls, code);
                lua_pushstring(ls , e_str.c_str());
                cocos2d::LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(hanlder, 2);
                cocos2d::LuaEngine::getInstance()->getLuaStack()->removeScriptHandler(hanlder);//对于一次性的局部函数，在调用之后需要删除，只单靠垃圾回收会引起内存的错误（而且无法获取具体错误的位置）
        //    cocos2d::LuaEngine::getInstance()->removeScriptHandler(hanlder);//源码中另外一种删除
    });
    
    log(">>>>> onComplateCallback end");
}

//CURLOPT_WRITEFUNCTION 设置的回调是在每次接收到数据之后，并不是接收了所有数据才回调
size_t HttpUtils::respond_callback(uint8_t * dataPtr, size_t size, size_t nmemb, void * user_p){
    log("**** uploading ! size=%ld , nmemb=%ld\n", size, nmemb);
    size_t realsize = size * nmemb;
    return realsize;
}

size_t HttpUtils::progress_callback(void * clientp, double dltotal, double dlnow, double ultotal, double ulnow){
//    log("HttpUploadVoice:progress_callback!ultotal=%f,ulnow=%f",ultotal,ulnow);
    return 0;
}

#endif
