//
//  UIView+directionBorder.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/9/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (directionBorder)
- (void)setDirectionBorderWithTop:(BOOL)hasTopBorder left:(BOOL)hasLeftBorder bottom:(BOOL)hasBottomBorder right:(BOOL)hasRightBorder borderColor:(UIColor *)borderColor withBorderWidth:(CGFloat)borderWidth;
@end

NS_ASSUME_NONNULL_END
