//
//  LameVoiceConverter.m
//  Jeans
//
//  Created by Jeans Huang on 12-7-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#include <stdio.h>
#include <iostream>
#include "cocos2d.h"
#import "LameVoiceConverter.h"
//#import "interf_dec.h"
//#import "dec_if.h"
//#import "interf_enc.h"
//#import "amrFileCodec.h"
#import "lame.h"


@implementation LameVoiceConverter


+ (int)ConvertWavToMp3:(NSString *)wavPath mp3SavePath:(NSString *)aSavePath{
    @try {
        int read, write;
        
        FILE *pcm = fopen([wavPath cStringUsingEncoding:1] , "rb");  //source    *cafFilePath
        if(pcm == NULL){
            return 0;
        }
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([aSavePath cStringUsingEncoding:1] , "wb");  //output   *mp3FilePath
        if(mp3 == NULL){
            return 0;
        }
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 8000.0); // 根据采样率
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
        
        return 1;
    }
    @catch (NSException *exception) {
        NSLog(@"MP3 转失败 %@",[exception description]);
        return 0;
    }
    
}
//获取录音设置
+ (NSDictionary*)GetAudioRecorderSettingDict{
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey, //采样率
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//采样位数 默认 16
                                   [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,//通道的数目
                                   [NSNumber numberWithInt: AVAudioQualityMedium]  ,AVEncoderAudioQualityKey,//音频编码质量
                                   //                                   [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,//大端还是小端 是内存的组织方式
                                   //                                   [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,//采样信号是整数还是浮点数
                                   //                                   [NSNumber numberWithInt: AVAudioQualityMedium],AVEncoderAudioQualityKey,//音频编码质量
                                   nil];
    return recordSetting;
}
    
@end
