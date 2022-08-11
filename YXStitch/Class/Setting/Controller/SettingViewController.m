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

@interface SettingViewController ()<CheckProViewDelegate,SettingTableViewDelegate>
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
            break;
        case 1:
            //水印
            break;
        case 2:
            //主屏幕图标
            [self.navigationController pushViewController:[SelectMainIconViewController new] animated:YES];
            break;
        case 3:
            //urlschemes
            break;
        case 4:
            //去appstore评价
            break;
        case 5:
            //分享给朋友
            break;
        case 6:
            //邮箱
            break;
        case 7:
            //新浪微博
            break;
        default:
            break;
    }
    
}

@end
