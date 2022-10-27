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
#import <CoreMedia/CoreMedia.h>
#import <sys/utsname.h>
#import "NSString+Extension.h"
#import "UIImage+Orientation.h"

#define BEfORETIME -(100 * 60)

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

+(CGSize)sizeOfText:(NSString *)text andFontSize:(NSInteger)fontSize{
    CGSize textSize = [text sizeOfMaxSize:CGSizeMake(150, MAXFLOAT) font:[UIFont systemFontOfSize:fontSize]];
    textSize.height += 50;
    return textSize;
}

#pragma mark - CMSampleBufferRef转换为UIImage
-(UIImage *)bufferToImage:(CMSampleBufferRef)buffer{
    
    //获取一个Core Video图像缓存对象
    //CVImageBufferRef：Base type for all CoreVideo image buffers
    CVImageBufferRef imgBuffer = CMSampleBufferGetImageBuffer(buffer);
    
    //锁定基地址
    //参数一：CVPixelBufferRef
    /**
     CVPixelBufferRef：Based on the image buffer type. The pixel
     buffer implements the memory storage for an image buffer.
     CVPixelBufferRef是以CVImageBufferRef为基础的类型
     */
    //参数二：CVPixelBufferLockFlags
    /**
     If you are not going to modify the data while you hold the
     lock, you should set this flag to avoid potentially
     invalidating any existing caches of the buffer contents.
     This flag should be passed both to the lock and unlock
     functions.  Non-symmetrical usage of this flag will result in
     undefined behavior.
     如果在持有锁时不打算修改数据，则应设置此标志以避免可能使缓冲区内容的任何现有缓存失效。此标志应同时传递给锁定和解锁功能。非对称使用此标志将导致未定义的行为。
     */
    CVReturn result = CVPixelBufferLockBaseAddress(imgBuffer, 0);
    NSLog(@"success or error result：%d", result);
    
    //获得基地址
    void *baseAddr = CVPixelBufferGetBaseAddress(imgBuffer);
    
    //获得行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imgBuffer);
    
    //获得宽、高
    size_t width = CVPixelBufferGetWidth(imgBuffer);
    size_t height = CVPixelBufferGetHeight(imgBuffer);
    NSLog(@"width：%zu, height：%zu", width, height);    
    //创建RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //创建一个图形上下文
    CGContextRef context = CGBitmapContextCreate(baseAddr, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    //根据上下文创建CGImage
    CGImageRef cgImg = CGBitmapContextCreateImage(context);
    //处理完成后，解锁（加锁、解锁要配套使用）
    CVPixelBufferUnlockBaseAddress(imgBuffer, 0);
    //这些资源不会自动释放，需要手动释放
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    //创建UIImage
    //UIImage *img = [UIImage imageWithCGImage:cgImg];
    UIImage *img = [UIImage imageWithCGImage:cgImg scale:1.0f orientation:UIImageOrientationUp];
    
    //释放
    CGImageRelease(cgImg);
    
    return img;
}
 
#pragma mark - CMSampleBufferRef转换为NSData
-(NSData *)bufferToData:(CMSampleBufferRef)buffer{
    
    CVImageBufferRef imgBuffer = CMSampleBufferGetImageBuffer(buffer);
    
    CVPixelBufferLockBaseAddress(imgBuffer, 0);
    
    size_t bytePerRow = CVPixelBufferGetBytesPerRow(imgBuffer);
    
    size_t height = CVPixelBufferGetHeight(imgBuffer);
    
    void *baseAddr = CVPixelBufferGetBaseAddress(imgBuffer);
    
    NSData *data = [NSData dataWithBytes:baseAddr length:bytePerRow * height];
    
    CVPixelBufferUnlockBaseAddress(imgBuffer, 0);
    
    return data;
    
}

+(NSMutableArray*)detectionScreenShotIMG{
    //ascenging 升序/逆序
    PHFetchOptions* options = [[PHFetchOptions alloc]init];
    options.sortDescriptors=@[[NSSortDescriptor sortDescriptorWithKey:@"creationDate"ascending:YES]];
    //多媒体类型的渭词
    NSPredicate *media = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    //查询指定时间之内的图片
    NSDate *date = [NSDate date];
    NSDate *lastDate = [date initWithTimeIntervalSinceNow:BEfORETIME];
    NSPredicate *predicateDate = [NSPredicate predicateWithFormat:@"creationDate >= %@", lastDate];
    NSCompoundPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[media, predicateDate]];
    options.predicate= compoundPredicate;
//    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat
    PHFetchResult* result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
    __block NSMutableArray *dataArr = [NSMutableArray array];
    if (result.count > 0){
        NSLog(@"2分钟以内的图片一共%ld张",result.count);
        for (PHAsset* asset in result) {
            [dataArr addObject:asset];
        }
    }else{
        NSLog(@"无数据");
    }
    return dataArr;
}

