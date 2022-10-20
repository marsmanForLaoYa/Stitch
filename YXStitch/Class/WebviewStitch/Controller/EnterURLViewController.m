//
//  EnterURLViewController.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/9.
//

#import "EnterURLViewController.h"
#import "WebViewController.h"

@interface EnterURLViewController ()

@property (nonatomic, strong)UITextView *enterUrlTV;
@property (nonatomic, strong)UIImageView *tipsIMG;

@end

@implementation EnterURLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"网页截图";
    [self setupViews];
}

-(void)setupViews{
    
    [self.view addSubview:[Tools getLineWithFrame:CGRectMake(0, Nav_H, SCREEN_WIDTH, 1)]];
    
    UILabel *lab = [UILabel new];
    lab.text = @"输入网址：";
    [self.view addSubview:lab];
    [lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@16);
        make.top.equalTo(@(Nav_H + 20));
    }];
    
    _enterUrlTV = [UITextView new];
    _enterUrlTV.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
    _enterUrlTV.layer.masksToBounds = YES;
    _enterUrlTV.layer.cornerRadius = 10;
//    _enterUrlTV.text = @"https://www.baidu.com";
    _enterUrlTV.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:_enterUrlTV];
    [_enterUrlTV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@16);
        make.width.equalTo(@(SCREEN_WIDTH - 32));
        make.height.equalTo(@((CGFloat)110 / 667 * SCREEN_HEIGHT));
        make.top.equalTo(lab.mas_bottom).offset(10);
    }];
    
    UILabel *tipsLab = [UILabel new];
    tipsLab.text = @"注：需要输入完整的网页，包括超文本传输安全协议（https://）";
    tipsLab.numberOfLines = 0;
    tipsLab.font = [UIFont systemFontOfSize:14];
    tipsLab.textColor = [UIColor colorWithHexString:@"#666666"];
    [self.view addSubview:tipsLab];
    [tipsLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@16);
        make.top.equalTo(_enterUrlTV.mas_bottom).offset(166);
        make.height.equalTo(@44);
        make.width.equalTo(@(SCREEN_WIDTH - 32));
    }];
    
    UIButton *copyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [copyBtn setTitle:@"剪切板中的网址" forState:UIControlStateNormal];
    [copyBtn setTintColor:[UIColor colorWithHexString:@"#1925c1"]];
    [copyBtn addTarget:self action:@selector(copyStr) forControlEvents:UIControlEventTouchUpInside];
    copyBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:copyBtn];
    [copyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_enterUrlTV.mas_bottom).offset(10);
        make.right.equalTo(@-16);
    }];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [nextBtn setBackgroundColor:[UIColor blackColor]];
    [nextBtn setTintColor:[UIColor whiteColor]];
    [nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    nextBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    nextBtn.layer.masksToBounds = YES;
    nextBtn.layer.cornerRadius = 4;
    [nextBtn addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_enterUrlTV.mas_bottom).offset(250);
        make.height.equalTo(@40);
        make.left.equalTo(@58);
        make.width.equalTo(@(SCREEN_WIDTH - 58 * 2));
    }];
}

#pragma mark ---- btn触发事件
- (void)copyStr{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    _enterUrlTV.text = pasteboard.string;
}

-(void)next{
    //校验网址
    if (_enterUrlTV.text.length > 0) {
        [_enterUrlTV resignFirstResponder];
        if ([Tools urlValidation:_enterUrlTV.text]){
            WebViewController *vc = [WebViewController new];
            vc.urlStr = _enterUrlTV.text;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            //非有效网址
            if (_tipsIMG == nil){
                _tipsIMG = [UIImageView new];
                _tipsIMG.image = [UIImage imageNamed:@"网址无效提示"];
                [self.view addSubview:_tipsIMG];
                [_tipsIMG mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.centerY.equalTo(self.view);
                    make.height.equalTo(@104);
                    make.width.equalTo(@184);
                }];
            }else{
                _tipsIMG.hidden = NO;
            }
            
            MJWeakSelf
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
                //1s后隐藏试图
                weakSelf.tipsIMG.hidden = YES;
            });

        }
    }else{
        [SVProgressHUD showInfoWithStatus:@"网址不能为空!"];
    }
    
}



@end
