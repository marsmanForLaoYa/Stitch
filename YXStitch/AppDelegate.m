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
#import "App.h"
#import "XWTimerTool.h"
#import <MOBFoundation/MobSDK+Privacy.h>
#import <ShareSDK/ShareSDK.h>

@interface AppDelegate ()

@property (nonatomic, assign) NSInteger pasteboardChangeCount;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self SetRootView];
    [self setKeyboardHandle];
    [self setShare];
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

    [[XWTimerTool shareInstance] addAutoLoginTimer];
    [App sharedInstance];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePasteboardNotification:) name:UIPasteboardChangedNotification object:nil];
    

    [LYLogger instance];
    
    return YES;
}

-(void)setShare{
    [MobSDK uploadPrivacyPermissionStatus:YES onResult:^(BOOL success) {
        
    }];
    [ShareSDK registPlatforms:^(SSDKRegister *platformsRegister) {
        //wx
        [platformsRegister setupWeChatWithAppId:@"wxc85cef5f6ea96402" appSecret:@"2c9dd114aa8a78b2d7baa7d2f7d41565" universalLink:@"https://www.pintu365app.com/ios"];
        [platformsRegister setupSinaWeiboWithAppkey:@"1582112744" appSecret:@"843084a22b83e24112b7794b756a8998" redirectUrl:@"https://www.pintu365app.com/" universalLink:@"https://www.pintu365app.com/ios"];
    }];
}

- (void)handlePasteboardNotification:(NSNotification *)notify {
    self.pasteboardChangeCount = [UIPasteboard generalPasteboard].changeCount;
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
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    if (self.pasteboardChangeCount != pasteboard.changeCount) {
        self.pasteboardChangeCount = pasteboard.changeCount;
       
        if (pasteboard.string == nil) {
            return;
        }
        NSData *jsonData = [pasteboard.string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&error];
        if (dic) {
            NSString *code = dic[@"code"];
            if ([User current].isLogin) {
                [[XWNetTool sharedInstance] uploadInvataionCodelWithCode:code callback:^(NSString * _Nonnull errorMsg, NSInteger code) {
                    if (code == CodeSuccess) {
                        //输入了邀请码会得到7天VIP有必要重新获取一下用户信息
                        [[XWNetTool sharedInstance] queryUserInformationShowAdAlert:NO callback:nil];
                    }
                    else if (code == CodeBindInviteCodeNoExist ||
                             code == CodeBindHadBindUser ||
                             code == CodeBindError)
                    {
//                        pasteboard.string = nil;
                    }
                }];
            }
        }
    }
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
-(BOOL)application:(UIApplication*)application continueUserActivity:(NSUserActivity*)userActivity restorationHandler:(void(^)(NSArray* __nullable restorableObjects))restorationHandler
{
    return YES;
}




@end