//获取image

+(void)getImageWithAsset:(PHAsset*)asset withBlock:(void(^)(UIImage *image))block{
    //通过asset资源获取图片
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = true;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = YES;
    //PHImageManagerMaximumSize
//    [[PHCachingImageManager defaultManager]requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//        block(result);
//    }];
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        UIImage *result = [UIImage imageWithData:imageData];
        block(result);
    }];
}

/*  遍历相簿中的全部图片
*  @param assetCollection 相簿
*  @param original        是否要原图
*/
+(void)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection original:(BOOL)original{
   NSLog(@"相簿名:%@", assetCollection.localizedTitle);
   
   PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
   options.resizeMode = PHImageRequestOptionsResizeModeFast;
   // 同步获得图片, 只会返回1张图片
   options.synchronous = YES;
   
   // 获得某个相簿中的所有PHAsset对象
   PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
   for (PHAsset *asset in assets) {
       // 是否要原图
       CGSize size = original ? CGSizeMake(asset.pixelWidth, asset.pixelHeight) : CGSizeZero;
       
       // 从asset中获得图片
       __weak typeof(self) weakSelf = self;
       [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
           NSLog(@"%@", result);
       }];
       dispatch_async(dispatch_get_main_queue(), ^{
//           [weakSelf.showPhotoCollectionView reloadData];
       });
   }
}

+(NSMutableArray *)search{
    PHFetchOptions *options = [PHFetchOptions new];
    PHFetchResult *topLevelUserCollections = [PHAssetCollection fetchTopLevelUserCollectionsWithOptions:options];
    PHAssetCollectionSubtype subType = PHAssetCollectionSubtypeAlbumRegular;
    PHFetchResult *smartAlbumsResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:subType options:options];
    
   __block PHAssetCollection *resultAsset = [PHAssetCollection new];
    NSMutableArray *photoGroups = [NSMutableArray array];
    [topLevelUserCollections enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[PHAssetCollection class]]) {
             PHAssetCollection *asset = (PHAssetCollection *)obj;
             PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:asset options:[PHFetchOptions new]];
             if (result.count > 0) {
                 
             }
         }
    }];
    [smartAlbumsResult enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *asset = (PHAssetCollection *)obj;
            PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:asset options:[PHFetchOptions new]];
            //截图相册
            if ([asset.localizedTitle isEqualToString:@"Screenshots"]){
                resultAsset = asset;
            }
         }
    }];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    //多媒体类型的渭词
    NSPredicate *media = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    //查询指定时间内的图片
    NSDate *date = [NSDate date];
    NSDate *lastDate = [date initWithTimeIntervalSinceNow:-60000];
    NSPredicate *predicateDate = [NSPredicate predicateWithFormat:@"creationDate >= %@", lastDate];
    //
    NSCompoundPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[media, predicateDate]];
    //
    options.predicate= compoundPredicate;
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:resultAsset options:options];
    __block NSMutableArray *dataArr = [NSMutableArray array];
    if(result.count > 0 && resultAsset.assetCollectionSubtype != PHAssetCollectionSubtypeSmartAlbumVideos) {
        
        for (PHAsset* asset in result) {
            [self getImageWithAsset:asset withBlock:^(UIImage *image) {
                [dataArr addObject:image];
            }];
        }
     }
    return  dataArr;

}

