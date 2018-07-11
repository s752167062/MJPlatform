//
//  AudioRecoderLua.cpp
//  GameChess
//
//  Created by SJ on 2017/6/13.
//
//

#include "AudioRecoderLua.h"
#include "string.h"

#include "tolua_fix.h"
#include "CCLuaStack.h"
#include "CCLuaValue.h"
#include "CCLuaEngine.h"

#import "AmrWavAudioRecoder.h"

using namespace std;

static AudioRecoderLua* _instance = nullptr ;

AudioRecoderLua* AudioRecoderLua::getInstance(){
    if (_instance == nullptr) {
        _instance = new AudioRecoderLua();
    }
    return _instance ;
}

void AudioRecoderLua::bind(lua_State* ls){
    this->ls = ls;

    lua_register(ls, "cpp_StartReocde"              , StartReocde);
    lua_register(ls, "cpp_EndReocde"                , EndReocde);
    lua_register(ls, "cpp_PlayVideo"                , PlayVideo);
    lua_register(ls, "cpp_StopPlayVideo"            , StopPlayVideo);
    lua_register(ls, "cpp_setAVAudioSessionCategory", setAVAudioSessionCategory);
}

//开始录制
int AudioRecoderLua::StartReocde(lua_State* ls){
    string file_name      = lua_tostring(ls, 1);
    string file_directory = lua_tostring(ls, 2);
    
    tolua_Error toerror;
    int hanlder = 0;
    if(!toluafix_isfunction(ls, 3, "LUA_FUNCTION", 0, &toerror)){
        tolua_error(ls, "# LUA ERR FUNCTION IN StartReocde ", &toerror);
        
    }else{
        hanlder = (toluafix_ref_function(ls, 3, 0));
        
        //
        NSString * name_c       = [[NSString alloc] initWithCString:(const char*)file_name.c_str() encoding:NSUTF8StringEncoding];
        NSString * directory_c  = [[NSString alloc] initWithCString:(const char*)file_directory.c_str() encoding:NSUTF8StringEncoding];
        
        [[AmrWavAudioRecoder getInstance] StartRecoderAmr:name_c
                                                Directory:directory_c
                                                 CallBack:^(BOOL result){
                                                                                lua_settop(ls, 0);
                                                                                lua_pushboolean(ls,result);
                                                                                cocos2d::LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(hanlder, 1);
                                                }];
    }
    return 0;
}


//结束录制
int AudioRecoderLua::EndReocde(lua_State* ls){
    tolua_Error toerror;
    int hanlder = 0;
    if(!toluafix_isfunction(ls, 1, "LUA_FUNCTION", 0, &toerror)){
        tolua_error(ls, "# LUA ERR FUNCTION IN StartReocde ", &toerror);
        
    }else{
        hanlder = (toluafix_ref_function(ls, 1, 0));
        
        [[AmrWavAudioRecoder getInstance] EndRecoderAmr:^(BOOL result){
                                                                lua_settop(ls, 0);
                                                                lua_pushboolean(ls,result);
                                                                cocos2d::LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(hanlder, 1);
                                                    }];
    }
    return 0;
}



//播放
int AudioRecoderLua::PlayVideo(lua_State* ls){
    string file_name      = lua_tostring(ls, 1);
    string file_directory = lua_tostring(ls, 2);
    
    tolua_Error toerror;
    int hanlder = 0;
    if(!toluafix_isfunction(ls, 3, "LUA_FUNCTION", 0, &toerror)){
        tolua_error(ls, "# LUA ERR FUNCTION IN StartReocde ", &toerror);
        
    }else{
        hanlder = (toluafix_ref_function(ls, 3, 0));
        
        //
        NSString * name_c       = [[NSString alloc] initWithCString:(const char*)file_name.c_str() encoding:NSUTF8StringEncoding];
        NSString * directory_c  = [[NSString alloc] initWithCString:(const char*)file_directory.c_str() encoding:NSUTF8StringEncoding];
        
        NSString * path = [directory_c stringByAppendingPathComponent:name_c];
        if ([name_c hasSuffix:@".amr"]) {
            [[AmrWavAudioRecoder getInstance] PlayAmr:path
                                             CallBack:^(BOOL result){
                                                                lua_settop(ls, 0);
                                                                lua_pushboolean(ls,result);
                                                                cocos2d::LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(hanlder, 1);
             }];
        }else{
            [[AmrWavAudioRecoder getInstance] PlayVideo:path
                                               CallBack:^(BOOL result){
                                                                lua_settop(ls, 0);
                                                                lua_pushboolean(ls,result);
                                                                cocos2d::LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(hanlder, 1);
             }];
        }
    }
    return 0;
}


//结束播放
int AudioRecoderLua::StopPlayVideo(lua_State* ls){
    [[AmrWavAudioRecoder getInstance] StopVideo];
    return 0;
}


int AudioRecoderLua::setAVAudioSessionCategory(lua_State* ls){
    int cate_type = lua_tointeger(ls, 1);
    int mode_type = lua_tointeger(ls, 2);
    NSLog(@" ----- SET AVAudioSessionCategory %d  , mode %d", cate_type, mode_type);
    switch (cate_type) {
        case 1:
            //--用于非以语音为主的应用，使用这个category的应用会随着静音键和屏幕关闭而静音。并且不会中止其它应用播放声音，可以和其它自带应用如iPod，safari等同时播放声音。注意：该Category无法在后台播放声音
            [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error:nil];
            break;
        case 2:
            //——用于以语音为主的应用，使用这个category的应用不会随着静音键和屏幕关闭而静音。可在后台播放声音
            [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
            break;
        case 3:
            //用于需要录音的应用，设置该category后，除了来电铃声，闹钟或日历提醒之外的其它系统声音都不会被播放。
            [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryRecord error:nil];
            break;
        case 4:
            //——用于既需要播放声音又需要录音的应用
            [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
            break;
        default:
            //——类似于AVAudioSessionCategoryAmbient 不同之处在于它会中止其它应用播放声音 这个category为默认category。该Category
            [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategorySoloAmbient error:nil];

            break;
    }
    
    switch (mode_type) {
        case 1:
            //VoIP 视频通话 适用AVAudioSessionCategoryPlayAndRecord
            [[AVAudioSession sharedInstance] setMode:AVAudioSessionModeVoiceChat error:nil];
            break;
        case 2:
            //视频播放 适用AVAudioSessionCategoryPlayback
            [[AVAudioSession sharedInstance] setCategory: AVAudioSessionModeMoviePlayback error:nil];
            break;
        case 3:
            //最小系统 。适用AVAudioSessionCategoryPlayback  AVAudioSessionCategoryPlayAndRecord  AVAudioSessionCategoryRecord
            [[AVAudioSession sharedInstance] setCategory: AVAudioSessionModeMeasurement error:nil];
            break;
        case 4:
            //录制视频时用 适用AVAudioSessionCategoryPlayAndRecord  AVAudioSessionCategoryRecord
            [[AVAudioSession sharedInstance] setMode: AVAudioSessionModeVideoRecording error:nil];
            break;
        default:
            //适用所有类别，默认模式
            [[AVAudioSession sharedInstance] setMode:AVAudioSessionModeDefault error:nil];
            
            break;
    }
    
    return 0;
}









