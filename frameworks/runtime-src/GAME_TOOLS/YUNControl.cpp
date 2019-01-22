//
//  YUNControl.cpp
//  Mahjong
//
//  Created by SJ on 16/9/1.
//
//

#include "cocos2d.h"
#include "YUNControl.h"

#include "tolua_fix.h"
#include "CCLuaStack.h"
#include "CCLuaValue.h"
#include "CCLuaEngine.h"

#import <YunCeng/YunCeng.h>

USING_NS_CC;

#define YUNAPPKEY @"";
static YUNControl* _instance = nullptr;

YUNControl* YUNControl::getInstance(){
    if (_instance == nullptr) {
        _instance = new YUNControl();
    }
    return _instance;
}

void YUNControl::init(){
    NSFileManager * fm = [NSFileManager defaultManager];
    NSString * appkey = @"";
    //1 优先update 文件夹下的 游戏遁key文件
    NSString *file_update_dir = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"update/src/AppPlatform/cocos/IOS_APPKEY_V3.xxxf"];
    NSLog(@"XIONG OC IOS_APPKEY PATH : %@",file_update_dir);
    if([fm fileExistsAtPath:file_update_dir]){
        NSData* data = [fm contentsAtPath:file_update_dir];
        appkey = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }else{
        //2
        NSString * url = [[NSBundle mainBundle] pathForResource:@"IOS_APPKEY_V3" ofType:@"xxxf"];
        NSLog(@" IOS_APPKEY path : %@" , url);
        if([fm fileExistsAtPath:url]){
            NSData* data = [fm contentsAtPath:url];
            appkey = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }else{
            NSLog(@" No File : IOS_APPKEY_V3 ");
            //文件不存在出现问题
            UIAlertView * mAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@" UR : IOS_APPKEY 文件不存在 ！！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [mAlert show];
            return ;
        }
    }
    
    //初始化
    @try {
        const char* key =[appkey cStringUsingEncoding:NSASCIIStringEncoding];
        int ret = [YunCeng initEx:key:"token"];
        if(0!= ret){
            NSLog(@"YUN INIT ERR %d" ,ret);
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:[NSString stringWithFormat:@"YUN 初始化失败 %d", ret]
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    @catch (NSException *exception) {
        NSLog(@" YUN INIT ERR ");
        if(exception != NULL){
            int code = ((YunCengException*)exception).code;
            NSLog(@"YUN INIT ERR %d" ,code);
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:[NSString stringWithFormat:@"YUN 初始化失败 %d", code]
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

std::string YUNControl::getYUNByGroupNameIP(const char* name , const char* uuid, const char* game_ip , const char* game_port ){
    NSLog(@" ------- getYUNByGroupNameIP");
    if(name == NULL){
        return "0,NIL_GroupName";
    }
    if(uuid == NULL){
        return "0,NIL_UUID";//token
    }
    if(game_ip == NULL){
        return "0,NIL_GameIP";
    }
    if(game_port == NULL){
        return "0,NIL_port";
    }
    
    char ip[128]  = {0};
    char port[32] = {0};
    @try {
        int ret = [YunCeng getProxyTcpByIp :uuid:name:game_ip:game_port:ip:128:port:32];
        if(0!= ret){
            return [[[NSString alloc] initWithFormat:@"0,YUNException_RET_CODE:%d" ,ret] cStringUsingEncoding:NSASCIIStringEncoding] ;
        }
    }
    @catch (NSException *exception) {
        if(exception != NULL){
            NSString * reson = ((YunCengException*)exception).reason;
            int code = ((YunCengException*)exception).code;

            NSString * tempresult = @"0,";
            NSString * result = [[tempresult stringByAppendingFormat:@"%@" , reson] stringByAppendingFormat:@" %d" , code];

            return [result cStringUsingEncoding:NSASCIIStringEncoding] ;
        }else{
            return "0,YUNException_NULL";
        }
    }
    
    //判断空
    if(strlen(ip) == 0){
        return "0,NILValue_Ip" ;
    }
    if(strlen(port) == 0){
        return "0,NILValue_Port" ;
    }
    
    NSString * tempresult = @"1,";
    NSString * result = [tempresult stringByAppendingFormat:@"%@:%@"
                         , [[NSString alloc] initWithCString:(const char*)ip  encoding:NSUTF8StringEncoding]
                         , [[NSString alloc] initWithCString:(const char*)port  encoding:NSUTF8StringEncoding]];
    
    NSLog(@" --- IP RESULT : %@" ,result);
    return [result cStringUsingEncoding:NSASCIIStringEncoding];
}


std::string YUNControl::getYUNByGroupNameDomain(const char* name , const char* uuid, const char* game_host , const char* game_port ){
    NSLog(@" ------- getYUNByGroupNameDomain");
    if(name == NULL){
        return "0,NIL_GroupName";
    }
    if(uuid == NULL){
        return "0,NIL_UUID";//token
    }
    if(game_host == NULL){
        return "0,NIL_GameIP";
    }
    if(game_port == NULL){
        return "0,NIL_port";
    }
    
    char ip[128]  = {0};
    char port[32] = {0};
    @try {
        int ret = [YunCeng getProxyTcpByDomain  :uuid:name:game_host:game_port:ip:128:port:32];
        if(0!= ret){
            return [[[NSString alloc] initWithFormat:@"0,YUNException_RET_CODE:%d" ,ret] cStringUsingEncoding:NSASCIIStringEncoding] ;
        }
    }
    @catch (NSException *exception) {
        if(exception != NULL){
            NSString * reson = ((YunCengException*)exception).reason;
            int code = ((YunCengException*)exception).code;
            
            NSString * tempresult = @"0,";
            NSString * result = [[tempresult stringByAppendingFormat:@"%@" , reson] stringByAppendingFormat:@" %d" , code];
            
            return [result cStringUsingEncoding:NSASCIIStringEncoding] ;
        }else{
            return "0,YUNException_NULL";
        }
    }
    
    //判断空
    if(strlen(ip) == 0){
        return "0,NILValue_Ip" ;
    }
    if(strlen(port) == 0){
        return "0,NILValue_Port" ;
    }
    
    NSString * tempresult = @"1,";
    NSString * result = [tempresult stringByAppendingFormat:@"%@:%@"
                         , [[NSString alloc] initWithCString:(const char*)ip  encoding:NSUTF8StringEncoding]
                         , [[NSString alloc] initWithCString:(const char*)port  encoding:NSUTF8StringEncoding]];
    
    NSLog(@" --- IP RESULT : %@" ,result);
    return [result cStringUsingEncoding:NSASCIIStringEncoding];
}








void YUNControl::networkDiagnosis(const char* ip , int port , int handler){
    
    this->y_ip = ip;
    this->y_port = port;
    this->handler = handler;
    pthread_t th;
    pthread_create(&th, NULL, (void*(*)(void*))&YUNControl::runNetworkDiagnosis, _instance);
    pthread_detach(th);
    
}
void* YUNControl::runNetworkDiagnosis(void *obj) {
    YUNControl* so = (YUNControl*)obj;

    const char * ip = so->y_ip;
    int port   = so->y_port;
//    const char ip[] = "https://www.aliyun.com/";
//    int port = 80;
    
    int handler= so->handler;
    @try {
        int ret = [YunCeng startNetworkDiagnosis: ip : port:^ (NSString* diagnosisResult) {
                   NSString * result = [[NSString alloc] initWithFormat:@"1,%@", diagnosisResult ];
                   NSLog(@"%@" , result);
                   //回调给lua
                   lua_State * ls = LuaEngine::getInstance()->getLuaStack()->getLuaState();
                                             std::string result_s = [result UTF8String]; // 转string
                   lua_settop(ls, 0);
                   lua_pushstring(ls, result_s.c_str());
                                       LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(handler, 1);
                   }];
        if (ret) {
            //错误状态
            lua_State * ls = LuaEngine::getInstance()->getLuaStack()->getLuaState();
            std::string result_s = [[[NSString alloc] initWithFormat:@"0,CHECK_NET_ERR RET_CODE:%d", ret] UTF8String]; // 转string
            lua_settop(ls, 0);
            lua_pushstring(ls, result_s.c_str());
            LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(handler, 1);
        }
    }
    @catch (NSException *exception) {
        lua_State * ls = LuaEngine::getInstance()->getLuaStack()->getLuaState();
        std::string result_s = [[[NSString alloc] initWithFormat:@"0,CHECK_NET_ERR RET_CODE:%d", ((YunCengException*)exception).code] UTF8String]; // 转string
        lua_settop(ls, 0);
        lua_pushstring(ls, result_s.c_str());
        LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(handler, 1);
    }
}

//std::string YUNControl::getYUNIPInfo_byGroup_name(const char* name){
//    NSLog(@" ------- getYUNIPInfo_byGroup_name");
//    if(name == NULL){
//        return "0,NIL_GroupName";
//    }
//
//    char ip[128]= {0};
//    char ip_info[32] = {0};
//    @try{
//        int ret = [YunCeng getNextIPInfoByGroupName:name:ip:128:ip_info:32];
//        if (0 != ret) {
//            std::string err_m = "0,GET_INFO_FAILT ";
//            char * c = const_cast<char*>(err_m.c_str());
//            std::ostringstream oss;
//            oss << c << ret;
//            err_m = oss.str();
//
//            return  err_m ;
//        }else {
//            NSString *c_ip      = [[NSString alloc] initWithCString:(const char*)ip
//                                                              encoding:NSUTF8StringEncoding];
//            NSString *c_info    = [[NSString alloc] initWithCString:(const char*)ip_info
//                                                              encoding:NSUTF8StringEncoding];
//            NSString * tempresult = @"1,";
//            NSString * result = [tempresult stringByAppendingFormat:@"%@:%@" , c_ip ,c_info] ;
//
//            NSLog(@" --- RESULT : %@" ,result);
//            return [result cStringUsingEncoding:NSASCIIStringEncoding] ;
//
//        }
//    }@catch(YunCengException *exception){
//        if(exception != NULL){
//            NSString * reson = exception.reason;
//            int code = exception.code;
//
//            NSString * tempresult = @"0,INFO_";
//            NSString * result = [[tempresult stringByAppendingFormat:@"%@" , reson] stringByAppendingFormat:@" %d" , code];
//
//            return [result cStringUsingEncoding:NSASCIIStringEncoding] ;
//        }else{
//            return "0,YUNException_NULL_INFO";
//        }
//    }
//}


unsigned int YUNControl::SDBMHash(char *str){
    unsigned int hash = 0;
    
    while (*str)
    {
        // equivalent to: hash = 65599*hash + (*str++);
        hash = (*str++) + (hash << 6) + (hash << 16) - hash;
    }
    
    return (hash & 0x7FFFFFFF);
}

