//
//  tomp3.h
//  audioTest
//
//  Created by lv on 2018/9/12.
//  Copyright © 2018年 lv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface PcmTomp3 : NSObject
/** 录音文件路径 */
@property (nonatomic,strong) NSString * pcmFilePath;
/** 转换的Mp3文件地址 */
@property (nonatomic,strong) NSString * mp3FilePath;

- (BOOL)convertToMp3;

@end
