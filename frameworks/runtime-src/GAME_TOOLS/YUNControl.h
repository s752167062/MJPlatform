//
//  YUNControl.h
//  Mahjong
//
//  Created by SJ on 16/9/1.
//
//

#ifndef YUNControl_h
#define YUNControl_h

#include <stdio.h>

class YUNControl {
    public :
    const char * y_ip;
    int y_port;
    int handler ;
    static YUNControl* getInstance();
    
    void init();
    std::string getYUNByGroupName(const char* name , const char* uuid, const char* game_port);
//    std::string  getYUNIPInfo_byGroup_name(const char* name); //V5版已去除相关接口
    void networkDiagnosis(const char* ip , int port , int hanlder);
    static void* runNetworkDiagnosis(void* obj);
    
    unsigned int SDBMHash(char *str);
    
    
};

#endif /* YUNControl_hpp */
