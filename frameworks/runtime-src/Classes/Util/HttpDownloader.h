/*
@HTTP
@author sunfan
@date	2017/05/04
*/

#ifndef HTTP_DOWNLOADER_H
#define HTTP_DOWNLOADER_H

#include <stdio.h>
#include "network/HttpClient.h"
#include "network/CCDownloader.h"
#include <iostream>

USING_NS_CC;

using namespace cocos2d::network;

class HttpDownloader
{
public:
	static HttpDownloader * getInstance();
	void httpGetRequest(const char* nameAcall, const char * url);
	void httpPostRequest(const char* nameAcall, const char * url, const char* params);
	void onRequestCompleated(HttpClient *sender, HttpResponse *response);
	void onCompleatedCallToLua(int code, const char* filename, const char* callfunc);
	void HttpDownloadFile(const char * callfunc, const char* name, const char * url);
private:
	network::Downloader * downloader;
	static HttpDownloader * instance;
};

#endif
