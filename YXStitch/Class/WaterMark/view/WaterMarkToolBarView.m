//
//  WaterMarkToolBarView.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/16.
//

#import "WaterMarkToolBarView.h"
#import "WaterTitleView.h"
#import "WaterColorSelectView.h"
#import "ColorPlateView.h"

@interface WaterMarkToolBarView()<WaterColorSelectViewDelegate>

@property (nonatomic ,strong)UIView *toolView;
@property (nonatomic ,strong)UIButton *titleBtn;
@property (nonatomic ,strong)WaterTitleView *titleView;
@property (nonatomic ,strong)WaterColorSelectView *colorSelectView;
@property (nonatomic ,strong)ColorPlateView *colorPlateView;

@end


@implementation WaterMarkToolBarView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = HexColor(@"#1A1A1A");
        _selectIndex = GVUserDe.waterPosition;
        NSLog(@"GVUserDe.waterPosition==%ld",GVUserDe.waterPosition);
        [self setupViews];
        [self setupLayout];
        
    }
    return self;
}
- (void)setupViews {
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"选中无水印",@"未选中水印左",@"未选中水印居中",@"未选中水印右",@"未选中水印全屏", nil];
    NSString *str;
    switch (GVUserDe.waterPosition) {
        case 1:
            str = @"选中无水印";
            break;
        case 2:
            str = @"选中水印左";
            break;
        case 3:
            str = @"选中水印居中";
            break;
        case 4:
            str = @"选中水印右";
            break;
        case 5:
            str = @"选中水印全屏";
            break;
        default:
            break;
    }
    arr[GVUserDe.waterPosition - 1] = str;
    _toolView = [UIView new];
    for (NSInteger i = 0 ; i < arr.count ; i ++) {
        UIButton *iconBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        iconBtn.tag = i + 1;
        [iconBtn addTarget:self action:@selector(iconBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_toolView addSubview:iconBtn];
        [iconBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@40);
            make.left.equalTo(@(15 + (50 * i)));
            make.top.equalTo(@6);
        }];
        
        UIImageView *icon = [UIImageView new];
        icon.tag = (i + 1) * 100;
        icon.image = IMG(arr[i]);
        [iconBtn addSubview:icon];
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@28);
            make.centerX.centerY.equalTo(iconBtn);
        }];
        
    }
    _titleBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_titleBtn setBackgroundColor:HexColor(@"#0A58F6")];
    [_titleBtn addTarget:self action:@selector(changeWaterTitle) forControlEvents:UIControlEventTouchUpInside];
    if (GVUserDe.waterTitle.length > 0){
        [_titleBtn setTitle:GVUserDe.waterTitle forState:UIControlStateNormal];
    }else{
        [_titleBtn setTitle:@"@拼图" forState:UIControlStateNormal];
    }
    
    [_titleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _titleBtn.layer.masksToBounds = YES;
    _titleBtn.layer.cornerRadius = 15;
    _titleBtn.titleLabel.font = Font13;
    [self addSubview:_toolView];
    [self addSubview:_titleBtn];
}
- (void)setupLayout {
    [_toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.left.equalTo(self);
        make.width.equalTo(@(SCREEN_WIDTH - 100));
        make.height.equalTo(@50);
    }];
    
//    CGFloat btnWidth = [Tools WidthWithLabelFont:Font13 withLabelHeight:30 AndStr:_titleBtn.titleLabel.text] + 20;
    [_titleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(75));
        make.height.equalTo(@30);
        make.centerY.equalTo(_toolView);
        make.right.equalTo(self.mas_right).offset(-14);
    }];
}

-(UIButton *)titleBtn{
    if (!_titleBtn){
        
    }
    return _titleBtn;
}

-(UIView *)toolView{
    if (!_toolView){
        
    }
    return _toolView;
}


-(void)changeWaterTitle{
    MJWeakSelf
    if (!_titleView){
        _titleView = [WaterTitleView new];
        _titleView.type = 1;
        _titleView.btnClick = ^(NSInteger tag) {
            weakSelf.titleView.hidden = YES;
            if (tag == 1){
                [weakSelf.titleBtn setTitle:weakSelf.titleView.titleTV.text forState:UIControlStateNormal];
                [weakSelf.delegate changeWaterText:weakSelf.titleView.titleTV.text];
                
            }
        };
        [self.superview.window addSubview:_titleView];
        [_titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.superview);
        }];
    }else{
        _titleView.hidden = NO;
    }
}

