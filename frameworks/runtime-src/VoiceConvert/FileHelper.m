//
//  FileHelper.m
//  AmrWavAudioRecoder
//
//  Created by SJ on 2017/1/3.
//  Copyright © 2017年 SJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileHelper.h"

@interface FileHelper()

@end

static NSString *baseDirectory;
@implementation FileHelper


#pragma mark - 生成当前时间字符串
+ (NSString*)GetCurrentTimeString{
     NSDateFormatter *dateformat = [[NSDateFormatter  alloc]init];
     [dateformat setDateFormat:@"yyyyMMddHHmmss"];
     return [dateformat stringFromDate:[NSDate date]];
}


#pragma mark - 生成文件路径
+ (NSString*)GetPathByFileName:(NSString *)_fileName ofType:(NSString *)_type{
    NSString *directory = baseDirectory;
    if([baseDirectory isKindOfClass:[NSNull class]]  ){
        directory= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    }
     NSString* fileDirectory = [[[directory stringByAppendingPathComponent:_fileName]
                                            stringByAppendingPathExtension:_type]
                                 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
     return fileDirectory;
}

#pragma mark - 获取文件大小
+ (NSInteger) getFileSize:(NSString*) path{
     NSFileManager * filemanager = [[NSFileManager alloc]init];
     if([filemanager fileExistsAtPath:path]){
          NSDictionary * attributes = [filemanager attributesOfItemAtPath:path error:nil];
          NSNumber *theFileSize;
          if ( (theFileSize = [attributes objectForKey:NSFileSize]) )
               return  [theFileSize intValue];
          else
               return -1;
     }
     else{
          return -1;
     }
}


+ (void) setBaseDirectory:(NSString*) directory{
    baseDirectory = directory;
}


@end
