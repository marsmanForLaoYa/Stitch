//
//  User.m
//  XWNWS
//
//  Created by mac_m11 on 2022/9/7.
//

#import "User.h"
#import "YKeychain.h"

@implementation User

@dynamic remainingDownloadTimes;
@dynamic account;

+ (instancetype)current {
    static User *user;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        user = [User read];
        if (!user)
        {
            user = [[User alloc] init];
        }
    });
    return user;
}

- (instancetype)init
{
    self = [super init];
    if (self) {

//        _login = YES;
//        _vipMember = YES;
    }
    return self;
}

- (BOOL)syncUpdateUser:(User *)user
{
    @try {
        id json = user.modelToJSONObject;
        if (json == nil)
        {
            return NO;
        }
        BOOL a = [self modelSetWithJSON:json];
        return YES;
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

- (NSString *)account
{
    NSString *uuid;
    NSString *uuidCache = [YKeychain valueForKey:@"account"];
    if (uuidCache) {
        uuid = uuidCache;
    }else {
        uuid = [NSUUID UUID].UUIDString;
        //如果没有获取到uuid，则随机生成一个字符串
        if (uuid == nil) {
            uuid = [self randomAcount:10];
        }
        //需要使用钥匙串的方式保存用户的唯一信息
        [YKeychain setValue:uuid forKey:@"account"];
    }
    return uuid;
}

- (void)setAccount:(NSString *)account
{
    
}

// 随机生成字符串(由大小写字母、数字组成)
- (NSString *)randomAcount:(int)len {
    
    char ch[len];
    for (int index=0; index<len; index++) {
        
        int num = arc4random_uniform(75)+48;
        if (num>57 && num<65) { num = num%57+48; }
        else if (num>90 && num<97) { num = num%90+65; }
        ch[index] = num;
    }
    return [[NSString alloc] initWithBytes:ch length:len encoding:NSUTF8StringEncoding];
}

- (int)remainingDownloadTimes
{
    NSString *count = [YKeychain valueForKey:@"VideoRemainingTimes"];
    if (count) {
        return [count intValue];
    }else{

        //把UUID存入到钥匙串
        [YKeychain setValue:@"5" forKey:@"VideoRemainingTimes"];
        return 5;
    }
}

- (void)setRemainingDownloadTimes:(int)remainingDownloadTimes
{

}

- (void)remainingDownloadTimesReduce {
    NSString *count = [YKeychain valueForKey:@"VideoRemainingTimes"];
    if (count) {
        if ([count intValue]>0) {
            int current = [count intValue]-1;
            NSString *saveStr = [NSString stringWithFormat:@"%d",current];
            [YKeychain setValue:saveStr forKey:@"VideoRemainingTimes"];
        }
    }else{
        //把UUID存入到钥匙串
        [YKeychain setValue:@"5" forKey:@"VideoRemainingTimes"];
    }
}

- (void)logout {

    [[NSNotificationCenter defaultCenter] postNotificationName:kLogoutNotification object:nil];
    self.vipMember = NO;
    self.login = NO;
}

// 获取当前控制器
+(UIViewController *)getCurrentVC {
    
    UIViewController *keyVC = nil;
    keyVC = [self viewControllerWithTab:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (keyVC.presentedViewController) {
        keyVC = [self viewControllerWithTab:keyVC.presentedViewController];
    }
    return keyVC;
}

+(UIViewController *)viewControllerWithTab:(UIViewController *)viewController {
    
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        return [self viewControllerWithTab:[(UINavigationController *)viewController topViewController]];
    } else if ([viewController isKindOfClass:[UITabBarController class]]) {
        return [self viewControllerWithTab:[(UITabBarController *)viewController selectedViewController]];
    } else {
        return viewController;
    }
    return nil;
}

+ (BOOL)checkLogin
{
    BOOL login = [User current].isLogin;
    if (!login) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
        [SVProgressHUD showInfoWithStatus:@"未登录"];
        [SVProgressHUD dismissWithDelay:2.0];
    }
    
    return login;
}

+ (BOOL)checkIsVipMember {
    
    if ([self checkLogin]) {
        BOOL vip = [User current].isVipMember;
        
        return vip;
    }
    else
    {
        return NO;
    }
}

@end
