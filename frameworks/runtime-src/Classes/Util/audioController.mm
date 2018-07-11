/*
@IOS语音
@author sunfan
@date	2017/05/04
*/

#include <stdio.h>
#import <Foundation/Foundation.h>
#import "audioController.h"
#include "cocos2d.h"
#include "CCLuaEngine.h"
#include <iostream>
#include "lame.h"

@implementation audioController
extern BOOL isRecording;
extern char* filename;
//
-(void)playAudio
{
//    CCLOG("开始录音播放");
//    
//    std::string strName = "/";
//    strName.append(filename);
//    
//    NSString *name = [[NSString alloc] initWithCString:(const char*) strName.c_str()
//                                              encoding:NSUTF8StringEncoding];
//    
//    NSString   *DocmentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES) objectAtIndex:0];
//    NSURL *url = [NSURL URLWithString:[DocmentPath stringByAppendingString: name ]];
//    
//    //把音频文件转换成url格式
//    //        NSURL *url = [NSURL fileURLWithPath:string];
//    //初始化音频类 并且添加播放文件
////    avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
////    //设置代理
////    avAudioPlayer.delegate = self;
////    //设置初始音量大小
////    avAudioPlayer.volume = 7  ;
////    //设置音乐播放次数  -1为一直循环
////    avAudioPlayer.numberOfLoops = 1;
////    
////    [avAudioPlayer prepareToPlay];
////    [avAudioPlayer play];
//    
//    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
//    if (player == nil)
//    {
//        CCLOG("创建player: 失败! ");//[[playerError description] cStringUsingEncoding:NSASCIIStringEncoding]
//        lua_State* L = cocos2d::LuaEngine::getInstance()->getLuaStack()->getLuaState();
//        lua_getglobal(L, "createAudioFail");
//        lua_call(L, 0, 0);
//    }
//    player.delegate = self;
//    [player play];
}


//
-(void)AudioRecording
{
//    /***
//     在应用程序中录制音频需要指定用于存储录音的文件(NSURL)，配置要创建的声音文件参数(NSDictionary)，再使用上述文件和设置分配并初始化一个AVAudioRecorder实例。
//     
//     如果不想将录音文件持久性保存，可以录音存在到tmp目录，这样当app退出时，该录音可能被自动删除；否则，应存储到Documents目录。下面的代码创建了一个NSURL，它指向temp目录中的文件RecordedFile：
//     
//     NSURL *soundFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"RecordedFile"]];
//     ***/
//   
//    // CCLOG(cocos2d::FileUtils::getInstance()->getWritablePath().c_str());
//    
//    std::string strName = "/";
//    strName.append(filename);
//    
//    //wav
//    strName = strName.substr( 0 ,  strName.find_first_of("."));
//    strName.append(".wav");
//    CCLOG("Recodeing filename %s", strName.c_str());
//    
//    NSString *name = [[NSString alloc] initWithCString:(const char*) strName.c_str()
//                                                       encoding:NSUTF8StringEncoding];
//    
//    NSString   *DocmentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES) objectAtIndex:0];
//    recordedFile = [NSURL URLWithString:[DocmentPath stringByAppendingString: name ]];
//    
//    
//    //创建一个NSDictionary，它包含录制的音频的设置
//    NSDictionary *  RecordParam = [[NSDictionary alloc] initWithObjectsAndKeys:
//                                        [NSNumber numberWithFloat: 8000.0]              ,AVSampleRateKey, //采样率  8000.0   /44100
//                                        [NSNumber numberWithInt: kAudioFormatLinearPCM ],AVFormatIDKey,  //kAudioFormatLinearPCM  /kAudioFormatMPEG4AAC .aac
//                                        [NSNumber numberWithInt: 16]                   ,AVLinearPCMBitDepthKey,  //采样位数 默认 16
//                                        [NSNumber numberWithInt: 2]                    ,AVNumberOfChannelsKey,   //通道的数目 2 /1
//                                        [NSNumber numberWithInt: AVAudioQualityMedium]  ,AVEncoderAudioQualityKey,//音频编码质量  //AVAudioQualityMedium  /AVAudioQualityHigh
//                                   nil];
//    
//    AVAudioSession *session = [AVAudioSession sharedInstance];
//    NSError *sessionError;
//    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
//    [session setActive:YES error:nil];
//    
//    if(session == nil)
//    {
//        CCLOG("创建session: 失败!");//        CCLOG("创建session: %@失败!", [sessionError description]);
//        lua_State* L = cocos2d::LuaEngine::getInstance()->getLuaStack()->getLuaState();
//        lua_getglobal(L, "createAudioFail");
//        lua_call(L, 0, 0);
//    }
//    else
//        [session setActive:YES error:nil];
//    if(!isRecording)
//    {
//        isRecording = YES;
//        CCLOG("正在录音");
//        recorder = [[AVAudioRecorder alloc] initWithURL:recordedFile settings:RecordParam error:nil];
//        [recorder prepareToRecord];
//        [recorder record];
//        player = nil;
//        
//        lua_State* L = cocos2d::LuaEngine::getInstance()->getLuaStack()->getLuaState();
//        lua_getglobal(L, "createAudio");
//        lua_pushnumber(L, 1);
//        lua_call(L, 1, 0);
//    }
//    else
//    {
//        isRecording = NO;
//        CCLOG("停止录音");
//        NSError *playerError;
//        [recorder stop];
//        recorder = nil;
//
//        [self toMp3]; // 转MP3
//        
//        lua_State* L = cocos2d::LuaEngine::getInstance()->getLuaStack()->getLuaState();
//        lua_getglobal(L, "createAudio");
//        lua_pushnumber(L, 0);
//        lua_call(L, 1, 0);
//        
//    }
}

