//
//  ImageBorderSettingView.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/9/27.
//

#import "ImageBorderSettingView.h"

@implementation ImageBorderSettingView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupViews];
    }
    return self;
}

-(void)setupViews{
    
    UIView *cancelView = [UIView new];
    cancelView.backgroundColor = [UIColor clearColor];
    [self addSubview:cancelView];
    [cancelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.width.equalTo(self);
        make.height.equalTo(@20);
    }];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.tag = 0;
    [cancelBtn setBackgroundColor:HexColor(@"#0D0D0D")];
    cancelBtn.layer.cornerRadius = 4;
    cancelBtn.layer.masksToBounds = YES;
    [cancelView addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@40);
        make.height.equalTo(@20);
        make.right.equalTo(cancelView.mas_right).offset(-37);
        make.top.equalTo(@2);
    }];
    
    UIImageView *cancelIMG = [UIImageView new];
    cancelIMG.image = IMG(@"set关闭");
    [cancelBtn addSubview:cancelIMG];
    [cancelIMG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@12);
        make.centerY.centerX.equalTo(cancelBtn);
    }];
    
    
    UIView *contentView = [UIView new];
    contentView.backgroundColor = HexColor(@"#1A1A1A");
    [self addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(cancelView);
        make.top.equalTo(cancelView.mas_bottom);
        make.height.equalTo(@80);
    }];
    
    UIView *btnView = [UIView new];
    btnView.backgroundColor = [UIColor clearColor];
    [contentView addSubview:btnView];
    [btnView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@210);
        make.height.equalTo(@30);
        make.centerX.equalTo(contentView);
        make.top.equalTo(@20);
    }];
    
    NSArray *iconArr = @[@"无边框_selected",@"内边框_unSelected",@"外边框_unSelected",@"全边框_unSelected"];
    for (NSInteger i = 0; i < iconArr.count ; i ++ ) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i + 1;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:IMG(iconArr[i]) forState:UIControlStateNormal];
        [btnView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@40);
            make.left.equalTo(@(i * 60));
        }];
        if (i == 0){
            _selectBtn = btn;
        }
    }
}

-(void)btnClick:(UIButton *)btn{
    if (_selectBtn != btn){
        switch (btn.tag) {
            case 1:
                [btn setImage:IMG(@"无边框_selected") forState:UIControlStateNormal];
                break;
            case 2:
                [btn setImage:IMG(@"内边框_selected") forState:UIControlStateNormal];
                break;
            case 3:
                [btn setImage:IMG(@"外边框_selected") forState:UIControlStateNormal];
            case 4:
                [btn setImage:IMG(@"全边框_selected") forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        switch (_selectBtn.tag) {
            case 1:
                [_selectBtn setImage:IMG(@"无边框_unSelected") forState:UIControlStateNormal];
                break;
            case 2:
                [_selectBtn setImage:IMG(@"内边框_unSelected") forState:UIControlStateNormal];
                break;
            case 3:
                [_selectBtn setImage:IMG(@"外边框_unSelected") forState:UIControlStateNormal];
                break;
            case 4:
                [_selectBtn setImage:IMG(@"全边框_unSelected") forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        _selectBtn = btn;
        self.btnClick(btn.tag);
    }
}

@end
