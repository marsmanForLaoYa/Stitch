//
// Created by SuJiang on 2018/1/13.
// Copyright (c) 2018 appscomm. All rights reserved.
//

#import "LYLogger.h"
#import "CocoaLumberjack.h"

#ifdef DEBUG
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

void LYBCVerbose(NSString *msg)
{
    if ([LYLogger instance].on)
    {
        DDLogVerbose(@"========= %@ =========", msg);
    }
}

void LYBCInfo(NSString *msg)
{
    if ([LYLogger instance].on)
    {
        DDLogInfo(@"========= %@ =========", msg);
    }
}
void LYBCWarn(NSString *msg)
{
    if ([LYLogger instance].on)
        DDLogWarn(@"========= %@ =========", msg);
}

void LYBCError(NSString *msg)
{
    if ([LYLogger instance].on)
        DDLogError(@"========= %@ =========", msg);
}

@implementation LYLogger {

}

+ (LYLogger *) instance
{
    static dispatch_once_t LYLogger_once_token;
    static LYLogger *logger = nil;
    dispatch_once(&LYLogger_once_token, ^{
        logger = [[LYLogger alloc] init];
    });
    return logger;
}


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.on = YES;
        
//        [self initAspects];
        [self initDDLogger];
    }
    return self;
}

- (void) initDDLogger
{
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    DDLogFileManagerDefault *documentsFileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:documentsPath];
    // 改变目录
    // https://stackoverflow.com/questions/19857508/cocoalumberjack-ios-can-we-change-the-logfile-name-and-directory
    
    
    DDTTYLogger *consoleLogger = [DDTTYLogger sharedInstance];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:documentsFileManager];
    
//    fileLogger.rollingFrequency = 60 * 60 * 24 * 10; // 一天一个文件
//    fileLogger.maximumFileSize = 50 * 1024 * 1024;  // 50M
//    fileLogger.maximumFileSize = 7;             // 最多存7个，也就是一周
    
    
    [DDLog addLogger:consoleLogger];
    [DDLog addLogger:fileLogger withLevel:DDLogLevelAll];
    
//    //获取log文件夹路径
//    NSString *logDirectory = [fileLogger.logFileManager logsDirectory];
//    DDLogDebug(@"%@", logDirectory);
//    //获取排序后的log名称
//    NSArray <NSString *>*logsNameArray = [fileLogger.logFileManager sortedLogFileNames];
//    DDLogDebug(@"%@", logsNameArray);
    
}

@end

#pragma mark - test
@interface CustomLogFileManager : DDLogFileManagerDefault

- (instancetype)initWithLogsDirectory:(NSString *)logsDirectory fileName:(NSString *)name;

@end

