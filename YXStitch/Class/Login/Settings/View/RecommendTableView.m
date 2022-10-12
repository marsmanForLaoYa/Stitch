//
//  SettingTableView.m
//  XWNWS
//
//  Created by mac_m11 on 2022/9/9.
//

#import "RecommendTableView.h"

#define kContentView_Left 15

@interface RecommendTableView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end
@implementation RecommendTableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTableView];
    }
    return self;
}

- (void)setDataSources:(NSArray<NSArray<RecommendModel *> *> *)dataSources
{
    _dataSources = dataSources;
    [self.tableView reloadData];
}

- (void)setTableView {
    UITableView *tableView = ({
        UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStyleGrouped];
        table.delegate = self;
        table.dataSource = self;
        table.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.001)];
        table.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.001)];
        table.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
        table.backgroundColor = [UIColor clearColor];
        table.separatorStyle = UITableViewCellSeparatorStyleNone;
        table.allowsSelection = YES;
        //去掉group模式下多余间距
        table.sectionFooterHeight = 0;
        if (@available(iOS 15.0, *)) {
            //去掉header和cell之间的空隙
            table.sectionHeaderTopPadding = 0;
        } else {
            // Fallback on earlier versions
        }
        table;
    });
    _tableView = tableView;
    [self addSubview:tableView];
}

- (void)reloadData
{
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSources.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSources[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifyCell = @"cell";
    RecommendCell *cell = [tableView dequeueReusableCellWithIdentifier:identifyCell];
    if (!cell) {
        cell = [[RecommendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifyCell];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    RecommendModel *model = self.dataSources[indexPath.section][indexPath.row];
    
    cell.settingModel = model;

    return cell;
}

#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(xw_tableView:viewForHeaderInSection:)]) {
        return [self.delegate xw_tableView:tableView viewForHeaderInSection:section];
    }
    else
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
        view.backgroundColor = [UIColor clearColor];
        return view;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(xw_tableView:heightForHeaderInSection:)]) {
        return [self.delegate xw_tableView:tableView heightForHeaderInSection:section];
    }
    else
    {
        return 30;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(xw_tableView:heightForRowAtIndexPath:)]) {
        return [self.delegate xw_tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    else
    {
        return 55 * NORMAL_SCALE;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(xw_tableView:didSelectRowAtIndexPath:)]) {
        [self.delegate xw_tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CAShapeLayer *shapeLayer;
    for (id view in cell.layer.sublayers) {
        if ([view isKindOfClass:[CAShapeLayer class]]) {
            shapeLayer = view;
        }
    }
    if (shapeLayer) {
        [shapeLayer removeFromSuperlayer];
    }
    //圆率
    CGFloat cornerRadius = 10;
    //大小
    CGFloat marginLeft = kContentView_Left;
    CGRect bounds = CGRectMake(marginLeft, 0, cell.bounds.size.width - marginLeft * 2, cell.bounds.size.height);
    //行数
    NSInteger numberOfRows = [tableView numberOfRowsInSection:indexPath.section];
    
    //绘制曲线
    UIBezierPath *bezierPath = nil;
    
    if (indexPath.row == 0 && numberOfRows == 1) {
        //一个为一组时,四个角都为圆角
        bezierPath = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    } else if (indexPath.row == 0) {
        //为组的第一行时,左上、右上角为圆角
        bezierPath = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight) cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    } else if (indexPath.row == numberOfRows - 1) {
        //为组的最后一行,左下、右下角为圆角
        bezierPath = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:(UIRectCornerBottomLeft|UIRectCornerBottomRight) cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    } else {
        //中间的都为矩形
        bezierPath = [UIBezierPath bezierPathWithRect:bounds];
    }
    //cell的背景色透明
    cell.backgroundColor = [UIColor clearColor];
    //新建一个图层
    CAShapeLayer *layer = [CAShapeLayer layer];
    //图层边框路径
    layer.path = bezierPath.CGPath;
    //图层填充色,也就是cell的底色
    layer.fillColor = [UIColor whiteColor].CGColor;
    //图层边框线条颜色
    /*
     如果self.tableView.style = UITableViewStyleGrouped时,每一组的首尾都会有一根分割线,目前我还没找到去掉每组首尾分割线,保留cell分割线的办法。
     所以这里取巧,用带颜色的图层边框替代分割线。
     这里为了美观,最好设为和tableView的底色一致。
     设为透明,好像不起作用。
     */
    layer.strokeColor = [UIColor whiteColor].CGColor;
    //将图层添加到cell的图层中,并插到最底层
    [cell.layer insertSublayer:layer atIndex:0];
}

@end
