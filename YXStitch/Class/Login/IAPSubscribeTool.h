//
//  IAPSubscribeTool.h
//  XWNWS
//
//  Created by mac_m11 on 2022/9/7.
//

#import <Foundation/Foundation.h>

typedef void (^IAPFinishedBlock)(NSString * _Nullable errorMsg, NSURL * _Nullable appStoreReceiptURL, BOOL isTest, BOOL isAutoRenewal);

NS_ASSUME_NONNULL_BEGIN

@interface IAPSubscribeTool : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, nullable, copy) IAPFinishedBlock iAPFinishedBlock;

- (void)buy:(NSString *)productId finishedBlock:(IAPFinishedBlock)finishedBlock;

- (void)listenerBlock:(IAPFinishedBlock)listenerBlock;

- (void)restoreBuyVip;

- (void)removeTransactionObserver;

@end

NS_ASSUME_NONNULL_END
