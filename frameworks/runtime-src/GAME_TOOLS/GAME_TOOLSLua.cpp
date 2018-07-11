//
//  GAME_TOOLSLua.cpp
//  GameChess
//
//  Created by SJ on 2017/6/13.
//
//

#include "GAME_TOOLSLua.h"
#include "string.h"

#include "tolua_fix.h"
#include "CCLuaStack.h"
#include "CCLuaValue.h"
#include "CCLuaEngine.h"
#include "YUNControl.h"
#include "GPSController.h"

#import "AmrWavAudioRecoder.h"
#import "SFHFKeychainUtils.h"
#import "IAPController.h"
#import "JumperController.h"

//阿里云推送部分
#import "AliPushManage.h"

using namespace std;

static GAME_TOOLSLua* _instance = nullptr ;

GAME_TOOLSLua* GAME_TOOLSLua::getInstance(){
    if (_instance == nullptr) {
        _instance = new GAME_TOOLSLua();
    }
    return _instance ;
}

void GAME_TOOLSLua::bind(lua_State* ls){
    this->ls = ls;
    this->init();
    
    lua_register(ls, "cpp_openSafari"                   , openSafari);
    lua_register(ls, "cpp_copyToSystem_Pasteboard"      , copy_txt  );
    lua_register(ls, "cpp_getTextFromSyetm_Pasteboard"  , paste_txt );
    lua_register(ls, "cpp_getDevicePower"               , getDevicePower );    
    lua_register(ls, "cpp_getYunIP"                     , getYunIp );
//    lua_register(ls, "cpp_getYunIP_INFO"                , getYunIp_INFO );
    lua_register(ls, "cpp_yunCheckNetStatus"            , yunCheckNetStatus);
    lua_register(ls, "cpp_getDevice_IMEI"               , getDevice_IMEI );
    
    lua_register(ls, "cpp_getGPS_Location"              , getGPS_Location );
    lua_register(ls, "cpp_setGPS_Location_callfun"      , setGPS_Location_callfun );
    lua_register(ls, "cpp_getGPS_Server_Status"         , getGPS_Server_Status );
    lua_register(ls, "cpp_stop_GPS"                     , stop_GPS );
    lua_register(ls, "cpp_show_App_GPS_Setting"         , show_App_GPS_Setting );
    
    lua_register(ls, "cpp_register_IAP_Callback"        , register_IAP_Callback );
    lua_register(ls, "cpp_unRegister_IAP_Callback"      , unRegister_IAP_Callback );
    lua_register(ls, "cpp_clean_IAP_receipt"            , clean_IAP_receipt );
    lua_register(ls, "cpp_IAP_PAY"                      , iap_pay );
    
    
    lua_register(ls, "cpp_register_JumperCallback"      , register_JumperCallback );
    lua_register(ls, "cpp_jump2App"                     , jump2App );
    
    //阿里云推送部分
    lua_register(ls, "cpp_GET_DEVICE_ID" , cpp_GET_DEVICE_ID);
    lua_register(ls, "cpp_getXcode_Preprocessor_Macros" , cpp_getXcode_Preprocessor_Macros);
}

void GAME_TOOLSLua::init(){
    YUNControl::getInstance()->init();
}

int GAME_TOOLSLua::openSafari(lua_State* ls){
    string url_path = lua_tostring(ls ,1);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString : [NSString stringWithUTF8String : url_path.c_str()]]];
    return 0;
}

int GAME_TOOLSLua::copy_txt(lua_State* ls){
    string txt = lua_tostring(ls ,1);
    
    @try {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [NSString stringWithUTF8String : txt.c_str()];
    }
    @catch(NSException* e){
        NSLog(@" xxxx// 复制出现异常 ");
    }
    return 0;
}

int GAME_TOOLSLua::paste_txt(lua_State* ls){
    string paste_txt;
    @try {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        NSString *txt = pasteboard.string ;
        if(txt == nil){
            txt = @"";
        }
        
        paste_txt = [txt cStringUsingEncoding: NSUTF8StringEncoding];
    }@catch(NSException* e){
        NSLog(@" xxxx// 粘贴出现异常 ");
        paste_txt = "Null";
    }
    
    lua_settop(ls, 0);
    lua_pushstring(ls, paste_txt.c_str());
    
    return 1;
}

int GAME_TOOLSLua::getDevicePower(lua_State* ls){
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceBatteryLevelDidChangeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                                // Level has changed
                                                                NSLog(@"Battery Level Change");
                                                                NSLog(@"电池电量：%.2f", [UIDevice currentDevice].batteryLevel);
     }];
    
    float level = [[UIDevice currentDevice] batteryLevel];
    int intlevel= level * 100 ;

    lua_settop(ls, 0);
    lua_pushinteger(ls, intlevel);
    return 1;
}