-(void)iconBtnClick:(UIButton *)btn{
    MJWeakSelf
    if (btn.tag == 1){
        self.btnClick(btn.tag);
    }else{
        if (btn.tag != _selectIndex) {
            UIImageView *findIMG = (UIImageView *)[self viewWithTag:_selectIndex * 100];
            UIImageView *selectIMG = (UIImageView *)[self viewWithTag:btn.tag * 100];
            switch (_selectIndex) {
                case 1:
                    findIMG.image = [UIImage imageNamed:@"选中无水印"];
                    break;
                case 2:
                    findIMG.image = [UIImage imageNamed:@"未选中水印左"];
                    break;
                case 3:
                    findIMG.image = [UIImage imageNamed:@"未选中水印居中"];
                    break;
                case 4:
                    findIMG.image = [UIImage imageNamed:@"未选中水印右"];
                    break;
                case 5:
                    findIMG.image = [UIImage imageNamed:@"未选中水印全屏"];
                    break;
                default:
                    break;
            }
            switch (btn.tag) {
                case 1:
                    selectIMG.image = [UIImage imageNamed:@"选中无水印"];
                    break;
                case 2:
                    selectIMG.image = [UIImage imageNamed:@"选中水印左"];
                    break;
                case 3:
                    selectIMG.image = [UIImage imageNamed:@"选中水印居中"];
                    break;
                case 4:
                    selectIMG.image = [UIImage imageNamed:@"选中水印右"];
                    break;
                case 5:
                    selectIMG.image = [UIImage imageNamed:@"选中水印全屏"];
                    break;
                default:
                    break;
            }
            //保存位置
            _selectIndex = btn.tag;
            GVUserDe.waterPosition = btn.tag;
            self.btnClick(btn.tag);
        }
    }
    
    
    if (btn.tag != 1){
        if (_colorSelectView == nil){
            _colorSelectView = [WaterColorSelectView new];
            _colorSelectView.type = 5;
            _colorSelectView.delegate = self;
            _colorSelectView.moreColorClick = ^{
                [weakSelf addColorPlateView];
            };
            [self.superview addSubview:_colorSelectView];
            [_colorSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.left.equalTo(self);
                make.bottom.equalTo(_toolView.mas_top);
                make.height.equalTo(@120);
            }];
        }else{
            _colorSelectView.hidden = NO;
        }
    }else{
        _colorSelectView.hidden = YES;
    }
    
}


-(void)addColorPlateView{
    MJWeakSelf
    _colorPlateView = [[ColorPlateView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, RYRealAdaptWidthValue(575))];
    [self.superview addSubview:_colorPlateView];
    _colorPlateView.btnClick = ^(NSInteger tag) {
        if (tag == 2) {
            NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:GVUserDe.selectColorArr];
            if (tmpArr.count >= 6) {
                [tmpArr removeFirstObject];
            }
            [tmpArr addObject:weakSelf.colorPlateView.colorLab.text];
            [weakSelf.delegate changeWaterFontColor:weakSelf.colorPlateView.colorLab.text];
            GVUserDe.selectColorArr = tmpArr;
            GVUserDe.waterTitleColor = [GVUserDe.selectColorArr lastObject];
            
        }
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.colorPlateView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH , weakSelf.colorPlateView.height);
        } completion:^(BOOL finished) {
            [weakSelf.colorPlateView removeFromSuperview];
        }];
        
    };
    [self.superview bringSubviewToFront:_colorPlateView];
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.colorPlateView.frame = CGRectMake(0, SCREEN_HEIGHT - weakSelf.colorPlateView.height, SCREEN_WIDTH , weakSelf.colorPlateView.height);
    }];
}

-(void)changeWaterFontSize:(NSInteger)size{
    [self.delegate changeWaterFontSize:size];
}
-(void)changeWaterFontColor:(NSString *)color{
    [self.delegate changeWaterFontColor:color];
}

@end
