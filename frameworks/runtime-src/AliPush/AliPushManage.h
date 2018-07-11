//
//  AliPushManage.h
//  HongZhong_mz
//
//  Created by marlon on 2017/11/3.
//
//
// iOS 10 notification
#import <UserNotifications/UserNotifications.h>

#ifndef AliPushManage_h
#define AliPushManage_h
@interface AliPushManage : NSObject
//企业包 的key 和 包名

+ (AliPushManage *) getInstance;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

- (void) initCloudPush;
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo;
- (void)registerMessageReceive;
- (void)onMessageReceived:(NSNotification *)notification;

- (void)getNotificationSettingStatus;
- (void)createCustomNotificationCategory;
- (void)handleiOS10Notification:(UNNotification *)notification;
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler;
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler;
-(NSString *) getDiviceID;
@end
#endif /* AliPushManage_h */
