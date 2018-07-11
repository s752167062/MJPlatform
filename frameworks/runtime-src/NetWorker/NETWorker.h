//
//  NETWorker.h
//  YYDemo
//
//  Created by SJ on 2017/4/25.
//  Copyright © 2017年 SJ. All rights reserved.
//
/**       
        添加
        CoreTelephony.framework   
 */

#ifndef NETWorker_h
#define NETWorker_h
#import "WXApi.h"
#import "WXApiManager.h"

@interface NETWorker : NSObject 

+(NETWorker*) getInstance;

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;


- (void) registerNetWorkListener:(void(^)(int))callfunc;
- (void) unregisterNetWorkListener;
- (bool) isNetEnable;
- (int)  getNetWorkType;

- (bool) isIPV6_NET;
- (void)checkIPV;
- (void) onNetWorkStatusChangeCallBack:(int)status;

@end

#endif /* NETWorker_h */
