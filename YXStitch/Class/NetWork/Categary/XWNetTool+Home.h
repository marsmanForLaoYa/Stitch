//
//  XWNetTool+Home.h
//  XWNWS
//
//  Created by mac_m11 on 2022/9/15.
//

#import "XWNetTool.h"
#import "HomeModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface XWNetTool (Home)

- (NSURLSessionDataTask *)queryApplicationListWithCallback:(void(^)(NSArray <HomeModel *>* _Nullable dataSources, BOOL isProcessing, NSString * _Nullable errorMsg))callback;

@end

NS_ASSUME_NONNULL_END
