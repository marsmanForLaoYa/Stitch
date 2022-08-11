//
//  SampleHandler.m
//  StitchScreenShare
//
//  Created by xwan-iossdk on 2022/8/8.
//


#import "SampleHandler.h"

@implementation SampleHandler

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    //这里主要就是做一些初始化的行为操作
    // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional. 
}

- (void)broadcastPaused {
    //接收系统暂停信号
    // User has requested to pause the broadcast. Samples will stop being delivered.
}

- (void)broadcastResumed {
    //接收系统恢复信号
    // User has requested to resume the broadcast. Samples delivery will resume.
}

- (void)broadcastFinished {
    //接收系统完成信号
    // User has requested to finish the broadcast.
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    //我们可以拿到系统源数据，分了三类，分别为视频帧、App内声音、麦克风
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo:
            // Handle video sample buffer
            break;
        case RPSampleBufferTypeAudioApp:
            // Handle audio sample buffer for app audio
            break;
        case RPSampleBufferTypeAudioMic:
            // Handle audio sample buffer for mic audio
            break;
            
        default:
            break;
    }
}

@end
