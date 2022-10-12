//
//  XWNetTool.h
//  XWNWS
//
//  Created by xwan-iossdk on 2022/6/17.
//

#import <Foundation/Foundation.h>
#import "NetworkAPI.h"
#import "NetworkErrorCode.h"
#import "AFHTTPSessionManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface XWNetTool : NSObject

+ (instancetype)sharedInstance;

- (NSURLSessionDataTask *)getRequestWithUrl:(NSString *)url withParam:(NSDictionary *)param success:(nullable void (^)(id _Nullable responseObject))success failure:(nullable void (^)(NSError * _Nonnull error))failure;

- (NSURLSessionDataTask *)getRequestWithUrl:(NSString *)url withParam:(nullable NSDictionary *)param headers:(nullable NSDictionary <NSString *, NSString *> *)headers success:(nullable void (^)(id _Nullable responseObject))success failure:(nullable void (^)(NSError * _Nonnull error))failure;

- (void)taskCancel;

- (NSURLSessionDataTask *)postRequestWithUrl:(NSString *)url withParam:(NSDictionary * _Nullable)param success:(nullable void (^)(id _Nullable responseObject))success failure:(nullable void (^)(NSError * _Nonnull error))failure;

- (NSURLSessionDataTask *)postRequestWithUrl:(NSString *)url withParam:(NSDictionary * _Nullable)param headers:(nullable NSDictionary <NSString *, NSString *> *)headers success:(nullable void (^)(id _Nullable responseObject))success failure:(nullable void (^)(NSError * _Nonnull error))failure;

- (BOOL)isEmpty:(NSString *)str;

@end

NS_ASSUME_NONNULL_END
