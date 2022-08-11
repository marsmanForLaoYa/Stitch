//
//  Tools.m
//  SkyMeeting
//
//  Created by xiaobin Tang on 2020/4/14.
//  Copyright © 2020 xiaobin Tang. All rights reserved.
//

#import "Tools.h"
#import <AVFoundation/AVFoundation.h>
#import <mach/mach.h>
#import <sys/sysctl.h>
@implementation Tools
+ (UIImageView *)getLineWithFrame:(CGRect )frame{
    UIImageView *line = [[UIImageView alloc]initWithFrame:frame];
    line.backgroundColor = HexColor(BKGrayColor);
    return line;

}

+(UIView *)addBGViewWithFrame:(CGRect)frame{
    UIView *view = [[UIView alloc]initWithFrame:frame];
    view.backgroundColor = [UIColor blackColor];
    view.alpha = 0.6;
    return view;
}

///计算时间间隔
+(int)pleaseInsertStarTime:(NSString *)starTime andInsertEndTime:(NSString *)endTime{
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"HH:mm"];//根据自己的需求定义格式
    NSDate* startDate = [formater dateFromString:starTime];
    NSDate* endDate = [formater dateFromString:endTime];
    NSTimeInterval time = [endDate timeIntervalSinceDate:startDate];
    NSInteger timeGap = time/60;
    return timeGap;
}

//设置不同字体颜色
+(NSMutableAttributedString *)changeTextColor:(NSString *)changeStr FontNumber:(id)font AndRange:(NSRange)range AndColor:(UIColor *)vaColor{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:changeStr];
    //设置字号
    [str addAttribute:NSFontAttributeName value:font range:range];
     
    //设置文字颜色
    [str addAttribute:NSForegroundColorAttributeName value:vaColor range:range];
     
    return str;
}

+ (BOOL) isValidateMobile:(NSString *)mobile{
    NSString *phoneRegex1=@"1[3456789]([0-9]){9}";
    NSPredicate *phoneTest1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex1];
    return [phoneTest1 evaluateWithObject:mobile];
}

+(BOOL)ValidateEmail:(NSString*)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return[emailTest evaluateWithObject:email];
}



/**
 URL参数转字典
 @param urlStr 整个URL
 @return 参数字典
 */
+(NSDictionary *)dictionaryWithUrlString:(NSString *)urlStr{
    if (urlStr && urlStr.length && [urlStr rangeOfString:@"?"].length == 1) {
        NSArray *array = [urlStr componentsSeparatedByString:@"?"];
        if (array && array.count == 2) {
            NSString *paramsStr = array[1];
            if (paramsStr.length) {
                NSMutableDictionary *paramsDict = [NSMutableDictionary dictionary];
                NSArray *paramArray = [paramsStr componentsSeparatedByString:@"&"];
                for (NSString *param in paramArray) {
                    if (param && param.length) {
                        NSArray *parArr = [param componentsSeparatedByString:@"="];
                        if (parArr.count == 2) {
                            [paramsDict setObject:parArr[1] forKey:parArr[0]];
                        }
                    }
                }
                return paramsDict;
            }else{
//                return nil;
                abort();
            }
        }else{
            abort();
        }
    }else{
        abort();
    }
}

#pragma mark- 编码

+ (NSString *)decodeFromPercentEscapeString: (NSString *) urlStr
{
    NSMutableString *outputStr = [NSMutableString stringWithString:urlStr];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@""
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0,
                                                      [outputStr length])];
    
    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
//非ARC
+(NSString *)getUrlStringFromStringNoARC:(NSString *)aStr{
    NSString *outputStr = (NSString *)   CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,    (CFStringRef)aStr,  NULL,  (CFStringRef)@"!*'();:@&=+$,/?%#[]",    kCFStringEncodingUTF8));
    return outputStr;
}
//ARC
//+(NSString *)getUrlStringFromStringARC:(NSString *)urlStr{
//    NSString *outputStr = (__bridge NSString *)  CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
//                                            (__bridge CFStringRef)urlStr,
//                                            NULL,
//                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
//                                            kCFStringEncodingUTF8);
//    return outputStr;
//}

+ (CGFloat)getStatusBarHight {
    float statusBarHeight = 0;
    if (@available(iOS 13.0, *)) {
        UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager;
        statusBarHeight = statusBarManager.statusBarFrame.size.height;
    }else {
        statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    return statusBarHeight;
    
}

+(int)jugleCurrentTimeWithStr:(NSString *)startStr andEndStr:(NSString *)endStr AndDateFormat:(NSString *)dataFormat{
    // 获取系统当前的时间
    int ci;

    NSDateFormatter *df = [[NSDateFormatter alloc]init];

    [df setDateFormat:dataFormat];

    NSDate *dt1 = [[NSDate alloc]init];

    NSDate *dt2 = [[NSDate alloc]init];

    dt1 = [df dateFromString:startStr];

    dt2 = [df dateFromString:endStr];

    NSComparisonResult result = [dt1 compare:dt2];
    switch (result) {
                //选择时间小于当前时间
        case NSOrderedAscending:
            ci = 1;
            break;
                //选择时间大于当前时间
        case NSOrderedDescending:
            ci = -1;
            break;
                //选择时间等于当前时间
        case NSOrderedSame:
            ci = 0;
            break;

        default:
            NSLog(@"erorr dates %@, %@", dt2, dt1);
            break;

    }
    return ci;
    
}

// 过滤所有表情
+(BOOL)stringContainsEmoji:(NSString *)string {
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {

         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 returnValue = YES;
             }

         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
     }];

    return returnValue;
}

