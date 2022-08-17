//
//  PrefenceTableViewCell.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PrefenceTableViewCell <NSObject>
@optional
- (void)autoDeleteWith:(BOOL)isAuto;
@end

@interface PrefenceTableViewCell : UITableViewCell
@property (nonatomic, assign) id<PrefenceTableViewCell> delegate;
@property (nonatomic, strong) UILabel *setingLabel;
@property (nonatomic, strong) UISwitch *funcswitch;
- (void)configModel:(NSString *)str andTag:(NSInteger)tag;
@end

NS_ASSUME_NONNULL_END