int GAME_TOOLSLua::getYunIp(lua_State* ls){
    string group_name = lua_tostring(ls ,1);
    string uuid       = lua_tostring(ls, 2);
    string game_port  = lua_tostring(ls, 3);
//    if (uuid.length() > 0 ) {
//        char * c = const_cast<char*>(uuid.c_str());
//        int hashcode = YUNControl::getInstance()->SDBMHash(c);
//        if (hashcode != 0) {
//            std::ostringstream oss;
//            group_name = group_name + "," ;
//            oss << group_name << hashcode;
//            group_name = oss.str();
//        }
//    }
    
    std::string cip = YUNControl::getInstance()->getYUNByGroupName(group_name.c_str() , uuid.c_str() , game_port.c_str());
    char * ip = new char[cip.length() + 1];
    strcpy(ip, cip.c_str());
    
    lua_settop(ls, 0);
    lua_pushstring(ls, ip);
    return 1;
}


//int GAME_TOOLSLua::getYunIp_INFO(lua_State* ls){
//    string group_name = lua_tostring(ls, 1);
//    std::string cip = YUNControl::getInstance()->getYUNIPInfo_byGroup_name(group_name.c_str());
//    char * ip = new char[cip.length() + 1];
//    strcpy(ip, cip.c_str());
//
//    lua_settop(ls, 0);
//    lua_pushstring(ls, ip);
//    return 1;
//}

//链路诊断
int GAME_TOOLSLua::yunCheckNetStatus(lua_State* ls){
    string ip = lua_tostring(ls, 1);
    int port  = lua_tointeger(ls, 2);
    
    tolua_Error toerror;
    int hanlder = 0;
    if(!toluafix_isfunction(ls, 3, "LUA_FUNCTION", 0, &toerror)){
        tolua_error(ls, "# LUA ERR FUNCTION IN yunCheckNetStatus ", &toerror);
    }else{
        hanlder = (toluafix_ref_function(ls, 3, 0));
        YUNControl::getInstance()->networkDiagnosis(ip.c_str(), port, hanlder);
    }
    
    return 0;
    
}

int GAME_TOOLSLua::getDevice_IMEI(lua_State* ls){
    NSString *SERVICE_NAME = [[NSBundle mainBundle] bundleIdentifier]; //最好用程序的bundle id
    NSString * str =  [SFHFKeychainUtils getPasswordForUsername:@"UUID" andServiceName:SERVICE_NAME error:nil];  // 从keychain获取数据
    if ([str length]<=0)
    {
        NSLog(@" ..... save chain");
        str  = [[[UIDevice currentDevice] identifierForVendor] UUIDString];  // 保存UUID作为手机唯一标识符
        [SFHFKeychainUtils storeUsername:@"UUID"
                             andPassword:str
                          forServiceName:SERVICE_NAME
                          updateExisting:1
                                   error:nil];  // 往keychain添加数据
    }
    NSLog(@" ..... %@" , str);
    if(str == nil || str.length ==0 ){
        str = @"0000000000_default";
    }
    lua_settop(ls, 0);
    lua_pushstring(ls, [str cStringUsingEncoding:NSASCIIStringEncoding]);
    return 1;
}

// GPS
int GAME_TOOLSLua::getGPS_Location(lua_State* ls){
    if(![[GPSController getInstance] isLocation_Opened]){
        [[GPSController getInstance] START_GPS];//还未开启GPS 主动注册
    }
    
    lua_settop(ls, 0);
    lua_pushstring(ls, [[[GPSController getInstance] getLoncation] cStringUsingEncoding:NSASCIIStringEncoding]);
    return 1;
}

int GAME_TOOLSLua::setGPS_Location_callfun(lua_State* ls){
    tolua_Error toerror;
    int hanlder = 0;
    if(!toluafix_isfunction(ls, 1, "LUA_FUNCTION", 0, &toerror)){
        tolua_error(ls, "# LUA ERR FUNCTION IN getGPS_Location ", &toerror);
        
    }else{
        hanlder = (toluafix_ref_function(ls, 1, 0));
        if(![[GPSController getInstance] isLocation_Opened]){
            [[GPSController getInstance] START_GPS];//还未开启GPS 主动注册
        }
        
        [[GPSController getInstance] setGPSPosStateCallback:^(NSString* result){
            string result_s = [result UTF8String]; // 转string
            lua_settop(ls, 0);
            lua_pushstring(ls, result_s.c_str());
            cocos2d::LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(hanlder, 1);
         }];
    }
    
    return 0;
}

int GAME_TOOLSLua::getGPS_Server_Status(lua_State* ls){
    bool istips = lua_toboolean(ls ,1);
    
    lua_settop(ls, 0);
    lua_pushboolean(ls, [[GPSController getInstance] checkGPS:istips]);
    return 1;
}

