//
//  SampleHandler.m
//  StitchScreenShare
//
//  Created by xwan-iossdk on 2022/8/8.
//


#import "SampleHandler.h"

#import "SampleHandler.h"
#import "SharePath.h"
#import "XWOpenCVHelper.h"
@interface SampleHandler()

//使用以下保存mp4
@property (strong, nonatomic) AVAssetWriter *assetWriter;
@property (strong, nonatomic) AVAssetWriterInput *videoInput;
@property (strong, nonatomic) AVAssetWriterInput *audioAppInput;
@property (strong, nonatomic) AVAssetWriterInput *audioMicInput;

@property (assign, nonatomic) NSInteger sameImageCount;
@property (strong, nonatomic) UIImage *lastImage;

@end

@implementation SampleHandler

- (void)setupAssetWriter {
    if ([self.assetWriter canAddInput:self.videoInput]) {
        [self.assetWriter addInput:self.videoInput];
    } else {
        NSAssert(false, @"添加视频写入失败");
    }
    if ([self.assetWriter canAddInput:self.audioAppInput]) {
        [self.assetWriter addInput:self.audioAppInput];
    } else {
        NSAssert(false, @"添加App音频写入失败");
    }
    if ([self.assetWriter canAddInput:self.audioMicInput]) {
        [self.assetWriter addInput:self.audioMicInput];
    } else {
        NSAssert(false, @"添加Mic音频写入失败");
    }
}

- (AVAssetWriter *)assetWriter {
    if (!_assetWriter) {
        NSError *error = nil;
        NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:GroupIDKey];
        NSString *fileName = [sharedDefaults objectForKey:FileKey];
        NSURL *filePathURL = [SharePath filePathUrlWithFileName:fileName];//保存在共享文件夹中
        _assetWriter = [[AVAssetWriter alloc] initWithURL:filePathURL fileType:(AVFileTypeMPEG4) error:&error];
        NSAssert(!error, @"_assetWriter初始化失败");
    }
    return _assetWriter;
}

- (AVAssetWriterInput *)videoInput {
    if (!_videoInput) {
        
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CGSize size = CGSizeMake(screenSize.width * 2, screenSize.height * 2);
        //写入视频大小
        NSInteger numPixels = size.width  * size.height;
        //每像素比特
        CGFloat bitsPerPixel = 10;
        NSInteger bitsPerSecond = numPixels * bitsPerPixel;
        // 码率和帧率设置
        NSDictionary *compressionProperties = @{
            AVVideoAverageBitRateKey : @(bitsPerSecond),//码率(平均每秒的比特率)
            AVVideoExpectedSourceFrameRateKey : @(15),//帧率（如果使用了AVVideoProfileLevelKey则该值应该被设置，否则可能会丢弃帧以满足比特流的要求）
            AVVideoMaxKeyFrameIntervalKey : @(15),//关键帧最大间隔
            AVVideoProfileLevelKey : AVVideoProfileLevelH264BaselineAutoLevel,
        };
        
        NSDictionary *videoOutputSettings = @{
            AVVideoCodecKey : AVVideoCodecTypeH264,
            AVVideoScalingModeKey : AVVideoScalingModeResizeAspect,
            AVVideoWidthKey : @(size.width * 2),
            AVVideoHeightKey : @(size.height * 2),
            AVVideoCompressionPropertiesKey : compressionProperties
        };
        _videoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:videoOutputSettings];
        _videoInput.expectsMediaDataInRealTime = true;//实时录制

    }
    return _videoInput;
}

- (AVAssetWriterInput *)audioAppInput {
    if (!_audioAppInput) {
        NSDictionary *audioCompressionSettings = @{ AVEncoderBitRatePerChannelKey : @(28000),
                                                    AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                                                    AVNumberOfChannelsKey : @(1),
                                                    AVSampleRateKey : @(22050) };

        _audioAppInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioCompressionSettings];
        _audioAppInput.expectsMediaDataInRealTime = true;//实时录制
    }
    return _audioAppInput;
}
- (AVAssetWriterInput *)audioMicInput {
    if (!_audioMicInput) {
        NSDictionary *audioCompressionSettings = @{ AVEncoderBitRatePerChannelKey : @(28000),
                                                    AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                                                    AVNumberOfChannelsKey : @(1),
                                                    AVSampleRateKey : @(22050) };

        _audioMicInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioCompressionSettings];
        _audioMicInput.expectsMediaDataInRealTime = true;//实时录制
    }
    return _audioMicInput;
}

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),(__bridge CFStringRef)ScreenDidStartNotif,NULL,nil,YES);
    
    //设置录屏时间
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:GroupIDKey];
    NSString *fileName = [NSDate timestamp];//mp4播放后fileName重新生成
    [sharedDefaults setObject:fileName forKey:FileKey];
    [sharedDefaults synchronize];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSDictionary *dic = @{NSLocalizedFailureReasonErrorKey : @"Screen is over"};
