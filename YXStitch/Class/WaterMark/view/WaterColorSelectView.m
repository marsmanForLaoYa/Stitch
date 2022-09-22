//
//  WaterColorSelectView.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/17.
//

#import "WaterColorSelectView.h"

#define CUB_WIDTH 30

#define SELECT_WIDTH CUB_WIDTH * 7 + 8
#define SELECT_HEIGHT CUB_WIDTH * 2 + 3

@interface WaterColorSelectView ()
@property (nonatomic, strong)UIButton *selectBtn;
@property (nonatomic ,assign)BOOL isLoad;
@end

@implementation WaterColorSelectView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = HexColor(@"#1A1A1A");
        self.userInteractionEnabled = YES;
        _colorArray = [NSMutableArray arrayWithObjects:@"#FFFFFF",@"#000000", @"#EF5B3D",@"#F98945",@"#F7DB78",@"#5EE16F",@"#51A0FD",nil];
        _isLoad = NO;
    }
    return self;
}

-(void)layoutSubviews{
    if (!_isLoad){
        [self setupViews];
        _isLoad = !_isLoad;
    }
    
}

- (void)setupViews{
    
    UIImageView *smallIcon = [UIImageView new];
    smallIcon.image = IMG(@"小字体icon");
    [self addSubview:smallIcon];
    [smallIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@10);
        make.top.equalTo(@29);
        make.left.equalTo(@24);
    }];
    
    UIImageView *bigIcon = [UIImageView new];
    bigIcon.image = IMG(@"大字体icon");
    [self addSubview:bigIcon];
    [bigIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@20);
        make.centerY.equalTo(smallIcon);
        make.right.equalTo(self.mas_right).offset(-20);
    }];
    //滑块图片
    UIImage *thumbImage = IMG(@"滑动icon");
    //左右轨的图片
    _paintSlider = [UISlider new];
    _paintSlider.minimumValue = 10;
    _paintSlider.maximumValue = 30;
    _paintSlider.userInteractionEnabled = YES;
    if (GVUserDe.waterTitleFontSize > 0){
        _paintSlider.value = GVUserDe.waterTitleFontSize;
    }else{
        _paintSlider.value = 16;
    }
    // 设置颜色
    _paintSlider.maximumTrackTintColor = HexColor(@"#282B30");
    _paintSlider.minimumTrackTintColor = [UIColor whiteColor];
    //注意这里要加UIControlStateHightlighted的状态，否则当拖动滑块时滑块将变成原生的控件
    [_paintSlider setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [_paintSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    //滑块拖动时的事件
    [_paintSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_paintSlider];
    _paintSlider.backgroundColor = [UIColor clearColor];
    [_paintSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(smallIcon);
        make.width.equalTo(@(RYRealAdaptWidthValue(264)));
        make.centerX.equalTo(self);
        make.height.equalTo(@30);
    }];
    if (_type == 2){
        for (NSInteger i = 0;  i < 8; i ++) {
            UIButton *fillBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [fillBtn setBackgroundImage:IMG(@"lightIcon") forState:UIControlStateNormal];
            fillBtn.tag = (i + 1) * 100;
            fillBtn.frame = CGRectMake(16 + i * (CUB_WIDTH + 16), 60 , CUB_WIDTH, CUB_WIDTH);
            fillBtn.layer.cornerRadius = CUB_WIDTH / 2;
            fillBtn.layer.masksToBounds = YES;
            [fillBtn addTarget:self action:@selector(fillBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:fillBtn];
        }
    }
    
    for (NSInteger i = 0; i < _colorArray.count; i++) {
        UIButton *colorBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        colorBtn.tag = i;
        colorBtn.backgroundColor = HexColor(self.colorArray[i]);
        colorBtn.frame = CGRectMake(16 + i * (CUB_WIDTH + 16), _type==1?60:110 , CUB_WIDTH, CUB_WIDTH);
        colorBtn.layer.cornerRadius = CUB_WIDTH / 2;
        colorBtn.layer.masksToBounds = YES;
        
        if ([GVUserDe.waterTitleColor isEqualToString:_colorArray[i]] ){
            if (i == 1){
                colorBtn.layer.borderColor = [UIColor redColor].CGColor;
            }else{
                colorBtn.layer.borderColor = [UIColor whiteColor].CGColor;
            }
            colorBtn.layer.borderWidth = 4;
            _selectBtn = colorBtn;
        }
        
        
        [colorBtn addTarget:self action:@selector(colorSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:colorBtn];
    }
    
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [moreBtn setBackgroundImage:IMG(@"更多颜色") forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(more) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:moreBtn];
    [moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@CUB_WIDTH);
        if (_type == 1){
            make.top.equalTo(@60);
        }else{
            make.top.equalTo(@110);
        }
        //make.right.equalTo(self.mas_right).offset(-16);
        make.left.equalTo(@(16 + 7 * (CUB_WIDTH + 16)));
    }];
    
    
}

- (void)colorSelected:(UIButton *)btn {
    if (btn != _selectBtn){
        _selectBtn.layer.borderWidth = 0;
        _selectBtn.layer.borderColor = [UIColor clearColor].CGColor;
        btn.layer.borderWidth = 4;
        if (btn.tag == 0){
            btn.layer.borderColor = [UIColor redColor].CGColor;
        }else{
            btn.layer.borderColor = [UIColor whiteColor].CGColor;
        }
        GVUserDe.waterTitleColor = _colorArray[btn.tag];
        _selectBtn = btn;
        [self.delegate changeWaterFontColor:_colorArray[btn.tag]];
    }
}

-(void)sliderValueChanged:(UISlider *)slider{
    GVUserDe.waterTitleFontSize = (NSInteger)slider.value;
    [self.delegate changeWaterFontSize:GVUserDe.waterTitleFontSize];
}

-(void)more{
    self.moreColorClick();
}

-(void)fillBtnClick:(UIButton *)btn{
    
}

#pragma mark - Getters

//- (NSMutableArray *)colorArray {
//    if (!_colorArray) {
//
//    }
//    return _colorArray;
//}

@end