+(void)setNaviBarBKColorWith:(UINavigationController *)navi andBKColor:(UIColor *)BKColor andFontColor:(UIColor *)fontClor{
    if (@available(iOS 15.0, *)) {
        NSMutableDictionary *textAttribute = [NSMutableDictionary dictionary];
        textAttribute[NSForegroundColorAttributeName] = fontClor;
        textAttribute[NSFontAttributeName] = Font18;
        UINavigationBar *navigationBar = navi.navigationBar;
        UINavigationBarAppearance *app = [UINavigationBarAppearance new];
        [app configureWithOpaqueBackground];
        [app setTitleTextAttributes:textAttribute];
        [app setBackgroundColor:BKColor];
        [app setShadowColor:[UIColor clearColor]];
        navigationBar.scrollEdgeAppearance = app;
        navigationBar.standardAppearance = app;
    }
}

+(void)saveImageWithImage:(UIImage *)image albumName:(NSString *)albumName withBlock:(void(^)(NSString *identify))block{
    // PHAsset : 一个资源，一个图片
    // PHAssetCollection : 一个相簿 （也可以说是一个相册）
    // PHotoLibrary 整个照片库（里面会有很多相册）
    
    __block NSString *assetLocalIdentifier = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        // 1.保存图片到相机胶卷中
        assetLocalIdentifier = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        if (success == NO || error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"保存照片失败");
            });
            return;
        }
        
        // 2. 获得相册
        PHAssetCollection *creatAssetCollction = [self creatPHAssetWithAlbumName:albumName];
        if (creatAssetCollction == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"创建相册失败");
            });
            return;
        }
        
        //创建成功，就把图片保存到相册中
        [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
            
            //添加相机胶卷中的图片到相簿中去
            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetLocalIdentifier] options:nil].lastObject;
            //添加图片到相册中的请求
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:creatAssetCollction];
            [request addAssets:@[asset]];
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success == NO || error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                  NSLog(@"保存图片失败");
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                  NSLog(@"保存图片成功");
                    block(assetLocalIdentifier);
                });
            }
        }];
        
    }];
}



+(PHAssetCollection *)creatPHAssetWithAlbumName:(NSString *)albumName {
    
    //从已经存在的相簿中查找应用对应的相册
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in assetCollections) {
        if ([collection.localizedTitle isEqualToString:albumName]) {
            return collection;
        }
    }
    // 没找到，就创建新的相簿
    NSError *error;
    __block NSString *assetCollectionLocalIdentifier = nil;
    //这里用wait请求，保证创建成功相册后才保存进去
    [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{

        assetCollectionLocalIdentifier = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName].placeholderForCreatedAssetCollection.localIdentifier;
        
    } error:&error];
    
    if (error) return nil;
    
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[assetCollectionLocalIdentifier] options:nil].lastObject;
}

+(UIImage *)removeColorWithMinHueAngle:(float)minHueAngle maxHueAngle:(float)maxHueAngle image:(UIImage *)originalImage{
    CIImage *image = [CIImage imageWithCGImage:originalImage.CGImage];
    CIContext *context = [CIContext contextWithOptions:nil];// kCIContextUseSoftwareRenderer : CPURender
    /** 注意
     *  UIImage 通过CIimage初始化，得到的并不是一个通过类似CGImage的标准UIImage
     *  所以如果不用context进行渲染处理，是没办法正常显示的
     */
    CIImage *renderBgImage = [self outputImageWithOriginalCIImage:image minHueAngle:minHueAngle maxHueAngle:maxHueAngle];
    CGImageRef renderImg = [context createCGImage:renderBgImage fromRect:image.extent];
    UIImage *renderImage = [UIImage imageWithCGImage:renderImg];
    return renderImage;
}

struct CubeMap {
    int length;
    float dimension;
    float *data;
};

