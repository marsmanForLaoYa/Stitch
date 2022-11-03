//
//  UnlockFuncView.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/11.
//

#import "UnlockFuncView.h"

@implementation UnlockFuncView
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        
    }
    return self;
}

-(void)layoutSubviews{
    [self setupViews];
    [self setupLayout];
}

-(void)setupViews{
    UIImageView *bkIMG = [UIImageView new];
    NSString *imgStr;
    switch (_type) {
        case 1:
            imgStr = @"一键删除原图";
            break;
        case 2:
            imgStr = @"自定义水印设置";
            break;
        case 3:
            imgStr = @"不限数量";
            break;
        case 4:
            imgStr = @"带壳截图";
            break;
        case 5:
            imgStr = @"layout_view_vip";
            break;
        case 6:
            imgStr = @"滚动截图";
            break;
        default:
            break;
    }
    bkIMG.image = IMG(imgStr);
    bkIMG.userInteractionEnabled = YES;
    [self addSubview:bkIMG];
    [bkIMG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self);
        make.height.equalTo(@222);
        make.width.equalTo(@260);
    }];;
    
    UIButton *buyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//    [buyBtn setBackgroundImage:IMG(@"btnIcon") forState:UIControlStateNormal];
    [buyBtn setBackgroundColor:HexColor(@"#F8E3D8")];
    [buyBtn setTitle:@"解锁高级功能" forState:UIControlStateNormal];
    [buyBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    buyBtn.tag = 1;
    buyBtn.layer.masksToBounds = YES;
    buyBtn.layer.cornerRadius = 10;
    [buyBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bkIMG addSubview:buyBtn];
    [buyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@38);
        make.centerX.equalTo(self);
        make.bottom.equalTo(bkIMG.mas_bottom).offset(-45);
        make.width.equalTo(@((CGFloat)213/375 *SCREEN_WIDTH));
    }];
    
    UIButton *checkBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [checkBtn setTitle:@"查看pro详情" forState:UIControlStateNormal];
    [checkBtn setTitleColor:HexColor(@"#DFCEC3") forState:UIControlStateNormal];
    checkBtn.tag = 2;
    [checkBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bkIMG addSubview:checkBtn];
    [checkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@29);
        make.centerX.equalTo(self);
        make.width.equalTo(@(100));
        make.top.equalTo(buyBtn.mas_bottom).offset(6);
    }];
    
    UIImageView *line = [UIImageView new];
    line.backgroundColor = HexColor(@"#5B665E");
    [checkBtn addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.bottom.equalTo(checkBtn);
        make.width.equalTo(@84);
        make.height.equalTo(@1);
    }];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeBtn setBackgroundImage:IMG(@"圆形取消") forState:UIControlStateNormal];
    closeBtn.tag = 3;
    [closeBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@27);
        make.centerX.equalTo(self);
        make.top.equalTo(bkIMG.mas_bottom).offset(20);
    }];
    
    
}
-(void)setupLayout{
    
}

-(void)btnClick:(UIButton *)btn{
    if (btn.tag == 3) {
        self.hidden = YES;
    }else{
        [self.delegate btnClickWithTag:btn.tag];
    }
}

@end
