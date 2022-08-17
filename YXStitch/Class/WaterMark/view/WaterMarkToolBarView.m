//
//  WaterMarkToolBarView.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/16.
//

#import "WaterMarkToolBarView.h"
@interface WaterMarkToolBarView()

@property (nonatomic ,strong)UIView *toolView;
@property (nonatomic ,strong)UIButton *titleBtn;


@end


@implementation WaterMarkToolBarView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = HexColor(@"#1A1A1A");
        _selectIndex = GVUserDe.waterPosition;
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
            str = @"未选中水印全屏";
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
    [_titleBtn setTitle:@"@拼图" forState:UIControlStateNormal];
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
    
    [_titleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@73);
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
    
}

-(void)iconBtnClick:(UIButton *)btn{
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
        
    }
}


@end
