//
//  ShellTableViewCell.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/9/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShellTableViewCell : UITableViewCell
@property (nonatomic, strong) UILabel *phoneLabel;
- (void)configModelWithTag:(NSInteger)tag AndStr:(NSString *)str;
@end

NS_ASSUME_NONNULL_END
