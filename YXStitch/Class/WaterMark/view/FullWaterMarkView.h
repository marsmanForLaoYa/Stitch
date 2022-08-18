//
//  FullWaterMarkView.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/17.
//

#import "BaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FullWaterMarkView : BaseView

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSString *waterMarkText;
@property (nonatomic,strong)NSString *waterMarkTextColor;
@property (nonatomic,assign)NSInteger waterMarkTextSize;

//创建水印View
+(FullWaterMarkView*)addWaterMarkView:(NSString*)waterMarkText andSize:(NSInteger)size andColor:(NSString *)color;
@end

NS_ASSUME_NONNULL_END
