//
//  XWNetTool+Bind.h
//  XWNWS
//
//  Created by mac_m11 on 2022/9/15.
//

#import "XWNetTool.h"

NS_ASSUME_NONNULL_BEGIN

@interface XWNetTool (Bind)

- (NSURLSessionDataTask *)uploadInvataionCodelWithCode:(NSString *)code callback:(nullable void(^)(NSString *errorMsg, NSInteger code))callback;

@end

NS_ASSUME_NONNULL_END
