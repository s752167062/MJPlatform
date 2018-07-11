//
//  FileHelper.h
//  AmrWavAudioRecoder
//
//  Created by SJ on 2017/1/3.
//  Copyright © 2017年 SJ. All rights reserved.
//

#ifndef FileHelper_h
#define FileHelper_h

@interface FileHelper : NSObject

+ (NSString*)GetCurrentTimeString;
+ (NSString*)GetPathByFileName:(NSString *)_fileName ofType:(NSString *)_type;
+ (NSInteger) getFileSize:(NSString*) path;
+ (void) setBaseDirectory:(NSString*) directory;
@end

#endif /* FileHelper_h */
