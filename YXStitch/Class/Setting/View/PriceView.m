//
//  PriceView.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/10.
//

#import "PriceView.h"

@implementation PriceView

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
    NSArray *priceArr = @[@"¥111",@"¥222",@"¥333"];
    NSArray *textArr = @[@"每月",@"每年",@"一次性购买"];
    CGFloat btnWidth = (CGFloat)(SCREEN_WIDTH - 64) / 3;
    for (NSInteger i = 0 ; i < priceArr.count ; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.tag = i;
        [btn addTarget:self action:@selector(buyClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@15);
            make.height.equalTo(@130);
            make.width.equalTo(@(btnWidth));
            make.left.equalTo(@(8 + i * (btnWidth + 8)));
        }];
        
        UILabel *textLab = [UILabel new];
        textLab.textAlignment = NSTextAlignmentCenter;
        textLab.text = textArr[i];
        textLab.font = Font16;
        [btn addSubview:textLab];
        [textLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@27);
            make.width.equalTo(btn);
        }];
        
        UILabel *priceLab = [UILabel new];
        priceLab.textAlignment = NSTextAlignmentCenter;
        priceLab.font = FontBold(21);
        NSMutableAttributedString * attriStr = [[NSMutableAttributedString alloc] initWithString:priceArr[i]];
        [attriStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, 1)];
        priceLab.attributedText = attriStr;
        [btn addSubview:priceLab];
        [priceLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(textLab.mas_bottom).offset(17);
            make.width.equalTo(btn);
        }];
        if (i == 1){
            [btn setBackgroundImage:IMG(@"mainIcon") forState:UIControlStateNormal];
            textLab.textColor = [UIColor whiteColor];
            priceLab.textColor = [UIColor whiteColor];
        }else{
            [btn setBackgroundImage:IMG(@"subsIcon") forState:UIControlStateNormal];
        }
        if(i != 0){
            UILabel *discountLab = [UILabel new];
            UIColor *color = [UIColor colorWithPatternImage:IMG(@"btnIcon")];
            discountLab.font = Font12;
            discountLab.textColor = HexColor(@"#5C3916");
            discountLab.textAlignment = NSTextAlignmentCenter;
            [discountLab setBackgroundColor:color];
            if (i == 1){
                discountLab.text = @"50%优惠";
            }else{
                discountLab.text = @"终生使用";
            }
            [btn addSubview:discountLab];
            [discountLab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@70);
                make.height.equalTo(@18);
                make.centerX.equalTo(btn);
                make.top.equalTo(priceLab.mas_bottom).offset(15);
            }];
        }
    }
}

#pragma mark -- btn触发事件
-(void)buyClick:(UIButton *)btn{
    [self.delegate buyClickWithTag:btn.tag];
}

@end
