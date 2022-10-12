//
//  XWNetTool.m
//  XWNWS
//
//  Created by xwan-iossdk on 2022/6/17.
//

#import "XWNetTool.h"

//#define BASEURL @"http://api.rocketbrowser.xyz/youtube"

@implementation XWNetTool

static XWNetTool *_XWNetTool;
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _XWNetTool = [[self alloc] init];
    });
    
    return _XWNetTool;
}

- (NSURLSessionDataTask *)getRequestWithUrl:(NSString *)url withParam:(NSDictionary *)param success:(nullable void (^)(id _Nullable responseObject))success failure:(nullable void (^)(NSError * _Nonnull error))failure{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@", BASEURL_DOMAIN, url];
    return [manager GET:baseUrl parameters:param headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"responseObject = %@",responseObject);
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

- (NSURLSessionDataTask *)getRequestWithUrl:(NSString *)url withParam:(nullable NSDictionary *)param headers:(nullable NSDictionary <NSString *, NSString *> *)headers success:(nullable void (^)(id _Nullable responseObject))success failure:(nullable void (^)(NSError * _Nonnull error))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@", BASEURL_DOMAIN, url];
    return [manager GET:baseUrl parameters:param headers:headers progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"responseObject = %@",responseObject);
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void)taskCancel
{
    [[AFHTTPSessionManager manager].tasks makeObjectsPerformSelector:@selector(cancel)];
}

- (NSURLSessionDataTask *)postRequestWithUrl:(NSString *)url withParam:(NSDictionary * _Nullable)param success:(nullable void (^)(id _Nullable responseObject))success failure:(nullable void (^)(NSError * _Nonnull error))failure{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
//    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
//    NSMutableSet *setM = [NSMutableSet setWithSet:manager.responseSerializer.acceptableContentTypes];
//    [setM addObject:@"text/html"];
//    [responseSerializer setAcceptableContentTypes:setM];
//    [manager setResponseSerializer:responseSerializer];
    
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@", BASEURL_DOMAIN, url];
    return [manager POST:baseUrl parameters:param headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

- (NSURLSessionDataTask *)postRequestWithUrl:(NSString *)url withParam:(NSDictionary * _Nullable)param headers:(nullable NSDictionary <NSString *, NSString *> *)headers success:(nullable void (^)(id _Nullable responseObject))success failure:(nullable void (^)(NSError * _Nonnull error))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@", BASEURL_DOMAIN, url];
    return [manager POST:baseUrl parameters:param headers:headers progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

- (BOOL)isEmpty:(NSString *)str {
    if (str == nil) {
        return YES;
    }
    NSString *tempStr = [NSString stringWithFormat:@"%@",str];
    
    if (!tempStr) {
        return YES;
    }
    if ([tempStr isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (!tempStr.length) {
        return YES;
    }
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedStr = [tempStr stringByTrimmingCharactersInSet:set];
    if (!trimmedStr.length) {
        return YES;
    }
    return NO;
}

@end
