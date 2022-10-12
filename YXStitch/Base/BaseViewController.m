//
//  BaseViewController.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/9.
//

#import "BaseViewController.h"

@interface BaseViewController ()
@property(nonatomic ,strong) UIApplication *app;
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.toolbar.translucent = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.tabBarController.tabBar.translucent = NO;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName :[UIColor colorWithHexString:@"#202C3D"]}];//title颜色
    //    //2.获取导航栏下面的黑线
    //    self.lineView = [self getLineViewInNavigationBar:self.navigationController.navigationBar];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    [self setupNavItems];
    [self setupViews];
    [self setupLayout];
}

- (void)setupViews{}
- (void)setupLayout{}
- (void)setupNavItems{}

- (void)setNavColorStatus {
//    CGSize size;
//    size.width = SCREEN_WIDTH;
//    size.height = Nav_HEIGHT;
//    UIImage *image = [UIImage imageWithColor:[UIColor whiteColor] andSize:size];
//    [self.navigationController.navigationBar setBackgroundImage:[self scaleToSize:image size:size] forBarMetrics:UIBarMetricsDefault];//导航加背景图片
}

@end
