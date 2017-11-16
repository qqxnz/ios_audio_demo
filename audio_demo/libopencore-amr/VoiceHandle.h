//
//  HZVoiceHandle.h
//  audio_demo
//
//  Created by mm on 2017/11/15.
//  Copyright © 2017年 mm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoiceHandle : NSObject

+ (int)isMP3File:(NSString *)filePath;

+ (int)isAMRFile:(NSString *)filePath;

+ (int)amrToWav:(NSString*)_amrPath wavSavePath:(NSString*)_savePath;

+ (int)wavToAmr:(NSString*)_wavPath amrSavePath:(NSString*)_savePath;

@end
