//
//  BaseView.h
//  DUGeneral
//
//  Created by ioser on 2019/6/13.
//  Copyright © 2019 . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ViewProtocol <NSObject>

@optional

///配置视图
- (void)setupViews;

///配置约束
- (void)setupLayout;

@end

NS_ASSUME_NONNULL_BEGIN

@interface BaseView : UIView<ViewProtocol>

@end

NS_ASSUME_NONNULL_END
