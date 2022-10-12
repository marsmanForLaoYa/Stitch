//
//  XWNetTool+Login.m
//  XWNWS
//
//  Created by mac_m11 on 2022/9/14.
//

#import "XWNetTool+Login.h"

@implementation XWNetTool (Login)

- (NSURLSessionDataTask *)loginWithCallback:(nullable void(^)(User *user, NSString *errorMsg, NSInteger code))callback
{
    if ([User current].account == nil || [User current].account.length == 0) {
        if (callback) {
            callback(nil, @"失败", CodeErrorEmpty);
        }
        return nil;
    }
    
    NSDictionary *param;
    if ([User current].invitation_code != nil && [User current].invitation_code.length > 0) {
        param = @{
            @"uuid":[User current].account,
            @"invitation_code":[User current].invitation_code
        };
    }
    else
    {
        param = @{
            @"uuid":[User current].account,
        };
    }

    return [self postRequestWithUrl:API_AUTH_LOGIN withParam:param success:^(id  _Nullable responseObject) {
        
        if (responseObject) {
            NSInteger errorCode = [responseObject[@"error"] integerValue];
            if (errorCode == CodeSuccess) {
                NSDictionary *dic = responseObject[@"data"];
                NSString *token = dic[@"token"];
                NSString *expire_time = dic[@"expire_time"];
                User *user = [User current];
                user.token = token;
                user.tokenExpireTimeStamp = [expire_time integerValue];

//                callback(user, nil, errorCode);
                //获取个人信息
                [self queryUserInformationShowAdAlert:YES callback:callback];
                //检查剪切板中是否有内容
                [self checkHaveInviteCodeIfHaveUpload];
            }
            else
            {
                if (callback) {
                    callback(nil, @"失败", errorCode);
                }
            }
        }
        else
        {
            if (callback) {
                callback(nil, @"失败", CodeErrorEmpty);
            }
        }
        
    } failure:^(NSError * _Nonnull error) {
        if (callback) {
            callback(nil, error.description, error.code);
        }
    }];
}

- (void)checkHaveInviteCodeIfHaveUpload {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    if (pasteboard.string == nil) {
        return;
    }
    NSData *jsonData = [pasteboard.string dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&error];
    if (dic) {
        NSString *code = dic[@"code"];
        [[XWNetTool sharedInstance] uploadInvataionCodelWithCode:code callback:^(NSString * _Nonnull errorMsg, NSInteger code) {
            if (code == CodeSuccess) {
//                pasteboard.string = nil;
                //输入了邀请码会得到7天VIP有必要重新获取一下用户信息
                [self queryUserInformationShowAdAlert:NO callback:nil];
            }
            else if (code == CodeBindInviteCodeNoExist ||
                     code == CodeBindHadBindUser ||
                     code == CodeBindError)
            {
//                pasteboard.string = nil;
            }
        }];
    }
}

- (NSURLSessionDataTask *)queryUserInformationShowAdAlert:(BOOL)show callback:(nullable void(^)(User *user, NSString *errorMsg, NSInteger code))callback
{
    NSDictionary *params = @{
        @"appname":[[NSBundle mainBundle] bundleIdentifier]
    };
    NSString *author = [NSString stringWithFormat:@"Bearer %@", [User current].token];
    return [self getRequestWithUrl:API_USER_INFO withParam:params headers:@{@"authorization":author} success:^(id  _Nullable responseObject) {
        
        if (responseObject) {
            NSInteger errorCode = [responseObject[@"error"] integerValue];
            if (errorCode == CodeSuccess) {
                NSDictionary *dic = responseObject[@"user"];
                NSString *userId = dic[@"id"];
                NSString *invitation_code = dic[@"invitation_code"];
                NSString *parent_id = dic[@"parent_id"];
                NSString *vip = dic[@"vip"];
                NSString *expire_time = dic[@"expire_time"];
                NSString *video_down_times = dic[@"video_down_times"];
                NSString *vip_buy_time = dic[@"vip_buy_time"];
                NSString *is_vip_appstore = dic[@"is_vip_appstore"];
                NSString *status = dic[@"status"];
                NSString *total_invites = dic[@"total_invites"];
                NSArray *shareArray = responseObject[@"shares"];

                User *user = [User current];
                user.userId = userId;
                user.invitation_code = invitation_code;
                user.parentId = parent_id;
                user.vipMember = [vip boolValue];
                user.vipExpireTimeStamp = [expire_time integerValue];
                user.videoDownTimes = [video_down_times integerValue];
                user.vipBuyTimeStamp = [vip_buy_time integerValue];
                user.isVipAppStore = [is_vip_appstore boolValue];
                user.status = status;
                user.totalInvites = [total_invites integerValue];
                user.login = YES;
                
                if(shareArray.count >= 0)
                {
                    NSDictionary *shareDic = shareArray.firstObject;
                    user.shareDescription = shareDic[@"description"];
                    user.shareUrl = shareDic[@"url"];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccessNotification object:nil];

                //如果不是vip，则显示广告
                if (!user.vipMember) {
                    if (show) {
                        [self showADAlertView];
                    }
                }
                if (callback) {
                    callback(user, nil, errorCode);
                }
            }
            else
            {
                if (callback) {
                    callback(nil, @"失败", errorCode);
                }
            }
        }
        else
        {
            if (callback) {
                callback(nil, @"失败", CodeErrorEmpty);
            }
        }
    } failure:^(NSError * _Nonnull error) {
        if (callback) {
            callback(nil, @"失败", CodeErrorEmpty);
        }
    }];
}

- (void)showADAlertView {

//    if ([videoChangeTool sharedInstance].AlertImgDic && [[[videoChangeTool sharedInstance].AlertImgDic allKeys] containsObject:@"image"] && [[[videoChangeTool sharedInstance].AlertImgDic allKeys] containsObject:@"url"]) {
//        [self AddViewWithInfoDic:[videoChangeTool sharedInstance].AlertImgDic];
//    }else {
//        [[XWNetTool sharedInstance] queryApplicationListWithCallback:^(NSArray<HomeModel *> * _Nullable dataSources, BOOL isAppStore, NSString * _Nullable errorMsg) {
//      
//            if (!errorMsg) {
//                [self AddViewWithInfoDic:[videoChangeTool sharedInstance].AlertImgDic];
//            }
//        }];
//    }
}

// 添加view
- (void)AddViewWithInfoDic:(NSDictionary *)infoDic{
    
//    if([infoDic allKeys].count == 0)
//    {
//        return;
//    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        ADDAlertView *view = [[ADDAlertView alloc] init];
//        view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
//        if ([[infoDic allKeys] containsObject:@"image"]) {
//            view.imgStr = infoDic[@"image"];
//        }
//        if ([[infoDic allKeys] containsObject:@"url"]) {
//            view.urlStr = infoDic[@"url"];
//        }
//        [[UIApplication sharedApplication].keyWindow addSubview:view];
//    });
}

@end
