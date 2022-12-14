//
//  CheckProView.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/10.
//

#import "CheckProView.h"


@implementation CheckProView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = HexColor(BKGrayColor);
        [self setupViews];
        [self setupLayout];
        
    }
    return self;
}

-(void)setupViews{
    UIImageView *proIMG = [UIImageView new];
    proIMG.image = IMG(@"永久解锁");
    proIMG.userInteractionEnabled = YES;
    [self addSubview:proIMG];
    [proIMG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self);
        make.height.equalTo(@160);
        make.top.equalTo(@-8);
    }];
    
    UIButton *recoverBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [recoverBtn setTitle:@"恢复购买" forState:UIControlStateNormal];
    [recoverBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    recoverBtn.titleLabel.font = Font17;
    [recoverBtn addTarget:self action:@selector(recover:) forControlEvents:UIControlEventTouchUpInside];
    [proIMG addSubview:recoverBtn];
    [recoverBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(proIMG.mas_right).offset(-20);
        make.bottom.equalTo(proIMG);
    }];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelBtn.tag = 1;
    [cancelBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [proIMG addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@40);
        make.top.equalTo(@5);
        make.left.equalTo(@0);
    }];
    
    UIImageView *icon = [UIImageView new];
    icon.image = IMG(@"set关闭");
    [cancelBtn addSubview:icon];
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@15);
        make.left.equalTo(@4);
        make.top.equalTo(@2);
    }];
    
    UIScrollView *scrollView = [UIScrollView new];
    [self addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(proIMG.mas_bottom).offset(20);
        make.width.left.equalTo(self);
        make.height.equalTo(@(self.height - proIMG.height - 100));
    }];
    
    NSArray *arr = @[@"set滚动截图",@"set拼接",@"set布局",@"set删除",@"set水印",@"set带壳"];
    NSArray *titleArr = @[@"滚动截图",@"不限数量拼接",@"所有布局模版",@"一键删除原图",@"自定义水印设置",@"带壳截图"];
    NSArray *subArr = @[@"通过录屏来制作一张长截图",@"图片拼接不再限制数量",@"解锁超过100种布局模板",@"拼接完成后可一键删除原图",@"多种形式的水印，自由设置",@"给你的截图带上设备外壳"];
    scrollView.contentSize = CGSizeMake(self.width, 110 * arr.count);
    for (NSInteger i = 0; i < arr.count ; i ++) {
        UIView *vc = [UIView new];
        vc.backgroundColor = [UIColor whiteColor];
        vc.layer.masksToBounds = YES;
        vc.layer.cornerRadius = 10;
        [scrollView addSubview:vc];
        [vc mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(self.width - 40));
            make.left.equalTo(@20);
            make.height.equalTo(@60);
            make.top.equalTo(@(i * 80));
        }];
        
        UILabel *titleLab = [UILabel new];
        titleLab.font = Font14Bold;
        titleLab.textColor = [UIColor blackColor];
        titleLab.text = titleArr[i];
        [vc addSubview:titleLab];
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@15);
            make.top.equalTo(@14);
        }];
        
        UILabel *subLab = [UILabel new];
        subLab.font = Font12;
        subLab.textColor = [UIColor colorWithHexString:@"#999999"];
        subLab.text = subArr[i];
        [vc addSubview:subLab];
        [subLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(titleLab);
            make.top.equalTo(titleLab.mas_bottom).offset(8);
        }];
        
        UIImageView *icon = [UIImageView new];
        icon.image = IMG(arr[i]);
        [vc addSubview:icon];
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(vc).offset(-20);
            make.centerY.equalTo(vc);
            make.height.width.equalTo(@40);
        }];
    }
    UIView *buyView = [UIView new];
    buyView.backgroundColor = [UIColor whiteColor];
    [self addSubview:buyView];
    [buyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.width.left.equalTo(self);
        make.height.equalTo(@80);
    }];
    UIButton *buyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //这里判断。是否已经是高级用户
    if(![User checkIsVipMember]) {
        [buyBtn setBackgroundColor:[UIColor blackColor]];
        [buyBtn setTitle:@"解锁高级功能" forState:UIControlStateNormal];
        [buyBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [buyBtn setBackgroundColor:HexColor(@"#999999")];
        [buyBtn setTitle:@"你已经是高级用户了" forState:UIControlStateNormal];
    }
    
    [buyBtn setTintColor:[UIColor whiteColor]];
    buyBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    buyBtn.layer.masksToBounds = YES;
    buyBtn.layer.cornerRadius = 4;
    buyBtn.tag = 2;
    [buyView addSubview:buyBtn];
    [buyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(buyView);
        make.height.equalTo(@40);
        make.width.equalTo(@260);
    }];
    
}
-(void)setupLayout{
    
}

-(void)recover:(UIButton *)btn{
    //恢复购买
    if ([User current].isVipAppStore){
        [SVProgressHUD showInfoWithStatus:@"您已恢复购买"];
    }else{
        [SVProgressHUD showInfoWithStatus:@"未查询到您的订阅记录，无法恢复！"];
    }
    
}

-(void)btnClick:(UIButton *)btn{
    [self.delegate cancelClickWithTag:btn.tag];
}

@end
