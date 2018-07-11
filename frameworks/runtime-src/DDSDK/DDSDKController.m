//
//  DDSDKController.m
//  YYDemo
//
//  Created by SJ on 2017/4/25.
//  Copyright © 2017年 SJ. All rights reserved.
//
//      YvChatManage 实现SDK除语音留言以外所有功能
//      回调都是异步的，需要遵守YvAudioToolsDelegate、YvChatManageDelegate协议接收其回调信息

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DDSDKController.h"
#import <DTShareKit/DTOpenKit.h>

//#define YY_APPID    @"100041"
//#define IS_TEST     false       //true:访问测试环境； false:访问正式环境；
//#define kResultSuccess  (0)     //成功为0

typedef void(^LoginCallBack)(NSString*);
typedef void(^UrlShareCallBack)(NSString*);
typedef void(^ImageShareCallBack)(NSString*);


@interface DDSDKController ()  <DTOpenAPIDelegate> {

}

@property (nonatomic ,strong) LoginCallBack loginCallback;
@property (nonatomic ,strong) UrlShareCallBack urlShareCallback;
@property (nonatomic ,strong) ImageShareCallBack imageShareCallback;

@property (nonatomic ,strong) NSString* APPID ;
@property (nonatomic ,strong) NSString* SERCERT ;

@end

@implementation DDSDKController

static DDSDKController* instance = NULL;

+(DDSDKController*) getInstance{
    if (instance == NULL) {
        instance = [[DDSDKController alloc] init];
    }
    return instance;
}

-(id)init{
    if (self = [super init]) {
        NSLog(@" DDSDKController 初始化");
        [self initAPPID];
        
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}


/*在lua中提取微信的 APPID 和 SERCRET*/
- (void) initAPPID{
    //查找 ddSDK.lua文件
    NSFileManager * fm = [NSFileManager defaultManager];
    NSString * url = [[NSBundle mainBundle] pathForResource:@"src/cocos/properties" ofType:@"txt"];
    NSLog(@" properties.txt path : %@" , url);
    if([fm fileExistsAtPath:url]){
        NSData* data = [fm contentsAtPath:url];
        NSString * content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        
#ifdef IPHONE_INHOUS
        //企业包的
        NSRange app_range_start = [content rangeOfString:@"#START_DDAPPID_INHOUS:"];
        NSString* app_id_data = [content substringFromIndex:app_range_start.location + app_range_start.length];
        
        NSRange app_range_end   = [app_id_data rangeOfString:@":END_DDAPPID_INHOUS#"];
        self.APPID = [app_id_data substringToIndex:app_range_end.location];
        NSLog(@" >>>> appID %@" ,self.APPID);

#else
        //App Store包
        NSRange app_range_start = [content rangeOfString:@"#START_DDAPPID:"];
        NSString* app_id_data = [content substringFromIndex:app_range_start.location + app_range_start.length];
        
        NSRange app_range_end   = [app_id_data rangeOfString:@":END_DDAPPID#"];
        self.APPID = [app_id_data substringToIndex:app_range_end.location];
        NSLog(@" >>>> appID %@" ,self.APPID);
  
#endif
        return ;
    }
    NSLog(@" No File : properties ");
    [self showAlertMessage:@" UR : dd 文件不存在 ！！"];
}


#pragma mark DDD文本 分享 分享类型 1 盆友圈  , 0 好友
- (bool) mDDTxtShare:(NSString *)msg Share_Type:(int)type{
    if (msg == nil || msg.length ==0) {
        return false;
    }
    //
    DTSendMessageToDingTalkReq * req = [[DTSendMessageToDingTalkReq alloc] init];
    
    DTMediaMessage *mediaMessage = [[DTMediaMessage alloc] init];
    
    DTMediaTextObject *textObject = [[DTMediaTextObject alloc] init];
    textObject.text = msg;
    
    mediaMessage.mediaObject = textObject;
    req.message = mediaMessage;
    

    BOOL result = [DTOpenAPI sendReq:req];
    if (!result) {
        NSLog(@"吊起dd分享失败");
        BOOL istry   = false;
        int trytimes = 0;
        while(!istry && trytimes <10){
            istry = [DTOpenAPI sendReq:req];
        }
        return istry;
    }
    return true;
}

#pragma mark 微信URL 分享 分享类型 1 盆友圈  , 0 好友
- (void) mDDUrlShare:(NSString *)title Desc:(NSString *)desc Url:(NSString *)url Share_Type:(int)type CallFunc:(void(^)(NSString*))callfunc{
    self.urlShareCallback = callfunc;
    self.imageShareCallback = nil;
    
    //分享
    DTSendMessageToDingTalkReq *req = [[DTSendMessageToDingTalkReq alloc] init];
    
    DTMediaMessage *mediaMessage = [[DTMediaMessage alloc] init];
    DTMediaWebObject *webObject = [[DTMediaWebObject alloc] init];
    webObject.pageURL = url;
    
    mediaMessage.title = title;
    mediaMessage.messageDescription = desc;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"AppIcon60x60@2x" ofType:@"png"];
    mediaMessage.thumbData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:path]);
    
    mediaMessage.mediaObject = webObject;
    req.message = mediaMessage;
    
    BOOL result = [DTOpenAPI sendReq:req];
    if (!result) {
        NSLog(@"吊起dd分享失败");
        BOOL istry   = false;
        int trytimes = 0;
        while(!istry && trytimes <10){
            istry = [DTOpenAPI sendReq:req];
        }
        if(!istry){
            [self onUrlShareCallBack:@"0,dd_Url_Share_Failed"];
        }
    }
}


