//
//  AmrWavAudioRecoder.h
//  AmrWavAudioRecoder
//
//  Created by SJ on 2017/1/3.
//  Copyright © 2017年 SJ. All rights reserved.
//

#ifndef AmrWavAudioRecoder_h
#define AmrWavAudioRecoder_h

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "FileHelper.h"

@interface  AmrWavAudioRecoder : UIViewController<AVAudioPlayerDelegate>
@property (nonatomic , readwrite , retain)id viewControl;

+(AmrWavAudioRecoder *) getInstance;
- (void)StartRecoderAmr:(NSString *)filenamee Directory:(NSString *) directory CallBack:(void(^)(BOOL))callfunc;
- (void)EndRecoderAmr:(void(^)(BOOL))callfunc;
- (void)PlayAmr:(NSString *)filename Directory:(NSString *) directory CallBack:(void(^)(BOOL))callfunc;
- (void)PlayAmr:(NSString *)filepath CallBack:(void(^)(BOOL))callfunc;

- (void)PlayVideo:(NSString *) filepath CallBack:(void(^)(BOOL))callfunc;
- (void)StopVideo;
@end

#endif /* AmrWavAudioRecoder_h */
