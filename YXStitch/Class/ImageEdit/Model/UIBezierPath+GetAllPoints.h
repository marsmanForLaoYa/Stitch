//
//  UIBezierPath+GetAllPoints.h
//  HYEfficientWhiteBoard
//
//  Created by xiaobin Tang on 2021/5/31.
//  Copyright © 2021 xiaobin Tang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIBezierPath (GetAllPoints)
/** 获取所有点*/
- (NSMutableArray *)points;
@end

NS_ASSUME_NONNULL_END