#pragma mark 图片分享 分享类型 1 盆友圈  , 0 好友
- (void) mDDImageShare:(NSString *)imagePath Share_Type:(int)type CallFunc:(void(^)(NSString*))callfunc{
    self.imageShareCallback = callfunc;
    self.urlShareCallback = NULL;
    
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    
    //生成一个新的小图 UIImage
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    CGSize size    = {240.0,160.0};
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* thumbImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    
    DTMediaImageObject *imageObject = [[DTMediaImageObject alloc] init];
    imageObject.imageData = imageData;
    
    DTMediaMessage *message = [[DTMediaMessage alloc] init];
    message.mediaObject = imageObject;
    
    DTSendMessageToDingTalkReq* req = [[DTSendMessageToDingTalkReq alloc] init];
    req.message = message;
    
    
    BOOL result = [DTOpenAPI sendReq:req];
    if (!result) {
        NSLog(@"吊起dd图片分享失败");
        BOOL istry   = false;
        int trytimes = 0;
        while(!istry && trytimes <10){
            istry = [DTOpenAPI sendReq:req];
        }
        if(!istry){
            [self onImageShareCallBack:@"0,dd_Image_Share_Failed"];
        }
    }

}

#pragma mark 合图分享
- (void) mDDImageMergeShare:(NSString *)image1Path Image2Path:(NSString *)image2Path PositionX:(int)px PositionY:(int)py ImageWidth:(int)imagewidth ImageHeight:(int)imageheight Share_Type:(int)type CallFunc:(void(^)(NSString*))callfunc{
    self.imageShareCallback = callfunc;
    self.urlShareCallback = NULL;
    
    /*图*/
    UIImage *uiimage1Path = [UIImage imageWithContentsOfFile:image1Path];
    UIImage *uiimage2Path = [UIImage imageWithContentsOfFile:image2Path];
    
    //合成
    CGSize size = uiimage1Path.size ;//CGSizeMake(uibg_image.size.width, uibg_image.size.height);
    UIGraphicsBeginImageContext(size);
    [uiimage1Path drawInRect:CGRectMake(0, 0, size.width, size.height)];
    [uiimage2Path  drawInRect:CGRectMake(px , py , imagewidth , imageheight)];
    UIImage *togetherImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //缩放
    CGSize thumb_size = {240,160};
    UIGraphicsBeginImageContext(thumb_size);
    [togetherImage drawInRect:CGRectMake(0, 0, thumb_size.width, thumb_size.height)];
    UIImage* thumbimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //
    NSData *imageData = UIImagePNGRepresentation(togetherImage);
    DTMediaImageObject *imageObject = [[DTMediaImageObject alloc] init];
    imageObject.imageData = imageData;
    
    DTMediaMessage *message = [[DTMediaMessage alloc] init];
    message.mediaObject = imageObject;
    
    DTSendMessageToDingTalkReq* req = [[DTSendMessageToDingTalkReq alloc] init];
    req.message = message;
    
    BOOL result = [DTOpenAPI sendReq:req];
    if (!result) {
        NSLog(@"吊起dd图片分享失败");
        BOOL istry   = false;
        int trytimes = 0;
        while(!istry && trytimes <10){
            istry = [DTOpenAPI sendReq:req];
        }
        if(!istry){
            [self onImageShareCallBack:@"0,dd_Image_Share_Failed"];
        }
    }

}

