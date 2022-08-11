//
//  GVUserDefaults+Properties.h
//  SkyMeeting
//
//  Created by xiaobin Tang on 2020/4/16.
//  Copyright © 2020 xiaobin Tang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GVUserDefaults/GVUserDefaults.h>

NS_ASSUME_NONNULL_BEGIN

@interface GVUserDefaults (Properties)
#pragma mark--记录全局保存信息
@property (nonatomic ,assign)NSInteger logoType;//logo类型，1=2drakIcon，2=lightIcon
@property (nonatomic ,assign)NSInteger waterPosition;//水印位置
@property (nonatomic ,assign)BOOL isMember;//是否是会员



@end

NS_ASSUME_NONNULL_END
