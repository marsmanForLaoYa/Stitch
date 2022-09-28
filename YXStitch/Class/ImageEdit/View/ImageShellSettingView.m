//
//  ImageShellSettingView.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/9/27.
//

#import "ImageShellSettingView.h"

@implementation ImageShellSettingView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

-(void)layoutSubviews{
    [self setupViews];
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
    NSArray *iconArr;
    if (_isVer){
        iconArr = @[@"套壳横竖_selected",@"套壳背景_unSelected",@"套壳刘海_unSelected"];
    }else{
        iconArr = @[@"套壳横竖_unSelected",@"套壳背景unSelected",@"套壳刘海_unSelected"];
    }
    for (NSInteger i = 0; i < iconArr.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i + 1;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:IMG(iconArr[i]) forState:UIControlStateNormal];
        [contentView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@40);
            make.left.equalTo(@(25 + i * 50));
            make.top.equalTo(@10);
        }];
        if (i == 0){
            _selectBtn = btn;
        }
    }
    
    UIButton *phoneTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [phoneTypeBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    phoneTypeBtn.tag = 0;
    [phoneTypeBtn setBackgroundImage:IMG(@"机型背景") forState:UIControlStateNormal];
    [contentView addSubview:phoneTypeBtn];
    [phoneTypeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@160);
        make.height.equalTo(@33);
        make.top.equalTo(@15);
        make.right.equalTo(contentView.mas_right).offset(-25);
    }];
    
    _phoneTypeLab = [UILabel new];
    _phoneTypeLab.textColor = [UIColor whiteColor];
    _phoneTypeLab.text = [Tools getIphoneType];
    _phoneTypeLab.font = Font13;
    [phoneTypeBtn addSubview:_phoneTypeLab];
    [_phoneTypeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@110);
        make.left.equalTo(@14);
        make.centerY.equalTo(phoneTypeBtn);
    }];
    
    _phoneBKIMG = [UIImageView new];
    _phoneBKIMG.layer.masksToBounds = YES;
    _phoneBKIMG.layer.cornerRadius = 8;
    _phoneBKIMG.backgroundColor = HexColor(@"#91918C");
    [phoneTypeBtn addSubview:_phoneBKIMG];
    [_phoneBKIMG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@16);
        make.centerY.equalTo(_phoneTypeLab);
        make.right.equalTo(phoneTypeBtn.mas_right).offset(-8);
    }];
    
    
}
-(void)btnClick:(UIButton *)btn{
    if (btn.tag == 0){
        self.btnClick(btn.tag);
    }else{
        if (_selectBtn != btn){
            switch (btn.tag) {
                case 1:
                    if (_isVer){
                        [btn setImage:IMG(@"套壳横竖_selected") forState:UIControlStateNormal];
                    }else{
                        [btn setImage:IMG(@"套壳横竖_unSelected") forState:UIControlStateNormal];
                    }
                    
                    break;
                case 2:
                    [btn setImage:IMG(@"套壳背景_selected") forState:UIControlStateNormal];
                    break;
                case 3:
                    [btn setImage:IMG(@"套壳刘海_selected") forState:UIControlStateNormal];
                default:
                    break;
            }
            switch (_selectBtn.tag) {
                case 1:
                    if (_isVer){
                        [_selectBtn setImage:IMG(@"套壳横竖_unSelected") forState:UIControlStateNormal];
                        
                    }else{
                        [_selectBtn setImage:IMG(@"套壳横竖_selected") forState:UIControlStateNormal];
                    }
                    
                    break;
                case 2:
                    [_selectBtn setImage:IMG(@"套壳背景_unSelected") forState:UIControlStateNormal];
                    break;
                case 3:
                    [_selectBtn setImage:IMG(@"套壳刘海_unSelected") forState:UIControlStateNormal];
                    break;
                default:
                    break;
            }
            _selectBtn = btn;
            self.btnClick(btn.tag);
        }
    }
    
}
@end
