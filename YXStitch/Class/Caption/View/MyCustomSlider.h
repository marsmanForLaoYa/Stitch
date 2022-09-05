//
//  CaptionBottomView.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/26.
//

#import <UIKit/UIKit.h>



@protocol SliderViewDelegate <NSObject>

@optional

- (void)sliderValueChanged:(float)value;
@end

@interface SliderButton : UIButton
@property (nonatomic, weak) id<SliderViewDelegate> delegate;
@end

@interface MyCustomSlider : UIView
/** 默认滑杆的颜色 */
@property (nonatomic, strong) UIColor *maximumTrackTintColor;
/** 滑杆进度颜色 */
@property (nonatomic, strong) UIColor *minimumTrackTintColor;
/** 滑杆进度的图片 */
@property (nonatomic, strong) UIImage *minimumTrackImage;
/** 滑块 */
@property (nonatomic, strong) SliderButton *sliderBtn;
// 滑块背景
- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state;
// 滑块图片
- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state;
@end



