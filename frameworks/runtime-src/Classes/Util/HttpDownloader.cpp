/*
@HTTP
@author sunfan
@date	2017/05/04
*/

#include "HttpDownloader.h"
#include "cocos2d.h"
#include "CCLuaEngine.h"

HttpDownloader * HttpDownloader::instance = nullptr ;

HttpDownloader* HttpDownloader::getInstance()
{
    if (instance == nullptr) 
	{
        instance = new HttpDownloader();
        instance->downloader = new network::Downloader(); 
    }
    return instance ;
}

void HttpDownloader::httpGetRequest(const char * nameAcall, const char * url)
{
    CCLOG("Http Get : %s\n %s  \n\n" , nameAcall , url) ;
    HttpRequest* request = new HttpRequest();
    request->setUrl(url);
    request->setRequestType(HttpRequest::Type::GET);
    request->setResponseCallback(CC_CALLBACK_2(HttpDownloader::onRequestCompleated,this));
    request->setTag(nameAcall);
    cocos2d::network::HttpClient::getInstance()->send(request);
    request->release();
    
}

void HttpDownloader::httpPostRequest(const char * nameAcall , const char * url , const char* params)
{
    CCLOG("Http Post : %s\n %s \n %s \n\n" , nameAcall , url , params) ;
    HttpRequest* request = new HttpRequest();
    request->setUrl(url);
    request->setRequestType(HttpRequest::Type::POST);
    request->setResponseCallback(CC_CALLBACK_2(HttpDownloader::onRequestCompleated,this));
    
    // write the post data
    const char* postData = params ;// "visitor=cocos2d&TestSuite=Extensions Test/NetworkTest";
    request->setRequestData(postData, strlen(postData));
    request->setTag(nameAcall);
    cocos2d::network::HttpClient::getInstance()->send(request);
    request->release();
}

void HttpDownloader::onRequestCompleated(HttpClient* sender, HttpResponse* response)
{

    if (!response || !response->isSucceed())
    {
        CCLOG("response failed");
        CCLOG("error buffer: %s", response->getErrorBuffer());
        return;
    }
    const char* nameAcall = response->getHttpRequest()->getTag();
    std::string str = nameAcall;
    size_t index = str.find_first_of(",", 0);
    const char * filename = str.substr(0 , index).c_str();
    const char * callfunc = str.substr(index + 1 , str.length() - (index + 1)).c_str();
    
    CCLOG("%s completed", filename);
    CCLOG("response code: %d", (int)response->getResponseCode());

    // dump data
    std::vector<char> *buffer = response->getResponseData();
    
    std::string path = cocos2d::FileUtils::getInstance()->getWritablePath()+"/" + filename;
    std::string buff( buffer->begin(),buffer->end() );
    
    //保存到本地文件
    CCLOG("****  Savepath: %s",path.c_str());
    FILE *fp = fopen(path.c_str(), "wb+");
    fwrite(buff.c_str(), 1,buffer->size(),  fp);
    fclose(fp);
    if (strlen(callfunc) > 0) 
	{
         onCompleatedCallToLua(1 , filename , callfunc);
    }
}

void HttpDownloader::onCompleatedCallToLua(int code ,const char* filename , const char* callfunc)
{
	if (strlen(callfunc) <= 0)
		return;
    //call lua
    lua_State* L = cocos2d::LuaEngine::getInstance()->getLuaStack()->getLuaState();
    lua_getglobal(L, callfunc);
    lua_pushnumber(L, code);
    lua_pushstring(L, filename);
    lua_call(L, 2, 0);
}


void HttpDownloader::HttpDownloadFile(const char * callfunc , const char* name, const char * url)
{
    CCLOG("Download File %s , %s , %s ",name , url , callfunc);
    auto path = FileUtils::getInstance()->getWritablePath() + name;

    network::Downloader* downloader = new network::Downloader(); ///xiong
    
    downloader->createDownloadFileTask(url, path, name);

    // define progress callback
    downloader->onTaskProgress = [this , name](const network::DownloadTask& task, int64_t bytesReceived, int64_t totalBytesReceived, int64_t totalBytesExpected)
    {
        float percent = float(totalBytesReceived * 100) / totalBytesExpected ;
        CCLOG("%.1f% [total %d KB] %s" , percent ,int(totalBytesExpected/1024) ,name);
    };
    
    downloader->onFileTaskSuccess = [this , name ,callfunc ,downloader](const cocos2d::network::DownloadTask& task)
    {
        if(strlen(callfunc) > 0)
		{
            this->onCompleatedCallToLua(1, name, callfunc);
            delete downloader ; ///xiong
        }
    };
    
    downloader->onTaskError = [this , name ,callfunc](const cocos2d::network::DownloadTask& task, int errorCode,  int errorCodeInternal, const std::string& errorStr)
    {
        CCLOG("Failed to download : %s, identifier(%s) error code(%d), internal error code(%d) desc(%s)"
            , task.requestURL.c_str()
            , task.identifier.c_str()
            , errorCode
            , errorCodeInternal
            , errorStr.c_str());
        
        this->onCompleatedCallToLua(0, name, callfunc);
    };
}
