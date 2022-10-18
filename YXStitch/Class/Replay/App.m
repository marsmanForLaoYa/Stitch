//
//  App.m
//  YXStitch
//
//  Created by mac_m11 on 2022/10/11.
//

#import "App.h"
#import "SharePath.h"
static void onDarwinReplayKit2PushFinish(CFNotificationCenterRef center,
                                        void *observer, CFStringRef name,
                                        const void *object, CFDictionaryRef
                                        userInfo){
    //转到cocoa层框架处理
    [[NSNotificationCenter defaultCenter] postNotificationName:ScreenRecordFinishNotif object:nil];
}
static void onDarwinReplayKit2PushStart(CFNotificationCenterRef center,
                                        void *observer, CFStringRef name,
                                        const void *object, CFDictionaryRef
                                        userInfo){
    //转到cocoa层框架处理
    [[NSNotificationCenter defaultCenter] postNotificationName:ScreenRecordStartNotif object:nil];
}

@implementation App

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sharedInstance
{
    static App *app = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        app = [[self alloc] init];
    });
    
    return app;
}

- (instancetype)init
{
    self = [super init];
    if (self) {

        [self registerNotifications];
    }
    return self;
}

- (void)registerNotifications
{
    //注册录屏开始与完成通知
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    (__bridge const void *)(self),
                                    onDarwinReplayKit2PushStart,
                                    (__bridge CFStringRef)(ScreenDidStartNotif),
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    (__bridge const void *)(self),
                                    onDarwinReplayKit2PushFinish,
                                    (__bridge CFStringRef)(ScreenDidFinishNotif),
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScreenRecordStartNotification:) name:ScreenRecordStartNotif object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScreenRecordEndNotification:) name:ScreenRecordFinishNotif object:nil];
    
    
    LYLog(@"检测文件1");
    if(![UIScreen mainScreen].isCaptured){//正在录屏
        NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:GroupIDKey];
        NSString *fileName = [sharedDefaults objectForKey:FileKey];
        LYLog(@"检测文件2");
        if (fileName.length>0) {//录屏时app挂掉重启后也可找到mp4
            LYLog(@"检测文件3");
            NSURL *oldUrl = [SharePath filePathUrlWithFileName:fileName];
            [self moveFromGroupUrl:oldUrl];
        }
    }
}

//录屏开始以后的推送
- (void)handleScreenRecordStartNotification:(NSNotification*)noti{
//    NSLog(@"录屏开始：%@",noti);
    [[NSNotificationCenter defaultCenter] postNotificationName:kScreenRecordStartNotification object:nil userInfo:nil];
}

//录屏结束以后的推送
- (void)handleScreenRecordEndNotification:(NSNotification*)noti{
//    NSLog(@"录屏结束：%@",noti);
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:GroupIDKey];
    NSString *fileName = [sharedDefaults objectForKey:FileKey];
    if (fileName.length>0) {
        NSURL *oldUrl = [SharePath filePathUrlWithFileName:fileName];
        [self moveFromGroupUrl:oldUrl];
    }
}

- (void)moveFromGroupUrl:(NSURL *)oldUrl{

    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSURL *newUrl = [NSURL fileURLWithPath:[path stringByAppendingString:[NSString stringWithFormat:@"/%@.mp4",[NSDate timestamp]]]];
    NSError *error;
    [[NSFileManager defaultManager] moveItemAtURL:oldUrl toURL:newUrl error:&error];
    NSURL *videoURL = nil;
    if (error) {
//        NSLog(@"转移失败:%@",error);
        videoURL = oldUrl;
    }else{
        NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:GroupIDKey];
        [sharedDefaults removeObjectForKey:FileKey];
        [sharedDefaults synchronize];
        videoURL = newUrl;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kScreenRecordFinishNotification object:nil userInfo:@{@"videoURL":videoURL}];
    _videoURL = videoURL;
    GVUserDe.isHaveScreenData = YES;
//    NSDictionary *dic = @{@"videoURL":videoURL};
//    GVUserDe.screenVideoDic = dic;
    
    LYLog(@"发送通知");
}

@end