#pragma mark
- (void) mDDImageMergeShareByJSON:(NSString *)json_str Share_Type:(int)share_type CallFunc:(void(^)(NSString*))callfunc{
    self.imageShareCallback = callfunc;
    
    //数据合集
    NSMutableDictionary* dir = [[NSMutableDictionary alloc] init];
    
    //解析JSON
    NSError *error = nil;
    NSDictionary* jsonObj = [NSJSONSerialization JSONObjectWithData:[json_str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if (jsonObj !=nil && error == nil){
        //处理合图
        if(jsonObj.count > 1 ){
            
            UIImage *togetherImage = nil;

            for (int i = 0; i < jsonObj.count; i++) {
                //数据
                NSDictionary * item =  [jsonObj objectAtIndex:i];
                NSString * data      = [item objectForKey:@"data"];
                NSString * colorCode = [item objectForKey:@"color_code"];
                int type   = [[NSString stringWithFormat:@"%@", [item objectForKey:@"type"]] intValue];
                int p_x    = [[NSString stringWithFormat:@"%@", [item objectForKey:@"p_x"]] intValue];
                int p_y    = [[NSString stringWithFormat:@"%@", [item objectForKey:@"p_y"]] intValue];
                int size_w = [[NSString stringWithFormat:@"%@", [item objectForKey:@"size_w"]] intValue];
                int size_y = [[NSString stringWithFormat:@"%@", [item objectForKey:@"size_h"]] intValue];
                int font_size  = [[NSString stringWithFormat:@"%@", [item objectForKey:@"font_size"]] intValue];
                
                NSLog(@" ITEN DATA : %@ %d %d %d %d %d %d %@" ,data,type,p_x,p_y,size_w,size_y, font_size ,colorCode);
                
                //
                if(i == 0){
                    if(type == 1 || data.length == 0){//必须是图 0  , 1 文本
                        [self showAlertMessage:@"JSON 首个合图数据必须是图片"];
                        return;
                    }
                    UIImage *image_1_bg = [UIImage imageWithContentsOfFile:data];
                    CGSize size = image_1_bg.size;
                    UIGraphicsBeginImageContext(size);
                    [image_1_bg drawInRect:CGRectMake(0, 0, size.width, size.height)]; //绘制底图
                
                }else{
                    if(type == 0){
                        UIImage *image_merge = [UIImage imageWithContentsOfFile:data];
                        [image_merge  drawInRect:CGRectMake(p_x , p_y  , size_w  , size_y)];
                    }else{
                        [data drawAtPoint:CGPointMake ( p_x  , p_y - font_size) //android 是从文本的左下角开始绘制 , ios 是从左上角开始 ，在此做兼容
                           withAttributes:@{ NSFontAttributeName :[ UIFont fontWithName : @"Arial-BoldMT" size : font_size ], NSForegroundColorAttributeName :[self getColorByCode:colorCode] } ];
                    }
                }
            }
            
            //结束
            togetherImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            //缩放
            CGSize thumb_size = {160,240};
            UIGraphicsBeginImageContext(thumb_size);
            [togetherImage drawInRect:CGRectMake(0, 0, thumb_size.width, thumb_size.height)];
            UIImage* thumbimage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            //
            NSData *imageData = UIImagePNGRepresentation(togetherImage);
            DTMediaImageObject *imageObject = [[DTMediaImageObject alloc] init];
            imageObject.imageData = imageData;
            
            DTMediaMessage *message = [[DTMediaMessage alloc] init];
            message.mediaObject = imageObject;
            
            DTSendMessageToDingTalkReq* req = [[DTSendMessageToDingTalkReq alloc] init];
            req.message = message;
            
            Boolean result = [DTOpenAPI sendReq:req];
            if (!result) {
                NSLog(@"吊起dd图片分享失败");
                [self onImageShareCallBack:@"0,dd_Image_Share_Failed"];
            }
            
            
        }else{
            NSLog(@"无合图相关数据");
            [self onImageShareCallBack:@"-1,dd_merge data <= 1"];
        }
    }else{
        NSLog(@"解析合图的JSON数据失败");
        [self onImageShareCallBack:@"-1,dd_share serializa json data_Failed"];

    }
    
}

- (bool) isDDClientExit{
    NSLog(@"检查dd客户端");
    return [DTOpenAPI isDingTalkInstalled];
}


- (bool) isDDSupport{
    NSLog(@"检查dd支持");
    return [DTOpenAPI isDingTalkSupportOpenAPI];
}


- (void) onLoginCallBack:(NSString *)msg{
    NSLog(@" >> onLoginCallBack %@",msg);
    if (msg && self.loginCallback) {
        self.loginCallback(msg);
        self.loginCallback = NULL;
    }
}

- (void) onUrlShareCallBack:(NSString *)msg{
    NSLog(@" >> onUrlShareCallBack %@",msg);
    if (msg && self.urlShareCallback) {
        self.urlShareCallback(msg);
        self.urlShareCallback = NULL;
    }
}

- (void) onImageShareCallBack:(NSString *)msg{
    NSLog(@" >> onImageShareCallBack %@",msg);
    if (msg && self.imageShareCallback) {
        self.imageShareCallback(msg);
        self.imageShareCallback = NULL;
    }
}



//////////////////
/*ViewControl 下的初始化*/
- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    return [DTOpenAPI registerApp:self.APPID ];
}

- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url{
     return [DTOpenAPI handleOpenURL:url delegate:self];
}

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [DTOpenAPI handleOpenURL:url delegate:self];
}

