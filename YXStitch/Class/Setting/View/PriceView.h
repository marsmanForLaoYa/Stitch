//
//  PriceView.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol PriceViewDelegate <NSObject>
@optional
- (void)buyClickWithTag:(NSInteger)tag;
@end

@interface PriceView : UIView
@property (nonatomic, assign) id<PriceViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
