//
//  WeChatSDKLua.h
//  Mahjong
//
//  Created by SJ on 16/6/20.
//
//
/**
 
 
 
 */


#ifndef WeChatSDKLua_h
#define WeChatSDKLua_h

#include <stdio.h>
#include "CCLuaEngine.h"

class WeChatSDKLua{
    public :
    lua_State* ls; 
    static WeChatSDKLua* getInstance();
    
    virtual void bind(lua_State* ls);
    static int WeChatLogin(lua_State* ls);
    static int WeChatTxtShare(lua_State* ls);
    static int WeChatUrlShare(lua_State* ls);
    static int WeChatImageShare(lua_State* ls);
    static int WeChatImageMergeShare(lua_State* ls);
    static int WeChatImageMergeShareByJSON(lua_State* ls);
    static int WeChatClientExit(lua_State* ls);
    static int WeChatMiniProjectShare(lua_State* ls);
    static int WeChatCheckLaunchData(lua_State* ls);
    static int WeChatSetLaunchCallback(lua_State* ls);
    
};
#endif /* WeChatSDKLua_hpp */