//DTOpenAPIDelegate
- (void)onReq:(DTBaseReq *)req
{
    
}
//DTOpenAPIDelegate
- (void)onResp:(DTBaseResp *)resp
{
    if(resp.errorCode == 0){
        NSLog(@"成功");
        [self onUrlShareCallBack:[NSString stringWithFormat:@"1,SUCCESS"]];
        [self onImageShareCallBack:[NSString stringWithFormat:@"1,SUCCESS"]];
        
    }else if(resp.errorCode == -2){
        NSLog(@"用户取消");
        
        [self onUrlShareCallBack:[NSString stringWithFormat:@"2,USER_CANCEL "]];
        [self onImageShareCallBack:[NSString stringWithFormat:@"2,USER_CANCEL "]];
    }else{
        NSLog(@"错误：%@" , resp.errorMessage);
        
        [self onUrlShareCallBack:[NSString stringWithFormat:@"-1,DDERR %L %@"   , resp.errorCode , resp.errorMessage]];
        [self onImageShareCallBack:[NSString stringWithFormat:@"-1,DDERR %L %@" , resp.errorCode , resp.errorMessage]];
        [self showAlertMessage:[NSString stringWithFormat:@"错误 : %@" , resp.errorMessage]];
    }
}


/////////////////

- (void)showAlertMessage:(NSString*)msg{
    UIAlertView * mAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [mAlert show];
}

- (UIColor*)getColorByCode:(NSString*)code{
    // 十六进制数字字符串转十进制数字
    NSString *s1 = [code substringWithRange:NSMakeRange(1, 2)];
    unsigned long c1 = strtoul([s1 UTF8String], 0, 16);
    
    NSString *s2 = [code substringWithRange:NSMakeRange(3, 2)];
    unsigned long c2 = strtoul([s2 UTF8String], 0, 16);
    
    NSString *s3 = [code substringWithRange:NSMakeRange(5, 2)];
    unsigned long c3 = strtoul([s3 UTF8String], 0, 16);
    
    // Red，green，blue 值的范围是 0 ～ 1，alpha：透明度，1 不透明
    return [UIColor colorWithRed:c1/255.0 green:c2/255.0 blue:c3/255.0 alpha:1];
}


@end
