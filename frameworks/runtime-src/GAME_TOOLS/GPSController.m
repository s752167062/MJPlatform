//
//  GPSController.m
//
//  Created by SJ on 2017/4/25.
//  Copyright © 2017年 SJ. All rights reserved.


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GPSController.h"


typedef void(^GPSPosCallback)(NSString*);

@interface GPSController ()<CLLocationManagerDelegate,UIAlertViewDelegate>{
    CLLocationManager* locationManager ;
    double jing_du;//经度
    double wei_du; //纬度
    int start_tips_count ;
    bool isLocation_open;
}

@property (nonatomic,strong) GPSPosCallback gpsPosCallBack;

@end

@implementation GPSController

static GPSController* instance = NULL;

+(GPSController*) getInstance{
    if (instance == NULL) {
        instance = [[GPSController alloc] init];
    }
    return instance;
}

-(id)init{
    if (self = [super init]) {
        //初始化
        jing_du = -1;
        wei_du  = -1;
        start_tips_count = 1;//开启服务提示次数
        isLocation_open = false;
    }
    return self;
}


-(void) START_GPS{
    //判断定位功能是否可用
    NSLog(@" xxxx // 开始初始化gps");
    if([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)){
        NSLog(@"xxxx // 定位可用");
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        
        //设置定位距离过滤参数 (当本次定位和上次定位之间的距离大于或等于这个值时，调用代理方法)
        locationManager.distanceFilter  = 2;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;// 设置定位精度(精度越高越耗电)
        
        if ([[UIDevice currentDevice].systemVersion floatValue] >=8.0 && start_tips_count > 0) {
            NSLog(@"8.0以上版本 >> ");
            [locationManager requestAlwaysAuthorization];
            [locationManager requestWhenInUseAuthorization];
        }

        
        [locationManager startUpdatingLocation];//开始更新位置
        isLocation_open = true;
    }else{
        NSLog(@" xxxx // **** 定位功能无法使用 ****");
        isLocation_open = false;
    }
    start_tips_count -= 1 ;
}


-(void) STOP_GPS{
    if (isLocation_open) {
        isLocation_open = false;
        [self stopUpdateLocation];
    }
}

-(void) startUpdateLocation{
    if([CLLocationManager locationServicesEnabled]){
        [locationManager startUpdatingLocation];//开始更新位置
    }
}

-(void) stopUpdateLocation{
    self.gpsPosCallBack = NULL;
    if([CLLocationManager locationServicesEnabled]){
        [locationManager stopUpdatingLocation];//关闭更新位置
        isLocation_open = false;
        self.gpsPosCallBack = NULL;
    }
}


-(NSString*) getLoncation{
    if (jing_du < 1 && wei_du < 1) {
        jing_du = -1;
        wei_du  = -1;
    }
    return [NSString stringWithFormat:@"%f,%f" , jing_du ,wei_du];
}

-(bool)checkGPS:(bool)istips{
    bool ret = true;
    if(![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        if (istips) {
            if ([[UIDevice currentDevice].systemVersion floatValue] >=8.0 ) {
                NSLog(@"8.0以上版本 >> ");
                [locationManager requestAlwaysAuthorization];
                [locationManager requestWhenInUseAuthorization];
            }
//             UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"打开定位开关"
//                                                                message:@"请点击设置打开定位服务"
//                                                               delegate:self
//                                                      cancelButtonTitle:@"取消"
//                                                      otherButtonTitles:@"设置", nil];
//            
//             [alertView show];
        }
        ret = false;
    }
    
    return ret ;
}

-(bool) isLocation_Opened{
    return isLocation_open ;
}


// 添加位置更新回调
-(void) setGPSPosStateCallback:(void(^)(NSString*))callback{
    self.gpsPosCallBack = callback;
}

-(void) onGPSCallback{
    if(self.gpsPosCallBack != NULL){
        NSString * location = [self getLoncation];
        self.gpsPosCallBack(location);
    }
}

-(void) show_App_GPS_Setting{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"打开定位开关"
                                                       message:@"请点击设置打开定位服务"
                                                      delegate:self
                                             cancelButtonTitle:@"取消"
                                             otherButtonTitles:@"设置", nil];
    
    [alertView show];
}

/**********************************************************************
    overried
 **/
#pragma mark 获取到新的位置信息时调用
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    NSLog(@" **** 定位到了");
    CLLocation * currentlocation = [locations lastObject];
    
    jing_du = currentlocation.coordinate.longitude;
    wei_du  = currentlocation.coordinate.latitude;
    
    [self onGPSCallback];
    NSLog(@" **** 经度: %f \n纬度：%f" , jing_du, wei_du);
    
}
#pragma mark 不能获取位置信息时调用
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@" **** 获取定位失败");
    jing_du = -1;
    wei_du  = -1;
    
    [self onGPSCallback];
}

#pragma mark定位服务状态改变时调用
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:{
            NSLog(@" **** 用户还未决定授权");
//            if([CLLocationManager locationServicesEnabled]){
//                if ([[UIDevice currentDevice].systemVersion floatValue] >=8.0 ) {
//                    NSLog(@"8.0以上版本 >> ");
//                    [locationManager requestAlwaysAuthorization];
//                    [locationManager requestWhenInUseAuthorization];
//                }
//            }
            
            break;
        }
        case kCLAuthorizationStatusRestricted:{
            NSLog(@" **** 访问受限");
            jing_du = -1;
            wei_du  = -1;
            [self onGPSCallback];
            break;
        }
        case kCLAuthorizationStatusDenied:{
            // 类方法，判断是否开启定位服务
            if ([CLLocationManager locationServicesEnabled]) {
                NSLog(@" **** 定位服务开启，被拒绝");
                jing_du = -1;
                wei_du  = -1;
            } else {
                NSLog(@" **** 定位服务关闭，不可用");
                jing_du = -1;
                wei_du  = -1;
            }
            [self onGPSCallback];
            
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:{
            NSLog(@" **** 获得前后台授权");
            [self onGPSCallback];
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse:{
            NSLog(@" **** 获得前台授权");
            [self onGPSCallback];
            break;
        }
        default:{
            NSLog(@" **** GPS默认");
            break;
        }
    }
}

/******************************************************************
    other
 **/

- (void)showAlertMessage:(NSString*)msg{
    UIAlertView * mAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [mAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
            
        }
    }
    
}


@end
