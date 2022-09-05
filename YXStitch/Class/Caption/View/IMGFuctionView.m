//
//  IMGFuctionView.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/29.
//

#import "IMGFuctionView.h"

@implementation IMGFuctionView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = HexColor(@"#1A1A1A");
        [self setupViews]; 
    }
    return self;
}
-(void)setupViews{
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.tag = 100;
    [self addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@40);
        make.top.equalTo(@10);
        make.left.equalTo(self);
    }];
    
    UIImageView *cancelIMG = [UIImageView new];
    cancelIMG.image = IMG(@"set关闭");
    [cancelBtn addSubview:cancelIMG];
    [cancelIMG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@12);
        make.centerX.top.equalTo(cancelBtn);
    }];
    
    NSArray *iconArr = @[@"旋转图片",@"水平镜像",@"垂直镜像",@"更换图片",@"删除图片"];
    for (NSInteger i = 0; i < iconArr.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.tag = i;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@(40));
            if ([Tools isIPhoneNotchScreen]){
                make.top.equalTo(@20);
            }else{
                make.centerY.equalTo(self);
            }
            
            if (i <=2){
                if (i == 2){
                    make.centerX.equalTo(self);
                }else{
                    make.right.equalTo(self.mas_centerX).offset(-(30 + (1 - i)* 50));
                }
            }else{
                make.left.equalTo(self.mas_centerX).offset(30 + (i - 3)* 50);
            }
        }];
        
        UIImageView *icon = [UIImageView new];
        icon.image = IMG(iconArr[i]);
        [btn addSubview:icon];
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@22);
            make.centerX.centerY.equalTo(btn);
        }];
        
    }
}

-(void)btnClick:(UIButton *)btn{
    self.btnClick(btn.tag);
}

@end
