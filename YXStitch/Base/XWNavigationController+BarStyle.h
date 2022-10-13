//
//  XWNavigationController+BarStyle.h
//  XWNWS
//
//  Created by mac_m11 on 2022/9/9.
//

#import "XWNavigationController.h"

NS_ASSUME_NONNULL_BEGIN

@interface XWNavigationController (BarStyle)

- (void) removeBarShadow;
- (void) removeNavBarShadowImage;
- (void) addNavBarShadowImageWithColor:(UIColor *)color;

- (void) addNavBarTitleTextAttributes:(NSDictionary *)attributes barShadowHidden:(BOOL)barShadowHidden shadowColor:(UIColor *)shadowColor;

- (void) setNavgationBarTintColor:(UIColor * __nullable)color;

- (UIImage *) shadowImage;

@end

NS_ASSUME_NONNULL_END
