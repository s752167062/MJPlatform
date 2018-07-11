//
//  WXApiManager.m
//  SDKSample
//
//  Created by Jeason on 16/07/2015.
//
//

#import "WXApiManager.h"
#import "WeChatSDKController.h"

@implementation WXApiManager

#pragma mark - LifeCycle
+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static WXApiManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WXApiManager alloc] init];
    });
    return instance;
}

//- (void)dealloc {
//    self.delegate = nil;
//    [super dealloc];
//}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendMessageToWXResp class]])
    {//分享的回调
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvMessageResponse:)]) {
            SendMessageToWXResp *messageResp = (SendMessageToWXResp *)resp;
            [_delegate managerDidRecvMessageResponse:messageResp];
        }
        
        if(resp == NULL){
            [[WeChatSDKController getInstance] onUrlShareCallBack:@"-1,SHARE_RESP_NULL"];
            [[WeChatSDKController getInstance] onImageShareCallBack:@"-1,SHARE_RESP_NULL"];
            return ;
        }
        
        if(resp.errCode == WXSuccess)
        {
            NSLog(@" >> 发送成功");
            [[WeChatSDKController getInstance] onUrlShareCallBack:@"1,SUCCESS"];
            [[WeChatSDKController getInstance] onImageShareCallBack:@"1,SUCCESS"];
            [[WeChatSDKController getInstance] onMiniProjectShareCallBack:@"1,SUCCESS"];
        }else if(resp.errCode == -2 || resp.errCode == -4 ) {
            NSLog(@" >> 用户拒绝 或 取消");
            [[WeChatSDKController getInstance] onUrlShareCallBack:[NSString stringWithFormat:@"2,USER_CALCEL %d" , resp.errCode]];
            [[WeChatSDKController getInstance] onImageShareCallBack:[NSString stringWithFormat:@"2,USER_CALCEL %d" , resp.errCode]];
            [[WeChatSDKController getInstance] onMiniProjectShareCallBack:[NSString stringWithFormat:@"2,USER_CALCEL %d" , resp.errCode]];
        }else{
            [[WeChatSDKController getInstance] onUrlShareCallBack:[NSString stringWithFormat:@"0,SHARE_DEFAULT_ERR %d" , resp.errCode]];
            [[WeChatSDKController getInstance] onImageShareCallBack:[NSString stringWithFormat:@"0,SHARE_DEFAULT_ERR %d" , resp.errCode]];
            [[WeChatSDKController getInstance] onMiniProjectShareCallBack:[NSString stringWithFormat:@"0,SHARE_DEFAULT_ERR %d" , resp.errCode]];
        }
 
    }
    else if ([resp isKindOfClass:[SendAuthResp class]])
    {//登录的回调
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvAuthResponse:)]) {
            SendAuthResp *authResp = (SendAuthResp *)resp;
            [_delegate managerDidRecvAuthResponse:authResp];
        }
        
        if (resp == NULL) {
            [[WeChatSDKController getInstance] onLoginCallBack:@"-1,AUTO_RESP_NULL"];
            return ;
        }
        
        if (resp.errCode == WXSuccess)//0
        {
            NSLog(@" >> 授权成功");
            SendAuthResp *aresp = (SendAuthResp *)resp; //aresp.code
            [[WeChatSDKController getInstance] onLoginCallBack:[NSString stringWithFormat:@"1,%@" , aresp.code]];
        }else if (resp.errCode == -4 || resp.errCode == -2 ){
            NSLog(@" >> 用户拒绝 or 取消");
            [[WeChatSDKController getInstance] onLoginCallBack:[NSString stringWithFormat:@"2,USER_CALCEL %d" , resp.errCode]];
        }else{
            [[WeChatSDKController getInstance] onLoginCallBack:[NSString stringWithFormat:@"0,AUTO_DEFAULT_ERR %d" , resp.errCode]];
        }
        
    }else if([resp isKindOfClass:[WXLaunchMiniProgramResp class]]){
         WXLaunchMiniProgramResp *launchresp = (WXLaunchMiniProgramResp *)resp;
         NSLog(@"launchresp.extMsg  %@", launchresp.extMsg);
    }
    

}

- (void)onReq:(BaseReq *)req {
    NSLog(@"====  req ");
    if ([req isKindOfClass:[GetMessageFromWXReq class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvGetMessageReq:)]) {
            GetMessageFromWXReq *getMessageReq = (GetMessageFromWXReq *)req;
            [_delegate managerDidRecvGetMessageReq:getMessageReq];
        }
    } else if ([req isKindOfClass:[ShowMessageFromWXReq class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvShowMessageReq:)]) {
            ShowMessageFromWXReq *showMessageReq = (ShowMessageFromWXReq *)req;
            [_delegate managerDidRecvShowMessageReq:showMessageReq];
        }
    } else if ([req isKindOfClass:[LaunchFromWXReq class]]) {
        LaunchFromWXReq *launchReq = (LaunchFromWXReq *)req;
        NSString *parament = launchReq.message.messageExt;//小程序传递过来的参数
        NSLog(@"  小程序传递过来的参数 %@",parament);
        [[WeChatSDKController getInstance] setWXLaunchData:parament];
        
        if (_delegate&& [_delegate respondsToSelector:@selector(managerDidRecvLaunchFromWXReq:)]) {
            LaunchFromWXReq *launchReq = (LaunchFromWXReq *)req;
            [_delegate managerDidRecvLaunchFromWXReq:launchReq];
        }
    }
}

@end
