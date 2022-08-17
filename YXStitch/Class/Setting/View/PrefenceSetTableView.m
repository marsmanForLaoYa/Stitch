//
//  PrefenceSetTableView.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/11.
//

#import "PrefenceSetTableView.h"
#import "PrefenceTableViewCell.h"

@interface PrefenceSetTableView ()<PrefenceTableViewCell>
@end

@implementation PrefenceSetTableView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = HexColor(BKGrayColor);
        _arr = [NSMutableArray arrayWithObjects:@"保存到拼图相册",@"自动删除原图",@"自动检测最近长截图",@"自动删除滚动条",nil] ;
        _expandArr = [NSMutableArray arrayWithObjects:@"所有图片类型",@"仅限截图",nil] ;
        _subsArr = [NSMutableArray arrayWithObjects:@"",@"拼接完成后会自动提示删除原图",@"打开应用时会自动检测是否有最近的长截图，如果有，会自动 弹出并拼接。",@"在自动拼接长截图和滚动截图时自动隐藏侧边的滚动条。",nil] ;
        [self setupViews];
        [self setupLayout];
        
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.tableView];
    [self.tableView registerClass:[PrefenceTableViewCell class] forCellReuseIdentifier:@"PrefenceTableViewCell"];
}
- (void)setupLayout {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}
#pragma mark - UI
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = HexColor(BKGrayColor);
        
        
    }
    return _tableView;

}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PrefenceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PrefenceTableViewCell"];
    [cell configModel:_arr[indexPath.section] andTag:indexPath.section];
    cell.delegate = self;
    cell.tag = indexPath.section;
    if (cell.tag == 0){
        cell.funcswitch.on = GVUserDe.isSaveIMGAlbum;
    }else if(cell.tag == 1){
        cell.funcswitch.on = GVUserDe.isAutoDeleteOriginIMG;
    }else if(cell.tag == 2){
        cell.funcswitch.on = GVUserDe.isAutoCheckRecentlyIMG;
    }else {
        cell.funcswitch.on = GVUserDe.isAutoHiddenScrollStrip;
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PrefenceTableViewCell * cell = (PrefenceTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 1 && !GVUserDe.isMember) {
        [self.delegate autoDeleteSwtichWithTag:1];
    }
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 2){
        return 40;
    }
    return 24;
}
-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return _subsArr[section];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(tintColor)]) {
        CGFloat cornerRadius = 10.f;
        cell.backgroundColor = UIColor.clearColor;
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        CGMutablePathRef pathRef = CGPathCreateMutable();
        CGRect bounds = CGRectInset(cell.bounds, 10, 0);
        BOOL addLine = NO;
        if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
            CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
        } else if (indexPath.row == 0) {

            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
            addLine = YES;
            
        } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
        } else {
            CGPathAddRect(pathRef, nil, bounds);
            addLine = YES;
        }
        layer.path = pathRef;
        CFRelease(pathRef);
        //颜色修改
        layer.fillColor = [UIColor whiteColor].CGColor;
        layer.strokeColor=[UIColor whiteColor].CGColor;
        // 阴影颜色
        layer.shadowColor = [UIColor blackColor].CGColor;
        // 阴影偏移，默认(0, -3)
        layer.shadowOffset = CGSizeMake(0,-3);
        // 阴影透明度，默认0
        layer.shadowOpacity = 0;
        if (addLine == YES) {
            //设置分割线
            CALayer *lineLayer = [[CALayer alloc] init];
            CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
            lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+10, bounds.size.height-lineHeight, bounds.size.width-10, lineHeight);
            lineLayer.backgroundColor = tableView.separatorColor.CGColor;
            [layer addSublayer:lineLayer];
        }
        //设置背景view
        UIView *clickBgView = [[UIView alloc] initWithFrame:bounds];
        [clickBgView.layer insertSublayer:layer atIndex:0];
        clickBgView.backgroundColor = UIColor.clearColor;
        cell.backgroundView = clickBgView;
    }
}

-(void)autoDeleteWith:(BOOL)isAuto{
    [self.delegate autoDeleteSwtichWithTag:1];
}

@end