+(CIImage *)outputImageWithOriginalCIImage:(CIImage *)originalImage minHueAngle:(float)minHueAngle maxHueAngle:(float)maxHueAngle{
    
    struct CubeMap map = createCubeMap(minHueAngle, maxHueAngle);
    const unsigned int size = 64;
    NSData *data = [NSData dataWithBytesNoCopy:map.data
                                        length:map.length
                                  freeWhenDone:YES];
    CIFilter *colorCube = [CIFilter filterWithName:@"CIColorCube"];
    [colorCube setValue:@(size) forKey:@"inputCubeDimension"];
    [colorCube setValue:data forKey:@"inputCubeData"];
    
    [colorCube setValue:originalImage forKey:kCIInputImageKey];
    CIImage *result = [colorCube valueForKey:kCIOutputImageKey];
    
    return result;
}

struct CubeMap createCubeMap(float minHueAngle, float maxHueAngle) {
    const unsigned int size = 64;
    struct CubeMap map;
    map.length = size * size * size * sizeof (float) * 4;
    map.dimension = size;
    float *cubeData = (float *)malloc (map.length);
    float rgb[3], hsv[3], *c = cubeData;
    
    for (int z = 0; z < size; z++){
        rgb[2] = ((double)z)/(size-1); // Blue value
        for (int y = 0; y < size; y++){
            rgb[1] = ((double)y)/(size-1); // Green value
            for (int x = 0; x < size; x ++){
                rgb[0] = ((double)x)/(size-1); // Red value
                rgbToHSV(rgb,hsv);
                float alpha = (hsv[0] > minHueAngle && hsv[0] < maxHueAngle) ? 0.0f: 1.0f;
                c[0] = rgb[0] * alpha;
                c[1] = rgb[1] * alpha;
                c[2] = rgb[2] * alpha;
                c[3] = alpha;
                c += 4;
            }
        }
    }
    map.data = cubeData;
    return map;
}

void rgbToHSV(float *rgb, float *hsv) {
    float min, max, delta;
    float r = rgb[0], g = rgb[1], b = rgb[2];
    float *h = hsv, *s = hsv + 1, *v = hsv + 2;
    
    min = fmin(fmin(r, g), b );
    max = fmax(fmax(r, g), b );
    *v = max;
    delta = max - min;
    if( max != 0 )
        *s = delta / max;
    else {
        *s = 0;
        *h = -1;
        return;
    }
    if( r == max )
        *h = ( g - b ) / delta;
    else if( g == max )
        *h = 2 + ( b - r ) / delta;
    else
        *h = 4 + ( r - g ) / delta;
    *h *= 60;
    if( *h < 0 )
        *h += 360;
}

