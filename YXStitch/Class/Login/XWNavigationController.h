//
//  XWNavigationViewController.h
//  XWNWS
//
//  Created by mac_m11 on 2022/8/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XWNavigationController : UINavigationController

@property(nonatomic, assign) BOOL pushing;
@property(nonatomic, assign) BOOL enableBackGesture;
- (UIImage *)imageWithColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
