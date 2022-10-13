//
//  XWModel.m
//  XWNWS
//
//  Created by mac_m11 on 2022/8/24.
//

#import "XWModel.h"
#import <objc/runtime.h>
@interface XWModel()<NSCoding, NSCopying>

@end

@implementation XWModel

+ (instancetype) read
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:[self getKey]];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (BOOL) save
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:[[self class] getKey]];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}
- (BOOL) del
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:[[self class] getKey]];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (instancetype)readFromFileCacheWithFileName:(NSString *)fileName
{
    NSString *cachePath = [[self diskCacheDir]  stringByAppendingPathComponent:fileName];
    
    return [self readFromFilePath:cachePath];
}

- (BOOL)saveToFileCacheWithFileName:(NSString *)fileName
{
    NSString *cachePath = [[self.class diskCacheDir] stringByAppendingPathComponent:fileName];
    
    return [self saveToFilePath:cachePath];
    
}

+ (BOOL)deleteFromFileCacheWithFileName:(NSString *)fileName
{
    NSString *cachePath = [[self diskCacheDir] stringByAppendingPathComponent:fileName];
    return [self deleteFromFilePath:cachePath];
}

+ (instancetype) readFromFilePath:(NSString *)filePath {
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    id obj = nil;
    
    obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            
    return obj;
}

- (BOOL) saveToFilePath:(NSString *)filePath {
    NSData *data = nil;
    data = [NSKeyedArchiver archivedDataWithRootObject:self];
    
    if (data) {
        BOOL result = [data writeToFile:filePath atomically:YES];
        return result;
    }
    else {
        return NO;
    }
}

+ (BOOL) deleteFromFilePath:(NSString *)filePath {
    NSError *error = nil;
    return [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
}

+ (NSString *)diskCacheDir {
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES).firstObject;
    return cachePath;
}

- (instancetype) superDeepCopy
{
    XWModel *model = [[[self class] alloc] init];
    
    NSMutableDictionary *dict = [[self getIvarsAndValueMap] mutableCopy];
    
    [dict removeObjectsForKeys:[[self class] ignoredPropertiesForCopying]];
    
    NSDictionary *replacedKeyFromPropertyNameDict = nil;
    if ([[self class] respondsToSelector:@selector(modelCustomPropertyMapper)]) {
        replacedKeyFromPropertyNameDict = [[self class] modelCustomPropertyMapper];
    }
    NSArray *allKeys = [dict allKeys];
    [replacedKeyFromPropertyNameDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([allKeys containsObject:key]) {
            [dict setObject:[dict objectForKey:key] forKey:obj];
            [dict removeObjectForKey:key];
        }
        
    }];
    
    [dict removeObjectsForKeys:[[self class] ignoredPropertiesForCopying]];
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        id variable = nil;
        
        if ([obj isKindOfClass:[XWModel class]]) {
            variable = [obj superDeepCopy];
        }
        else if ([obj conformsToProtocol:@protocol(NSMutableCopying)] && [obj respondsToSelector:@selector(mutableCopy)]) {
            variable = [obj mutableCopy];
        }
        else {
            variable = obj;
        }
        
        [model setValue:variable forKey:key];
    }];
    
    return model;
}

- (void)synchronizeWithSCModel:(XWModel *)xwModel
{
    NSDictionary *dict = [xwModel getIvarsAndValueMap];
//    return [self modelSetWithDictionary:dict];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self setValue:obj forKey:key];
    }];
    
}

+ (NSString *) getKey
{
    return [NSString stringWithFormat:@"XW_Archive_%@", NSStringFromClass([self class])];
}

- (NSDictionary *)getIvarsAndValueMap
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

    unsigned int count = 0;
    Class currentClass = [self class];
    do {
        Ivar *ivars = class_copyIvarList(currentClass, &count);
        for (int i = 0; i<count; i++) {
            
            Ivar ivar = ivars[i];
            const char *name = ivar_getName(ivar);
            NSString *key = [NSString stringWithUTF8String:name];
            
            id value = [self valueForKey:key];
            if (value) {
                [dict setObject:value forKey:key];
            }
            
        }
        free(ivars);
        currentClass = [currentClass superclass];

    } while (currentClass != [XWModel class]);
    
    
    return [dict copy];
}

/* 获取LYModel以及他子类对象的所有属性 以及属性值  */
- (NSDictionary *)properties_aps
{
    
    Class currentClass = [self class];
    
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    
    do {
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList([currentClass class], &outCount);
        for (i = 0; i < outCount; i++)
        {
            objc_property_t property = properties[i];
            const char* char_f =property_getName(property);
            NSString *propertyName = [NSString stringWithUTF8String:char_f];
            id propertyValue = [self valueForKey:(NSString *)propertyName];
            if (propertyValue) [props setObject:propertyValue forKey:propertyName];
        }
        free(properties);
        
        currentClass = [currentClass superclass];
    } while (currentClass != [XWModel class]);
    
    return props;
}

