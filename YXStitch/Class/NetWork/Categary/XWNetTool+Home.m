//
//  XWNetTool+Home.m
//  XWNWS
//
//  Created by mac_m11 on 2022/9/15.
//

#import "XWNetTool+Home.h"
#import "MJExtension.h"

@implementation XWNetTool (Home)

- (NSURLSessionDataTask *)queryApplicationListWithCallback:(void(^)(NSArray <HomeModel *>* _Nullable dataSources, BOOL isProcessing, NSString * _Nullable errorMsg))callback
{
    NSDictionary *params = @{
        @"appname":[[NSBundle mainBundle] bundleIdentifier],
        @"version":[NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"]
    };
    
    return [self getRequestWithUrl:API_HOME_APPLICATION_LIST withParam:params success:^(id  _Nullable responseObject) {
        
        BOOL isProcessing = NO;
        if ([[responseObject allKeys] containsObject:@"is_review"]) {
            isProcessing = [responseObject[@"is_review"] boolValue];
        }
        
        if ([[responseObject allKeys] containsObject:@"advertisements"]) {
            NSArray *adverArr = responseObject[@"advertisements"];
            if (adverArr.count>0) {
                NSDictionary *alertDic =adverArr[0];
                [User current].advertisingDic = [NSDictionary dictionaryWithDictionary:alertDic];
            }
        }
        // 数据
        if ([[responseObject allKeys] containsObject:@"navigations"]) {
            NSArray *navigationsArr = responseObject[@"navigations"];
            NSArray *datas = [HomeModel mj_objectArrayWithKeyValuesArray:navigationsArr];

            NSArray *sortDatas = [datas sortedArrayUsingComparator:^NSComparisonResult(HomeModel * _Nonnull model1, HomeModel * _Nonnull model2) {

                if (model1.sort < model2.sort){
                    return NSOrderedAscending;

                }else{
                    return NSOrderedDescending;
                }
            }];

            callback(sortDatas, isProcessing, nil);
        }
        else
        {
            callback(nil, nil, @"失败");
        }
        
    } failure:^(NSError * _Nonnull error) {
        callback(nil, nil, error.description);
    }];
}

@end
