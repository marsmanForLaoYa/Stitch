//
//  XWNetTool+AppStore.m
//  XWNWS
//
//  Created by mac_m11 on 2022/9/15.
//

#import "XWNetTool+AppStore.h"

@implementation XWNetTool (AppStore)

- (NSURLSessionDataTask *)uploadSubscribeReceiptToServiceWithUrl:(NSURL *)appStoreReceiptURL isTest:(BOOL)isTest needAutoCheck:(BOOL)needAutoCheck callback:(nullable void(^)(NSString * _Nullable errorMsg))callback
{
    if (appStoreReceiptURL == nil) {
        if (callback) {
            callback(@"失败");
        }
        return nil;
    }
    NSData *receiptData = [NSData dataWithContentsOfURL:appStoreReceiptURL];// 从沙盒中获取到购买凭据
    NSString *receiptBase64 = [NSString base64StringFromData:receiptData length:[receiptData length]];
    NSDictionary *paramDic = @{
        @"receipt":receiptBase64,
        @"package":[[NSBundle mainBundle] bundleIdentifier],
        @"need_auto_check":@(needAutoCheck),
        @"test":@(isTest)
    };
    
    NSString *author = [NSString stringWithFormat:@"Bearer %@", [User current].token];
    
    return [self postRequestWithUrl:API_APPSTORE_RECEIPT withParam:paramDic headers:@{@"authorization":author} success:^(id  _Nullable responseObject) {
        
        NSLog(@"%@", responseObject);
        if (responseObject) {
            NSInteger errorCode = [responseObject[@"error"] integerValue];
//            NSString *msg = responseObject[@"msg"];
            if (errorCode == CodeSuccess) {
                //每次订阅并上传数据到服务器后，从服务器重新获取当前的会员状态
                [[XWNetTool sharedInstance] queryUserInformationShowAdAlert:NO callback:^(User * _Nonnull user, NSString * _Nonnull errorMsg, NSInteger code) {
                    if (errorMsg) {
                        if (callback) {
                            callback(errorMsg);
                        }
                    }
                    else
                    {
                        if (callback) {
                            callback(nil);
                        }
                    }
                }];
            }
            else
            {
                if (callback) {
                    callback(@"失败");
                }
            }
        }
        else
        {
            if (callback) {
                callback(@"失败");
            }
        }
    } failure:^(NSError * _Nonnull error) {
        if (callback) {
            callback(error.description);
        }
    }];
}

@end
