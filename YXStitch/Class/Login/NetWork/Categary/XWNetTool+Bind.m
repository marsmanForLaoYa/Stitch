//
//  XWNetTool+Bind.m
//  XWNWS
//
//  Created by mac_m11 on 2022/9/15.
//

#import "XWNetTool+Bind.h"

@implementation XWNetTool (Bind)

- (NSURLSessionDataTask *)uploadInvataionCodelWithCode:(NSString *)code callback:(nullable void(^)(NSString *errorMsg, NSInteger code))callback
{
    if (code == nil || code.length == 0) {
        callback(@"失败", CodeErrorEmpty);
        return nil;
    }
    NSDictionary *params = @{
        @"invitation_code": code
    };
    NSString *author = [NSString stringWithFormat:@"Bearer %@", [User current].token];
    NSDictionary *headers = @{
        @"authorization":author
    };
    
    return [self postRequestWithUrl:API_USER_BIND withParam:params headers:headers success:^(id  _Nullable responseObject) {
        
        if (responseObject) {
            NSInteger errorCode = [responseObject[@"error"] integerValue];
            NSString *msg = responseObject[@"msg"];
            if (errorCode == CodeSuccess) {
                
                callback(nil, errorCode);
            }
            else
            {
                callback(msg, errorCode);
            }
        }
        else
        {
            callback(@"失败", CodeErrorEmpty);
        }
        
    } failure:^(NSError * _Nonnull error) {
        callback(@"失败", error.code);
    }];
}

@end
