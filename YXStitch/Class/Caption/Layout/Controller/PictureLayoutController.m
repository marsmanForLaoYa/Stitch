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
#import "WaterColorSelectView.h"
#import "ColorPlateView.h"
#import "GridScaleView.h"

#define kBottomHeight 80
#define kContainerHeight (SCREEN_HEIGHT - (Nav_HEIGHT + kBottomHeight))

@interface PictureLayoutController ()<WaterColorSelectViewDelegate>

@property (nonatomic, strong) GridShowView *gridsShowView;

@property (nonatomic, strong) LayoutBottomView *bottomView;

@property (nonatomic, strong) GridSelectedView *gridSelectedView;
@property (nonatomic, copy) NSArray *grids;

@property (nonatomic, strong) GridScaleView *gridScaleView;
@property (nonatomic, copy) NSArray *scales;

@property (nonatomic ,strong) WaterColorSelectView *colorSelectView;
@property (nonatomic ,strong) ColorPlateView *colorPlateView;

@end

@implementation PictureLayoutController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = RGB(25, 25, 25);

    [self getLayoutGrids];
    [self getScaleGrids];
//    [self drawGridsWithIndex:0];
    [self setBottomView];
    [self initlalizeGridShowViewWithWidth:1 height:1];
 
    [self addGridSelectedView];
    [self addGridScalesView];
    [self addColorSelectedView];
}

#pragma mark - dataSources
- (void)getLayoutGrids {
    NSString *jsonName = [NSString stringWithFormat:@"GridLayout_%lu", (unsigned long)self.pictures.count];
    NSString *path = [[NSBundle mainBundle] pathForResource:jsonName ofType:@"json"];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:NSJSONReadingAllowFragments error:nil];
    self.grids = dic[@"types"];
}

- (void)getScaleGrids {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Scales" ofType:@"json"];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:NSJSONReadingAllowFragments error:nil];
    self.scales = dic[@"data"];
}

#pragma mark - Create views
- (void)drawGridsWithIndex:(NSInteger)index {
    
    NSDictionary *dict = self.grids[index];
    self.gridsShowView.gridsDic = dict;
}

- (void)setBottomView {
    
    LayoutBottomView *bottomView = [[LayoutBottomView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - Nav_HEIGHT - kBottomHeight, SCREEN_WIDTH, kBottomHeight)];
    bottomView.backgroundColor = RGB(25, 25, 25);
    @weakify(self);
    bottomView.layoutBottomBlock = ^(NSInteger index) {
        @strongify(self);
        [self clickBottomWithIndex:index];
    };
    [self.view addSubview:bottomView];
    _bottomView = bottomView;
}

- (void)initlalizeGridShowViewWithWidth:(NSInteger)width height:(NSInteger)height
{
    if (!_gridsShowView) {
        GridShowView *gridsShowView = [[GridShowView alloc] initWithFrame:CGRectZero];
        [self.view addSubview:gridsShowView];
        _gridsShowView = gridsShowView;
        _gridsShowView.pictures = self.pictures;
    }
    CGFloat viewWidth = SCREEN_WIDTH;
    CGFloat viewHeight = viewWidth * height / width;
    
    if (viewHeight >= kContainerHeight) {
        viewHeight = kContainerHeight;
        viewWidth = kContainerHeight * width / height;
    }
    _gridsShowView.width = viewWidth;
    _gridsShowView.height = viewHeight;
    _gridsShowView.centerY = kContainerHeight / 2 + Nav_HEIGHT;
    _gridsShowView.centerX = self.view.centerX;
}

- (void)addGridSelectedView
{
    GridSelectedView *gridSelectedView = [[GridSelectedView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 80)];
    gridSelectedView.bottom = self.bottomView.top;
    @weakify(self);
    gridSelectedView.gridSelectedItemBlock = ^(NSInteger index) {
        @strongify(self);
        [self drawGridsWithIndex:index];
    };
    gridSelectedView.backgroundColor = RGB(25, 25, 25);
    [self.view addSubview:gridSelectedView];
    _gridSelectedView = gridSelectedView;
    self.gridSelectedView.grids = self.grids;

    //隐藏
    [self hiddenGridSelectedView];
}

- (void)showGridSelectedView {
    [UIView animateWithDuration:0.1 animations:^{

        self.gridSelectedView.hidden = NO;
        self.gridSelectedView.bottom = self.bottomView.top;

    } completion:^(BOOL finished) {

    }];
}

- (void)hiddenGridSelectedView {
    [UIView animateWithDuration:0.1 animations:^{
        self.gridSelectedView.bottom = self.gridSelectedView.bottom + 30;
        

    } completion:^(BOOL finished) {
        self.gridSelectedView.hidden = YES;
    }];
}

