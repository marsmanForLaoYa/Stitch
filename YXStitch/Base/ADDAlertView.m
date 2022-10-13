//
//  ADDAlertView.m
//  XWNWS
//
//  Created by xwan-iossdk on 2022/6/18.
//

#import "ADDAlertView.h"
#import "Masonry.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ADDAlertView()

@property (nonatomic, strong) UIView *xwAlertView;
@property (nonatomic, strong) UIImageView *alertImgView;
@property (nonatomic, strong) UIButton *imgBtn;
@property (nonatomic, strong) UIButton *closeBotton;

@end

@implementation ADDAlertView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setAlertUI];
    }
    return self;
}

//- (NSString *)imgStr {
//    return _imgStr?_imgStr:@"";
//}

- (void)setAlertUI {
    
    _xwAlertView = [[UIView alloc] init];
    _xwAlertView.backgroundColor = [UIColor colorWithRed:18/255.0 green:18/255.0 blue:18/255.0 alpha:0.35];
    [self addSubview:_xwAlertView];
    [_xwAlertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
    
    _alertImgView = [[UIImageView alloc] init];
    [_alertImgView sd_setImageWithURL:[NSURL URLWithString:_imgStr]];
    [_xwAlertView addSubview:_alertImgView];
    [_alertImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_xwAlertView);
        make.centerY.equalTo(_xwAlertView);
        make.width.equalTo(@320);
        make.height.equalTo(@305);
    }];
    
    _imgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_imgBtn addTarget:self action:@selector(imgBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [_xwAlertView addSubview:_imgBtn];
    [_imgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(_alertImgView);
    }];
    
    _closeBotton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeBotton setImage:[UIImage imageNamed:@"xw_x"] forState:UIControlStateNormal];
    [_closeBotton addTarget:self action:@selector(xwCloseBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [_xwAlertView addSubview:_closeBotton];
    [_closeBotton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_imgBtn);
        make.top.equalTo(_imgBtn);
        make.width.height.equalTo(@26);
    }];
}

- (void)setImgStr:(NSString *)imgStr {
    [_alertImgView sd_setImageWithURL:[NSURL URLWithString:imgStr]];
}

- (void)setUrlStr:(NSString *)urlStr {
    
    _urlStr = urlStr;
}

- (void)imgBtnAction:(UIButton *)btn {
    
    [self poenWithStr:_urlStr];
}

- (void)poenWithStr:(NSString *)str {
    if ([self isEmpty:str]) {
        return;
    }
    
    if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str] options:@{} completionHandler:nil];
    }else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
}

- (BOOL)isEmpty:(NSString *)str {
    if (str == nil) {
        return YES;
    }
    NSString *tempStr = [NSString stringWithFormat:@"%@",str];
    
    if (!tempStr) {
        return YES;
    }
    if ([tempStr isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (!tempStr.length) {
        return YES;
    }
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedStr = [tempStr stringByTrimmingCharactersInSet:set];
    if (!trimmedStr.length) {
        return YES;
    }
    return NO;
}

- (void)xwCloseBtnAction:(UIButton *)btn {
    [self removeFromSuperview];
}

@end
