//
//  WaterMarkViewController.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/16.
//

#import "WaterMarkViewController.h"
#import "WaterMarkToolBarView.h"
#import "UnlockFuncView.h"
#import "BuyViewController.h"
#import "CheckProView.h"
@interface WaterMarkViewController ()<UnlockFuncViewDelegate,CheckProViewDelegate>
@property (nonatomic ,strong)WaterMarkToolBarView *toolView;
@property (nonatomic ,strong)UnlockFuncView *funcView;
@property (nonatomic ,strong)CheckProView *checkProView;
@property (nonatomic ,strong)UIView *bgView;
@end

@implementation WaterMarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"水印";
    [self setupViews];
    [self setupNavItems];
}
-(void)setupViews{
    //如果没有则显示默认图片
    UIImageView *defaultIMG = [UIImageView new];
    defaultIMG.image = IMG(@"水印默认图片");
    if (_waterIMG){
        
    }else{
        
    }
    [self.view addSubview:defaultIMG];
    [defaultIMG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@300);
        make.centerX.centerY.equalTo(self.view);
    }];
    
    _toolView = [WaterMarkToolBarView new];
    [self.view addSubview:_toolView];
    [_toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.bottom.equalTo(self.view);
        make.height.equalTo(@80);
    }];
}

-(void)setupNavItems{
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [saveBtn setBackgroundImage:[UIImage imageNamed:@"水印保存"] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc]initWithCustomView:saveBtn];
    self.navigationItem.rightBarButtonItem = saveItem;
}

-(void)rightBtnClick{
    //判断是否是高级会员
    _funcView = [UnlockFuncView new];
    _funcView.delegate = self;
    _funcView.type = 2;
    [self.view addSubview:_funcView];
    [_funcView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
//    if(GVUserDe.isMember){
//        GVUserDe.waterPosition = _toolView.selectIndex;
//    }else{
//
//    }
    
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



@end
