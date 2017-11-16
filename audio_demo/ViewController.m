//
//  ViewController.m
//  audio_demo
//
//  Created by mm on 2017/11/15.
//  Copyright © 2017年 mm. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "VoiceHandle.h"


# define COUNTDOWN 60

@interface ViewController (){
    
    NSTimer *_timer; //定时器
    NSInteger countDown;  //倒计时
    NSString *filePath;
    NSString *amrPath;
    NSString *amrPath_new;
    NSString *wavPath_new;
}

@property (nonatomic, strong) AVAudioSession *session;
@property (weak, nonatomic) IBOutlet UILabel *noticeLabel;
@property (nonatomic, strong) AVAudioRecorder *recorder;//录音器
@property (weak, nonatomic) IBOutlet UITextView *baseText;

@property (nonatomic, strong) AVAudioPlayer *player; //播放器
@property (nonatomic, strong) NSURL *recordFileUrl; //文件地址


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startRecord:(id)sender {
    
    NSLog(@"开始录音");
    
    countDown = 60;
    [self addTimer];
    
    AVAudioSession *session =[AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if (session == nil) {
        
        NSLog(@"Error creating session: %@",[sessionError description]);
        
    }else{
        [session setActive:YES error:nil];
        
    }
    
    self.session = session;
    
    
    //1.获取沙盒地址
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    filePath = [path stringByAppendingString:@"/RRecord.wav"];
    
    //2.获取文件路径
    self.recordFileUrl = [NSURL fileURLWithPath:filePath];
    
    //设置参数
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   //采样率  8000/11025/22050/44100/96000（影响音频的质量）
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey,
                                   // 音频格式
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   //采样位数  8、16、24、32 默认为16
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                   // 音频通道数 1 或 2
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                   //录音质量
                                   [NSNumber numberWithInt:AVAudioQualityHigh],AVEncoderAudioQualityKey,
                                   nil];
    
    
    _recorder = [[AVAudioRecorder alloc] initWithURL:self.recordFileUrl settings:recordSetting error:nil];
    
    if (_recorder) {
        
        _recorder.meteringEnabled = YES;
        [_recorder prepareToRecord];
        [_recorder record];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self stopRecord:nil];
        });
        
        
        
    }else{
        NSLog(@"音频格式和文件存储格式不匹配,无法初始化Recorder");
        
    }
    
    

    
}

- (IBAction)stopRecord:(id)sender {
    [self removeTimer];
    NSLog(@"停止录音");
    
    if ([self.recorder isRecording]) {
        [self.recorder stop];
    }
    
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        
        _noticeLabel.text = [NSString stringWithFormat:@"录了 %ld 秒,文件大小为 %.2fKb",COUNTDOWN - (long)countDown,[[manager attributesOfItemAtPath:filePath error:nil] fileSize]/1024.0];
        
    }else{
        
        _noticeLabel.text = @"最多录60秒";
        
    }
    
    
}

- (IBAction)PlayRecord:(id)sender {
    
    
    NSLog(@"播放录音");
    [self.recorder stop];
    
    if ([self.player isPlaying])return;
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recordFileUrl error:nil];
    
    
    
    NSLog(@"%li",self.player.data.length/1024);
    
    
    
    [self.session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [self.player play];
    
}

/**
 *  添加定时器
 */
- (void)addTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshLabelText) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

/**
 *  移除定时器
 */
- (void)removeTimer
{
    [_timer invalidate];
    _timer = nil;
    
}


-(void)refreshLabelText{
    
    countDown --;
    
    _noticeLabel.text = [NSString stringWithFormat:@"还剩 %ld 秒",(long)countDown];
    
    
}

- (IBAction)wTa:(id)sender {
    
    //1.获取沙盒地址
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    amrPath = [path stringByAppendingString:@"/aaaa.amr"];
    
    NSLog(@"%@",filePath);
    NSLog(@"%@",amrPath);
    
    int i =  [VoiceHandle wavToAmr:filePath amrSavePath:amrPath];
    
    NSLog(@"%d",i);
    
//    NSLog(@"%@",data);

    if(i == 0){
        _noticeLabel.text = @"wavToamr----OK";
    }else{
        _noticeLabel.text = @"wavToamr----NO";
    }
    
    
}

- (IBAction)getBase64Str:(id)sender {
    
    NSData *data = [[NSFileManager defaultManager]contentsAtPath:amrPath];
    NSString * base64Str = [data base64EncodedStringWithOptions:0];
    NSLog(@"%@",base64Str);
    
    _baseText.text = base64Str;
    
}

- (IBAction)strToamr:(id)sender {
    
    NSData *data =[[NSData alloc] initWithBase64EncodedString:_baseText.text options:0];
    
    //1.获取沙盒地址
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    amrPath_new = [path stringByAppendingString:@"/aaaa.amr"];
    
   BOOL ok =  [[NSFileManager defaultManager] createFileAtPath:amrPath_new contents:data attributes:nil];
    
    if(ok){
         _noticeLabel.text = @"strToamr----OK";
        return;
    }
    _noticeLabel.text = @"strToamr----NO";
    
}

- (IBAction)amrTowav:(id)sender {
    
    //1.获取沙盒地址
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    wavPath_new = [path stringByAppendingString:@"/new_ssdfsdf.wav"];
    
    int i =  [VoiceHandle amrToWav:amrPath_new wavSavePath:wavPath_new];
    
    if(i == 0){
        _noticeLabel.text = @"amrTowav----OK";
    }else{
        _noticeLabel.text = @"amrTowav----NO";
    }
    
    
}

- (IBAction)playNewwav:(id)sender {
    NSLog(@"播放录音");
    [self.recorder stop];
    
    if ([self.player isPlaying])return;
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:wavPath_new] error:nil];
    
    NSLog(@"%li",self.player.data.length/1024);
    
    [self.session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [self.player play];
    
}


@end
