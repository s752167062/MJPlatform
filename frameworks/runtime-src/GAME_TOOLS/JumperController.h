
//
//  JumperController.h
//  HongZhong_mz
//
//  Created by SJ on 16/9/19.
//
//

#ifndef JumperController_h
#define JumperController_h
#import <UIKit/UIKit.h>


//在 url scheme 中注册
typedef void(^JumperCallBack)(NSString*);

@interface JumperController : NSObject
+ (JumperController *) getInstance;

@property (nonatomic, readwrite, retain) id GViewController;
@property (nonatomic ,strong) JumperCallBack jumperCallBack;
@property (nonatomic ,strong) NSString *mAppData ;


- (void)check_OpenUrlData:(NSString*)urlString;
- (bool)jump2App:(NSString*)schme Data:(NSString*)data ;

- (void)doJumper_Callback_lua:(NSString*)app_data;
- (void)setJumperCallback:(void(^)(NSString*))callfunc;
@end

#endif /* JumperController_h */
