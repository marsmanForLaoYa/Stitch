//
//  IMGFuctionView.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IMGFuctionView : UIView
@property (nonatomic ,copy)void(^btnClick)(NSInteger tag);

@end
NS_ASSUME_NONNULL_END
