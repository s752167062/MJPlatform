//
//  WeChatSDKController.m
//  YYDemo
//
//  Created by SJ on 2017/4/25.
//  Copyright © 2017年 SJ. All rights reserved.
//
//      YvChatManage 实现SDK除语音留言以外所有功能
//      回调都是异步的，需要遵守YvAudioToolsDelegate、YvChatManageDelegate协议接收其回调信息

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WeChatSDKController.h"
#import "WXApiManager.h"

//#define YY_APPID    @"100041"
//#define IS_TEST     false       //true:访问测试环境； false:访问正式环境；
//#define kResultSuccess  (0)     //成功为0

typedef void(^LoginCallBack)(NSString*);
typedef void(^UrlShareCallBack)(NSString*);
typedef void(^ImageShareCallBack)(NSString*);
typedef void(^MiniProjectShareCallBack)(NSString*);
typedef void(^onMiniProjectLaunchCallBack)(NSString*);


@interface WeChatSDKController ()<WXApiManagerDelegate>{
    BOOL islogin ;
}

@property (nonatomic ,strong) LoginCallBack loginCallback;
@property (nonatomic ,strong) UrlShareCallBack urlShareCallback;
@property (nonatomic ,strong) ImageShareCallBack imageShareCallback;
@property (nonatomic ,strong) MiniProjectShareCallBack miniProjectShareCallback;
@property (nonatomic ,strong) onMiniProjectLaunchCallBack miniProjectLaunchCallback;

@property (nonatomic ,strong) NSString* APPID ;
@property (nonatomic ,strong) NSString* SERCERT ;
@property (nonatomic ,strong) NSString* launchData ;

@end

@implementation WeChatSDKController

static WeChatSDKController* instance = NULL;

+(WeChatSDKController*) getInstance{
    if (instance == NULL) {
        instance = [[WeChatSDKController alloc] init];
    }
    return instance;
}

