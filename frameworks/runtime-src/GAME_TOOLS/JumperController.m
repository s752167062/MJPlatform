//
//  JumperController.m
//  HongZhong_mz
//
//  Created by SJ on 16/9/19.
//
//

#import <Foundation/Foundation.h>
#import "JumperController.h"

@interface JumperController()

@end

static JumperController* instance = nil;
@implementation JumperController


+ (JumperController *) getInstance{
    if(instance == nil){
        instance = [[JumperController alloc] init];
        [instance retain];
    }
    
    return instance;
}

-(id)init{
    if(self=[super init]){
       self.jumperCallBack = nil ;
        NSLog(@"Add监听 ");
    }
    return self;
}

//回调
- (void)doJumper_Callback_lua:(NSString*)app_data{
    if (self.jumperCallBack != nil) {
        self.jumperCallBack(app_data);
        self.mAppData = nil;
    }else{
         self.mAppData = app_data;
    }
}

- (void)check_OpenUrlData:(NSString*)urlString{
    NSLog(@" --- scheme check_OpenUrlData %@" , urlString);
    if ([urlString containsString:@"ur_param:"]) {
        
        NSRange app_range_start = [urlString rangeOfString:@"ur_param:"];
        NSString* parme_data = [urlString substringFromIndex:app_range_start.location + app_range_start.length];
        NSLog(@" --- app 发来的消息 %@" , parme_data);
        if(parme_data != nil && parme_data.length > 0 ){
            [self doJumper_Callback_lua:parme_data];
        }
        
    } else {
        NSLog(@"string 不存在 ur_param");
    }

}

- (bool)jump2App:(NSString*)schme Data:(NSString*)data {
    if(schme == nil || schme.length == 0){
        NSLog(@" --- scheme %@",schme);
        return false;
    }
    BOOL result = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://" , schme ]]];
    if(result == false){
        NSLog(@" --- scheme canOpenURL %d",result);
        return false;
    }

    NSString *url = [NSString stringWithFormat:@"%@://ur_param:%@" , schme , data ];
    NSLog(@" --- scheme url  %@",url);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];

    return true;
}

- (void)setJumperCallback:(void(^)(NSString*))callfunc{
    self.jumperCallBack = callfunc;
    
    //初始化回调前有数据
    if(self.mAppData != nil && self.mAppData.length > 0 ){
        [self doJumper_Callback_lua:self.mAppData];
    }
}


- (void)dealloc{
    [super dealloc];
}



///////////////////////////////////////////////////////////////////////////////////////////////
- (void)showAlertMessage:(NSString*)msg{
    UIAlertView * mAlert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                      message:msg
                                                     delegate:nil
                                            cancelButtonTitle:@"确定"
                                            otherButtonTitles:nil, nil];
    [mAlert show];
}


@end
