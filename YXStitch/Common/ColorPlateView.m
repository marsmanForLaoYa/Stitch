//
//  ColorPlateView.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/17.
//

#import "ColorPlateView.h"
#import "RGBColorSlider.h"
#import "RGBColorSliderDelegate.h"

@interface ColorPlateView ()<RGBColorSliderDataOutlet>
@property (nonatomic ,strong)UIView *colorView;
@property (nonatomic ,strong)RGBColorSlider *redSlider;
@property (nonatomic ,strong)RGBColorSlider *greenSlider;
@property (nonatomic ,strong)RGBColorSlider *blueSlider;


@property (nonatomic ,strong)UILabel *redLab;
@property (nonatomic ,strong)UILabel *greenLab;
@property (nonatomic ,strong)UILabel *blueLab;
@end

@implementation ColorPlateView
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupViews];
        [self setupLayout];    
    }
    return self;
}

-(void)setupViews{
    MJWeakSelf
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelBtn.tag = 1;
    [cancelBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@40);
        make.left.top.equalTo(self);
    }];
    
    UIImageView *canIcon = [UIImageView new];
    canIcon.image = IMG(@"取消");
    [cancelBtn addSubview:canIcon];
    [canIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(cancelBtn);
        make.width.height.equalTo(@14);
    }];
    
    _colorView = [UIView new];
    _colorView.backgroundColor = HexColor(@"#E35AF6");
    _colorView.layer.masksToBounds = YES;
    _colorView.layer.cornerRadius = 75;
    [self addSubview:_colorView];
    [_colorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@150);
        make.centerX.equalTo(self);
        make.top.equalTo(@55);
    }];
    
    _colorLab = [UILabel new];
    _colorLab.text = [Tools HexStringWithColor:_colorView.backgroundColor HasAlpha:NO];
    _colorLab.font = Font18;
    _colorLab.textColor = [UIColor blackColor];
    [self addSubview:_colorLab];
    [_colorLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(_colorView.mas_bottom).offset(10);
    }];
    
    RGBColorSliderDelegate *delegate = [[RGBColorSliderDelegate alloc] init];
    delegate.delegate = self;

    _redSlider = [[RGBColorSlider alloc] initWithFrame:CGRectMake(20, 265, RYRealAdaptWidthValue(280), 24) sliderColor:RGBColorTypeRed trackHeight:10 delegate:delegate];
    _greenSlider = [[RGBColorSlider alloc] initWithFrame:CGRectMake(20, _redSlider.bottom + 36, _redSlider.width, _redSlider.height) sliderColor:RGBColorTypeGreen trackHeight:10 delegate:delegate];
    _blueSlider = [[RGBColorSlider alloc] initWithFrame:CGRectMake(20, _greenSlider.bottom + 36, _redSlider.width, _redSlider.height) sliderColor:RGBColorTypeBlue trackHeight:10 delegate:delegate];
    [self addSubview:_redSlider];
    [self addSubview:_greenSlider];
    [self addSubview:_blueSlider];
    
    for (NSInteger i = 0; i < 3; i ++) {
        UILabel *lab = [UILabel new];
        lab.textColor = HexColor(@"#121212");
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = Font15;
        [self addSubview:lab];
        [lab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).offset(-16);
            make.width.equalTo(@80);
            if (i == 0){
                make.centerY.equalTo(weakSelf.redSlider);
                lab.text = [NSString stringWithFormat:@"R：%ld",(NSInteger)weakSelf.redSlider.value];
                weakSelf.redLab = lab;
            }else if (i == 1){
                make.centerY.equalTo(weakSelf.greenSlider);
                lab.text = [NSString stringWithFormat:@"G：%ld",(NSInteger)weakSelf.greenSlider.value];
                weakSelf.greenLab = lab;
            }else{
                make.centerY.equalTo(weakSelf.blueSlider);
                lab.text = [NSString stringWithFormat:@"B：%ld",(NSInteger)weakSelf.blueSlider.value];
                weakSelf.blueLab = lab;
            }
        }];
    }
    
    UILabel *tipsLab = [UILabel new];
    tipsLab.text = @"我匹配过的颜色：";
    tipsLab.font = Font15;
    tipsLab.textColor = HexColor(@"#121212");
    [self addSubview:tipsLab];
    [tipsLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_redSlider);
        make.top.equalTo(_blueSlider.mas_bottom).offset(42);
    }];
    
    for (NSInteger i = 0 ; i < GVUserDe.selectColorArr.count; i ++) {
        UIButton *iconBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        iconBtn.layer.masksToBounds = YES;
        iconBtn.layer.cornerRadius = 14;
        iconBtn.tag = i;
        iconBtn.backgroundColor = HexColor(GVUserDe.selectColorArr[i]);
        [iconBtn addTarget:self action:@selector(iconBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:iconBtn];
        [iconBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@28);
            make.left.equalTo(@(40 + i * 56));
            make.top.equalTo(tipsLab.mas_bottom).offset(16);
        }];
    }
    
    NSArray *arr = @[@"颜色取消",@"颜色确定"];
    for (NSInteger i = 0 ; i < arr.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.tag = i + 1;
        [btn setBackgroundImage:IMG(arr[i]) forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@100);
            make.height.equalTo(@40);
            make.bottom.equalTo(self.mas_bottom).offset(-16);
            if (i == 0) {
                make.left.equalTo(@35);
            }else{
                make.right.equalTo(self.mas_right).offset(-35);
            }
        }];
    }
    
}



-(void)setupLayout{
    
}

-(void)iconBtnClick :(UIButton *)btn{
    _colorView.backgroundColor = btn.backgroundColor;
    _colorLab.text = [Tools HexStringWithColor:btn.backgroundColor HasAlpha:NO];
}

-(void)btnClick:(UIButton *)btn{
    self.btnClick(btn.tag);
}

-(void)updateColor:(UIColor *)color{
    _colorView.backgroundColor = color;
    _redLab.text = [NSString stringWithFormat:@"R：%ld",(NSInteger)(_redSlider.value * 255)];
    _greenLab.text = [NSString stringWithFormat:@"G：%ld",(NSInteger)(_greenSlider.value * 255)];
    _blueLab.text = [NSString stringWithFormat:@"B：%ld",(NSInteger)(_blueSlider.value * 255)];
    _colorLab.text = [Tools HexStringWithColor:color HasAlpha:NO];
}


@end