+ (NSString *)getIphoneType {
    
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString * phoneType = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if ([phoneType isEqualToString:@"i386"])   return @"Simulator";
    
    if ([phoneType isEqualToString:@"x86_64"])  return @"Simulator";
    
    //  常用机型  不需要的可自行删除
    if([phoneType  isEqualToString:@"iPhone1,1"])  return @"iPhone 2G";
    
    if([phoneType  isEqualToString:@"iPhone1,2"])  return @"iPhone 3G";
    
    if([phoneType  isEqualToString:@"iPhone2,1"])  return @"iPhone 3GS";
    
    if([phoneType  isEqualToString:@"iPhone3,1"])  return @"iPhone 4";
    
    if([phoneType  isEqualToString:@"iPhone3,2"])  return @"iPhone 4";
    
    if([phoneType  isEqualToString:@"iPhone3,3"])  return @"iPhone 4";
    
    if([phoneType  isEqualToString:@"iPhone4,1"])  return @"iPhone 4S";
    
    if([phoneType  isEqualToString:@"iPhone5,1"])  return @"iPhone 5";
    
    if([phoneType  isEqualToString:@"iPhone5,2"])  return @"iPhone 5";
    
    if([phoneType  isEqualToString:@"iPhone5,3"])  return @"iPhone 5c";
    
    if([phoneType  isEqualToString:@"iPhone5,4"])  return @"iPhone 5c";
    
    if([phoneType  isEqualToString:@"iPhone6,1"])  return @"iPhone 5s";
    
    if([phoneType  isEqualToString:@"iPhone6,2"])  return @"iPhone 5s";
    
    if([phoneType  isEqualToString:@"iPhone7,1"])  return @"iPhone 6 Plus";
    
    if([phoneType  isEqualToString:@"iPhone7,2"])  return @"iPhone 6";
    
    if([phoneType  isEqualToString:@"iPhone8,1"])  return @"iPhone 6s";
    
    if([phoneType  isEqualToString:@"iPhone8,2"])  return @"iPhone 6s Plus";
    
    if([phoneType  isEqualToString:@"iPhone8,4"])  return @"iPhone SE";
    
    if([phoneType  isEqualToString:@"iPhone9,1"])  return @"iPhone 7";
    
    if([phoneType  isEqualToString:@"iPhone9,2"])  return @"iPhone 7 Plus";
    
    if([phoneType  isEqualToString:@"iPhone9,4"])  return @"iPhone 7 Plus";
    
    if([phoneType  isEqualToString:@"iPhone10,1"]) return @"iPhone 8";
    
    if([phoneType  isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
    
    if([phoneType  isEqualToString:@"iPhone10,2"]) return @"iPhone 8 Plus";
    
    if([phoneType  isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
    
    if([phoneType  isEqualToString:@"iPhone10,3"]) return @"iPhone X";
    
    if([phoneType  isEqualToString:@"iPhone10,6"]) return @"iPhone X";
    
    if([phoneType  isEqualToString:@"iPhone11,8"]) return @"iPhone XR";
    
    if([phoneType  isEqualToString:@"iPhone11,2"]) return @"iPhone XS";
    
    if([phoneType  isEqualToString:@"iPhone11,4"]) return @"iPhone XS Max";
    
    if([phoneType  isEqualToString:@"iPhone11,6"]) return @"iPhone XS Max";
    
    if([phoneType  isEqualToString:@"iPhone12,1"])  return @"iPhone 11";
    
    if ([phoneType isEqualToString:@"iPhone12,3"])  return @"iPhone 11 Pro";
    
    if ([phoneType isEqualToString:@"iPhone12,5"])   return @"iPhone 11 Pro Max";
    
    if ([phoneType isEqualToString:@"iPhone12,8"])   return @"iPhone SE2";
    
    if ([phoneType isEqualToString:@"iPhone13,1"])    return @"iPhone 12 mini";
    if ([phoneType isEqualToString:@"iPhone13,2"])    return @"iPhone 12";
    if ([phoneType isEqualToString:@"iPhone13,3"])    return @"iPhone 12 Pro";
    if ([phoneType isEqualToString:@"iPhone13,4"])    return @"iPhone 12 Pro Max";
    
    if ([phoneType isEqualToString:@"iPhone14,4"])    return @"iPhone 13 mini";
    if ([phoneType isEqualToString:@"iPhone14,5"])    return @"iPhone 13";
    if ([phoneType isEqualToString:@"iPhone14,2"])    return @"iPhone 13 Pro";
    if ([phoneType isEqualToString:@"iPhone14,3"])    return @"iPhone 13 Pro Max";

       return phoneType;
}

///水平翻转/垂直翻转图片
+(UIImage *)turnImageWith:(UIImage *)img AndType:(NSInteger)type AndisTurn:(BOOL)isTurn{
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToRect(context, rect);
    if (type == 1){
        //水平翻转
        if (!isTurn){
            CGContextRotateCTM(context, (CGFloat)M_PI);
        }else{
            CGContextRotateCTM(context, (CGFloat)-M_PI);
        }
        CGContextTranslateCTM(context, -rect.size.width, -rect.size.height);
    }
    CGContextDrawImage(context, rect, img.CGImage);
    //翻转图片
    UIImage *drawImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *flipImage = [UIImage imageWithCGImage:drawImage.CGImage scale:img.scale orientation:img.imageOrientation];
    return flipImage;

}

//翻转图片
+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    image = [image fixOrientation:image];
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    
    return newPic;
    
}


+(void)getAssetWithImage:(UIImage *)image getAssetSuccess:(void(^)(PHAsset *asset))getSuccess{

    __block NSString *assetId = nil;

       [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{

        // 保存相片到相机胶卷，并返回标识
           assetId= [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;

    } completionHandler:^(BOOL success, NSError * _Nullable error) {

  // 根据标识获得相片对象

        PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].lastObject;

        getSuccess(asset);

    }];
}

@end
