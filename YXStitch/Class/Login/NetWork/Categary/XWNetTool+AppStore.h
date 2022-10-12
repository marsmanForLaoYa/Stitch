//
//  XWNetTool+AppStore.h
//  XWNWS
//
//  Created by mac_m11 on 2022/9/15.
//

#import "XWNetTool.h"

NS_ASSUME_NONNULL_BEGIN

@interface XWNetTool (AppStore)

- (NSURLSessionDataTask *)uploadSubscribeReceiptToServiceWithUrl:(NSURL *)appStoreReceiptURL isTest:(BOOL)isTest needAutoCheck:(BOOL)needAutoCheck callback:(nullable void(^)(NSString * _Nullable errorMsg))callback;

@end

NS_ASSUME_NONNULL_END
