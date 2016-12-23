//
//  ViewController.m
//  IOSMediaDemo
//
//  Created by Xinhou Jiang on 23/12/16.
//  Copyright © 2016年 Xinhou Jiang. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVAudioPlayerDelegate>

@property (nonatomic, strong)AVAudioPlayer *audioPlayer;         // 定义一个播放器【一个播放器只能播放一首音乐，多首音乐需要定义一个播放器数组】
@property (nonatomic, weak)IBOutlet UIProgressView *processView; // 进度条显示音乐播放进度
@property (nonatomic, weak)IBOutlet UISlider *slider;            // 滑动条用于调节音量
@property (nonatomic, weak)NSTimer *timer;                       // 进度更新定时器

@end

@implementation ViewController

#pragma mark -life cycle
// 视图加载
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 开启定时器
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(update) userInfo:nil repeats:true];
    // 初始化进度条为0
    [self.processView setProgress:0 animated:NO];
    // 初始化进度条
    [_slider setMinimumValue:0];
    [_slider setMaximumValue:1.0];
    [_slider setValue:0.5];
    [_slider setContinuous:YES];
    [_slider addTarget:self action:@selector(sliderValChanged) forControlEvents:UIControlEventValueChanged];
    
}

// audioPlayer懒加载getter方法
- (AVAudioPlayer *)audioPlayer {
    if (!_audioPlayer) {
        // 资源路径
        NSString *urlStr = [[NSBundle mainBundle]pathForResource:@"snow" ofType:@"wav"];
        NSURL *url = [NSURL fileURLWithPath:urlStr];
        
        // 初始化播放器，注意这里的Url参数只能为本地文件路径，不支持HTTP Url
        NSError *error = nil;
        _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        
        //设置播放器属性
        _audioPlayer.numberOfLoops = 0;// 不循环
        _audioPlayer.delegate = self;
        _audioPlayer.volume = 0.5; // 音量
        [_audioPlayer prepareToPlay];// 加载音频文件到缓存【这个函数在调用play函数时会自动调用】
        
        if(error){
            NSLog(@"初始化播放器过程发生错误,错误信息:%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioPlayer;
}

// 定时更新
- (void)update {
    // 更新进度条
    if (_audioPlayer && _audioPlayer.isPlaying) {
        [_processView setProgress:(_audioPlayer.currentTime/_audioPlayer.duration) animated:YES];
    }
}

// 滑动条值改变触发事件
- (void)sliderValChanged {
    // 改变音量
    if (_audioPlayer) {
        [_audioPlayer setVolume:_slider.value];
    }
}

#pragma maek -IBAction
// 播放
- (IBAction)play:(id)sender {
    [self.audioPlayer play];
}
// 暂停
- (IBAction)pause:(id)sender {
    [self.audioPlayer pause];
}


#pragma mark -播放器播放代理事件
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    // 播放完成...
    NSLog(@"播放完成...");
    // 关闭会话好让其他音频继续播放【这个不一定在这里设置，可以自定合适的时机释放会话】
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    // 播放器解码错误...
    NSLog(@"播放器解码错误...");
}

@end
