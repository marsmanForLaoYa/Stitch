//
//  Appconfig.h
//  SkyMeeting
//
//  Created by xiaobin Tang on 2020/4/14.
//  Copyright © 2020 xiaobin Tang. All rights reserved.
//

#ifndef Appconfig_h
#define Appconfig_h


#pragma mark - 时间
//获取系统时间戳
#define getCurentTime           [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]]

#pragma mark - 系统信息
#pragma mark 获取当前语言
#define RYCurrentLanguage           ([[NSLocale preferredLanguages] objectAtIndex:0])

#pragma mark 判断当前的iPhone设备/系统版本
#define NORMAL_SCALE  (kScreenWidth/375.0f)
//判断是否为iPhone
#define IS_IPHONE                        (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//判断是否为iPad
#define IS_IPAD                          (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
////判断是否为ipod
//#define IS_IPOD                         ([[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"])
//// 判断是否为 iPhone 5SE
//#define iPhone5SE                        [[UIScreen mainScreen] bounds].size.width == 320.0f && [[UIScreen mainScreen] bounds].size.height == 568.0f
//// 判断是否为iPhone 6/6s
//#define iPhone6_6s                       [[UIScreen mainScreen] bounds].size.width == 375.0f && [[UIScreen mainScreen] bounds].size.height == 667.0f
//// 判断是否为iPhone 6Plus/6sPlus
//#define iPhone6Plus_6sPlus               [[UIScreen mainScreen] bounds].size.width == 414.0f && [[UIScreen mainScreen] bounds].size.height == 736.0f
#define IS_iPHONE_X (SCREEN_HEIGHT == 812.f ? YES : NO)          //判断是否iPhone X
//获取系统版本
#define IOS_SYSTEM_VERSION               [[[UIDevice currentDevice] systemVersion] floatValue]
//判断 iOS 8 或更高的系统版本
#define IOS_VERSION_8_OR_LATER          (([[[UIDevice currentDevice] systemVersion] floatValue] >=8.0)? (YES):(NO))
//APP版本号
#define kAppVersion                     [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
//设备版本号
#define kSystemVersion                   [[UIDevice currentDevice] systemVersion]
//设备标识符
#define DeviceIdentifier                [[[UIDevice currentDevice] identifierForVendor] UUIDString]
#define DeviceName                      [[UIDevice currentDevice] name];  //获取设备名称 例如：XX的手机
#define DeviceSystemName                [[UIDevice currentDevice] systemName]; //获取系统名称 例如：iPhone OS
#define DeviceModel                [[UIDevice currentDevice] model]; //获取设备的型号 例如：iPhone
/***************************系统版本*****************************/




//获取手机系统的版本
#define HitoSystemVersion               [[[UIDevice currentDevice] systemVersion] floatValue]
////是否为iOS7及以上系统
//#define HitoiOS7                        ([[UIDevice currentDevice].systemVersion doubleValue] >= 7.0)
////是否为iOS8及以上系统
//#define HitoiOS8                        ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0)
////是否为iOS9及以上系统
//#define HitoiOS9                        ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0)
////是否为iOS10及以上系统
//#define HitoiOS10                       ([[UIDevice currentDevice].systemVersion doubleValue] >= 10.0)
////是否为iOS11及以上系统
//#define HitoiOS11                       ([[UIDevice currentDevice].systemVersion doubleValue] >= 11.0)

#pragma mark - 字体
#pragma mark - 字体
/*font
 Font18: 标准字36px18sp/18pt导航标题、文章标题、重要突出词句
 Font16: 标准字32px16sp/16pt用户姓名、列表文章标题、分类栏目、模块名称、按钮文字等
 Font14: 标准字28px14sp/14pt长段描述文字、非标题文字、文章正文、提示性文字等
 Font12: 标准字24px12sp/12pt次要描述文字、小副标题、 次要提示、标签文字等
 Font10: 标准字20px10sp/10pt标签栏名称、次要长段描述或提示文字
 */

#define Font(F)             [UIFont systemFontOfSize:(F)]
#define FontBold(F)         [UIFont boldSystemFontOfSize:(F)]
#define Font20              [UIFont fontWithName:@"Helvetica" size:20]
#define Font20Bold          [UIFont fontWithName:@"Helvetica-Bold" size:20]
#define Font19              [UIFont fontWithName:@"Helvetica" size:19]
#define Font19Bold          [UIFont fontWithName:@"Helvetica-Bold" size:19]
#define Font18              [UIFont fontWithName:@"Helvetica" size:18]
#define Font18Bold          [UIFont fontWithName:@"Helvetica-Bold" size:18]
#define Font18Medium        [UIFont fontWithName:@"PingFang-SC-Medium" size:18]
#define Font17              [UIFont fontWithName:@"Helvetica" size:17]
#define Font17Bold          [UIFont fontWithName:@"Helvetica-Bold" size:17]
#define Font17Medium        [UIFont fontWithName:@"PingFang-SC-Medium" size:17]
#define Font16              [UIFont fontWithName:@"Helvetica" size:16]
#define Font16Bold          [UIFont fontWithName:@"Helvetica-Bold" size:16]
#define Font16Medium        [UIFont fontWithName:@"PingFang-SC-Medium" size:16]
#define Font15              [UIFont fontWithName:@"Helvetica" size:15]
#define Font15Bold          [UIFont fontWithName:@"Helvetica-Bold" size:15]
#define Font15Medium        [UIFont fontWithName:@"PingFang-SC-Medium" size:15]
#define Font14              [UIFont fontWithName:@"Helvetica" size:14]
#define Font14Bold          [UIFont fontWithName:@"Helvetica-Bold" size:14]
#define Font14Medium        [UIFont fontWithName:@"PingFang-SC-Medium" size:14]
#define Font13              [UIFont fontWithName:@"Helvetica" size:13]
#define Font13Bold          [UIFont fontWithName:@"Helvetica-Bold" size:13]
#define Font13Medium        [UIFont fontWithName:@"PingFang-SC-Medium" size:13]
#define Font12              [UIFont fontWithName:@"Helvetica" size:12]
#define Font12Bold          [UIFont fontWithName:@"Helvetica-Bold" size:12]
#define Font12Medium        [UIFont fontWithName:@"PingFang-SC-Medium" size:12]
#define Font10              [UIFont fontWithName:@"Helvetica" size:10]
#define Font10Bold          [UIFont fontWithName:@"Helvetica-Bold" size:10]
#define FontTitleNormal     [UIFont fontWithName:@"Helvetica-Bold" size:15]
#define FontPromptNormal    [UIFont fontWithName:@"Helvetica" size:14]

#define BOLDSYSTEMFONT(FONTSIZE)        [UIFont boldSystemFontOfSize:FONTSIZE]
#define SYSTEMFONT(FONTSIZE)            [UIFont systemFontOfSize:FONTSIZE]
#define FONT(NAME,FONTSIZE)             [UIFont fontWithName:(NAME)size:(FONTSIZE)]

#endif /* Appconfig_h */
