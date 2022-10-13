//
//  XWModel.h
//  XWNWS
//
//  Created by mac_m11 on 2022/8/24.
//

#import <Foundation/Foundation.h>
#import <YYKit/NSObject+YYModel.h>
NS_ASSUME_NONNULL_BEGIN

@interface XWModel : NSObject
/// 以下3个方法是归档存在UserDefaults中的。
+ (instancetype) read;
- (BOOL) save;
- (BOOL) del;

/**
 以下3个方法，是归档存在Library/Cache中。自己命名文件
 
 */
+ (instancetype) readFromFileCacheWithFileName:(NSString *)fileName;
- (BOOL) saveToFileCacheWithFileName:(NSString *)fileName;
+ (BOOL) deleteFromFileCacheWithFileName:(NSString *)fileName;

+ (instancetype) readFromFilePath:(NSString *)filePath;
- (BOOL) saveToFilePath:(NSString *)filePath;
+ (BOOL) deleteFromFilePath:(NSString *)filePath;

+ (NSString *)diskCacheDir;

/**
 深度copy一个对象，和普通copy不同的是，所有该对象的所有属性都会执行一次copy/mutableCopy操作（若属性是mutable的，例如NSMutableDictonary则执行mutable）

 @return 完全深度拷贝的model
 */
- (instancetype) superDeepCopy;

/**
 同步model，使得self的所有属性值和lyModel的属性值一样。

 @param scModel 目标model
 */
- (void)synchronizeWithSCModel:(XWModel *)xwModel;

+ (NSString *) getKey;

/// 保存时忽略的属性
+ (NSArray<NSString *>*)ignoredProperties;

/**
 进行copy操作时，忽略的属性

 @return 属性名数组
 */
+ (NSArray<NSString *>*)ignoredPropertiesForCopying;
@end

NS_ASSUME_NONNULL_END
