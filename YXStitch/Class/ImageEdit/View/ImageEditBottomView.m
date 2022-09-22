//
//  ImageEditBottomView.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/9/21.
//

#import "ImageEditBottomView.h"

@implementation ImageEditBottomView
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = HexColor(@"#1A1A1A");
        [self setupViews];
    }
    return self;
}

-(void)setupViews{
    NSArray *iconArr = @[@"标注",@"边框",@"套壳",@"水印"];
    CGFloat btnWidth = SCREEN_WIDTH / iconArr.count;
    for (NSInteger i = 0; i < iconArr.count ; i ++ ) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i + 1;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(btnWidth));
            make.height.top.equalTo(self);
            make.left.equalTo(@(i * btnWidth));
        }];
        
        UIImageView *icon = [UIImageView new];
        NSString *iconStr = [NSString stringWithFormat:@"%@_icon",iconArr[i]];
        icon.image = IMG(iconStr);
        [btn addSubview:icon];
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@22);
            make.top.equalTo(@22);
            make.centerX.equalTo(btn);
        }];
        
        UILabel *iconLab = [UILabel new];
        iconLab.textColor = [UIColor whiteColor];
        iconLab.font = Font12;
        iconLab.text = iconArr[i];
        iconLab.textAlignment = NSTextAlignmentCenter;
        [btn addSubview:iconLab];
        [iconLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.left.equalTo(btn);
            make.top.equalTo(icon.mas_bottom).offset(8);
        }];
    }
}

-(void)btnClick:(UIButton *)btn{
    self.btnClick(btn.tag);
}
@end
