//
//  LayoutBottomView.h
//  YXStitch
//
//  Created by mac_m11 on 2022/9/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^LayoutBottomBlock)(NSInteger index);
@interface LayoutBottomView : UIView

@property (nonatomic, copy) LayoutBottomBlock layoutBottomBlock;

@end

@interface ButtonView : UIView

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *titleLabel;
- (instancetype)initWithNormalImagName:(NSString *)normalImageName selectedImagName:(NSString *)selectedImagName title:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
