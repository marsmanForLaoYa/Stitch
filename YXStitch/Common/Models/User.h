//
//  User.h
//  XWNWS
//
//  Created by mac_m11 on 2022/9/7.
//

#import "XWModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface User : XWModel

+ (instancetype)current;

@property (nonatomic, assign, getter=isLogin) BOOL login;

#pragma mark - 从登录接口获取
@property (nonatomic, copy) NSString *token;
//token过期时间
@property (nonatomic, assign) NSUInteger tokenExpireTimeStamp;

#pragma mark - 从用户信息接口获取
//在服务器注册后生成的id
@property (nonatomic, copy) NSString *userId;
//上级用户id
@property (nonatomic, copy) NSString *parentId;
//@property (nonatomic, assign, getter=isVip) BOOL vip;
@property (nonatomic, assign, getter=isVipMember) BOOL vipMember;
@property (nonatomic, assign) NSUInteger vipExpireTimeStamp;
@property (nonatomic, assign) NSUInteger videoDownTimes;
@property (nonatomic, assign) NSUInteger vipBuyTimeStamp;
//是否从appstore购买vip
@property (nonatomic, assign) BOOL isVipAppStore;
//是用户状态 1 为正常
@property (nonatomic, copy) NSString *status;
//共邀请了几次
@property (nonatomic, assign) NSUInteger totalInvites;

#pragma mark - 邀请码，第一次从剪切板获取，上传服务器后从用户信息接口获取
@property (nonatomic, copy) NSString *invitation_code;

#pragma mark - 广告
@property (nonatomic, copy) NSDictionary *advertisingDic;

#pragma mark - share
//分享描述
@property (nonatomic, copy) NSString *shareDescription;
//分享Url
@property (nonatomic, copy) NSString *shareUrl;

#pragma mark - keychain Property
//账号(设备的uuid自动生成)
@property (nonatomic, copy) NSString *account;

//未开通会员时，剩余下载次数
@property (nonatomic, assign) int remainingDownloadTimes;

//减少下载次数
- (void)remainingDownloadTimesReduce;

- (BOOL)syncUpdateUser:(User *)user;

- (void)logout;

+(UIViewController *)getCurrentVC;

+ (BOOL)checkLogin;
+ (BOOL)checkIsVipMember;

@end

NS_ASSUME_NONNULL_END
