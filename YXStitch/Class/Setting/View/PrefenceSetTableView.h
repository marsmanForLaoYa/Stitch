//
//  PrefenceSetTableView.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/11.
//

#import "BaseView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PrefenceSetTableViewDelegate <NSObject>
@optional
- (void)autoDeleteSwtichWithTag:(NSInteger)tag;
@end
@interface PrefenceSetTableView : BaseView<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) id<PrefenceSetTableViewDelegate> delegate;
@property (nonatomic, strong)NSMutableArray *arr;
@property (nonatomic, strong)NSMutableArray *expandArr;
@property (nonatomic, strong)NSMutableArray *subsArr;
@end

NS_ASSUME_NONNULL_END
