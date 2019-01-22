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
    std::string getYUNByGroupNameIP(const char* name , const char* uuid, const char* game_ip , const char* game_port );
    std::string getYUNByGroupNameDomain(const char* name , const char* uuid, const char* game_host , const char* game_port );
    
    void networkDiagnosis(const char* ip , int port , int hanlder);
    static void* runNetworkDiagnosis(void* obj);
    
    unsigned int SDBMHash(char *str);
    
    
};

#endif /* YUNControl_hpp */
