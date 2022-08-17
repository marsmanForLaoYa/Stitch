//
//  SettingTableViewCell.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SettingTableViewCell : UITableViewCell
@property (nonatomic, strong) UILabel *setingLabel;
- (void)configModel:(NSString *)str andTag:(NSInteger)tag andType:(NSInteger)type;

@end

NS_ASSUME_NONNULL_END
