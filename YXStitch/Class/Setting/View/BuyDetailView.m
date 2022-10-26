//
//  BuyDetailView.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/10.
//

#import "BuyDetailView.h"

@implementation BuyDetailView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 10;
        [self setupViews];
    }
    return self;
}

-(void)setupViews{
    UILabel *tipsLab = [UILabel new];
    tipsLab.text = @"订阅高级版";
    tipsLab.textColor = HexColor(@"#43429C");
    tipsLab.font = Font15;
    [self addSubview:tipsLab];
    [tipsLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(@21);
    }];
    
    UIImageView *left = [UIImageView new];
    left.image = IMG(@"leftIcon");
    [self addSubview:left];
    [left mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@54);
        make.height.equalTo(@2);
        make.centerY.equalTo(tipsLab);
        make.right.equalTo(tipsLab.mas_left).offset(-7);
    }];
    
    UIImageView *right = [UIImageView new];
    right.image = IMG(@"rightIcon");
    [self addSubview:right];
    [right mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.centerY.equalTo(left);
        make.left.equalTo(tipsLab.mas_right).offset(7);
    }];
    UIView *iconView = [UIView new];
    [self addSubview:iconView];
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipsLab.mas_bottom).offset(21);
        make.left.equalTo(@24);
        make.width.equalTo(@(SCREEN_WIDTH - 24 - 48));
        make.height.equalTo(@80);
    }];
    

    NSArray *arr = @[@"付费高级",@"付费更多",@"付费无限"];
    NSArray *textArr = @[@"拼图高级版",@"享受未来更多\n高级用户专属功能",@"全部功能无限使用"];
    for (NSInteger i = 0; i < arr.count ; i ++) {
        UIImageView *icon = [UIImageView new];
        icon.image = IMG(arr[i]);
        [iconView addSubview:icon];
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@44);
            make.top.equalTo(@4);
            if (i == 0){
                make.left.equalTo(@20);
            }else if (i == 1){
                make.centerX.equalTo(iconView);
            }else{
                make.right.equalTo(iconView.mas_right).offset(-20);
            }
        }];
        
        UILabel *iconLab = [UILabel new];
        iconLab.text = textArr[i];
        iconLab.textAlignment = NSTextAlignmentCenter;
        iconLab.numberOfLines = 0;
        iconLab.font = Font12;
        iconLab.textColor = HexColor(@"#212435");
        [iconView addSubview:iconLab];
        [iconLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(icon);
            make.top.equalTo(icon.mas_bottom).offset(8);
        }];
    }
    
    UILabel *driLab = [UILabel new];
    driLab.text = @"若您选择「订阅」购买模式，在订阅前，请知悉以下内容:\n\n费用将在确认购买后、免费试用期结束时正式开始从 iTunes 帐户扣除·订阅是自动续期的服务，若不打算续期，请在当前计费周期结束前至少24小时手动关闭·续期的费用将在当前周期结束前的24小时内扣除·订阅后可以在 App Store的账户里提供的「订阅」入口进行管理续费周期等操作·提供7天免费试用，免费试用期间，任何未使用天数，将在用户购买该服务后被没收";
    driLab.font = Font(12);
    driLab.textColor = HexColor(@"#BBBBBB");
    driLab.numberOfLines = 0;
    [self addSubview:driLab];
    [driLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@12);
        make.width.equalTo(@(SCREEN_WIDTH - 48));
        make.height.equalTo(@(140));
        make.top.equalTo(iconView.mas_bottom).offset(30);
    }];
}

@end
