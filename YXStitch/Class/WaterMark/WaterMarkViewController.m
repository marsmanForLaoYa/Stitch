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
#import "FullWaterMarkView.h"
@interface WaterMarkViewController ()<UnlockFuncViewDelegate,CheckProViewDelegate,WaterMarkToolBarViewDelegate>
@property (nonatomic ,strong)WaterMarkToolBarView *toolView;
@property (nonatomic ,strong)UnlockFuncView *funcView;
@property (nonatomic ,strong)UIView *bgView;
@property (nonatomic ,strong)CheckProView *checkProView;

@property (nonatomic ,strong)UIImageView *BKIMG;
@property (nonatomic ,strong)UILabel *waterLab;

@end

@implementation WaterMarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"水印";
    [self setupViews];
    [self setupNavItems];

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    XWNavigationController *nav = (XWNavigationController *)self.navigationController;
    [nav addNavBarShadowImageWithColor:[UIColor blackColor]];
    NSDictionary *titleAttr= @{
                                   NSForegroundColorAttributeName:RGB(255, 255, 255),
                                   NSFontAttributeName:[UIFont systemFontOfSize:18]
                                   };
        //设置导航栏标题字体颜色、分割线颜色
    [nav addNavBarTitleTextAttributes:titleAttr barShadowHidden:NO shadowColor:[UIColor blackColor]];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_BKIMG removeAllSubviews];
    XWNavigationController *nav = (XWNavigationController *)self.navigationController;
        [nav addNavBarShadowImageWithColor:RGB(255, 255, 255)];
    NSDictionary *titleAttr= @{
                                   NSForegroundColorAttributeName:RGB(0, 0, 0),
                                   NSFontAttributeName:[UIFont systemFontOfSize:18]
                                   };
        //设置导航栏标题字体颜色、分割线颜色
    [nav addNavBarTitleTextAttributes:titleAttr barShadowHidden:NO shadowColor:RGB(233, 233, 233)];


}
-(void)setupViews{
    MJWeakSelf
    //如果没有则显示默认图片
    _BKIMG = [UIImageView new];
    _BKIMG.image = IMG(@"水印默认图片");
    _BKIMG.layer.masksToBounds = YES;
    [self.view addSubview:_BKIMG];
    [_BKIMG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@300);
        make.centerX.centerY.equalTo(self.view);
    }];
    
    _toolView = [WaterMarkToolBarView new];
    _toolView.delegate = self;
    _toolView.type = 1;
    _toolView.btnClick = ^(NSInteger tag) {
        [weakSelf waterSettingWithTag:tag];
    };
    [self.view addSubview:_toolView];
    [_toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.bottom.equalTo(self.view);
        make.height.equalTo(@80);
    }];
    if (GVUserDe.waterPosition > 0){
        if (GVUserDe.waterPosition == 5){
            //全屏
            [self addFullView];
        }else{
            if (GVUserDe.waterPosition != 1){
                [self addWaterLab];
            }
        }
    }
}

-(void)setupNavItems{
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    saveBtn.tag = 0;
    [saveBtn setBackgroundImage:IMG(@"水印保存") forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc]initWithCustomView:saveBtn];
    self.navigationItem.rightBarButtonItem = saveItem;
    
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 30)];
    leftBtn.tag = 1;
    [leftBtn setImage:IMG(@"stitch_white_back") forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = item;
}

-(void)addFuncView{
    if (_funcView == nil){
        _funcView = [UnlockFuncView new];
        _funcView.delegate = self;
        _funcView.type = 2;
        [self.view addSubview:_funcView];
        [_funcView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    _funcView.hidden = NO;
}
-(void)waterSettingWithTag:(NSInteger )tag{
    [_BKIMG removeAllSubviews];
    if (tag == 5){
        //全屏
        [self addFullView];
    }else{
        [_BKIMG removeAllSubviews];
        if (tag != 1){
            [self addWaterLab];
        }
    }
   
}

#pragma mark ---btnClick && viewDelegateClick
-(void)btnClick:(UIButton *)btn{
    if (btn.tag == 0){
        //判断是否是高级会员
        if(User.checkIsVipMember){
            GVUserDe.waterPosition = _toolView.selectIndex;
            GVUserDe.waterTitle = _toolView.titleBtn.titleLabel.text;
        }else{
            [self addFuncView];
            
        }
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
}

-(void)btnClickWithTag:(NSInteger)tag{
    _funcView.hidden = YES;
    if (tag == 1) {
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
            weakSelf.checkProView.frame = CGRectMake(0, SCREEN_HEIGHT + 100, SCREEN_WIDTH  , weakSelf.checkProView.height);
        } completion:^(BOOL finished) {
            weakSelf.bgView.hidden = YES;
        }];
    }else{
        _checkProView.hidden = YES;
        _checkProView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 550);
        _bgView.hidden = YES;
        [self.navigationController pushViewController:[BuyViewController new] animated:YES];
    }
}
-(void)changeWaterFontSize:(NSInteger)size{
    if (GVUserDe.waterPosition == 5){
        //全屏
        [self addFullView];
  
    }else{
        _waterLab.font = [UIFont systemFontOfSize:size];
    }
}

-(void)changeWaterFontColor:(NSString *)color{
    if (GVUserDe.waterPosition == 5){
        //全屏
        [self addFullView];
    }else{
        _waterLab.textColor = HexColor(color);
    }
}

-(void)changeWaterText:(NSString *)text{
    if (GVUserDe.waterPosition == 5){
        //全屏
        [self addFullView];
    }else{
        _waterLab.text = text;
    }
}
-(void)hintUser{
    [self addFuncView];
}

-(void)addFullView{
    [_BKIMG removeAllSubviews];
    [_BKIMG addSubview:[FullWaterMarkView addWaterMarkView:GVUserDe.waterTitle.length > 0 ? GVUserDe.waterTitle : @"@快捷截长图" andSize:GVUserDe.waterTitleFontSize > 10 ?GVUserDe.waterTitleFontSize : 14 andColor:GVUserDe.waterTitleColor.length >0?GVUserDe.waterTitleColor: @"#D93030"]];
}

-(void)addWaterLab{
    _waterLab = [UILabel new];
    if (GVUserDe.waterTitleColor.length >0){
        _waterLab.textColor = HexColor(GVUserDe.waterTitleColor);
    }else{
        _waterLab.textColor = [UIColor whiteColor];
    }
    
    if (GVUserDe.waterTitle.length > 0){
        _waterLab.text = GVUserDe.waterTitle;
    }else{
        _waterLab.text = @"@快捷截长图";
    }
    if (GVUserDe.waterTitleFontSize > 10){
        _waterLab.font = [UIFont systemFontOfSize:GVUserDe.waterTitleFontSize];
    }else{
        _waterLab.font = Font13;
    }
    [_BKIMG addSubview:_waterLab];
    [_waterLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_BKIMG.mas_bottom).offset(-8);
        if (GVUserDe.waterPosition == 2){
            //水印在左
            make.left.equalTo(@10);
        }else if (GVUserDe.waterPosition == 3){
            //居中
            make.centerX.equalTo(_BKIMG);
        }else{
            //右
            make.right.equalTo(_BKIMG.mas_right).offset(-8);
        }
    }];
}





@end
