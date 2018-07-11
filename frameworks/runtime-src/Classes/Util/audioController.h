/*
@IOS”Ô“Ù
@author sunfan
@date	2017/05/04
*/

#ifndef AUDIO_CONTROL_H
#define AUDIO_CONTROL_H

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface audioController : UIViewController<AVAudioPlayerDelegate> 
{

    NSURL *recordedFile;
    AVAudioPlayer *player;
    AVAudioPlayer *avAudioPlayer ;
    AVAudioRecorder *recorder;
}

-(void)playAudio;
-(void)AudioRecording;
-(void)toMp3;

@end

#endif
