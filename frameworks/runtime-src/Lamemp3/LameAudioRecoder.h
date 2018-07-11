//
//  LameAudioRecoder.h
//  LameAudioRecoder
//
//  Created by SJ on 2017/1/3.
//  Copyright © 2017年 SJ. All rights reserved.
//

#ifndef LameAudioRecoder_h
#define LameAudioRecoder_h

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "FileHelper.h"

@interface  LameAudioRecoder : UIViewController<AVAudioPlayerDelegate>
@property (nonatomic , readwrite , retain)id viewControl;

+(LameAudioRecoder *) getInstance;
- (void)StartRecoderLame:(NSString *)filenamee Directory:(NSString *) directory CallBack:(void(^)(BOOL))callfunc;
- (void)EndRecoderLame:(void(^)(BOOL))callfunc;
- (void)PlayLame:(NSString *)filename Directory:(NSString *) directory CallBack:(void(^)(BOOL))callfunc;
- (void)PlayLame:(NSString *)filepath CallBack:(void(^)(BOOL))callfunc;

- (void)PlayVideo:(NSString *) filepath CallBack:(void(^)(BOOL))callfunc;
- (void)StopVideo;
@end

#endif /* LameAudioRecoder_h */
