//
//  GPSController.h
//
//  Created by SJ on 2017/4/25.
//  Copyright © 2017年 SJ. All rights reserved.
//
/**
 在info.plist中加入：
 //允许在前台使用时获取GPS的描述
    NSLocationAlwaysUsageDescription＝YES
 
 //允许永久使用GPS的描述
    NSLocationWhenInUseUsageDescription＝YES
 
 添加：
    CoreLocation.framework
 
 
 游戏业务调用 getLoncation 或者setGPSPosStateCallback  前都会自动的判断服务并初始化
    1. 可以使用计时器不断获取getLoncation。
    2. 也可以注册setGPSPosStateCallback 等待状态获取。
 
 */

#ifndef GPSController_h
#define GPSController_h

#import <CoreLocation/CoreLocation.h>
@interface GPSController : NSObject

@property (nonatomic , readwrite , retain)id viewController;
+(GPSController*) getInstance;

-(void) START_GPS;
-(void) STOP_GPS;

-(void) startUpdateLocation;
-(void) stopUpdateLocation;

-(NSString*) getLoncation;
-(bool) checkGPS:(bool)istips;

-(bool) isLocation_Opened;

-(void) setGPSPosStateCallback:(void(^)(NSString*))callback;
-(void) onGPSCallback;

-(void) show_App_GPS_Setting;

@end

#endif /* GPSController_h */
