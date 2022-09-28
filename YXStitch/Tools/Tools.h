//
//  Tools.h
//  SkyMeeting
//
//  Created by xiaobin Tang on 2020/4/14.
//  Copyright © 2020 xiaobin Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Photos/Photos.h"

NS_ASSUME_NONNULL_BEGIN

@interface Tools : NSObject

///画一条分割线
+(UIImageView *)getLineWithFrame:(CGRect )frame;

///正则判断手机号
+(BOOL)isValidateMobile:(NSString *)mobile;

///添加背景view
+(UIView *)addBGViewWithFrame:(CGRect )frame;

+(int)pleaseInsertStarTime:(NSString *)starTime andInsertEndTime:(NSString *)endTime;

//正则判断邮箱格式
+(BOOL)ValidateEmail:(NSString*)email;

//状态栏高度获取
+ (CGFloat)getStatusBarHight;

#pragma mark- 字符串转换
//string转换
+(NSMutableAttributedString *)changeTextColor:(NSString *)changeStr
                                   FontNumber:(id)font
                                     AndRange:(NSRange)range
                                     AndColor:(UIColor *)vaColor;
/**
 URL参数转字典
 
 @param urlStr ?后面的参数
 @return 参数字典
 */
+(NSDictionary *)dictionaryWithUrlString:(NSString *)urlStr;


#pragma mark- 编码

/**
 URL中文解码成中文(%E4%B8%AD%E5%9B%BD)

 @param urlStr urlStr
 @return 中文
 */
+ (NSString *)decodeFromPercentEscapeString: (NSString *) urlStr;


/**
 URL编码 //ARC
 */
//+(NSString *)getUrlStringFromStringARC:(NSString *)urlStr;

/**
 URL编码 //非ARC
 */
+(NSString *)getUrlStringFromStringNoARC:(NSString *)aStr;


//日期比较
+(int)jugleCurrentTimeWithStr:(NSString *)startStr andEndStr:(NSString *)endStr AndDateFormat:(NSString *)dataFormat;

//判断emoji表情
+(BOOL)stringContainsEmoji:(NSString *)string;

//计算文本高度
+ (CGFloat)heightWithLabelFont:(UIFont *)font withLabelWidth:(CGFloat)width AndStr:(NSString *)labStr ;

//计算文本宽度
+ (CGFloat)WidthWithLabelFont:(UIFont *)font withLabelHeight:(CGFloat)height AndStr:(NSString *)labStr ;

+ (BOOL)isBlankDictionary:(NSDictionary *)dic;

///生成uuid
+ (NSString *)uuidString;

///生成canvasid
+(NSString *)canvasUUID;

///生成pathid
+(NSString *)pathUUID;

///生成临时userid
+(NSString *)tempUserID;

///字典转Json字符串
+(NSString *)convertToJsonData:(NSDictionary *)dict;


///Json字符串转字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

///UIColor 转 HexString
+ (NSString *)HexStringWithColor:(UIColor *)color HasAlpha:(BOOL)hasAlpha;

///判断是否插入耳机
+ (BOOL)isHeadphone;

/// 判断是否是刘海屏
+(BOOL)isIPhoneNotchScreen;

/// 计算内存占比
+(CGFloat)cpu_usage;

///获取当前任务所占用的内存（单位：MB）
+(double)availableMemory;


///UIView 转换成uiimage
+(UIImage *)imageFromView:(UIView *)view rect:(CGRect)rect;



/**
 * 网址正则验证 1或者2使用哪个都可以
 *
 *  @param string 要验证的字符串
 *
 *  @return 返回值类型为BOOL
 */
 
///正则判断邮箱是否有效
+(BOOL)urlValidation:(NSString *)string;

///检测是否连续截图
+(NSMutableArray*)detectionScreenShotIMG;

///PHAsset转换成UIImage
+(void)getImageWithAsset:(PHAsset*)asset withBlock:(void(^)(UIImage*image))block;
/// iOS15重置navigationbar 颜色和字体
+(void)setNaviBarBKColorWith:(UINavigationController *)navi andBKColor:(UIColor *)BKColor andFontColor:(UIColor *)fontClor;

///保存图片到指定相册
+(void)saveImageWithImage:(UIImage *)image albumName:(NSString *)albumName withBlock:(void(^)(NSString *identify))block;

///抠图hsv范围颜色
+(UIImage *)removeColorWithMinHueAngle:(float)minHueAngle maxHueAngle:(float)maxHueAngle image:(UIImage *)originalImage;

///
+ (NSString *)getIphoneType ;

@end

NS_ASSUME_NONNULL_END
