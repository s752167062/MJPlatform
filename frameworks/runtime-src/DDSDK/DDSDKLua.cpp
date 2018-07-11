//
//  DDSDKLua.cpp
//  Mahjong
//
//  Created by SJ on 16/6/20.
//
//

#include "DDSDKLua.h"
#include "string.h"

#include "tolua_fix.h"
#include "CCLuaStack.h"
#include "CCLuaValue.h"
#include "CCLuaEngine.h"
#import "DDSDKController.h"

using namespace std;

static DDSDKLua* _instance = nullptr ;

DDSDKLua* DDSDKLua::getInstance(){
    if (_instance == nullptr) {
        _instance = new DDSDKLua();
    }
    return _instance ;
}

void DDSDKLua::bind(lua_State* ls){
    this->ls = ls;
    //DD好友、  url 、图片（包含合图）
    lua_register(ls, "cpp_DDTxtShare"           , DDTxtShare);
    lua_register(ls, "cpp_DDUrlShare"           , DDUrlShare);
    lua_register(ls, "cpp_DDImageShare"         , DDImageShare);
    lua_register(ls, "cpp_DDImageMergeShare"    , DDImageMergeShare);
    lua_register(ls, "cpp_DDImageMergeShareByJSON" , DDImageMergeShareByJSON);
    lua_register(ls, "cpp_DDClientExit"            , DDClientExit);
    lua_register(ls, "cpp_DDSupport"            , DDSupport);
}


int DDSDKLua::DDTxtShare(lua_State* ls){
    string msg     = lua_tostring(ls, 1);
    int share_type = lua_tointeger(ls, 2);//分享类型

    NSString * msg_c  = [[NSString alloc] initWithCString:(const char*)msg.c_str() encoding:NSUTF8StringEncoding];
    bool success = [[DDSDKController getInstance] mDDTxtShare:msg_c
                                                           Share_Type:share_type];
    lua_settop(ls, 0);
    lua_pushboolean(ls, success);
    
    return 1;
}

int DDSDKLua::DDUrlShare(lua_State* ls){
    string title   = lua_tostring(ls, 1);
    string desc    = lua_tostring(ls, 2);
    string url     = lua_tostring(ls, 3);
    int share_type = lua_tointeger(ls, 4);//分享类型
    
    tolua_Error toerror;
    int hanlder = 0;
    if(!toluafix_isfunction(ls, 5, "LUA_FUNCTION", 0, &toerror)){
        tolua_error(ls, "# LUA ERR FUNCTION IN WeChatUrlShare ", &toerror);
        
    }else{
        hanlder = (toluafix_ref_function(ls, 5, 0));//回调函数
 
        NSString * title_c  = [[NSString alloc] initWithCString:(const char*)title.c_str() encoding:NSUTF8StringEncoding];
        NSString * desc_c   = [[NSString alloc] initWithCString:(const char*)desc.c_str() encoding:NSUTF8StringEncoding];
        NSString * url_c    = [[NSString alloc] initWithCString:(const char*)url.c_str() encoding:NSUTF8StringEncoding];
        
        if (url_c.length > 0 ) {
            [[DDSDKController getInstance] mDDUrlShare:title_c Desc:desc_c Url:url_c Share_Type:share_type CallFunc:^(NSString* result){
                string result_s = [result UTF8String]; // 转string
                lua_settop(ls, 0);
                lua_pushstring(ls, result_s.c_str());
                cocos2d::LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(hanlder, 1);
             }];
        }else{
            NSString * result = @"-1,URL A Null Value!";
            string result_s = [result UTF8String]; // 转string
            lua_settop(ls, 0);
            lua_pushstring(ls, result_s.c_str());
            cocos2d::LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(hanlder, 1);
        }
    }
    
    return 0;
}

//图片分享
int DDSDKLua::DDImageShare(lua_State* ls){
    string imagePath = lua_tostring(ls, 1);
    int share_type   = lua_tointeger(ls ,2);
    tolua_Error toerror;
    int hanlder = 0;
    if(!toluafix_isfunction(ls, 3, "LUA_FUNCTION", 0, &toerror)){
        tolua_error(ls, "# LUA ERR FUNCTION IN WeChatImageShare ", &toerror);
        
    }else{
        hanlder = (toluafix_ref_function(ls, 3, 0));
        
        NSString * imagePath_c  = [[NSString alloc] initWithCString:(const char*)imagePath.c_str() encoding:NSUTF8StringEncoding];
        if (imagePath_c.length > 0) {
            [[DDSDKController getInstance] mDDImageShare:imagePath_c Share_Type:share_type CallFunc:^(NSString* result){
                string result_s = [result UTF8String]; // 转string
                lua_settop(ls, 0);
                lua_pushstring(ls, result_s.c_str());
                cocos2d::LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(hanlder, 1);
             }];
        }else{
            NSString * result = @"-1,ImageFilePath A Null Value!";
            string result_s = [result UTF8String]; // 转string
            lua_settop(ls, 0);
            lua_pushstring(ls, result_s.c_str());
            cocos2d::LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(hanlder, 1);
        }
        
    }
    return 0;
}

