//
//  NET_WORKER_Lua.hpp
//  GameChess
//
//  Created by SJ on 2017/6/13.
//
//

#ifndef NET_WORKER_Lua_hpp
#define NET_WORKER_Lua_hpp

#include <stdio.h>
#include "CCLuaEngine.h"

class NET_WORKER_Lua{
    public :
    lua_State* ls;
    static NET_WORKER_Lua* getInstance();
    
    virtual void bind(lua_State* ls);
    void init();
    
    static int registerNetWorkListener(lua_State* ls);  //注册网络监听
    static int unregisterNetWorkListener(lua_State* ls);//取消注册网络监听
    static int isNetEnable(lua_State* ls);              //判断网络是否可用
    static int getNetWorkType(lua_State* ls);           //获取网络类型 wifi 2g 3g 4g null
};
#endif /* NET_WORKER_Lua_hpp */