- (void)addGridScalesView
{
    GridScaleView *gridScaleView = [[GridScaleView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 60)];
    gridScaleView.bottom = self.bottomView.top;
    @weakify(self);
    gridScaleView.gridScaleItemSelectedBlock = ^(NSInteger scaleWidth, NSInteger scaleHeight) {
        @strongify(self);
        NSLog(@"%ld %ld", scaleWidth, scaleHeight);
        [self initlalizeGridShowViewWithWidth:scaleWidth height:scaleHeight];
        self.gridsShowView.gridsDic = self.gridsShowView.gridsDic;
    };

    gridScaleView.backgroundColor = RGB(25, 25, 25);
    [self.view addSubview:gridScaleView];
    _gridScaleView = gridScaleView;
    self.gridScaleView.scales = self.scales;
    //隐藏
    [self hiddenGridScaleView];
}

- (void)showGridScaleView {
    [UIView animateWithDuration:0.1 animations:^{

        self.gridScaleView.hidden = NO;
        self.gridScaleView.bottom = self.bottomView.top;

    } completion:^(BOOL finished) {

    }];
}

- (void)hiddenGridScaleView {
    [UIView animateWithDuration:0.1 animations:^{
        self.gridScaleView.bottom = self.gridSelectedView.bottom + 30;
        

    } completion:^(BOOL finished) {
        self.gridScaleView.hidden = YES;
    }];
}

-(void)addColorSelectedView {
    MJWeakSelf
    _colorSelectView = [[WaterColorSelectView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 160)];
    _colorSelectView.bottom = self.bottomView.top;
    _colorSelectView.type = 6;
    _colorSelectView.delegate = self;
    _colorSelectView.moreColorClick = ^{
        [weakSelf addColorPlateView];
    };
    [self.view addSubview:_colorSelectView];
    
    [self hiddenColorSelectedView];
}

- (void)showColorSelectedView {
    [UIView animateWithDuration:0.1 animations:^{

        self.colorSelectView.hidden = NO;
        self.colorSelectView.bottom = self.bottomView.top;

    } completion:^(BOOL finished) {

    }];
}

- (void)hiddenColorSelectedView {
    [UIView animateWithDuration:0.1 animations:^{
        self.colorSelectView.bottom = self.colorSelectView.bottom + 30;
    } completion:^(BOOL finished) {
        self.colorSelectView.hidden = YES;
    }];
}

#pragma mark -- colorSelectViewDelegate
- (void)changeSliderValue:(CGFloat)value {

    //vale 0-1;
    self.gridsShowView.imagePadding = value * 20;
}

- (void)changeWaterFontColor:(NSString *)color{

    [self.gridsShowView setShowViewBackgroundColorWithHex:color];
}

#pragma mark -- 添加颜色选择器
-(void)addColorPlateView{
    MJWeakSelf
    _colorPlateView = [[ColorPlateView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, RYRealAdaptWidthValue(575))];
    [self.view addSubview:_colorPlateView];
    _colorPlateView.btnClick = ^(NSInteger tag) {
        if (tag == 2) {
            NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:GVUserDe.selectColorArr];
            if (tmpArr.count >= 6) {
                [tmpArr removeFirstObject];
            }
            [tmpArr addObject:weakSelf.colorPlateView.colorLab.text];
            GVUserDe.selectColorArr = tmpArr;
            [weakSelf changeWaterFontColor:weakSelf.colorPlateView.colorLab.text];
        }
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.colorPlateView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH , weakSelf.colorPlateView.height);
        } completion:^(BOOL finished) {
            [weakSelf.colorPlateView removeFromSuperview];
        }];
        
    };
    [self.view bringSubviewToFront:_colorPlateView];
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.colorPlateView.frame = CGRectMake(0, SCREEN_HEIGHT - weakSelf.colorPlateView.height, SCREEN_WIDTH , weakSelf.colorPlateView.height);
    }];
}

#pragma mark - Method
- (void)clickBottomWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            if(!self.colorSelectView.hidden) {
                [self hiddenColorSelectedView];
            }
            
            if(!self.gridScaleView.hidden) {
                [self hiddenGridScaleView];
            }
            
            if(self.gridSelectedView.hidden) {
                [self showGridSelectedView];
            }
            else
            {
                [self hiddenGridSelectedView];
            }
        }
            break;
        case 1:
        {
            
            if(!self.colorSelectView.hidden) {
                [self hiddenColorSelectedView];
            }
            
            if(!self.gridSelectedView.hidden) {
                [self hiddenGridSelectedView];
            }
            
            if(self.gridScaleView.hidden) {
                [self showGridScaleView];
            }
            else
            {
                [self hiddenGridScaleView];
            }
            
        }
            break;
        case 2:
        {
            if(!self.gridSelectedView.hidden) {
                [self hiddenGridSelectedView];
            }
            
            if(!self.gridScaleView.hidden) {
                [self hiddenGridScaleView];
            }
            
            if(self.colorSelectView.hidden) {
                [self showColorSelectedView];
            }
            else
            {
                [self hiddenColorSelectedView];
            }
            
        }
            break;
            
        default:
            break;
    }
}

@end
