//
//  XWTimerTool.m
//  XWNWS
//
//  Created by mac_m11 on 2022/9/15.
//

#import "XWTimerTool.h"
//5min
#define Login_Time_Duration ( 60 * 5)

@interface XWTimerTool ()

@property (nonatomic, strong) NSTimer *autoLoginTimer;

@end

@implementation XWTimerTool

+ (instancetype)shareInstance {
    static XWTimerTool *timerTool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timerTool = [[XWTimerTool alloc] init];
    });
    return timerTool;;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
     
    }
    return self;
}

- (void)addAutoLoginTimer
{
    [self removeAutoLoginTimer];
    if (!self.autoLoginTimer) {
        dispatch_queue_t queue = dispatch_queue_create("com.login.auto", DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(queue, ^{

            self.autoLoginTimer = [NSTimer timerWithTimeInterval:Login_Time_Duration target:self selector:@selector(autoLogin) userInfo:nil repeats:YES];
            //提前触发，app启动时就同步一次数据
            [self.autoLoginTimer fire];
            [[NSRunLoop currentRunLoop] addTimer:self.autoLoginTimer forMode:NSRunLoopCommonModes];
            [[NSRunLoop currentRunLoop] run];
        });
    }
}

- (void)removeAutoLoginTimer {
    [self.autoLoginTimer invalidate];
    self.autoLoginTimer = nil;
}

- (void)autoLogin
{
    if (![User current].isLogin) {
        [self login];
        return;
    }
    
    NSTimeInterval nowTimeStamp = [[NSDate date] timeIntervalSince1970];
    NSUInteger tokenExpire = [User current].tokenExpireTimeStamp;
    if (tokenExpire > nowTimeStamp && tokenExpire - nowTimeStamp < Login_Time_Duration) {
        
        [[User current] logout];
        [self login];
    }
}

- (void)login
{
    [[XWNetTool sharedInstance] loginWithCallback:nil];
}

@end