int GAME_TOOLSLua::stop_GPS(lua_State* ls){
    [[GPSController getInstance] STOP_GPS];
    return 0;
}

int GAME_TOOLSLua::show_App_GPS_Setting(lua_State* ls){
    [[GPSController getInstance] show_App_GPS_Setting];
    return 0;
}

/***IAP IOS 应用内支付相关接口**/
int GAME_TOOLSLua::register_IAP_Callback(lua_State* ls){
    tolua_Error toerror;
    int hanlder = 0;
    if(!toluafix_isfunction(ls, 1, "LUA_FUNCTION", 0, &toerror)){
        tolua_error(ls, "# LUA ERR FUNCTION IN register_IAP_Callback ", &toerror);
        
    }else{
        hanlder = (toluafix_ref_function(ls, 1, 0));
        
        [[IAPController getInstance] START_IAP:^(NSString* result){
                                        string result_s = [result UTF8String]; // 转string
                                        lua_settop(ls, 0);
                                        lua_pushstring(ls, result_s.c_str());
                                        cocos2d::LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(hanlder, 1);
         }];
    }
    
    return 0;
}

int GAME_TOOLSLua::unRegister_IAP_Callback(lua_State* ls){
    @try{
        [[IAPController getInstance] PAUSE_IAP];
    }
    @catch(NSException *e){
        NSLog(@" //// clean un register ");
    }
    return 0;
}

int GAME_TOOLSLua::clean_IAP_receipt(lua_State* ls){
    @try{
        [[IAPController getInstance] clean_Receipt];
    }
    @catch(NSException *e){
        NSLog(@" //// clean receipt err ");
    }
    return 0;
}

int GAME_TOOLSLua::iap_pay(lua_State* ls){
    string goodsid   = lua_tostring(ls, 1);
    NSString * goodsid_c  = [[NSString alloc] initWithCString:(const char*)goodsid.c_str()
                                                     encoding:NSUTF8StringEncoding];
    [[IAPController getInstance] IAPPay:goodsid_c];
    return 0;
}


int GAME_TOOLSLua::register_JumperCallback(lua_State* ls){
    tolua_Error toerror;
    int hanlder = 0;
    if(!toluafix_isfunction(ls, 1, "LUA_FUNCTION", 0, &toerror)){
        tolua_error(ls, "# LUA ERR FUNCTION IN register_JumperCallback ", &toerror);
        
    }else{
        hanlder = (toluafix_ref_function(ls, 1, 0));
        
        [[JumperController getInstance] setJumperCallback:^(NSString* result){
                                        NSLog(@"appjumper callback to lua %@",result);
                                        string result_s = [result UTF8String]; // 转string
                                        lua_settop(ls, 0);
                                        lua_pushstring(ls, result_s.c_str());
                                        cocos2d::LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(hanlder, 1);
         }];
    }
    
    return 0;
}

int GAME_TOOLSLua::jump2App(lua_State* ls){
    string packname = lua_tostring(ls ,1);
    string data     = lua_tostring(ls, 2);
    
    NSString * packname_c  = [[NSString alloc] initWithCString:(const char*)packname.c_str()
                                                     encoding:NSUTF8StringEncoding];
    NSString * data_c  = [[NSString alloc] initWithCString:(const char*)data.c_str()
                                                     encoding:NSUTF8StringEncoding];
    
    lua_settop(ls, 0);
    lua_pushboolean(ls, [[JumperController getInstance] jump2App:packname_c Data:data_c]);
    return 1;
}

//阿里云推送部分 拿设备ID
int GAME_TOOLSLua::cpp_GET_DEVICE_ID(lua_State *ls){
    NSString* deviceID = [[AliPushManage getInstance] getDiviceID];
    lua_settop(ls, 0);
    lua_pushstring(ls, [deviceID UTF8String]);
    return 1;
}

int GAME_TOOLSLua::cpp_getXcode_Preprocessor_Macros(lua_State *ls){
    lua_settop(ls, 0);
    
#ifdef IPHONE_DEV
    lua_pushstring(ls, "IPHONE_DEV");
#endif
    
#ifdef IPHONE_RELEASE
    lua_pushstring(ls, "IPHONE_RELEASE");
#endif
    
#ifdef IPHONE_INHOUS
    lua_pushstring(ls, "IPHONE_INHOUS");
#endif
    return 1;
}

void GAME_TOOLSLua::onGameParuse(){
    CCLOG(" ******** onGame Pause ******** ");
    lua_State* L = cocos2d::LuaEngine::getInstance()->getLuaStack()->getLuaState();
    lua_getglobal(L, "onGame_Paruse");
    lua_call(L, 0, 0);
}

