//
// Created by SuJiang on 2018/1/13.
// Copyright (c) 2018 appscomm. All rights reserved.
//

#import <Foundation/Foundation.h>

void LYBCVerbose(NSString *msg);
void LYBCInfo(NSString *msg);
void LYBCWarn(NSString *msg);
void LYBCError(NSString *msg);

#define LYLog(fmt, ...) LYBCVerbose([NSString stringWithFormat:fmt, ##__VA_ARGS__])
#define LYLogInfo(fmt, ...) LYBCInfo([NSString stringWithFormat:fmt, ##__VA_ARGS__])
#define LYLogWarn(fmt, ...) LYBCWarn([NSString stringWithFormat:fmt, ##__VA_ARGS__])
#define LYLogError(fmt, ...) LYBCError([NSString stringWithFormat:fmt, ##__VA_ARGS__])

@interface LYLogger : NSObject

+ (LYLogger *) instance;

// 是否打开日志、默认是打开的
@property(nonatomic, assign) BOOL on;

@end