-(id)init{
    if (self = [super init]) {
        NSLog(@" WeChatSDKController 初始化");
        [self initAPPID_SERCRET];
        
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}


/*在lua中提取微信的 APPID 和 SERCRET*/
- (void) initAPPID_SERCRET{
    //查找 WeChatSDK.lua文件
    NSFileManager * fm = [NSFileManager defaultManager];
    NSString * url = [[NSBundle mainBundle] pathForResource:@"src/cocos/properties" ofType:@"txt"];
    NSLog(@" properties.txt path : %@" , url);
    if([fm fileExistsAtPath:url]){
        NSData* data = [fm contentsAtPath:url];
        NSString * content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        
#ifdef IPHONE_INHOUS
        //企业包的
        NSRange app_range_start = [content rangeOfString:@"#START_WXAPPID_INHOUS:"];
        NSString* app_id_data = [content substringFromIndex:app_range_start.location + app_range_start.length];
        
        NSRange app_range_end   = [app_id_data rangeOfString:@":END_WXAPPID_INHOUS#"];
        self.APPID = [app_id_data substringToIndex:app_range_end.location];
        NSLog(@" >>>> appID %@" ,self.APPID);
        
        
        NSRange sercret_range_start = [content rangeOfString:@"#START_WXSECRET_INHOUS:"];
        NSString* app_sercret_data = [content substringFromIndex:sercret_range_start.location + sercret_range_start.length];
        
        NSRange sercret_range_end   = [app_sercret_data rangeOfString:@":END_WXSECRET_INHOUS#"];
        self.SERCERT = [app_sercret_data substringToIndex:sercret_range_end.location];
        NSLog(@" >>>> SERCERT %@" ,self.SERCERT);

#else
        //App Store包
        NSRange app_range_start = [content rangeOfString:@"#START_WXAPPID:"];
        NSString* app_id_data = [content substringFromIndex:app_range_start.location + app_range_start.length];
        
        NSRange app_range_end   = [app_id_data rangeOfString:@":END_WXAPPID#"];
        self.APPID = [app_id_data substringToIndex:app_range_end.location];
        NSLog(@" >>>> appID %@" ,self.APPID);
        
        
        NSRange sercret_range_start = [content rangeOfString:@"#START_WXSECRET:"];
        NSString* app_sercret_data = [content substringFromIndex:sercret_range_start.location + sercret_range_start.length];
        
        NSRange sercret_range_end   = [app_sercret_data rangeOfString:@":END_WXSECRET#"];
        self.SERCERT = [app_sercret_data substringToIndex:sercret_range_end.location];
        NSLog(@" >>>> SERCERT %@" ,self.SERCERT);
  
#endif
        return ;
    }
    NSLog(@" No File : properties ");
    [self showAlertMessage:@" UR : WeChat 文件不存在 ！！"];
}


#pragma mark 微信登录回调 0,msg or 1,token
- (void) mWeChatLogin:(void(^)(NSString*))callfunc{
    self.loginCallback = callfunc ;
    //第三方向微信终端发送一个SendAuthReq消息结构
    
    SendAuthReq* req =[[SendAuthReq alloc ] init ];
    req.scope = @"snsapi_userinfo" ;
    req.state = @"login" ;
    BOOL result = [WXApi sendReq:req];
    if (!result) {
        NSLog(@"吊起微信失败");
        [self onLoginCallBack:@"0,Send_AuthReq_ERR"];
    }
}

#pragma mark 微信文本 分享 分享类型 1 盆友圈  , 0 好友
- (bool) mWeChatTxtShare:(NSString *)msg Share_Type:(int)type{
    if (msg == nil || msg.length ==0) {
        return false;
    }
    //
    SendMessageToWXReq * req = [[SendMessageToWXReq alloc] init];
    req.text = msg;
    req.bText = YES;
    if (type == 1) {//盆友圈
        req.scene = WXSceneTimeline;
    }else{
        req.scene = WXSceneSession;
    }
    
    BOOL result = [WXApi sendReq:req];
    if (!result) {
        NSLog(@"吊起微信分享失败");
        BOOL istry   = false;
        int trytimes = 0;
        while(!istry && trytimes <10){
            istry = [WXApi sendReq:req];
        }
        return istry;
        // return false;
    }
    return true;
}

#pragma mark 微信URL 分享 分享类型 1 盆友圈  , 0 好友
- (void) mWeChatUrlShare:(NSString *)title Desc:(NSString *)desc Url:(NSString *)url Share_Type:(int)type CallFunc:(void(^)(NSString*))callfunc{
    self.urlShareCallback = callfunc;
    self.imageShareCallback = nil;
    
    //分享
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = desc;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"AppIcon60x60@2x" ofType:@"png"];
    
    [message setThumbImage:[UIImage imageWithContentsOfFile:path]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = url ;
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    
    if (type == 1) {//盆友圈
        req.scene = WXSceneTimeline;
    }else{
        req.scene = WXSceneSession;
    }

    BOOL result = [WXApi sendReq:req];
    if (!result) {
        NSLog(@"吊起微信分享失败");
        BOOL istry   = false;
        int trytimes = 0;
        while(!istry && trytimes <10){
            istry = [WXApi sendReq:req];
        }
        if(!istry){
            [self onUrlShareCallBack:@"0,WeChat_Url_Share_Failed"];
        }
    }
}


#pragma mark 图片分享 分享类型 1 盆友圈  , 0 好友
- (void) mWeChatImageShare:(NSString *)imagePath Share_Type:(int)type CallFunc:(void(^)(NSString*))callfunc{
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
    
    
    WXImageObject *ext = [WXImageObject object];
    ext.imageData = imageData;
    
    WXMediaMessage *message = [[WXMediaMessage alloc] init];
    [message setThumbImage:thumbImage];
    message.mediaObject=ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    
    if (type == 1) {//盆友圈
        req.scene = WXSceneTimeline;
    }else{
        req.scene = WXSceneSession;
    }
    
    BOOL result = [WXApi sendReq:req];
    if (!result) {
        NSLog(@"吊起微信图片分享失败");
        BOOL istry   = false;
        int trytimes = 0;
        while(!istry && trytimes <10){
            istry = [WXApi sendReq:req];
        }
        if(!istry){
            [self onImageShareCallBack:@"0,WeChat_Image_Share_Failed"];
        }
    }

}

#pragma mark 合图分享
- (void) mWeChatImageMergeShare:(NSString *)image1Path Image2Path:(NSString *)image2Path PositionX:(int)px PositionY:(int)py ImageWidth:(int)imagewidth ImageHeight:(int)imageheight Share_Type:(int)type CallFunc:(void(^)(NSString*))callfunc{
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
    CGSize tisize = togetherImage.size;
    CGSize thumb_size = {160,240};
    if(tisize.width > tisize.height){
        thumb_size = {240,160};
    }
    UIGraphicsBeginImageContext(thumb_size);
    [togetherImage drawInRect:CGRectMake(0, 0, thumb_size.width, thumb_size.height)];
    UIImage* thumbimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //
    NSData *imageData = UIImagePNGRepresentation(togetherImage);
    WXImageObject *ext = [WXImageObject object];
    ext.imageData = imageData;
    
    WXMediaMessage *message = [[WXMediaMessage alloc] init];
    [message setThumbImage:thumbimage];
    message.mediaObject=ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    
    if (type == 1) {//盆友圈
        req.scene = WXSceneTimeline;
    }else{
        req.scene = WXSceneSession;
    }
    
    BOOL result = [WXApi sendReq:req];
    if (!result) {
        NSLog(@"吊起微信图片分享失败");
        BOOL istry   = false;
        int trytimes = 0;
        while(!istry && trytimes <10){
            istry = [WXApi sendReq:req];
        }
        if(!istry){
            [self onImageShareCallBack:@"0,WeChat_Image_Share_Failed"];
        }
    }

}

#pragma mark
- (void) mWeChatImageMergeShareByJSON:(NSString *)json_str Share_Type:(int)share_type CallFunc:(void(^)(NSString*))callfunc{
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
            CGSize tisize = togetherImage.size;
            CGSize thumb_size = {160,240};
            if(tisize.width > tisize.height){
                thumb_size = {240,160};
            }
            UIGraphicsBeginImageContext(thumb_size);
            [togetherImage drawInRect:CGRectMake(0, 0, thumb_size.width, thumb_size.height)];
            UIImage* thumbimage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            //
            NSData *imageData = UIImagePNGRepresentation(togetherImage);
            WXImageObject *ext = [WXImageObject object];
            ext.imageData = imageData;
            
            WXMediaMessage *message = [[WXMediaMessage alloc] init];
            [message setThumbImage:thumbimage];
            message.mediaObject=ext;
            
            
            SendMessageToWXReq* resp = [[SendMessageToWXReq alloc] init];
            resp.bText=NO;
            resp.message=message;
            if( share_type == 1){
                resp.scene = WXSceneTimeline; //盆友圈
            }else{
                resp.scene = WXSceneSession;  //好友
            }
            
            Boolean result = [WXApi sendReq:resp];
            if (!result) {
                NSLog(@"吊起微信图片分享失败");
                [self onImageShareCallBack:@"0,WeChat_Image_Share_Failed"];
            }
            
            
        }else{
            NSLog(@"无合图相关数据");
            [self onImageShareCallBack:@"-1,WeChat_merge data <= 1"];
        }
    }else{
        NSLog(@"解析合图的JSON数据失败");
        [self onImageShareCallBack:@"-1,WeChat_share serializa json data_Failed"];

    }
    
}

