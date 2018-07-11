//
//  NET_WORKER_Lua.cpp
//  GameChess
//
//  Created by SJ on 2017/6/13.
//
//

#include "NET_WORKER_Lua.h"
#include "string.h"

#include "tolua_fix.h"
#include "CCLuaStack.h"
#include "CCLuaValue.h"
#include "CCLuaEngine.h"

#import "NETWorker.h"

using namespace std;

static NET_WORKER_Lua* _instance = nullptr ;

NET_WORKER_Lua* NET_WORKER_Lua::getInstance(){
    if (_instance == nullptr) {
        _instance = new NET_WORKER_Lua();
    }
    return _instance ;
}

void NET_WORKER_Lua::bind(lua_State* ls){
    this->ls = ls;
    this->init();
    
    lua_register(ls, "cpp_registerNetWorkListener"        , registerNetWorkListener);
    lua_register(ls, "cpp_unregisterNetWorkListener"      , unregisterNetWorkListener  );
    lua_register(ls, "cpp_isNetEnable"                    , isNetEnable );
    lua_register(ls, "cpp_getNetWorkType"                 , getNetWorkType );
}

void NET_WORKER_Lua::init(){

}

int NET_WORKER_Lua::registerNetWorkListener(lua_State* ls){
    tolua_Error toerror;
    int hanlder = 0;
    if(!toluafix_isfunction(ls, 1, "LUA_FUNCTION", 0, &toerror)){
        tolua_error(ls, "# LUA ERR FUNCTION IN registerNetWorkListener ", &toerror);
        
    }else{
        hanlder = (toluafix_ref_function(ls, 1, 0));
        [[NETWorker getInstance] registerNetWorkListener:^(int status){
            lua_settop(ls, 0);
            lua_pushinteger(ls, status);
            cocos2d::LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(hanlder, 1);
         }];
    }
    return 0;

}

int NET_WORKER_Lua::unregisterNetWorkListener(lua_State* ls){
    [[NETWorker getInstance] unregisterNetWorkListener];
    return 0;
}

int NET_WORKER_Lua::isNetEnable(lua_State* ls){
    BOOL status = [[NETWorker getInstance] isNetEnable];
    
    lua_settop(ls, 0);
    lua_pushboolean(ls, status);
    return 1;
}

int NET_WORKER_Lua::getNetWorkType(lua_State* ls){
    int type = [[NETWorker getInstance] getNetWorkType];

    lua_settop(ls, 0);
    lua_pushinteger(ls, type);
    return 1;
}