//        NSError *err = [NSError errorWithDomain:@"domain" code:401 userInfo:dic];
//        [self finishBroadcastWithError:err];
//    });
    _sameImageCount = 0;
    [self setupAssetWriter];//初始化AssetWriter
    NSLog(@"开始录屏");
}

- (void)broadcastPaused {
    // User has requested to pause the broadcast. Samples will stop being delivered.
    NSLog(@"录屏暂停");
}

- (void)broadcastResumed {
    // User has requested to resume the broadcast. Samples delivery will resume.
    NSLog(@"录屏继续");
}

- (void)finishBroadcastWithError:(NSError *)error {
    NSLog(@"录屏错误");
    [self stopWriting];
    [super finishBroadcastWithError:error];
    //通知主程 录屏结束
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),(__bridge CFStringRef)ScreenDidFinishNotif,NULL,nil,YES);
}

- (void)broadcastFinished {
    // User has requested to finish the broadcast.
    NSLog(@"录屏结束");
    [self stopWriting];
    //通知主程 录屏结束
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),(__bridge CFStringRef)ScreenDidFinishNotif,NULL,nil,YES);
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo:
            // Handle video sample buffer
            @autoreleasepool {
                
                UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
                
                if(self.lastImage && image) {
                    cv::Mat matImage = [XWOpenCVHelper cvMatFromUIImage:image];
                    cv::Mat matLastImage = [XWOpenCVHelper cvMatFromUIImage:self.lastImage];
                    //如果不相同的数据位数不超过5，就说明两张图像很相似；如果大于10，就说明这是两张不同的图像。
                    int hashValue = aHash(matImage, matLastImage);
                    if(hashValue < 5) {
                        _sameImageCount ++;
                    }
                    else
                    {
                        _sameImageCount = 0;
                    }
                    
                    if (hashValue > 0) {
                        NSLog(@"sameImageCount:%ld hashsValue: %d", (long)_sameImageCount, hashValue);
                    }
                    else
                    {
                        NSLog(@"sameImageCount:%ld hashValueZero: %d", (long)_sameImageCount, hashValue);
                    }
                }
                //100张相同的图片，停止录屏
                if(_sameImageCount > 60) {
                    NSDictionary *dic = @{NSLocalizedFailureReasonErrorKey : @"图片已生成"};
                    NSError *err = [NSError errorWithDomain:@"domain" code:401 userInfo:dic];
                    [self finishBroadcastWithError:err];
                }
  
                self.lastImage = image;
                
                AVAssetWriterStatus status = self.assetWriter.status;
                if ( status == AVAssetWriterStatusFailed || status == AVAssetWriterStatusCompleted || status == AVAssetWriterStatusCancelled) {
                    NSAssert(false,@"屏幕录制AVAssetWriterStatusFailed error :%@", self.assetWriter.error);
                    return;
                }
                if (status == AVAssetWriterStatusUnknown) {
                    [self.assetWriter startWriting];
                    CMTime time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
                    [self.assetWriter startSessionAtSourceTime:time];
                }
                if (status == AVAssetWriterStatusWriting) {
                    if (self.videoInput.isReadyForMoreMediaData) {
                       BOOL success = [self.videoInput appendSampleBuffer:sampleBuffer];
                        if (!success) {
                            [self stopWriting];
                        }
                    }
                }
            }
            break;
        case RPSampleBufferTypeAudioApp:
            if (self.audioAppInput.isReadyForMoreMediaData) {
                BOOL success = [self.audioAppInput appendSampleBuffer:sampleBuffer];
                if (!success) {
                    [self stopWriting];
                }
            }
            // Handle audio sample buffer for app audio
            break;
        case RPSampleBufferTypeAudioMic:
            if (self.audioMicInput.isReadyForMoreMediaData) {
                BOOL success = [self.audioMicInput appendSampleBuffer:sampleBuffer];
                if (!success) {
                    [self stopWriting];
                }
            }
            // Handle audio sample buffer for mic audio
            break;
        default:
            break;
    }
}

- (void)stopWriting{
    if (self.assetWriter.status == AVAssetWriterStatusWriting) {
        [self.videoInput markAsFinished];
        [self.audioAppInput markAsFinished];
        [self.audioMicInput markAsFinished];
        if(@available(iOS 14.0, *)){
            [self.assetWriter finishWritingWithCompletionHandler:^{
                self.videoInput = nil;
                self.audioAppInput = nil;
                self.audioMicInput = nil;
                self.assetWriter = nil;
            }];
        }else{//iOS14之前使用弃用方法mp4才能播放
            [self.assetWriter finishWriting];
        }
    }
}

- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(imageBuffer), CVPixelBufferGetHeight(imageBuffer))];
    
    UIImage *image = [[UIImage alloc] initWithCGImage:videoImage];
    CGImageRelease(videoImage);
    
    return image;
}

@end
