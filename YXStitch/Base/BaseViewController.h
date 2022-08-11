//
//  BaseViewController.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BaseViewControllerProtocol <NSObject>

@required
/// 配置View
- (void)setupViews;

/// 配置layout
- (void)setupLayout;


@optional
/// 配置NavBarItem
- (void)setupNavItems;

/// 配置刷新控件
- (void)setupRefresh;


@end

@interface BaseViewController : UIViewController<BaseViewControllerProtocol>

- (void)adjustNavBarColor:(UIColor *)color;

- (void)setNavColorStatus;

@end

NS_ASSUME_NONNULL_END
