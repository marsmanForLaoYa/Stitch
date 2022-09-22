//
//  PreferenceSetViewController.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/10.
//

#import "PreferenceSetViewController.h"
#import "PrefenceSetTableView.h"
#import "UnlockFuncView.h"
#import "BuyViewController.h"
#import "CheckProView.h"
@interface PreferenceSetViewController ()<PrefenceSetTableViewDelegate,UnlockFuncViewDelegate,CheckProViewDelegate>
@property (nonatomic ,strong)PrefenceSetTableView *tabletView;
@property (nonatomic ,strong)UnlockFuncView *funcView;
@property (nonatomic ,strong)CheckProView *checkProView;
@property (nonatomic ,strong)UIView *bgView;
@end

@implementation PreferenceSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"偏好设置";
    [self setupViews];
}

-(void)setupViews{
    _tabletView = [PrefenceSetTableView new];
    _tabletView.delegate = self;
    [self.view addSubview:_tabletView];
    [_tabletView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(Nav_H));
        make.left.width.equalTo(self.view);
        make.height.equalTo(@(SCREEN_HEIGHT - Nav_H));

    }];
}

#pragma mark -- viewDelegate
-(void)autoDeleteSwtichWithTag:(NSInteger)tag{
    _funcView = [UnlockFuncView new];
    _funcView.delegate = self;
    _funcView.type = 1;
    [self.view addSubview:_funcView];
    [_funcView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

-(void)btnClickWithTag:(NSInteger)tag{
    if (tag == 1) {
        [_funcView removeFromSuperview];
        [self.navigationController pushViewController:[BuyViewController new] animated:YES];
    }else{
        //触发购买
        MJWeakSelf
        if (_bgView == nil){
            _bgView = [Tools addBGViewWithFrame:self.view.frame];
            [self.view addSubview:_bgView];
        }else{
            _bgView.hidden = NO;
            [self.view bringSubviewToFront:_bgView];
        }
        if (_checkProView == nil){
            _checkProView = [[CheckProView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 550)];
            _checkProView.delegate = self;
            [self.view addSubview:_checkProView];
        }
        _checkProView.hidden = NO;
        [self.view bringSubviewToFront:_checkProView];
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.checkProView.frame = CGRectMake(0, SCREEN_HEIGHT - weakSelf.checkProView.height, SCREEN_WIDTH , weakSelf.checkProView.height);
        }];
    }
}
-(void)cancelClickWithTag:(NSInteger)tag{
    MJWeakSelf
    if (tag == 1){
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.checkProView.frame = CGRectMake(0, SCREEN_HEIGHT+ 100, SCREEN_WIDTH , weakSelf.checkProView.height);
            weakSelf.bgView.hidden = YES;
        }];
    }else{
        _checkProView.hidden = YES;
        _checkProView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 550);
        _bgView.hidden = YES;
        [self.navigationController pushViewController:[BuyViewController new] animated:YES];
    }
    
}
@end
