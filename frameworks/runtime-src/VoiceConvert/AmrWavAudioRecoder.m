//
//  AmrWavAudioRecoder.m
//  AmrWavAudioRecoder
//
//  Created by SJ on 2017/1/3.
//  Copyright © 2017年 SJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AmrWavAudioRecoder.h"
#import "VoiceConverter.h"


#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

typedef void(^PlayCallBack)(BOOL);

@interface AmrWavAudioRecoder()

@property (strong, nonatomic)   AVAudioRecorder  *recorder;
@property (strong, nonatomic)   AVAudioPlayer    *player;
@property (strong, nonatomic)   NSString         *recordFileName;
@property (strong, nonatomic)   NSString         *recordFilePath;

@property (strong, nonatomic)   NSString         *videoDisctory;
@property (nonatomic ,strong) PlayCallBack playCallBack;

@end

static AmrWavAudioRecoder * instance = nil;
@implementation AmrWavAudioRecoder


+ (AmrWavAudioRecoder *) getInstance{
     if (instance == nil) {
          instance = [[AmrWavAudioRecoder alloc] init];
     }
     
     return instance;
}


- (id)init{
     
     if (self= [super init]) {
          NSLog(@"AmrWavAudioRecoder 初始化");
          [self recorderinit];
     }
     return self;
}

