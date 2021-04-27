//
//  tomp3.m
//  audioTest
//
//  Created by lv on 2018/9/12.
//  Copyright © 2018年 lv. All rights reserved.
//

#import "PcmTomp3.h"
#import "lame.h"

@implementation PcmTomp3


- (BOOL)convertToMp3
{
    
    @try {
        int read,write;
        //只读方式打开被转换音频文件
        FILE *pcm = fopen([self.pcmFilePath cStringUsingEncoding:1], "rb");
        fseek(pcm, 4 * 1024, SEEK_CUR);//删除头，否则在前一秒钟会有杂音
        //只写方式打开生成的MP3文件
        FILE *mp3 = fopen([self.mp3FilePath cStringUsingEncoding:1], "wb");
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE * 2];
        unsigned char mp3_buffer[MP3_SIZE];
        //这里要注意，lame的配置要跟AVAudioRecorder的配置一致，否则会造成转换不成功
//        lame_t lame = lame_init();
//        lame_set_in_samplerate(lame, 22050.0);//采样率
//        lame_set_VBR(lame, vbr_default);
//        lame_init_params(lame);
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_num_channels(lame, 2);//通道
        lame_set_quality(lame, 1);//质量
        lame_set_VBR(lame, vbr_default);
        lame_set_brate(lame, 32);
        lame_set_mode(lame, 3);
        lame_init_params(lame);
        

        do {
            
            //以二进制形式读取文件中的数据
            read = (int)fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            //二进制形式写数据到文件中  mp3_buffer：数据输出到文件的缓冲区首地址  write：一个数据块的字节数  1:指定一次输出数据块的个数   mp3:文件指针
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
        
    } @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
        return NO;
    } @finally {
        NSLog(@"MP3生成成功!!!");
        return YES;
    }
}




@end
