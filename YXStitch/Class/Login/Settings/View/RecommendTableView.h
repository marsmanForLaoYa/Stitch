//
//  SettingTableView.h
//  XWNWS
//
//  Created by mac_m11 on 2022/9/9.
//

#import <UIKit/UIKit.h>
#import "RecommendModel.h"
#import "RecommendCell.h"
NS_ASSUME_NONNULL_BEGIN

@protocol RecommendTableViewDelegate <NSObject>

- (void)xw_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (CGFloat)xw_tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)xw_tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;

- (UIView *)xw_tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;



@end

@interface RecommendTableView : UIView

@property (nonatomic, strong) NSArray <NSArray <RecommendModel *>*>*dataSources;
@property (nonatomic, weak) id<RecommendTableViewDelegate>delegate;
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
