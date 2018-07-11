//
//  WeChatSDKLua.cpp
//  Mahjong
//
//  Created by SJ on 16/6/20.
//
//

#include "WeChatSDKLua.h"
#include "string.h"

#include "tolua_fix.h"
#include "CCLuaStack.h"
#include "CCLuaValue.h"
#include "CCLuaEngine.h"
#import "WeChatSDKController.h"

using namespace std;

static WeChatSDKLua* _instance = nullptr ;

WeChatSDKLua* WeChatSDKLua::getInstance(){
    if (_instance == nullptr) {
        _instance = new WeChatSDKLua();
    }
    return _instance ;
}

void WeChatSDKLua::bind(lua_State* ls){
    this->ls = ls;
    //微信好友、 盆友圈 、 url 、图片（包含合图）
    lua_register(ls, "cpp_WeChatLogin"              , WeChatLogin);
    lua_register(ls, "cpp_WeChatTxtShare"           , WeChatTxtShare);
    lua_register(ls, "cpp_WeChatUrlShare"           , WeChatUrlShare);
    lua_register(ls, "cpp_WeChatImageShare"         , WeChatImageShare);
    lua_register(ls, "cpp_WeChatImageMergeShare"    , WeChatImageMergeShare);
    lua_register(ls, "cpp_WeChatImageMergeShareByJSON" , WeChatImageMergeShareByJSON);
    lua_register(ls, "cpp_WeChatClientExit"            , WeChatClientExit);
    
    lua_register(ls, "cpp_WeChatMiniProjectShare"      , WeChatMiniProjectShare);
    lua_register(ls, "cpp_WeChatCheckLaunchData"       , WeChatCheckLaunchData);
    lua_register(ls, "cpp_WeChatSetLaunchCallback"       , WeChatSetLaunchCallback);
}

//登录
int WeChatSDKLua::WeChatLogin(lua_State* ls){
    tolua_Error toerror;
    int hanlder = 0;
    if(!toluafix_isfunction(ls, 1, "LUA_FUNCTION", 0, &toerror)){
        tolua_error(ls, "# LUA ERR FUNCTION IN WeChatLogin ", &toerror);
        
    }else{
        hanlder = (toluafix_ref_function(ls, 1, 0));
        [[WeChatSDKController getInstance] mWeChatLogin:^(NSString* result){
            string result_s = [result UTF8String]; // 转string
            lua_settop(ls, 0);
            lua_pushstring(ls, result_s.c_str());
            cocos2d::LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(hanlder, 1);
         }];
    }
    return 0;
}


int WeChatSDKLua::WeChatTxtShare(lua_State* ls){
    string msg     = lua_tostring(ls, 1);
    int share_type = lua_tointeger(ls, 2);//分享类型

    NSString * msg_c  = [[NSString alloc] initWithCString:(const char*)msg.c_str() encoding:NSUTF8StringEncoding];
    bool success = [[WeChatSDKController getInstance] mWeChatTxtShare:msg_c
                                                           Share_Type:share_type];
    lua_settop(ls, 0);
    lua_pushboolean(ls, success);
    
    return 1;
}

int WeChatSDKLua::WeChatUrlShare(lua_State* ls){
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
            [[WeChatSDKController getInstance] mWeChatUrlShare:title_c Desc:desc_c Url:url_c Share_Type:share_type CallFunc:^(NSString* result){
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
int WeChatSDKLua::WeChatImageShare(lua_State* ls){
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
            [[WeChatSDKController getInstance] mWeChatImageShare:imagePath_c Share_Type:share_type CallFunc:^(NSString* result){
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
int WeChatSDKLua::WeChatImageMergeShare(lua_State* ls){
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
            [[WeChatSDKController getInstance] mWeChatImageMergeShare:image1Path_c Image2Path:image2Path_c PositionX:position_x PositionY:position_y ImageWidth:image2Width ImageHeight:image2Height Share_Type:share_type CallFunc:^(NSString* result){
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
int WeChatSDKLua::WeChatImageMergeShareByJSON(lua_State* ls){
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
            [[WeChatSDKController getInstance] mWeChatImageMergeShareByJSON:json_str_c Share_Type:share_type CallFunc:^(NSString* result){
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


int WeChatSDKLua::WeChatClientExit(lua_State* ls){
    CCLOG(" CHECK WECHAT CLIENT EXIT ");
    lua_settop(ls, 0);
    lua_pushboolean(ls, [[WeChatSDKController getInstance] isWXClientExit]);
    return 1 ;
}

int WeChatSDKLua::WeChatMiniProjectShare(lua_State* ls){
    string json_str = lua_tostring( ls, 1);
    tolua_Error toerror;
    int hanlder = 0;
    if(!toluafix_isfunction(ls, 2, "LUA_FUNCTION", 0, &toerror)){
        tolua_error(ls, "# LUA ERR FUNCTION IN WeChatImageMergeShareByJSON ", &toerror);
        
    }else{
        hanlder = (toluafix_ref_function(ls, 2, 0));
        
        NSString * json_str_c  = [[NSString alloc] initWithCString:(const char*)json_str.c_str() encoding:NSUTF8StringEncoding];
        if (json_str_c.length > 0) {//要求数据是存在的
            [[WeChatSDKController getInstance] mWeChatMiniProjectShareByJSON:json_str_c CallFunc:^(NSString* result){
                                                                     string result_s = [result UTF8String]; // 转string
                                                                     lua_settop(ls, 0);
                                                                     lua_pushstring(ls, result_s.c_str());
                                                                     cocos2d::LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(hanlder, 1);
             }];
        }else{
            NSString * result = @"-1,Share mini project JSON data nil";
            string result_s = [result UTF8String]; // 转string
            lua_settop(ls, 0);
            lua_pushstring(ls, result_s.c_str());
            cocos2d::LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(hanlder, 1);
        }
        
    }

    return 0;
}

int WeChatSDKLua::WeChatSetLaunchCallback(lua_State* ls){
    tolua_Error toerror;
    int hanlder = 0;
    if(!toluafix_isfunction(ls, 1, "LUA_FUNCTION", 0, &toerror)){
        tolua_error(ls, "# LUA ERR FUNCTION IN WeChatSetLaunchCallback ", &toerror);
        
    }else{
        hanlder = (toluafix_ref_function(ls, 1, 0));
        [[WeChatSDKController getInstance] mWeChatSetLaunchCallback:^(NSString* result){
                                                            string result_s = [result UTF8String]; // 转string
                                                            lua_settop(ls, 0);
                                                            lua_pushstring(ls, result_s.c_str());
                                                            cocos2d::LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(hanlder, 1);
         }];
        
    }
    
    return 0;
}

int WeChatSDKLua::WeChatCheckLaunchData(lua_State* ls){
    NSString * data = [[WeChatSDKController getInstance] getWXLaunchData];
    string result_data;
    if(data == nil){
        result_data = "";
    }else{
        result_data = [data UTF8String];
    }
    
    lua_settop(ls, 0);
    lua_pushstring(ls, result_data.c_str());
    return 1 ;
}

