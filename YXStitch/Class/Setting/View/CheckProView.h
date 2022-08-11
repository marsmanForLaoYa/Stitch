//
//  CheckProView.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/10.
//

#import "BaseView.h"
#import "SettingViewController.h"
NS_ASSUME_NONNULL_BEGIN
@protocol CheckProViewDelegate <NSObject>
@optional
- (void)cancelClickWithTag:(NSInteger)tag;
@end

@interface CheckProView : BaseView
@property (nonatomic, assign) id<CheckProViewDelegate> delegate;
@property (nonatomic, weak) SettingViewController *vc;
@end

NS_ASSUME_NONNULL_END
