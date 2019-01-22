//
//  GAME_TOOLSLua.hpp
//  GameChess
//
//  Created by SJ on 2017/6/13.
//
//

#ifndef GAME_TOOLSLua_hpp
#define GAME_TOOLSLua_hpp

#include <stdio.h>
#include "CCLuaEngine.h"

class GAME_TOOLSLua{
    public :
    lua_State* ls;
    static GAME_TOOLSLua* getInstance();
    
    virtual void bind(lua_State* ls);
    void init();
    
    static int openSafari(lua_State* ls);//打开浏览器
    static int copy_txt(lua_State* ls);//添加文本到复制的内容
    static int paste_txt(lua_State* ls);//获取粘贴文本内容
    static int getDevicePower(lua_State* ls);//电量
    static int getYunIp(lua_State* ls);//获取游戏遁IP
    static int getYunIpWithDomain(lua_State* ls);//获取游戏遁IP
//    static int getYunIp_INFO(lua_State* ls);//获取网络运营商
    static int yunCheckNetStatus(lua_State* ls);//链路诊断
    
    static int getDevice_IMEI(lua_State* ls);//获取手机设备号
    
    static int cpp_getGPS_Location(lua_State* ls);
    static int cpp_setGPS_Location_callfun(lua_State* ls);
    static int cpp_getGPS_Server_Status(lua_State* ls);
    static int cpp_Stop_GPS(lua_State* ls);
    static int cpp_get_GPS_Distance(lua_State* ls);
    static int cpp_show_App_GPS_Setting(lua_State* ls);
    
    static int register_IAP_Callback(lua_State* ls);
    static int unRegister_IAP_Callback(lua_State* ls);
    static int clean_IAP_receipt(lua_State* ls);
    static int iap_pay(lua_State* ls);
    
    static int register_JumperCallback(lua_State* ls);
    static int jump2App(lua_State* ls);
    
    //阿里云推送部分
    static int cpp_GET_DEVICE_ID(lua_State* ls);
    
    //阿里云推送部分
    static int cpp_getXcode_Preprocessor_Macros(lua_State* ls);
    
    //打开H5
    static int cpp_startH5Game(lua_State* ls);
    void onGameParuse();
};
#endif /* GAME_TOOLSLua_hpp */
