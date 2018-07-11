//
//  WeChatSDKController.h
//  YYDemo
//
//  Created by SJ on 2017/4/25.
//  Copyright © 2017年 SJ. All rights reserved.
//
/**
        修改other link 为 -ObjC
        修改编译模式为 ObjectiveC++
        修改 Build Active Architecture Only : No
        
        添加
        libsqlite3.0.tbd
        CoreTelephony.framework
        Security.framework
        SystemConfiguration.framework
        MediaPlayer.framework
        GameController.framework
 
        修改info.plist
        
 */

#ifndef WeChatSDKController_h
#define WeChatSDKController_h
#import "WXApi.h"
#import "WXApiManager.h"

@interface WeChatSDKController : NSObject 

+(WeChatSDKController*) getInstance;

/*ViewControl 下的初始化*/
- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url;
- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
    

/*在lua中提取微信 APPID 和 SERCRET*/
- (void) initAPPID_SERCRET;

- (void) mWeChatLogin:(void(^)(NSString *))callfunc;
- (bool) mWeChatTxtShare:(NSString *)msg Share_Type:(int)type;
- (void) mWeChatUrlShare:(NSString *)title Desc:(NSString *)desc Url:(NSString *)url Share_Type:(int)type CallFunc:(void(^)(NSString*))callfunc;
- (void) mWeChatImageShare:(NSString *)imagePath Share_Type:(int)type CallFunc:(void(^)(NSString*))callfunc;
- (void) mWeChatImageMergeShare:(NSString *)image1Path Image2Path:(NSString *)image2Path PositionX:(int)px PositionY:(int)py ImageWidth:(int)imagewidth ImageHeight:(int)imageheight Share_Type:(int)type CallFunc:(void(^)(NSString*))callfunc;
- (void) mWeChatImageMergeShareByJSON:(NSString *)json_str Share_Type:(int)type CallFunc:(void(^)(NSString*))callfunc;
- (bool) isWXClientExit;

- (void) mWeChatMiniProjectShareByJSON:(NSString *)json_str CallFunc:(void(^)(NSString*))callfunc;
- (void) mWeChatSetLaunchCallback:(void(^)(NSString*))callfunc;

- (NSString*) getWXLaunchData;
- (void) setWXLaunchData:(NSString*)data;
- (void) cleanLaunchData;

- (void) onLoginCallBack:(NSString *)msg;
- (void) onUrlShareCallBack:(NSString *)msg;
- (void) onImageShareCallBack:(NSString *)msg;
- (void) onMiniProjectShareCallBack:(NSString *)msg;
- (void) onMiniProjectLaunchCallBack:(NSString *)msg;
@end

#endif /* WeChatSDKController_h */
