//
//  CustomDefine.h
//  SkyMeeting
//
//  Created by xiaobin Tang on 2020/4/14.
//  Copyright © 2020 xiaobin Tang. All rights reserved.
//

#ifndef CustomDefine_h
#define CustomDefine_h
#import <Foundation/Foundation.h>

#define APP_KEY  @"62f5a71b88ccdf4b7eff832f"

#define APP_TOKEN  @"5bb48865c0984c0cd6a684ce18aca6425b77dea312f8c3fd8427ef25cda284a1e50fec2757672344fc891509c30a7d698ffe98bb52fbf8c4c1d262b5d04b413d"

#define ADMIN_ACCOUNT @"kangwenquan@skyworth.com"
#define ADMIN_PWD  @"sky123456"



//拼接前缀
#define PRE_FIX  @"zhuchuncheng."

//拼接后缀
#define SUF_FIX  @"@skyworth.com"


#pragma mark- 高度
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define ScreenWidthScale = SCREEN_WIDTH/375.0
#define ScreenHeightScale = SCREEN_HEIGHT / 667.0
#define ViewGap = 16 //页面间隙

#define GUIDE_SHOW_KEY @"GUIDE_SHOW_KEY"
#define GUIDE_PRE_SHOW_KEY @"GUIDE_PRE_SHOW_KEY"
#define EDITORVIEW_SIZE SCALE_VALUE(30)

#define STATUS_HEIGHT [[UIApplication sharedApplication] statusBarFrame].size.height

//头高度,iPhone X：88，iPhone 8：64
#define Nav_HEIGHT [[UIApplication sharedApplication] statusBarFrame].size.height + 44
#define Nav_H ([[UIApplication sharedApplication] statusBarFrame].size.height + 44)
// 适配iPhone x 底栏高度  (iphoneX高了34)
#define Tabbar_HEIGHT  ([[UIApplication sharedApplication] statusBarFrame].size.height>20?83:49)


//适应屏幕的高度
#define RYAdaptScreenSizeH(ui_w,ui_h) ((ui_h)/(ui_w)*[UIScreen mainScreen].bounds.size.width)
//适应屏幕的宽
#define RYAdaptScreenSizeW(ui_w,ui_h) ((ui_h)/(ui_w)*[UIScreen mainScreen].bounds.size.height)
///适应屏幕的宽
#define RYRealAdaptWidthValue(ui_w) ((ui_w)/375.0f*[UIScreen mainScreen].bounds.size.width)    //6S:375pt    6P:414.0f
///适应屏幕比列的高
#define RYRealAdaptHeightValue(ui_h) ((ui_h)/667.0f*[UIScreen mainScreen].bounds.size.height)    //6S:667pt

#define SCALE_VALUE(value) ((value)*SCREEN_WIDTH/375)
#define XXT_DRAWER_WIDTH ((SCREEN_WIDTH*2)/3)

/******************************************************************************************************************************************************************/

#define wSelf(self) __weak typeof(self) wSelf = self;
// 弱引用
#define MJWeakSelf __weak typeof(self) weakSelf = self;

//weak 对象
#define WeakObj(o) try{}@finally{} __weak typeof(o) o##Weak = o;
//strong 对象
#define StrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

#pragma mark- GVUserDefaults
#define GVUserDe                            [GVUserDefaults standardUserDefaults]


#pragma mark- NSString
#define ChangeNullString(obj)                [[NSString stringWithFormat:@"%@",obj] isEqualToString:@"<null>"] || [[NSString stringWithFormat:@"%@",obj] isEqualToString:@"(null)"]?@"":[NSString stringWithFormat:@"%@",obj]
#define IntValueToString(obj)                  [NSString stringWithFormat:@"%ld",obj]
#define FloatValueToString(obj)                  [NSString stringWithFormat:@"%.2f",obj]

/******************************************************************************************************************************************************************/

#pragma mark-  代码缩写
#define IMG(Name)             [UIImage imageNamed:Name]
#pragma mark 获取系统对象
#define kApplication                        [UIApplication sharedApplication]
#define kAppWindow                          [UIApplication sharedApplication].delegate.window
#define kAppDelegate                        [AppDelegate shareAppDelegate]
#define kRootViewController                 [UIApplication sharedApplication].delegate.window.rootViewController
#define kUserDefaults                       [NSUserDefaults standardUserDefaults]
#define kNotificationCenter                 [NSNotificationCenter defaultCenter]
#define kBundle                             [NSBundle mainBundle]
#define kMainScreen                         [UIScreen mainScreen]
#define kWeakSelf typeof(self) __weak weakSelf = self;

/******************************************************************************************************************************************************************/

#pragma mark-  枚举
typedef enum : NSUInteger {
    Get  = 1,
    Post = 2,
    Put = 3,
    DELETE = 4,
} MethodType;

#pragma mark-  Block
typedef void (^ResultBlock) (id result, NSUInteger code);
typedef void (^NetErrorBlock) (NSError *error);
typedef void (^NetSuccessBlock) (NSUInteger code);

/******************************************************************************************************************************************************************/

#pragma mark-  开发or上线功能
#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DLog(...)
#endif

#pragma mark-  真机or模拟器
//判断是真机还是模拟器
#if TARGET_OS_IPHONE
//真机
#endif
#if TARGET_IPHONE_SIMULATOR
//模拟器

#endif


#endif/* CustomDefine_h */