//初始化
- (void)recorderinit{
    NSLog(@"录音的初始化");
    //
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

#pragma mark - 开始录制 .mar   ; filename 文件名  , directory 文件存放文件目录
- (void)StartRecoderAmr:(NSString *)filenamee Directory:(NSString *) directory CallBack:(void(^)(BOOL))callfunc{
    NSLog(@" 系统音量 ------------- %f" , [[AVAudioSession sharedInstance] outputVolume]);
     if (filenamee == nil ) {
          NSLog(@" 空的文件名 ");
          if (self.recorder.isRecording){
               [self.recorder stop];
          }
        
         [self alertMsg:@"录音空的文件名"];
         return ;
     }
    [FileHelper setBaseDirectory:directory];//设置默认的读取目录
    
     NSString * filename ;
     NSRange range = [filenamee rangeOfString:@"."];
     if (range.location > 0 ) {
          //amr 校验
          if(![filenamee hasSuffix:@".amr"]){
              [self alertMsg:@" 录制仅支持 .amr 文件的录制"];
              return ;
          }
          //修改
          filename = [filenamee substringToIndex:range.location];
          NSLog(@" 新的Filename %@" , filename);
     }
     
     if (self.recorder.isRecording){//录音中
          //停止录音
         [self EndRecoderAmr:nil];
         if (callfunc != nil) {
             callfunc(false);
         }
     }else{
          //录音
          //根据当前时间生成文件名
          self.recordFileName = filename ;
          //获取路径
          self.recordFilePath = [FileHelper GetPathByFileName:self.recordFileName ofType:@"wav"];
          //初始化录音
          self.recorder = [[AVAudioRecorder alloc]initWithURL:[NSURL fileURLWithPath:self.recordFilePath]
                                                     settings:[VoiceConverter GetAudioRecorderSettingDict]
                                                        error:nil];
          
          //准备录音
          if ([self.recorder prepareToRecord]){
               
               [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
//               [[AVAudioSession sharedInstance] setActive:YES error:nil]; -- 设置Active 会卡UI  (程序需要播放视频，视频播放时，需要暂停背景音乐，结束或划出可视区域暂停需要恢复背景音乐。setActive 可以控制，但会卡住 UI 一下)
              
               //开始录音
               if (![self.recorder record]){
                   if (callfunc != nil) {
                       callfunc(false);
                   }
                   [self alertMsg:@"启动录音失败"];
               }else{
                   if (callfunc != nil) {
                       callfunc(true);
                   }
               }
          }else{
              NSLog(@" 录音未准备好 ");
          }
     }


}

#pragma mark - 结束录制
- (void)EndRecoderAmr:(void(^)(BOOL))callfunc{
     if (self.recorder.isRecording){//录音中
          //停止录音
          [self.recorder stop];
          
          //开始转换格式
          NSString *amrPath = [FileHelper GetPathByFileName:self.recordFileName ofType:@"amr"];
          
          #warning wav转amr
          if ([VoiceConverter ConvertWavToAmr:self.recordFilePath amrSavePath:amrPath]){
               // amr 文件完成 ！！
              if (callfunc != nil) {
                  callfunc(true);
              }
              NSLog(@"录音文件完成");
               
          }else{
              NSLog(@" wav转amr失败 ----- 录音转码失败 -----");
              if (callfunc != nil) {
                  callfunc(false);
              }
//              [self alertMsg:@"录音转码失败"];
          }
     }
     
}

#pragma mark - amr转码播放 wav   ; filepath 文件路径  , directory 文件存放文件目录 . 转码后存放在 NSDocumentDirectory 目录下/ 平台在自己目录下
- (void)PlayAmr:(NSString *)filenamee Directory:(NSString *) directory CallBack:(void(^)(BOOL))callfunc{
     if(filenamee == nil || filenamee.length < 1 || directory == nil || directory.length < 1 ){
          NSLog(@"空的文件名 或 路径");
          return ;
     }
    
     NSString * filename ;
     NSRange range = [filenamee rangeOfString:@"."];
     if (range.location > 0 ) {
          //amr 校验
          if(![filenamee hasSuffix:@".amr"]){
               [self alertMsg:@" PlayAmr 仅支持 .amr 转 .wav 播放"];
               return ;
          }
          //修改
          filename = [filenamee substringToIndex:range.location];
          NSLog(@" Filename %@" , filename);
     }
     
     //amr 文件
     NSFileManager *fileManager = [NSFileManager defaultManager];
     NSString * amrPath = [directory stringByAppendingPathComponent:filenamee];
     NSLog(@"amr 文件位置 %@" , amrPath);
     if(![fileManager fileExistsAtPath:amrPath]){
          [self alertMsg:@"音频文件不存在"];
          return ;
     }
     
     //转 wav 后存放的位置
     NSString * convertedPath = [FileHelper GetPathByFileName:filename ofType:@"wav"];
     NSLog(@"转换的文件路径 wav  %@" ,convertedPath);
     
     //转码
     if ([VoiceConverter ConvertAmrToWav:amrPath wavSavePath:convertedPath]){
          NSLog(@"播放 amr 转 wav 后的文件 ");
//          [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
          [[AVAudioSession sharedInstance] setActive:YES error:nil];
         
         if(self.player ==nil){
             //初始化播放器
             self.player = [[AVAudioPlayer alloc]init];
         }
          self.player = [self.player initWithContentsOfURL:[NSURL URLWithString:convertedPath] error:nil];
          [self.player play];
          
     }else{
          NSLog(@"amr转wav失败");
          [self alertMsg:@"播放前转码失败"];
     }
}

-(void)PlayAmr:(NSString *)filepath CallBack:(void(^)(BOOL))callfunc{
     if (filepath == nil || filepath.length < 1) {
          NSLog(@"音频路径是空的");
          return ;
     }
    self.playCallBack = callfunc;
    
     NSRange rang = [filepath rangeOfString:@"/" options:NSBackwardsSearch]; // 反向查找
     NSString * directory = [filepath substringToIndex:rang.location ];
     NSString * filename  = [filepath substringFromIndex:rang.location];
     
     NSLog(@" 目录 %@" , directory);
     NSLog(@" 文件名 %@" , filename);
    [FileHelper setBaseDirectory:directory];//设置默认的读取目录
    [self PlayAmr:filename Directory:directory CallBack:callfunc];
}

#pragma mark - 正常播放文件   filepath 文件路径
- (void)PlayVideo:(NSString *) filepath CallBack:(void(^)(BOOL))callfunc{
     NSFileManager *fileManager = [NSFileManager defaultManager];
     if(![fileManager fileExistsAtPath:filepath]){
          NSLog(@"播放的文件不存在 ");
          [self alertMsg:@"通用音频文件不存在"];
          return ;
     }
     self.playCallBack = callfunc;
    
//     [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
     [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    if(self.player == nil){
        //初始化播放器
        self.player = [[AVAudioPlayer alloc]init];
    }
     self.player = [self.player initWithContentsOfURL:[NSURL URLWithString:filepath] error:nil];
     self.player.delegate = self;
     [self.player play];
     
}

#pragma mark - 停止播放
- (void)StopVideo{
    @try {
        if(self.player != nil && self.player.isPlaying){
            [self.player stop];
        }
    } @catch (NSException *exception) {
        NSLog(@" stop exception %@", exception.description);
    }
}

- (void)doPlayCallBack:(BOOL)flag{
    if (self.playCallBack != nil ) {
        self.playCallBack(flag);
        self.playCallBack = nil;
        return ;
    }
    NSLog(@" 回调 playCallback nil");
}

//播放完成时调用的方法  (代理里的方法),需要设置代理才可以调用
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"---播放结束");
    [self doPlayCallBack:true];
    
}

///解码出错后调用这个函数
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    NSLog(@"---解码出错");
    [self doPlayCallBack:false];
}

////产生中断后调用这个函数，通常暂停播放
//- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player{
//    [self.player pause];
//}
//
////恢复中断后调用这个函数，继续播放
//- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags{
//    [self.player play];
//}

- (void)setDirectory:(NSString *)directory{
    self.videoDisctory = directory;
}

- (NSString *)getDirectory{
    return self.videoDisctory;
}
/**/
- (void)alertMsg:(NSString *)msg
{
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                     message:msg
                                                    delegate:nil
                                           cancelButtonTitle:NSLocalizedString(@"sure", @"确定")
                                           otherButtonTitles:nil];
     [alert show];
}

@end
