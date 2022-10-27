//
//  UrlSchemeTableView.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/11.
//

#import "BaseView.h"

NS_ASSUME_NONNULL_BEGIN
@protocol UrlSchemeTableViewDelegate <NSObject>
@optional
- (void)urlSchemeClickWithTag:(NSInteger)tag;
@end

@interface UrlSchemeTableView : BaseView<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) id<UrlSchemeTableViewDelegate> delegate;
@property (nonatomic, strong)NSMutableArray *arr;
@property (nonatomic, strong)NSMutableArray *strArr;

@end

NS_ASSUME_NONNULL_END
