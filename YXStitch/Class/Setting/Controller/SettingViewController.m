//
//  SettingViewController.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/10.
//

#import "SettingViewController.h"
#import "PreferenceSetViewController.h"
#import "SettingTableView.h"
#import "CheckProView.h"
#import "BuyViewController.h"
#import "SelectMainIconViewController.h"
#import "URLSchemesViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "WaterMarkViewController.h"
@interface SettingViewController ()<CheckProViewDelegate,SettingTableViewDelegate,MFMailComposeViewControllerDelegate>
@property (nonatomic ,strong)UIView *contentView;
@property (nonatomic ,strong)SettingTableView *tabletView;

@property (nonatomic ,strong)CheckProView *checkProView;
@property (nonatomic ,strong)UIView *bgView;


@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"设置";
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupViews];
}

#pragma mark - UI
-(void)setupViews{
    _contentView = [[UIView alloc]init];
    _contentView.backgroundColor = HexColor(BKGrayColor);
    [self.view addSubview:_contentView];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(self.view);
        make.height.equalTo(@(SCREEN_HEIGHT - Nav_H));
        make.top.equalTo(@(Nav_H));
    }];

    UIImageView *proIMG = [UIImageView new];
    proIMG.image = IMG(@"永久解锁");
    proIMG.userInteractionEnabled = YES;
    [_contentView addSubview:proIMG];
    [proIMG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(20));
        make.left.equalTo(@16);
        make.width.equalTo((@(SCREEN_WIDTH - 32)));
        make.height.equalTo(@140);
    }];
    
    UIButton *checkbtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [checkbtn setTitle:@"查看详情" forState:UIControlStateNormal];
    [checkbtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [checkbtn setBackgroundColor:[UIColor colorWithHexString:@"#F7E3D5 "]];
    checkbtn.layer.masksToBounds = YES;
    checkbtn.layer.cornerRadius = 15;
    checkbtn.titleLabel.font = Font13;
    [checkbtn addTarget:self action:@selector(checkPro) forControlEvents:UIControlEventTouchUpInside];
    [proIMG addSubview:checkbtn];
    [checkbtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@73);
        make.height.equalTo(@30);
        make.bottom.equalTo(proIMG.mas_bottom).offset(-20);
        make.right.equalTo(proIMG.mas_right).offset(-27);
    }];
    
    _tabletView = [SettingTableView new];
    _tabletView.delegate = self;
    [_contentView addSubview:_tabletView];
    [_tabletView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(proIMG.mas_bottom).offset(10);
        make.left.width.equalTo(self.view);
        make.height.equalTo(@(SCREEN_HEIGHT - 170));

    }];
}


#pragma mark -- btn触发事件
-(void)checkPro{
    //触发购买
    MJWeakSelf
    if (_bgView == nil){
        _bgView = [Tools addBGViewWithFrame:self.view.frame];
        [self.view addSubview:_bgView];
    }else{
        _bgView.hidden = NO;
    }
    if (_checkProView == nil){
        _checkProView = [[CheckProView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 550)];
        _checkProView.delegate = self;
        [self.view addSubview:_checkProView];
    }
    _checkProView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.checkProView.frame = CGRectMake(0, SCREEN_HEIGHT - weakSelf.checkProView.height, SCREEN_WIDTH , weakSelf.checkProView.height);
    }];
}

#pragma mark -- viewDelegate
-(void)cancelClickWithTag:(NSInteger)tag{
    MJWeakSelf
    if (tag == 1){
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.checkProView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH , weakSelf.checkProView.height);
            weakSelf.bgView.hidden = YES;
        }];
    }else{
        _checkProView.hidden = YES;
        _checkProView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 550);
        _bgView.hidden = YES;
        [self.navigationController pushViewController:[BuyViewController new] animated:YES];
    }
    
}
-(void)settingClickWithTag:(NSInteger)tag{
    switch (tag) {
        case 0:
            //偏好设置
            [self.navigationController pushViewController:[PreferenceSetViewController new] animated:YES];
            break;
        case 1:
            //水印
            [self.navigationController pushViewController:[WaterMarkViewController new] animated:YES];
            break;
        case 2:
            //主屏幕图标
            [self.navigationController pushViewController:[SelectMainIconViewController new] animated:YES];
            break;
        case 3:
            //urlschemes
            [self.navigationController pushViewController:[URLSchemesViewController new] animated:YES];
            break;
        case 4:
            //去appstore评价
            break;
        case 5:
            //分享给朋友
            [self share];
            break;
        case 6:
            //邮箱
            [self setEmail];
            break;
        case 7:
            //新浪微博
            [self gotoSinaWB];
            break;
        default:
            break;
    }
    
}
-(void)gotoAppStore{
    //appid
    NSInteger apple_id = 121212;
    NSString *str = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%ld",(long)apple_id];
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str] options:@{} completionHandler:nil];
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
    
}


-(void)share{
    //分享的标题
    NSString *textToShare = @"分享给朋友";
    //分享的图片
    //UIImage *imageToShare = _screenshotIMG;
    //分享的url
    NSInteger apple_id = 121212;
    NSString *str = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%ld",(long)apple_id];
    NSURL *urlToShare = [NSURL URLWithString:str];
    NSArray *activityItems = @[textToShare,urlToShare];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll];
    [self presentViewController:activityVC animated:YES completion:nil];
    [SVProgressHUD dismiss];
        
    //分享之后的回调
    activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        if (completed) {
           // NSLog(@"completed");
            //分享 成功
        } else  {
          //  NSLog(@"cancled");
            //分享 取消
        }
    };
}


-(void)setEmail{
    //c方法，填写系统结构体内容，返回值为0，表示成功。
    NSString *messageBody = @"xxxxxx";
    NSArray *toRecipents = [NSArray arrayWithObject:@"394974296@qq.com "];
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:@"我的反馈"];//邮件主题
    [mc setMessageBody:messageBody isHTML:NO];//邮件部分内容
    [mc setToRecipients:toRecipents];//发送地址
    [mc.navigationBar setTintColor:[UIColor whiteColor]];
    if (!mc) {
        return;
    }else{
        [self presentViewController:mc animated:YES completion:NULL];
    }

}

-(void)gotoSinaWB{
    NSURL *url = [NSURL URLWithString:@"sinaweibo://userinfo?uid=2808126020"];
        // 如果已经安装了这个应用,就跳转
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            }else{
                [[UIApplication sharedApplication] openURL:url];
            }
        }else{
            [SVProgressHUD showInfoWithStatus:@"未安装新浪微博无法跳转"];
        }
}

@end
