//
//  SettingTableView.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/10.
//

#import "BaseView.h"
#import "SettingViewController.h"
NS_ASSUME_NONNULL_BEGIN

@protocol SettingTableViewDelegate <NSObject>
@optional
- (void)settingClickWithTag:(NSInteger)tag;
@end

@interface SettingTableView : BaseView<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) id<SettingTableViewDelegate> delegate;
@property (nonatomic, weak) SettingViewController *vc;
@property (nonatomic, strong)NSMutableArray *arr;
@end

NS_ASSUME_NONNULL_END
