//
//  XWNetTool+Login.h
//  XWNWS
//
//  Created by mac_m11 on 2022/9/14.
//

#import "XWNetTool.h"

NS_ASSUME_NONNULL_BEGIN

@interface XWNetTool (Login)

/// 登录
/// @param callback <#callback description#>
- (NSURLSessionDataTask *)loginWithCallback:(nullable void(^)(User *user, NSString *errorMsg, NSInteger code))callback;

- (NSURLSessionDataTask *)queryUserInformationShowAdAlert:(BOOL)show callback:(nullable void(^)(User *user, NSString *errorMsg, NSInteger code))callback;

@end

NS_ASSUME_NONNULL_END
