//
//  IAPSubscribeTool.m
//  XWNWS
//
//  Created by mac_m11 on 2022/9/7.
//

#import "IAPSubscribeTool.h"
#import <StoreKit/StoreKit.h>

@interface IAPSubscribeTool ()<SKProductsRequestDelegate,SKPaymentTransactionObserver>

//@property (nonatomic, assign) NSInteger verifyCount;
@property (nonatomic, copy) NSString *productId;

@end

@implementation IAPSubscribeTool

- (void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

+ (instancetype)sharedInstance
{
    static IAPSubscribeTool *iap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        iap = [[IAPSubscribeTool alloc] init];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:iap];
    });
    return iap;
}

- (void)listenerBlock:(IAPFinishedBlock)listenerBlock
{
    self.iAPFinishedBlock = listenerBlock;
}

- (void)buy:(NSString *)productId finishedBlock:(IAPFinishedBlock)finishedBlock {
    
    self.productId = productId;
    self.iAPFinishedBlock = finishedBlock;
    
    if ([SKPaymentQueue canMakePayments]) {
     
        [self requestProductData: productId];
//        NSLog(@"允许程序内付费购买");
    }else{
        
        if (self.iAPFinishedBlock) {
            self.iAPFinishedBlock(@"不允许程序内付费购买", nil, NO, NO);
        }
    }
}

-(void)requestProductData:(NSString *)productId {

    NSLog(@"---------请求对应的产品信息------------");
    NSArray *product = @[productId];
    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers: nsset];
    request.delegate=self;
    [request start];
}

#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(nonnull SKProductsRequest *)request didReceiveResponse:(nonnull SKProductsResponse *)response {
    
    NSArray *products = response.products;
    if (products.count == 0) {
        
        if (self.iAPFinishedBlock) {
            self.iAPFinishedBlock(@"失败", nil, NO, NO);
        }
        return;
    }
    
    SKProduct *product = nil;
    for (SKProduct *pro in products) {
        
        if ([pro.productIdentifier isEqualToString:self.productId]) {
            product = pro;
        }
    }
    
    // 发送购买请求
    if (product != nil) {
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue]addPayment:payment];
    }
}

//请求失败回调
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    if (self.iAPFinishedBlock) {
        self.iAPFinishedBlock(error.description, nil, NO, NO);
    }
}

- (void)requestDidFinish:(SKRequest *)request
{
    NSLog(@"----------反馈信息结束--------------");
}

#pragma mark - SKPaymentTransactionObserver
// 监听购买结果
- (void)paymentQueue:(nonnull SKPaymentQueue *)queue updatedTransactions:(nonnull NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *tran in transactions){
        
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased:
                NSLog(@"交易完成");
                // 订阅特殊处理
                if (tran.originalTransaction) {
                    // 如果是自动续费的订单,originalTransaction会有内容
                    NSLog(@"自动续费的订单,originalTransaction = %@",tran.originalTransaction);
                } else {
                    // 普通购买，以及第一次购买自动订阅
                    NSLog(@"普通购买，以及第一次购买自动订阅");
                }
                [self completeTransaction:tran];

                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"商品添加进列表");
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"已经购买过商品");
                [self completeTransaction:tran];

                //[[SKPaymentQueue defaultQueue] finishTransaction:tran];
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"交易失败");
//                [self.channel invokeMethod:kPluginResponseName arguments:@(0)];
//                [self yFailTransaction:tran];
//                [SVProgressHUD dismiss];
                if (self.iAPFinishedBlock) {
                    self.iAPFinishedBlock([self yFailTransaction:tran], nil, NO, NO);
                }
                break;
            default:
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    if (self.iAPFinishedBlock) {
        self.iAPFinishedBlock(error.description, nil, NO, NO);
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
//    if (self.completedBlock) {
//        self.completedBlock(nil);
//    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    
    NSString * str = [[NSString alloc] initWithData:transaction.transactionReceipt encoding:NSUTF8StringEncoding];
    BOOL isTest = NO;
    if ([str containsString:@"Sandbox"]) {
        isTest = YES;
    }
    
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    if (self.iAPFinishedBlock) {
        if (transaction.originalTransaction) {
            self.iAPFinishedBlock(nil, receiptURL, isTest, YES);
        }
        else
        {
            self.iAPFinishedBlock(nil, receiptURL, isTest, NO);
        }
        
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

#pragma mark - 失败详情
- (NSString *)yFailTransaction:(SKPaymentTransaction *)tranacton {
    
    
    if (tranacton.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@ %ld", tranacton.error.localizedDescription,(long)tranacton.error.code);
    }

    if ([SKPaymentQueue defaultQueue]) {
        [[SKPaymentQueue defaultQueue] finishTransaction: tranacton];
    }
    
    NSString *MXCnstErrorString = @"";
    NSInteger MXCnstErrorStringCode = tranacton.error.code;
    
    if (@available(iOS 9.3, *)) {
        switch (MXCnstErrorStringCode) {
            case SKErrorCloudServiceNetworkConnectionFailed:
                MXCnstErrorString = @"设备未能连接网络，请查看设备网络！";
                break;
            case SKErrorCloudServicePermissionDenied:
                MXCnstErrorString = @"用户不允许访问云服务信息，请查看设备设置！";
                break;
            default:
                break;
        }
    } else if (@available(iOS 10.3, *)) {
        switch (MXCnstErrorStringCode) {
            case SKErrorCloudServiceRevoked:
                MXCnstErrorString = @"用户已撤销使用此云服务的权限，请查看设备设置！";
                break;
            default:
                break;
        }
    } else if (@available(iOS 12.2, *)) {
        switch (MXCnstErrorStringCode) {
            case SKErrorPrivacyAcknowledgementRequired:
                MXCnstErrorString = @"用户需要确认苹果的隐私政策！";
                break;
            case SKErrorUnauthorizedRequestData:
                MXCnstErrorString = @"该应用程序试图使用SKPayment的requestData属性，但没有相应的权限！";
                break;
            case SKErrorInvalidOfferIdentifier:
                MXCnstErrorString = @"指定的订阅要约标识符无效,请联系客服！";
                break;
            case SKErrorInvalidSignature:
                MXCnstErrorString = @"提供的密码签名无效！";
                break;
            case SKErrorMissingOfferParams:
                MXCnstErrorString = @"缺少来自SKPaymentDiscount的一个或多个参数！";
                break;
            case SKErrorInvalidOfferPrice:
                MXCnstErrorString = @"所选要约的价格无效！";
                break;
            default:
                break;
        }
    }
    
    switch (MXCnstErrorStringCode) {
        case SKErrorPaymentInvalid:
            MXCnstErrorString = @"商品标识无效，请联系客服！";
            break;
        case SKErrorUnknown:
            MXCnstErrorString = [tranacton.error localizedDescription];
            break;
        case SKErrorPaymentCancelled:
            MXCnstErrorString = @"订单已取消！";
            break;
        case SKErrorClientInvalid:
            MXCnstErrorString = @"不允许客户端发出请求，请联系客服！";
            break;
        case SKErrorPaymentNotAllowed:
            MXCnstErrorString = @"此设备是不允许付款！";
            break;
        case SKErrorStoreProductNotAvailable:
            MXCnstErrorString = @"该产品在当前的店面中不可用！";
            break;
        default:
            break;
    }
    NSLog(@"详情信息：%@",MXCnstErrorString);

    return MXCnstErrorString;
}

- (void)restoreBuyVip
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)removeTransactionObserver
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

@end