+ (CGFloat)heightWithLabelFont:(UIFont *)font withLabelWidth:(CGFloat)width AndStr:(NSString *)labStr {
    NSDictionary *attribute = @{NSFontAttributeName:font};
    CGSize rectSize = [labStr boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                               options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                             attributes:attribute
                                               context:nil].size;
    return rectSize.height;
}
+ (CGFloat)WidthWithLabelFont:(UIFont *)font withLabelHeight:(CGFloat)height AndStr:(NSString *)labStr {
    NSDictionary *attribute = @{NSFontAttributeName:font};
    CGSize rectSize = [labStr boundingRectWithSize:CGSizeMake(MAXFLOAT, height)
                                               options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                             attributes:attribute
                                               context:nil].size;
    return rectSize.width;
}

+ (BOOL)isBlankDictionary:(NSDictionary *)dic {
    if (!dic) {
        return YES;
    }
    if ([dic isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (!dic.count) {
        return YES;
    }
    if (dic == nil) {
        return YES;
    }
    if (dic == NULL) {
        return YES;
    }
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return YES;
    }

    return NO;
}

+ (NSString *)uuidString{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    
    //去除UUID ”-“
    NSString *UUID = [[uuid lowercaseString] stringByReplacingOccurrencesOfString:@"-" withString:@""];

    return UUID;
}

+(NSString *)canvasUUID{ 
    NSString *newUUID = [NSString stringWithFormat:@"canvas-%@",[Tools uuidString]];
    return newUUID;
}

+(NSString *)pathUUID{
    NSString *newUUID = [NSString stringWithFormat:@"path-%@",[Tools uuidString]];
    return newUUID;
}

+(NSString *)tempUserID{
    NSString *newUUID = [NSString stringWithFormat:@"user-%@",[Tools uuidString]];
    return newUUID;
}



+(NSString *)convertToJsonData:(NSDictionary *)dict{
    
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
//    NSString *jsonString;
//    if (!jsonData) {
//        NSLog(@"%@",error);
//
//    }else{
//        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
//
//    }
//    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
//
//    NSRange range = {0,jsonString.length};
//
//    //去掉字符串中的空格
//
//    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
//
//    NSRange range2 = {0,mutStr.length};
//
//    //去掉字符串中的换行符
//
//    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    NSData *data=[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];

    NSString *jsonStr=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];

    return jsonStr;
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString{
    if (jsonString == nil) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err){
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


+ (NSString *)HexStringWithColor:(UIColor *)color HasAlpha:(BOOL)hasAlpha {
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    int rgb = (int)(r * 255.0f)<<16 | (int)(g * 255.0f)<<8 | (int)(b * 255.0f)<<0;
    if (hasAlpha) {
        rgb = (int)(a * 255.0f)<<24 | (int)(r * 255.0f)<<16 | (int)(g * 255.0f)<<8 | (int)(b * 255.0f)<<0;
    }

    return [NSString stringWithFormat:@"#%06x", rgb];
}

+ (BOOL)isHeadphone{
    
//    AVAudioSessionRouteDescription* route1 = [[AVAudioSession sharedInstance] currentRoute];
//    for (AVAudioSessionPortDescription* desc in [route1 outputs]) {
//        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
//            NSLog(@"有耳机");
//    }
    
    UInt32 routeSize = sizeof (CFStringRef);
    CFStringRef route;

    OSStatus error = AudioSessionGetProperty (kAudioSessionProperty_AudioRoute,&routeSize, &route);

    /* Known values of route:
     * "Headset"
     * "Headphone"
     * "Speaker"
     * "SpeakerAndMicrophone"
     * "HeadphonesAndMicrophone"
     * "HeadsetInOut"
     * "ReceiverAndMicrophone"
     * "Lineout"
     */

    if (!error && (route != NULL)) {

        NSString* routeStr = (__bridge NSString *)route;

        NSRange headphoneRange = [routeStr rangeOfString : @"Head"];

        if (headphoneRange.location != NSNotFound) return YES;

    }

    return NO;
}


+(UIImage *)imageFromView:(UIView *)view rect:(CGRect)rect{
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 1.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGRect myImageRect = rect;
    CGImageRef imageRef = image.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef,myImageRect );
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, myImageRect, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    UIGraphicsEndImageContext();
    
    return smallImage;
}

+ (BOOL)isIPhoneNotchScreen{
    BOOL result = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return result;
    }
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            result = YES;
        }
    }
    return result;
}



+(CGFloat)cpu_usage{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

+(double)availableMemory{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                                 HOST_VM_INFO,
                                                 (host_info_t)&vmStats,
                                                 &infoCount);
      
    if (kernReturn != KERN_SUCCESS) {
    return NSNotFound;
    }
    return ((vm_page_size *vmStats.free_count) / 1024.0) / 1024.0;
}

+(BOOL)urlValidation:(NSString *)string {
 
    NSError *error;
 
    // 正则1
 
    NSString *regulaStr =@"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
 
    // 正则2
 
    regulaStr =@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
 
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr options:NSRegularExpressionCaseInsensitive error:&error];
 
    NSArray *arrayOfAllMatches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
 
    for (NSTextCheckingResult *match in arrayOfAllMatches){
//        NSString* substringForMatch = [string substringWithRange:match.range];
        NSLog(@"正确网址");
        return YES;
 
    }
 
    return NO;
}

@end
