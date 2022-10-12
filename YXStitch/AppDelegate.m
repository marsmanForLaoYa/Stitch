//
//  AppDelegate.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/8.
//

#import "AppDelegate.h"
//#import "KSViewController.h"
#import "XWNavigationController.h"
#import "HomeViewController.h"
#import <UMShare/UMShare.h>
#import <UMCommon/UMCommon.h>
#import "App.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self SetRootView];
    [self setKeyboardHandle];
    [self setUM];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"everLaunched"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"everLaunched"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
        GVUserDe.isMember = NO;
        GVUserDe.logoType = 1;
        GVUserDe.waterPosition = 3;
        GVUserDe.isAutoSaveIMGAlbum = NO;
        GVUserDe.isAutoCheckRecentlyIMG = NO;
        GVUserDe.isAutoDeleteOriginIMG = NO;
        GVUserDe.isAutoHiddenScrollStrip = NO;
    }else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
    }

    [App sharedInstance];
    return YES;
}

-(void)setUM{
    [UMConfigure initWithAppkey:APP_KEY channel:@"App Store"];
    //配置微信平台的Universal Links
    //微信和QQ完整版会校验合法的universalLink，不设置会在初始化平台失败
    [UMSocialGlobal shareInstance].universalLinkDic = @{@(UMSocialPlatformType_WechatSession):@"https://umplus-sdk-download.oss-cn-shanghai.aliyuncs.com/",
                                                        @(UMSocialPlatformType_QQ):@"https://umplus-sdk-download.oss-cn-shanghai.aliyuncs.com/qq_conn/101830139"
                                                        };
    
    /* 设置微信的appKey和appSecret */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:@"wx60d36f0847db422c" appSecret:@"5758b4e5dedabcd34d5bfe7a1a65f31d" redirectURL:nil];

//    /* 设置QQ */
//    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"101830139"/*设置QQ平台的appID*/  appSecret:nil redirectURL:nil];

    /* 设置sina */
//    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:@"3921700954"  appSecret:@"04b48b094faeb16683c32669824ebdad" redirectURL:@"https://sns.whalecloud.com/sina2/callback"];
}

#pragma mark-设置rootView
-(void)SetRootView{
    //SVP全局样式设置
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    //设置SVP显示时间
    [SVProgressHUD setMinimumDismissTimeInterval:1];
    XWNavigationController *navC = [[XWNavigationController alloc]initWithRootViewController:[HomeViewController new]];
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

-(void)applicationDidBecomeActive:(UIApplication *)application{
    
}
-(void)applicationWillEnterForeground:(UIApplication *)application{
    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation
{
      if (self.window) {
          if (url) {
              NSString *fileNameStr = [url lastPathComponent];
              NSString *Doc = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/localFile"] stringByAppendingPathComponent:fileNameStr];
              NSData *data = [NSData dataWithContentsOfURL:url];
              [data writeToFile:Doc atomically:YES];
              NSLog(@"文件已存到本地文件夹内");
         }
     }
     return YES;
 }




@end