//合图分享
int DDSDKLua::DDImageMergeShare(lua_State* ls){
    string image1Path = lua_tostring(ls, 1);
    string image2Path = lua_tostring(ls, 2);
    int position_x    = lua_tointeger(ls ,3);
    int position_y    = lua_tointeger(ls ,4);
    int image2Width   = lua_tointeger(ls ,5);
    int image2Height  = lua_tointeger(ls ,6);
    int share_type    = lua_tointeger(ls ,7);

    tolua_Error toerror;
    int hanlder = 0;
    if(!toluafix_isfunction(ls, 8, "LUA_FUNCTION", 0, &toerror)){
        tolua_error(ls, "# LUA ERR FUNCTION IN WeChatImageShare ", &toerror);
        
    }else{
        hanlder = (toluafix_ref_function(ls, 8, 0));
        
        NSString * image1Path_c  = [[NSString alloc] initWithCString:(const char*)image1Path.c_str() encoding:NSUTF8StringEncoding];
        NSString * image2Path_c  = [[NSString alloc] initWithCString:(const char*)image2Path.c_str() encoding:NSUTF8StringEncoding];
        if (image1Path_c.length > 0 || image2Path_c.length > 0 ) {//合图要求两张图都是存在的
            [[DDSDKController getInstance] mDDImageMergeShare:image1Path_c Image2Path:image2Path_c PositionX:position_x PositionY:position_y ImageWidth:image2Width ImageHeight:image2Height Share_Type:share_type CallFunc:^(NSString* result){
                string result_s = [result UTF8String]; // 转string
                lua_settop(ls, 0);
                lua_pushstring(ls, result_s.c_str());
                cocos2d::LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(hanlder, 1);
             }];
        }else{
            NSString * result = @"-1,Share merge Image Path nil";
            string result_s = [result UTF8String]; // 转string
            lua_settop(ls, 0);
            lua_pushstring(ls, result_s.c_str());
            cocos2d::LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(hanlder, 1);
        }
        
    }
    return 0;
}

//根据JSON 数据合图分享
int DDSDKLua::DDImageMergeShareByJSON(lua_State* ls){
    string json_str = lua_tostring( ls, 1);
    int share_type  = lua_tointeger(ls, 2);
    
    tolua_Error toerror;
    int hanlder = 0;
    if(!toluafix_isfunction(ls, 3, "LUA_FUNCTION", 0, &toerror)){
        tolua_error(ls, "# LUA ERR FUNCTION IN WeChatImageMergeShareByJSON ", &toerror);
        
    }else{
        hanlder = (toluafix_ref_function(ls, 3, 0));
        
        NSString * json_str_c  = [[NSString alloc] initWithCString:(const char*)json_str.c_str() encoding:NSUTF8StringEncoding];
        if (json_str_c.length > 0) {//合图要求合图数据是存在的
            [[DDSDKController getInstance] mDDImageMergeShareByJSON:json_str_c Share_Type:share_type CallFunc:^(NSString* result){
                                    string result_s = [result UTF8String]; // 转string
                                    lua_settop(ls, 0);
                                    lua_pushstring(ls, result_s.c_str());
                                    cocos2d::LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(hanlder, 1);
             }];
        }else{
            NSString * result = @"-1,Share merge image JSON data nil";
            string result_s = [result UTF8String]; // 转string
            lua_settop(ls, 0);
            lua_pushstring(ls, result_s.c_str());
            cocos2d::LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(hanlder, 1);
        }
        
    }
    return 0;

}


int DDSDKLua::DDClientExit(lua_State* ls){
    CCLOG(" CHECK WECHAT CLIENT EXIT ");
    lua_settop(ls, 0);
    lua_pushboolean(ls, [[DDSDKController getInstance] isDDClientExit]);
    return 1 ;
}

int DDSDKLua::DDSupport(lua_State* ls){
    CCLOG(" CHECK WECHAT CLIENT EXIT ");
    lua_settop(ls, 0);
    lua_pushboolean(ls, [[DDSDKController getInstance] isDDSupport]);
    return 1 ;
}
