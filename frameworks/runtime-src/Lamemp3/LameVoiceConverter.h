//
//  LameVoiceConverter.h
//  Jeans
//
//  Created by Jeans Huang on 12-7-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface LameVoiceConverter : NSObject


/**
 * 转换wav到mp3
 */
+ (int)ConvertWavToMp3:(NSString *)wavPath mp3SavePath:(NSString *)aSavePath;

/**
	获取录音设置.
    建议使用此设置，如有修改，则转换amr时也要对应修改参数，比较麻烦
	@returns 录音设置
 */
+ (NSDictionary*)GetAudioRecorderSettingDict;

@end