#pragma mark -NSCopying
- (instancetype)copyWithZone:(NSZone *)zone
{
    XWModel *object = [[[self class] allocWithZone:zone] init];
    NSMutableDictionary *dict = [[self getIvarsAndValueMap] mutableCopy];
    
    [dict removeObjectsForKeys:[[self class] ignoredPropertiesForCopying]];
    
    NSDictionary *replacedKeyFromPropertyNameDict = nil;
    if ([[self class] respondsToSelector:@selector(modelCustomPropertyMapper)]) {
        replacedKeyFromPropertyNameDict = [[self class] modelCustomPropertyMapper];
    }
    NSArray *allKeys = [dict allKeys];
    [replacedKeyFromPropertyNameDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([allKeys containsObject:key]) {
            [dict setObject:[dict objectForKey:key] forKey:obj];
            [dict removeObjectForKey:key];
        }

    }];

    [dict removeObjectsForKeys:[[self class] ignoredPropertiesForCopying]];
    
//    BOOL value = [object modelSetWithDictionary:dict];
//    if (value) {
//        return object;
//    }
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [object setValue:obj forKey:key];
    }];
    
    return object;
}

#pragma mark - 归档
- (id)initWithCoder:(NSCoder *)coder
{
    Class cls = [self class];
    while (cls != [NSObject class]) {
        /*判断是自身类还是父类*/
        BOOL bIsSelfClass = (cls == [self class]);
        unsigned int iVarCount = 0;
        unsigned int propVarCount = 0;
        unsigned int sharedVarCount = 0;
        Ivar *ivarList = bIsSelfClass ? class_copyIvarList([cls class], &iVarCount) : NULL;/*变量列表，含属性以及私有变量*/
        objc_property_t *propList = bIsSelfClass ? NULL : class_copyPropertyList(cls, &propVarCount);/*属性列表*/
        sharedVarCount = bIsSelfClass ? iVarCount : propVarCount;
        NSArray *ignoredProperties = [[self class] ignoredProperties];

        for (int i = 0; i < sharedVarCount; i++) {
            const char *varName = bIsSelfClass ? ivar_getName(*(ivarList + i)) : property_getName(*(propList + i));
            NSString *key = [NSString stringWithUTF8String:varName];
            
            if (ignoredProperties.count && key.length > 1)
            {
                NSString *property = [key stringByReplacingCharactersInRange:(NSRange){0,1} withString:@""];
                if ([ignoredProperties containsObject:key] ||
                    [ignoredProperties containsObject:property])
                {
                    continue;
                }
            }
            
            id varValue = [coder decodeObjectForKey:key];
            NSArray *filters = @[@"superclass", @"description", @"debugDescription", @"hash"];
            if (varValue && [filters containsObject:key] == NO) {
                //奔溃在这里，检查下该属性的赋值状态。readonly。
                //归档反归档的属性，如果是class_copyPropertyList，需要手动生成setter方法或在重写ignoredProperties方法。
                [self setValue:varValue forKey:key];
            }
        }
        free(ivarList);
        free(propList);
        cls = class_getSuperclass(cls);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    Class cls = [self class];
    while (cls != [NSObject class]) {
        /*判断是自身类还是父类*/
        BOOL bIsSelfClass = (cls == [self class]);
        unsigned int iVarCount = 0;
        unsigned int propVarCount = 0;
        unsigned int sharedVarCount = 0;
        Ivar *ivarList = bIsSelfClass ? class_copyIvarList([cls class], &iVarCount) : NULL;/*变量列表，含属性以及私有变量*/
        objc_property_t *propList = bIsSelfClass ? NULL : class_copyPropertyList(cls, &propVarCount);/*属性列表*/
        sharedVarCount = bIsSelfClass ? iVarCount : propVarCount;
        NSArray *ignoredProperties = [[self class] ignoredProperties];
        
        for (int i = 0; i < sharedVarCount; i++) {
            const char *varName = bIsSelfClass ? ivar_getName(*(ivarList + i)) : property_getName(*(propList + i));
            NSString *key = [NSString stringWithUTF8String:varName];
            
            if (ignoredProperties.count && key.length > 1)
            {
                NSString *property = [key stringByReplacingCharactersInRange:(NSRange){0,1} withString:@""];
                if ([ignoredProperties containsObject:key] ||
                    [ignoredProperties containsObject:property])
                {
                    continue;
                }
            }
            
            /*valueForKey只能获取本类所有变量以及所有层级父类的属性，不包含任何父类的私有变量(会崩溃)*/
            id varValue = [self valueForKey:key];
            NSArray *filters = @[@"superclass", @"description", @"debugDescription", @"hash"];
            if (varValue && [filters containsObject:key] == NO) {
                [coder encodeObject:varValue forKey:key];
            }
        }
        free(ivarList);
        free(propList);
        cls = class_getSuperclass(cls);
    }
}


+ (NSArray<NSString *> *)ignoredProperties
{
    return nil;
}

+ (NSArray<NSString *>*)ignoredPropertiesForCopying
{
    return nil;
}

@end
