//
//  FullWaterMarkTableViewCell.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FullWaterMarkTableViewCell : UITableViewCell
@property (nonatomic,strong)UILabel *waterTextLabel;
- (void)configModel:(NSString *)str andSize:(NSInteger)Size andColor:(NSString *)color;
@end

NS_ASSUME_NONNULL_END
