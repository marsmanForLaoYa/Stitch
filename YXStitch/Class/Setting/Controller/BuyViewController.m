//
//  BuyViewController.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/10.
//

#import "BuyViewController.h"
#import "PriceView.h"
#import "BuyDetailView.h"
@interface BuyViewController ()<PriceViewDelegate>
@property (nonatomic ,strong)PriceView *priceView;
@property (nonatomic ,strong)BuyDetailView *detailView;
@end

@implementation BuyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"解锁高级功能";
    self.view.backgroundColor = HexColor(@"#f4f4f4");
    [self setupViews];
    [self addPriceView];
    [self addDetailView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    UIColor *color = [UIColor whiteColor];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = dict;
}

-(void)viewWillDisappear:(BOOL)animated{
    UIColor *color = [UIColor blackColor];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = dict;
}

-(void)setupViews{
    UIImageView *bkIMG = [UIImageView new];
    bkIMG.image = IMG(@"付费背景");
    [self.view addSubview:bkIMG];
    [bkIMG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.top.equalTo(self.view);
        make.height.equalTo(@190);
    }];
    
}

-(void)addPriceView{
    _priceView = [PriceView new];
    _priceView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_priceView];
    [_priceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(Nav_H + 20));
        make.left.equalTo(@16);
        make.width.equalTo(@(SCREEN_WIDTH - 32));
        make.height.equalTo(@160);
    }];
   
}

-(void)addDetailView{
    _detailView = [BuyDetailView new];
    [self.view addSubview:_detailView];
    [_detailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_priceView.mas_bottom).offset(20);
        make.width.left.equalTo(_priceView);
        make.height.equalTo(@335);
    }];
}
#pragma mark --viewDelegate
-(void)buyClickWithTag:(NSInteger)tag{
    
}


@end
