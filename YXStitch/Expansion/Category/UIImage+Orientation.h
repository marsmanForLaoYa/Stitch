//
//  UIImage+Orientation.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/10/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Orientation)
- (UIImage *)fixOrientation:(UIImage *)aImage;
@end

NS_ASSUME_NONNULL_END
