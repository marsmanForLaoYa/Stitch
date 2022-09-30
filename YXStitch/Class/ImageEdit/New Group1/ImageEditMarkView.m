//
//  ImageEditBottomView.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/9/20.
//

#import "ImageEditMarkView.h"

@implementation ImageEditMarkView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        //[self setupViews];
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
    
    NSArray *imgIconArr = @[@"空心填充框_unSelected",@"实心填充框_unSelected",@"马赛克_unSelected",@"箭头_unSelected",@"画笔_unSelected",@"文字_unSelected"];
    NSArray *funcArr = @[@"撤销_unSelected",@"删除垃圾桶_unSelected"];
    for (NSInteger i = 0; i < imgIconArr.count ; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i + 1;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:IMG(imgIconArr[i]) forState:UIControlStateNormal];
        [contentView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(22 + i *43));
            make.centerY.equalTo(contentView);
            make.width.height.equalTo(@22);
        }];
    }
    
    for (NSInteger i = 0 ; i < funcArr.count ; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = (i + 1) * 100;
        [btn addTarget:self action:@selector(funcClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:IMG(funcArr[1-i]) forState:UIControlStateNormal];
        [contentView addSubview:btn];
        if (i == 0){
            _deleteBtn = btn;
        }else{
            _backBtn = btn;
        }
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(contentView);
            make.width.height.equalTo(@27);
            make.right.equalTo(contentView.mas_right).offset(-(i * 55 + 28));
        }];
    }
 
}

-(void)funcClick:(UIButton *)btn{
    self.btnClick(btn.tag);
}

-(void)btnClick:(UIButton *)btn{
    if (_selectBtn != btn){
        switch (btn.tag) {
            case 1:
                [btn setImage:IMG(@"空心填充框_selected") forState:UIControlStateNormal];
                break;
            case 2:
                [btn setImage:IMG(@"实心填充框_selected") forState:UIControlStateNormal];
                break;
            case 3:
                [btn setImage:IMG(@"马赛克_selected") forState:UIControlStateNormal];
                break;
            case 4:
                [btn setImage:IMG(@"箭头_selected") forState:UIControlStateNormal];
                break;
            case 5:
                [btn setImage:IMG(@"画笔_selected") forState:UIControlStateNormal];
                break;
            case 6:
                [btn setImage:IMG(@"文字_selected") forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        switch (_selectBtn.tag) {
            case 1:
                [_selectBtn setImage:IMG(@"空心填充框_unSelected") forState:UIControlStateNormal];
                break;
            case 2:
                [_selectBtn setImage:IMG(@"实心填充框_unSelected") forState:UIControlStateNormal];
                break;
            case 3:
                [_selectBtn setImage:IMG(@"马赛克_unSelected") forState:UIControlStateNormal];
                break;
            case 4:
                [_selectBtn setImage:IMG(@"箭头_unSelected") forState:UIControlStateNormal];
                break;
            case 5:
                [_selectBtn setImage:IMG(@"画笔_unSelected") forState:UIControlStateNormal];
                break;
            case 6:
                [_selectBtn setImage:IMG(@"文字_unSelected") forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        _selectBtn = btn;
        self.btnClick(btn.tag);
    }
    
}


@end