- (void) mWeChatMiniProjectShareByJSON:(NSString *)json_str CallFunc:(void(^)(NSString*))callfunc{
    NSLog(@"分享小程序");
    self.miniProjectShareCallback = callfunc;
    //数据合集
    NSMutableDictionary* dir = [[NSMutableDictionary alloc] init];
    
    //解析JSON
    NSError *error = nil;
    NSDictionary* jsonObj = [NSJSONSerialization JSONObjectWithData:[json_str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if (jsonObj !=nil && error == nil){
        //处理合图
        if(jsonObj.count > 1 ){
            //数据
            NSString * wx_miniBase      = [jsonObj objectForKey:@"wx_miniBase"];    //小程序原始ID 和账号有关系..
            NSString * webUrl           = [jsonObj objectForKey:@"webUrl"];         //低版本不支持小程序的微信客户端用
            NSString * path             = [jsonObj objectForKey:@"path"];           //小程序页面
            NSString * parament         = [jsonObj objectForKey:@"parament"];       //小程序页面的参数
            NSString * title            = [jsonObj objectForKey:@"title"];          //分享小卡片的标题
            NSString * desc             = [jsonObj objectForKey:@"desc"];           //分享小卡片的描述信息
            NSString * imagepath        = [jsonObj objectForKey:@"image"];          //分享小卡片的显示图片的本地地址
            
            NSDictionary * mergeData =[jsonObj objectForKey:@"mergeData"]; //合并的数据
            
            NSLog(@" ITEN DATA : %@ \n%@ \n%@ \n%@ \n%@ \n%@ \n%@" ,wx_miniBase , webUrl ,path ,parament ,title ,desc , imagepath);
            
            //图片数据地址
            if(imagepath == nil || imagepath.length == 0){
                imagepath = [[NSBundle mainBundle] pathForResource:@"AppIcon60x60@2x" ofType:@"png"];
            }
            UIImage *image_merge = [UIImage imageWithContentsOfFile:imagepath];
            
            //检查合并图
            if(mergeData !=nil && mergeData.count >1){
                CGSize size = image_merge.size;
                UIGraphicsBeginImageContext(size);
                [image_merge drawInRect:CGRectMake(0, 0, size.width, size.height)]; //绘制底图
                
                for (int i = 0; i < mergeData.count; i++) {
                    //数据
                    NSDictionary * item =  [mergeData objectAtIndex:i];
                    NSString * data      = [item objectForKey:@"data"];
                    NSString * colorCode = [item objectForKey:@"color_code"];
                    int type   = [[NSString stringWithFormat:@"%@", [item objectForKey:@"type"]] intValue];
                    int p_x    = [[NSString stringWithFormat:@"%@", [item objectForKey:@"p_x"]] intValue];
                    int p_y    = [[NSString stringWithFormat:@"%@", [item objectForKey:@"p_y"]] intValue];
                    int size_w = [[NSString stringWithFormat:@"%@", [item objectForKey:@"size_w"]] intValue];
                    int size_y = [[NSString stringWithFormat:@"%@", [item objectForKey:@"size_h"]] intValue];
                    int font_size  = [[NSString stringWithFormat:@"%@", [item objectForKey:@"font_size"]] intValue];
                    
                    NSLog(@" mergeData ITEN DATA : %@ %d %d %d %d %d %d %@" ,data,type,p_x,p_y,size_w,size_y, font_size ,colorCode);
                    
                    //
                    if(type == 0){
                        UIImage *image_draw = [UIImage imageWithContentsOfFile:data];
                        [image_draw  drawInRect:CGRectMake(p_x , p_y  , size_w  , size_y)];
                    }else{
                        [data drawAtPoint:CGPointMake ( p_x  , p_y - font_size) //android 是从文本的左下角开始绘制 , ios 是从左上角开始 ，在此做兼容
                            withAttributes:@{ NSFontAttributeName :[ UIFont fontWithName : @"Arial-BoldMT" size : font_size ], NSForegroundColorAttributeName :[self getColorByCode:colorCode] } ];
                    }
                }
                
                //结束
                image_merge = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            NSData *imageData = UIImagePNGRepresentation(image_merge);
            
            //share
            WXMiniProgramObject *wxminiobj = [WXMiniProgramObject object];
            wxminiobj.webpageUrl = webUrl;
            wxminiobj.userName = wx_miniBase;
            wxminiobj.path = [NSString stringWithFormat:@"%@%@" , path, parament];
            wxminiobj.hdImageData = imageData; //小程序高清大图，小于128k
            wxminiobj.withShareTicket = YES;
            wxminiobj.miniProgramType = WXMiniProgramTypeRelease;//WXMiniProgramTypeTest ;//开发测试模式
            
            WXMediaMessage *message = [WXMediaMessage message];
            message.title = title;
            message.description = desc;
//            message.thumbData = imageData;//兼容就版本的图片 小于32k 优先使用WXMiniProgramObject 的 hdImageData属性
            message.mediaObject = wxminiobj;
            message.messageExt= @"";//不需要用到
            
            SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
            req.message = message;
            req.scene = WXSceneSession; //目前只支持聊天
            
            Boolean result = [WXApi sendReq:req];
            if (!result) {
                NSLog(@"吊起微信小程序分享失败");
                [self onMiniProjectShareCallBack:@"0,WeChat_mini_Share_Failed"];
            }
            
            
        }else{
            NSLog(@"无小程序分享相关数据");
            [self onMiniProjectShareCallBack:@"-1,WeChat_minishare data <= 1"];
        }
    }else{
        NSLog(@"解析小程序分享的JSON数据失败");
        [self onMiniProjectShareCallBack:@"-1,WeChat_minishare serializa json data_Failed"];
        
    }
    
}

- (void) mWeChatSetLaunchCallback:(void(^)(NSString*))callfunc{
    self.miniProjectLaunchCallback = callfunc;
    if([self.launchData isKindOfClass:[NSString class]] && self.launchData.length > 0 ){
        self.miniProjectLaunchCallback([self.launchData copy]);
        self.launchData = nil;
    }
}


-(NSString*) getWXLaunchData{
    if (self.launchData == nil) {
        return nil;
    }
    NSString *launchDataCopy = [self.launchData copy];
    return launchDataCopy;
}
- (void) setWXLaunchData:(NSString*)data{
    self.launchData = data;
    if(self.miniProjectLaunchCallback != 0 && [self.launchData isKindOfClass:[NSString class]] && self.launchData.length > 0 ){
        self.miniProjectLaunchCallback([self.launchData copy]);
        self.launchData = nil;
    }
}

-(void) cleanLaunchData{
    self.launchData = nil;
}

- (bool) isWXClientExit{
    NSLog(@"检查微信客户端");
    bool isexit = [WXApi isWXAppInstalled];
    return isexit;
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
- (void) onMiniProjectShareCallBack:(NSString *)msg{
    NSLog(@" >> onMiniProjectShareCallBack %@",msg);
    if (msg && self.miniProjectShareCallback) {
        self.miniProjectShareCallback(msg);
        self.miniProjectShareCallback = NULL;
    }
}



//////////////////
/*ViewControl 下的初始化*/
- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
//    return [WXApi registerApp:self.APPID ];
    [WXApi startLogByLevel:WXLogLevelNormal logBlock:^(NSString *log) {
        NSLog(@">>> wxlog : %@", log);
    }];
    
    //向微信注册
    [WXApi registerApp:self.APPID enableMTA:YES];
    
    //向微信注册支持的文件类型
    UInt64 typeFlag = MMAPP_SUPPORT_TEXT | MMAPP_SUPPORT_PICTURE | MMAPP_SUPPORT_LOCATION | MMAPP_SUPPORT_VIDEO |MMAPP_SUPPORT_AUDIO | MMAPP_SUPPORT_WEBPAGE | MMAPP_SUPPORT_DOC | MMAPP_SUPPORT_DOCX | MMAPP_SUPPORT_PPT | MMAPP_SUPPORT_PPTX | MMAPP_SUPPORT_XLS | MMAPP_SUPPORT_XLSX | MMAPP_SUPPORT_PDF;
    
    [WXApi registerAppSupportContentFlag:typeFlag];
    return TRUE;
}

- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url{
     return [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
}

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
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
