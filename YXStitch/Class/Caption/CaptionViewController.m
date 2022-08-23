//
//  CaptionViewController.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/19.
//

#import "CaptionViewController.h"
#import "UnlockFuncView.h"
#import "CheckProView.h"
#import "BuyViewController.h"
#import "CaptionBottomView.h"

@interface CaptionViewController ()<UnlockFuncViewDelegate,CheckProViewDelegate>
@property (nonatomic ,strong)UnlockFuncView *funcView;
@property (nonatomic ,strong)UIView *bgView;
@property (nonatomic ,strong)CheckProView *checkProView;
@property (nonatomic ,strong)UISlider *topSlider;
@property (nonatomic ,strong)UISlider *bottomSlider;
@property (nonatomic ,strong)CaptionBottomView *bottomView;
@property (nonatomic ,assign)CGFloat topCurrentValue;
@property (nonatomic ,assign)CGFloat bottomCurrentValue;
@property (nonatomic ,strong)NSMutableArray *originTopArr;
@property (nonatomic ,strong)NSMutableArray *originBottomArr;
@end

@implementation CaptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.title = [NSString stringWithFormat:@"%ld张图片",_dataArr.count];
    _originTopArr = [NSMutableArray array];
    _originBottomArr = [NSMutableArray array];
    _topCurrentValue = 0;
    [self setupViews];
    [self setupNavItems];
    [self addBottomView];

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (@available(iOS 15.0, *)) {
        [Tools setNaviBarBKColorWith:self.navigationController andBKColor:[UIColor blackColor] andFontColor:[UIColor whiteColor]];
    }else{
        UIColor *color = [UIColor whiteColor];
        NSDictionary *dict = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
        self.navigationController.navigationBar.titleTextAttributes = dict;
    }
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    UIColor *color = [UIColor blackColor];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [Tools setNaviBarBKColorWith:self.navigationController andBKColor:[UIColor whiteColor] andFontColor:[UIColor blackColor]];
}

-(void)setupViews{
    UIScrollView *sc = [UIScrollView new];
    sc.backgroundColor = [UIColor clearColor];
    [self.view addSubview:sc];
    [sc mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(RYRealAdaptWidthValue(300)));
        make.centerX.top.equalTo(self.view);
        make.height.equalTo(@(SCREEN_HEIGHT - 80 - Nav_H));
    }];
    CGFloat totalHeight = 0.0 ;
    for (NSInteger i = 0; i < _dataArr.count; i ++) {
        UIImageView *img = [UIImageView new];
        UIImage *icon = _dataArr[i];
        img.tag = i * 100;
        img.layer.zPosition =  (_dataArr.count - i) * 100;
        img.image = icon;
        [sc addSubview:img];
        if (i == 0){
            totalHeight += Nav_H;
        }else{
            totalHeight += (CGFloat)(icon.size.height/icon.size.width) * 300 ;
        }
        [img mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@300);
            make.height.equalTo(@((CGFloat)(icon.size.height/icon.size.width) * 300));
            make.centerX.equalTo(sc);
            make.top.equalTo(@(totalHeight));
        }];
        NSNumber *numTop = [NSNumber numberWithFloat:totalHeight];
        [_originTopArr addObject:numTop];
        
    }
    sc.contentSize = CGSizeMake(sc.width,totalHeight + 200);
    UIImageView *adjustView = [UIImageView new];
    adjustView.userInteractionEnabled = YES;
    adjustView.image = IMG(@"调整背景");
    [self.view addSubview:adjustView];
    [self.view bringSubviewToFront:adjustView];
    [adjustView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@28);
        make.centerY.equalTo(self.view);
        make.height.equalTo(@300);
        make.right.equalTo(sc.mas_right).offset(-20);
    }];
    
    for (NSInteger i = 0; i < 1; i ++) {
        //滑块图片
        UIImage *thumbImage = IMG(@"调整icon");
        //左右轨的图片
        UISlider *paintSlider = [UISlider new];;
        if (i == 0){
            // 设置颜色
            paintSlider.minimumValue = 1;
            paintSlider.maximumValue = 150;
            paintSlider.maximumTrackTintColor = HexColor(@"#282B30");
            paintSlider.minimumTrackTintColor = [UIColor whiteColor];
            paintSlider.value = 1;
            paintSlider.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
        }else{
            // 设置颜色
            paintSlider.maximumTrackTintColor = [UIColor whiteColor];
            paintSlider.minimumTrackTintColor = HexColor(@"#282B30");
            paintSlider.minimumValue = 1;
            paintSlider.maximumValue = 50;
            paintSlider.value = 100;
            paintSlider.transform = CGAffineTransformMakeRotation(M_PI * 1.5);
        }
        paintSlider.userInteractionEnabled = YES;
        
        //注意这里要加UIControlStateHightlighted的状态，否则当拖动滑块时滑块将变成原生的控件
        [paintSlider setThumbImage:thumbImage forState:UIControlStateHighlighted];
        [paintSlider setThumbImage:thumbImage forState:UIControlStateNormal];
        //滑块拖动时的事件
        paintSlider.tag = i;
        [paintSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [adjustView addSubview:paintSlider];
        paintSlider.backgroundColor = [UIColor clearColor];
        [paintSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(240));
            make.centerX.equalTo(adjustView);
            make.height.equalTo(@28);
            make.top.equalTo(@140);
        }];
    }
}

-(void)addBottomView{
    MJWeakSelf
    _bottomView = [CaptionBottomView new];
    _bottomView.btnClick = ^(NSInteger tag) {
        [weakSelf bottomBtnClick:tag];
    };
    [self.view addSubview:_bottomView];
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.bottom.equalTo(self.view);
        make.height.equalTo(@80);
    }];
}

-(void)bottomBtnClick:(NSInteger )tag{
    
}

-(void)sliderValueChanged:(UISlider *)slider{
    for (NSInteger i = 1 ; i < _dataArr.count ; i ++) {
        UIImageView *findIMG = (UIImageView *)[self.view viewWithTag:i * 100];
        CGFloat top =  [_originTopArr[i] floatValue];
        CGFloat height = findIMG.height;
        CGFloat nextHeight = 0;
        if (i > 1) {
            nextHeight = top - slider.value * i;
        }else{
            nextHeight = top - slider.value;
        }
        [findIMG mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@300);
            make.height.equalTo(@(height));
            make.centerX.equalTo(self.view);
            make.top.equalTo(@(nextHeight));
        }];
        _topCurrentValue = slider.value;
    }
}

-(void)setupNavItems{
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    saveBtn.tag = 0;
    [saveBtn setBackgroundImage:IMG(@"水印保存") forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(checkBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc]initWithCustomView:saveBtn];
    self.navigationItem.rightBarButtonItem = saveItem;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    leftBtn.tag = 1;
   // [leftBtn setBackgroundImage:IMG(@"白色返回") forState:UIControlStateNormal];
    leftBtn.titleLabel.font = Font18;
    [leftBtn setTitle:@"返回" forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(checkBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = item;
}

#pragma mark ---btnClick && viewDelegateClick
-(void)checkBtnClick:(UIButton *)btn{
    if (btn.tag == 0){
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
    }else{
        
        [self.navigationController popViewControllerAnimated:YES];
    }
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
