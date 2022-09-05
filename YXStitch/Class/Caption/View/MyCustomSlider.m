//
//  CaptionBottomView.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/26.
//

#import "MyCustomSlider.h"
#import "Masonry.h"
#define kSliderBtnWidth 16
#define kSliderWidth 5

@interface MyCustomSlider()

/** 进度背景 */
@property (nonatomic, strong) UIImageView *bgProgressView;

/** 滑动进度 */
@property (nonatomic, strong) UIImageView *sliderProgressView;
@end

@implementation MyCustomSlider

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubViews];
    }
    return self;
}
- (void)addSubViews {
    __weak typeof(self) wealSelf = self;
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.bgProgressView];
    [self.bgProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wealSelf);
        make.centerX.equalTo(wealSelf);
        make.height.mas_equalTo(wealSelf);
        make.width.mas_equalTo(kSliderWidth);
    }];
    
    
    [self addSubview:self.sliderProgressView];
    [self.sliderProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wealSelf);
        make.centerX.equalTo(wealSelf);
        make.height.mas_equalTo(0);
        make.width.mas_equalTo(kSliderWidth);
    }];
    
    [self addSubview:self.sliderBtn];
    [self.sliderBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wealSelf);
        make.height.mas_equalTo(kSliderBtnWidth);
        make.width.mas_equalTo(kSliderBtnWidth);
        make.centerX.equalTo(wealSelf);
    }];
}
- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state {
    [self.sliderBtn setBackgroundImage:image forState:state];
    
    [self.sliderBtn sizeToFit];
}

- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state {
    [self.sliderBtn setImage:image forState:state];
    
    [self.sliderBtn sizeToFit];
}
- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor {
    _maximumTrackTintColor = maximumTrackTintColor;
    
    self.bgProgressView.backgroundColor = maximumTrackTintColor;
}

- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor {
    _minimumTrackTintColor = minimumTrackTintColor;
    
    self.sliderProgressView.backgroundColor = minimumTrackTintColor;
}
#pragma mark - 懒加载
- (UIImageView *)bgProgressView {
    if (!_bgProgressView) {
        _bgProgressView = [UIImageView new];
        _bgProgressView.backgroundColor = [UIColor whiteColor];
        _bgProgressView.layer.cornerRadius = kSliderWidth*0.5;
        _bgProgressView.layer.masksToBounds = YES;
        _bgProgressView.clipsToBounds = YES;
    }
    return _bgProgressView;
}

- (UIImageView *)sliderProgressView {
    if (!_sliderProgressView) {
        _sliderProgressView = [UIImageView new];
        _sliderProgressView.backgroundColor = [UIColor blueColor];
        _sliderProgressView.layer.cornerRadius = kSliderWidth*0.5;
        _sliderProgressView.layer.masksToBounds = YES;
        _sliderProgressView.clipsToBounds = YES;
    }
    return _sliderProgressView;
}

- (SliderButton *)sliderBtn {
    if (!_sliderBtn) {
        _sliderBtn = [SliderButton new];
    }
    return _sliderBtn;
}
@end


@interface SliderButton()
@property (nonatomic, assign) CGFloat moveValue;//移动的距离
@property(nonatomic, assign) CGPoint beginPoint;//开始的位置
@property(nonatomic, assign) CGRect selfBeginFrame;//按钮开始的位置

@end

@implementation SliderButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

// 重写此方法将按钮的点击范围扩大
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    
    // 扩大点击区域
    bounds = CGRectInset(bounds, -20, -20);
    
    // 若点击的点在新的bounds里面。就返回yes
    return CGRectContainsPoint(bounds, point);
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [self layoutIfNeeded];
    UITouch *touch = [touches anyObject];
    self.beginPoint = [touch locationInView:self.superview];
    self.selfBeginFrame = self.frame;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint nowPoint = [touch locationInView:self.superview];
    CGFloat offsetY = nowPoint.y - self.beginPoint.y;
    CGFloat afterY = CGRectGetMaxY(self.selfBeginFrame) + offsetY;
    if (afterY <= 0) {
        afterY = 0.0;
    }else if (afterY >= CGRectGetHeight(self.superview.frame)-kSliderBtnWidth){
        afterY = CGRectGetHeight(self.superview.frame)-kSliderBtnWidth;
    }
    //改变自己的frame
    CGRect oriFrame = self.selfBeginFrame;
    oriFrame.origin.y = afterY;
    self.frame = oriFrame;
    //改变进度条的frame
    MyCustomSlider *parerntView = (MyCustomSlider *)self.superview;
    CGRect progressViewFrame = parerntView.sliderProgressView.frame;
    progressViewFrame.size.height = CGRectGetMaxY(self.frame);
    parerntView.sliderProgressView.frame = progressViewFrame;
    if (self.delegate && [self.delegate respondsToSelector:@selector(sliderValueChanged:)]) {
        [self.delegate sliderValueChanged:(afterY / (CGRectGetHeight(self.superview.frame)-kSliderBtnWidth))];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}
@end
