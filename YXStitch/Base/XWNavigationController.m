//
//  XWNavigationViewController.m
//  XWNWS
//
//  Created by mac_m11 on 2022/8/23.
//

#import "XWNavigationController.h"
#import "XWNavigationController+BarStyle.h"

@interface XWNavigationController ()<UINavigationControllerDelegate, UIGestureRecognizerDelegate>


@end

@implementation XWNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     __weak __typeof(self) weakSelf = self;
    self.interactivePopGestureRecognizer.delegate = weakSelf;
    self.delegate = weakSelf;
    self.enableBackGesture = YES;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.pushing)
    {
        return;
    }
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)] && animated == YES)
    {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
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
    self.pushing = YES;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)] && animated == YES)
    {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    return [super popToRootViewControllerAnimated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if( [self respondsToSelector:@selector(interactivePopGestureRecognizer)] )
    {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    return [super popToViewController:viewController animated:animated];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.interactivePopGestureRecognizer.enabled = YES;
    }
    self.pushing = NO;
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( gestureRecognizer == self.interactivePopGestureRecognizer )
    {
        if ( self.viewControllers.count < 2 || self.visibleViewController == [self.viewControllers objectAtIndex:0] )
        {
            return NO;
        }
    }
    return self.enableBackGesture;
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    
    if (@available(iOS 13.0, *)) {
        viewControllerToPresent.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)popView
{
    [self popViewControllerAnimated:YES];
}

- (void) loadView
{
    [super loadView];

    //设置导航栏背景颜色
    [self addNavBarShadowImageWithColor:RGB(255, 255, 255)];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    UIColor *color = RGB(0, 0, 0);
    NSDictionary *titleAttr= @{
                               NSForegroundColorAttributeName:color,
                               NSFontAttributeName:[UIFont systemFontOfSize:18]
                               };
    //设置导航栏标题字体颜色、分割线颜色
    [self addNavBarTitleTextAttributes:titleAttr barShadowHidden:NO shadowColor:RGB(233, 233, 233)];
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f); //宽高 1.0只要有值就够了
    UIGraphicsBeginImageContext(rect.size); //在这个范围内开启一段上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);//在这段上下文中获取到颜色UIColor
    CGContextFillRect(context, rect);//用这个颜色填充这个上下文
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();//从这段上下文中获取Image属性,,,结束
    UIGraphicsEndImageContext();
    
    return image;
}

@end
