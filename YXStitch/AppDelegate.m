//
//  AppDelegate.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/8.
//

#import "AppDelegate.h"
#import "KSViewController.h"
#import "HomeViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self SetRootView];
    [self setKeyboardHandle];
    return YES;
}

#pragma mark-设置rootView
-(void)SetRootView{
    //SVP全局样式设置
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    //设置SVP显示时间
    [SVProgressHUD setMinimumDismissTimeInterval:1];
    KSViewController *navC = [[KSViewController alloc]initWithRootViewController:[HomeViewController new]];
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = navC;
    [self.window makeKeyAndVisible];
}

#pragma mark- 键盘设置
-(void)setKeyboardHandle{
    IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager]; // 获取类库的单例变量
    
    keyboardManager.enable = YES; // 控制整个功能是否启用
    
    keyboardManager.shouldResignOnTouchOutside = YES; // 控制点击背景是否收起键盘
    
    keyboardManager.shouldToolbarUsesTextFieldTintColor = YES; // 控制键盘上的工具条文字颜色是否用户自定义
    
    keyboardManager.toolbarManageBehaviour = IQAutoToolbarBySubviews; // 有多个输入框时，可以通过点击Toolbar 上的“前一个”“后一个”按钮来实现移动到不同的输入框
    
    keyboardManager.enableAutoToolbar = YES; // 控制是否显示键盘上的工具条
    
    keyboardManager.shouldShowToolbarPlaceholder = YES; // 是否显示占位文字
    
    keyboardManager.placeholderFont = [UIFont boldSystemFontOfSize:17]; // 设置占位文字的字体
    
    keyboardManager.keyboardDistanceFromTextField = 10.0f; // 输入框距离键盘的距离
    
    
}





@end