- (void) toMp3
{
//    //mp3
//    std::string strName = "/";
//    strName.append(filename);
//    
//    //wav
//    std::string strWavName = strName.substr( 0 , strName.find_first_of("."));
//    strWavName.append(".wav");
//    
//    CCLOG(" FILE NAME %s",strName.c_str());
//    CCLOG(" Juest FILE NAME %s",strWavName.c_str());
//    
//    NSString *WAVname = [[NSString alloc] initWithCString:(const char*) strWavName.c_str()
//                                              encoding:NSUTF8StringEncoding];
//    
//    NSString *Mp3name = [[NSString alloc] initWithCString:(const char*) strName.c_str()
//                                              encoding:NSUTF8StringEncoding];
//
//    NSString *DocmentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES) objectAtIndex:0];
//
//    
//    @try {
//        int read, write;
//        
//        FILE *pcm = fopen([[DocmentPath stringByAppendingString: WAVname ] cStringUsingEncoding:1], "rb");  //source    *cafFilePath
//        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
//        FILE *mp3 = fopen([[DocmentPath stringByAppendingString: Mp3name ] cStringUsingEncoding:1], "wb");  //output   *mp3FilePath
//        
//        const int PCM_SIZE = 8192;
//        const int MP3_SIZE = 8192;
//        short int pcm_buffer[PCM_SIZE*2];
//        unsigned char mp3_buffer[MP3_SIZE];
//        
//        lame_t lame = lame_init();
//        lame_set_in_samplerate(lame, 8000.0); // 根据采样率
//        lame_set_VBR(lame, vbr_default);
//        lame_init_params(lame);
//        
//        do {
//            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
//            if (read == 0)
//                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
//            else
//                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
//            
//            fwrite(mp3_buffer, write, 1, mp3);
//            
//        } while (read != 0);
//        
//        lame_close(lame);
//        fclose(mp3);
//        fclose(pcm);
//    }
//    @catch (NSException *exception) {
//        NSLog(@"%@",[exception description]);
//        CCLOG("MP3 装失败");
//        lua_State* L = cocos2d::LuaEngine::getInstance()->getLuaStack()->getLuaState();
//        lua_getglobal(L, "createAudioFail");
//        lua_call(L, 0, 0);
//    }
}



@end
