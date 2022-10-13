//
//  XWTimerTool.h
//  XWNWS
//
//  Created by mac_m11 on 2022/9/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XWTimerTool : NSObject

+ (instancetype)shareInstance;

//添加自动登录定时器
- (void)addAutoLoginTimer;

@end

NS_ASSUME_NONNULL_END
