//
//  PictureLayoutController.m
//  YXStitch
//
//  Created by mac_m11 on 2022/9/22.
//

#import "PictureLayoutController.h"
#import "LayoutBottomView.h"
#import "GridSelectedView.h"
#import "GridShowView.h"
@interface PictureLayoutController ()

@property (nonatomic, strong) LayoutBottomView *bottomView;
@property (nonatomic, strong) GridSelectedView *gridView;
@property (nonatomic, strong) NSArray *grids;
@property (nonatomic, strong) GridShowView *gridsShowView;

@end

@implementation PictureLayoutController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = RGB(25, 25, 25);

    [self getDataSources];
//    [self drawGridsWithIndex:0];
    [self setBottomView];
    [self initlalizeGridShowView];
    [self initlalizeGridSelectedView];
}

#pragma mark - dataSources
- (void)getDataSources {
    NSString *jsonName = [NSString stringWithFormat:@"GridLayout_%lu", (unsigned long)self.pictures.count];
    NSString *path = [[NSBundle mainBundle] pathForResource:jsonName ofType:@"json"];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:NSJSONReadingAllowFragments error:nil];
    self.grids = dic[@"types"];
}

#pragma mark - Create views
- (void)drawGridsWithIndex:(NSInteger)index {
    
    NSDictionary *dict = self.grids[index];
    self.gridsShowView.gridsDic = dict;
//    NSInteger rowsCount = [dict[@"rowsCount"] integerValue];
//    NSArray *rows = dict[@"rows"];
//
//    for (int i = 0; i < rows.count; i++) {
//        NSDictionary *dicRows = rows[i];
//        CGFloat start = [dicRows[@"start"] integerValue];
//        NSInteger columnsCount = [dicRows[@"columnsCount"] integerValue];
//        NSArray *columns = dicRows[@"columns"];
//        CGFloat left = start * self.bgView.width / columnsCount;
//        for (int j = 0; j < columns.count; j++) {
//            NSDictionary *dicColumn = columns[j];
//            CGFloat width = [dicColumn[@"width"] floatValue];
//            CGFloat height = [dicColumn[@"height"] floatValue];
//            CGFloat margin = [dicColumn[@"margin"] floatValue] * self.bgView.width / columnsCount;
//            CGFloat top = [dicColumn[@"top"] floatValue];
//            [self creatSubviewsWithFrame:CGRectMake(left + margin, top * self.bgView.height / rowsCount, width * self.bgView.width / columnsCount, height * self.bgView.height / rowsCount)];
//            left += width * self.bgView.width / columnsCount;
//        }
//    }
}

//- (void)creatSubviewsWithFrame:(CGRect)frame{
//    UIView *subView = [[UIView alloc] initWithFrame:frame];
//    subView.backgroundColor = [UIColor cyanColor];
//    subView.layer.borderColor = [UIColor greenColor].CGColor;
//    subView.layer.borderWidth = 1.0;
//    [self.bgView addSubview:subView];
//}

- (void)setBottomView {
    
    LayoutBottomView *bottomView = [[LayoutBottomView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - Nav_HEIGHT - 80, SCREEN_WIDTH, 80)];
    bottomView.backgroundColor = RGB(25, 25, 25);
    @weakify(self);
    bottomView.layoutBottomBlock = ^(NSInteger index) {
        @strongify(self);
        [self clickBottomWithIndex:index];
    };
    [self.view addSubview:bottomView];
    _bottomView = bottomView;
}

- (void)initlalizeGridSelectedView
{
    GridSelectedView *gridView = [[GridSelectedView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 80)];
    gridView.bottom = self.bottomView.top;
    @weakify(self);
    gridView.gridSelectedItemBlock = ^(NSInteger index) {
        @strongify(self);
        [self drawGridsWithIndex:index];
    };
    gridView.backgroundColor = RGB(25, 25, 25);
    [self.view addSubview:gridView];
    _gridView = gridView;
    self.gridView.grids = self.grids;
}

- (void)initlalizeGridShowView
{
    GridShowView *gridsShowView = [[GridShowView alloc] initWithFrame:CGRectMake(0, 100, SCREEN_WIDTH, SCREEN_WIDTH)];
    gridsShowView.pictures = self.pictures;
    [self.view addSubview:gridsShowView];
    _gridsShowView = gridsShowView;
}

#pragma mark - Method
- (void)clickBottomWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            
        }
            break;
        case 1:
        {
            
            
        }
            break;
        case 2:
        {
            
            
        }
            break;
            
        default:
            break;
    }
}

@end
