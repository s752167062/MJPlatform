//
//  DDSDKLua.h
//  Mahjong
//
//  Created by SJ on 16/6/20.
//
//
/**
 
 
 
 */


#ifndef DDSDKLua_h
#define DDSDKLua_h

#include <stdio.h>
#include "CCLuaEngine.h"

class DDSDKLua{
    public :
    lua_State* ls; 
    static DDSDKLua* getInstance();
    
    virtual void bind(lua_State* ls);

    static int DDTxtShare(lua_State* ls);
    static int DDUrlShare(lua_State* ls);
    static int DDImageShare(lua_State* ls);
    static int DDImageMergeShare(lua_State* ls);
    static int DDImageMergeShareByJSON(lua_State* ls);
    static int DDClientExit(lua_State* ls);
    static int DDSupport(lua_State* ls);
    
};
#endif /* DDSDKLua_hpp */
