//
//  KSViewController.m
//  SkyMeeting
//
//  Created by xiaobin Tang on 2020/4/14.
//  Copyright © 2020 xiaobin Tang. All rights reserved.
//

#import "KSViewController.h"

@interface KSViewController ()<UIGestureRecognizerDelegate>

@end

@implementation KSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置手势代理
    self.interactivePopGestureRecognizer.delegate = self;
    //设置NavigationBar
    [self setupNavigationBar];
    
}

-(BOOL)shouldAutorotate{
    return YES;
}
-(UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

//设置导航栏主题
- (void)setupNavigationBar
{
    UINavigationBar *appearance = [UINavigationBar appearance];
    [appearance setBarTintColor:UIColor.whiteColor]; //统一设置导航栏颜色，如果单个界面需要设置，可以在viewWillAppear里面设置，在viewWillDisappear设置回统一格式。
//    [appearance setBarTintColor:[UIColor colorWithHexString:@"#2ED1A1" ]];

    //导航栏title格式
    NSMutableDictionary *textAttribute = [NSMutableDictionary dictionary];
//    textAttribute[NSForegroundColorAttributeName] = [UIColor whiteColor];
    textAttribute[NSForegroundColorAttributeName] = [UIColor blackColor];
    textAttribute[NSFontAttributeName] = Font18;
    [appearance setTitleTextAttributes:textAttribute];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count > 0) {
        //viewController.hidesBottomBarWhenPushed = YES;

        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        
        [backButton setBackgroundImage:[UIImage imageNamed:@"black_leftBack"] forState:UIControlStateNormal];
       // [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -12, 0, 12)];
        [backButton addTarget:self action:@selector(popView) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
        //  再创建一个空白的UIBarButtonItem，通过设置他的宽度可以偏移其右侧的返回按钮的位置
        
        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        
        spaceItem.width = 5;
        //  将两个UIBarButtonItem设置给当前的VC
        viewController.navigationItem.leftBarButtonItems = @[backItem];
    }
    [super pushViewController:viewController animated:animated];
}

- (void)popView
{
    [self popViewControllerAnimated:YES];
}


//手势代理
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return self.childViewControllers.count > 1;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
