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
#import "GridEditView.h"

#define kBottomHeight 80
#define kContainerHeight (SCREEN_HEIGHT - (Nav_HEIGHT + kBottomHeight))

@interface PictureLayoutController ()<WaterColorSelectViewDelegate, HXCustomNavigationControllerDelegate,HXPhotoViewDelegate,HXPhotoViewDelegate>

@property (nonatomic, strong) GridShowView *gridsShowView;

@property (nonatomic, strong) LayoutBottomView *bottomView;

@property (nonatomic, strong) GridSelectedView *gridSelectedView;
@property (nonatomic, copy) NSArray *grids;

@property (nonatomic, strong) GridScaleView *gridScaleView;
@property (nonatomic, copy) NSArray *scales;

@property (nonatomic ,strong) WaterColorSelectView *colorSelectView;
@property (nonatomic ,strong) ColorPlateView *colorPlateView;

@property (nonatomic, strong) GridEditView *gridEditView;

#pragma mark - 相册
@property (weak, nonatomic) HXPhotoView *photoView;
@property (strong, nonatomic) HXPhotoManager *manager;
#pragma mark - 翻转
@property (nonatomic ,assign)BOOL isTurn;

@end

@implementation PictureLayoutController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = RGB(25, 25, 25);

    [self getLayoutGrids];
    [self getScaleGrids];

    //添加底部三个按钮
    [self setBottomView];
    //初始化排列view
    [self initlalizeGridShowViewWithScaleWidth:1 scaleHeight:1];
    //添加选中showview的控制view
    [self addEditShowViewControl];
    //选中布局
    [self addGridSelectedView];
    //选中画布
    [self addGridScalesView];
    //选中边框
    [self addColorSelectedView];
    
    _isTurn = NO;
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

- (void)initlalizeGridShowViewWithScaleWidth:(NSInteger)scaleWidth scaleHeight:(NSInteger)scaleHeight
{
    if (!_gridsShowView) {
        GridShowView *gridsShowView = [[GridShowView alloc] initWithFrame:CGRectZero];
        @weakify(self);
        gridsShowView.gridShowViewSelecedImageBlock = ^(UIImage * _Nonnull image) {
            @strongify(self);
            [self showGridEditViewAnimated:YES];
        };
        [self.view addSubview:gridsShowView];
        _gridsShowView = gridsShowView;
        _gridsShowView.pictures = self.pictures;
    }
    CGFloat viewWidth = SCREEN_WIDTH;
    CGFloat viewHeight = viewWidth * scaleHeight / scaleWidth;
    
    if (viewHeight >= kContainerHeight) {
        viewHeight = kContainerHeight;
        viewWidth = kContainerHeight * scaleWidth / scaleHeight;
    }
    _gridsShowView.width = viewWidth;
    _gridsShowView.height = viewHeight;
    _gridsShowView.centerY = kContainerHeight / 2 + Nav_HEIGHT;
    _gridsShowView.centerX = self.view.centerX;
}

//添加选中showview的控制view
- (void)addEditShowViewControl {
    GridEditView *gridEditView = [[GridEditView alloc] initWithFrame:CGRectZero];
    @weakify(self);
    gridEditView.btnClick = ^(NSInteger tag) {
        @strongify(self);
        switch (tag) {
            case 0:
            {
                //旋转
               UIImage * flipImage = [Tools image:self.gridsShowView.lastShowImgView.image rotation:UIImageOrientationDown];
                [self.gridsShowView changeSelectedShowImgViewWithImage:flipImage];
            }
                break;
            case 1:
            {
                //水平镜像
                UIImage *flipImage = [Tools turnImageWith:self.gridsShowView.lastShowImgView.image AndType:1 AndisTurn:self.isTurn];
                self.isTurn = !self.isTurn;
                [self.gridsShowView changeSelectedShowImgViewWithImage:flipImage];
            }
                break;
            case 2:
            {
                //垂直镜像
                UIImage *flipImage = [Tools turnImageWith:self.gridsShowView.lastShowImgView.image AndType:2 AndisTurn:self.isTurn];
                [self.gridsShowView changeSelectedShowImgViewWithImage:flipImage];
            }
                break;
        
            case 3: {
                //更换图片
                if (self.photoView == nil){
                    [self addPhotoView];
                }
                HXCustomNavigationController *nav = [[HXCustomNavigationController alloc] initWithManager:self.manager delegate:self];
                nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
                nav.modalPresentationCapturesStatusBarAppearance = YES;
                [self.view.viewController presentViewController:nav animated:YES completion:nil];
            }
                break;
                
            case 100:
            {
                [self hiddenGridEditViewAnimated:YES];
            }
                break;
            default:
                break;
        }
    };
    gridEditView.width = self.bottomView.width;
    gridEditView.height = self.bottomView.height;
    gridEditView.left = self.bottomView.left;
    gridEditView.bottom = self.bottomView.bottom;
    [self.view addSubview:gridEditView];
    _gridEditView = gridEditView;
    //隐藏editView
    [self hiddenGridEditViewAnimated:NO];
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
    [self hiddenGridSelectedViewAnimated:NO];
}

- (void)addGridScalesView
{
    GridScaleView *gridScaleView = [[GridScaleView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 60)];
    gridScaleView.bottom = self.bottomView.top;
    @weakify(self);
    gridScaleView.gridScaleItemSelectedBlock = ^(NSInteger scaleWidth, NSInteger scaleHeight) {
        @strongify(self);
        NSLog(@"%ld %ld", scaleWidth, scaleHeight);
        [self initlalizeGridShowViewWithScaleWidth:scaleWidth scaleHeight:scaleHeight];
        self.gridsShowView.gridsDic = self.gridsShowView.gridsDic;
    };

    gridScaleView.backgroundColor = RGB(25, 25, 25);
    [self.view addSubview:gridScaleView];
    _gridScaleView = gridScaleView;
    self.gridScaleView.scales = self.scales;
    //隐藏
    [self hiddenGridScaleViewAnimated:NO];
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
    
    [self hiddenColorSelectedViewAnimated:NO];
}

#pragma mark - show && hidden
- (void)showGridEditViewAnimated:(BOOL)animated {
    if(animated) {
        [UIView animateWithDuration:0.1 animations:^{

            self.gridEditView.hidden = NO;
            self.gridEditView.top = self.bottomView.top;

        } completion:^(BOOL finished) {

        }];
    }
    else
    {
        self.gridEditView.hidden = NO;
        self.gridEditView.top = self.bottomView.top;
    }
    
    //隐藏其它view
    if(!self.gridSelectedView.hidden) {
        [self hiddenGridSelectedViewAnimated:NO];
    }
    
    if(!self.gridScaleView.hidden) {
        [self hiddenGridScaleViewAnimated:NO];
    }
    
    if(!self.colorSelectView.hidden) {
        [self hiddenColorSelectedViewAnimated:NO];
    }
}

- (void)hiddenGridEditViewAnimated:(BOOL)animated {
    
    if(animated) {
        [UIView animateWithDuration:0.1 animations:^{
            self.gridEditView.top = self.gridEditView.bottom;
        } completion:^(BOOL finished) {
            self.gridEditView.hidden = YES;
        }];
    }
    else
    {
        self.gridEditView.top = self.gridEditView.bottom;
        self.gridEditView.hidden = YES;
    }
    
    //清除选中view的边框
    [self.gridsShowView clearSelectedShowImgView];
}

- (void)showGridSelectedViewAnimated:(BOOL)animated {
    if(animated) {
        [UIView animateWithDuration:0.1 animations:^{

            self.gridSelectedView.hidden = NO;
            self.gridSelectedView.bottom = self.bottomView.top;

        } completion:^(BOOL finished) {

        }];
    }
    else
    {
        self.gridSelectedView.hidden = NO;
        self.gridSelectedView.bottom = self.bottomView.top;
    }
}

- (void)hiddenGridSelectedViewAnimated:(BOOL)animated {
    
    if(animated) {
        [UIView animateWithDuration:0.1 animations:^{
            self.gridSelectedView.bottom = self.gridSelectedView.bottom + 30;
        } completion:^(BOOL finished) {
            self.gridSelectedView.hidden = YES;
        }];
    }
    else
    {
        self.gridSelectedView.bottom = self.gridSelectedView.bottom + 30;
        self.gridSelectedView.hidden = YES;
    }
}

- (void)showGridScaleViewAnimated:(BOOL)animated {
    
    if(animated) {
        [UIView animateWithDuration:0.1 animations:^{

            self.gridScaleView.hidden = NO;
            self.gridScaleView.bottom = self.bottomView.top;

        } completion:^(BOOL finished) {

        }];
    }
    else
    {
        self.gridScaleView.hidden = NO;
        self.gridScaleView.bottom = self.bottomView.top;
    }
}

- (void)hiddenGridScaleViewAnimated:(BOOL)animated {
    
    if(animated) {
        [UIView animateWithDuration:0.1 animations:^{
            self.gridScaleView.bottom = self.gridSelectedView.bottom + 30;
        } completion:^(BOOL finished) {
            self.gridScaleView.hidden = YES;
        }];
    }
    else
    {
        self.gridScaleView.bottom = self.gridSelectedView.bottom + 30;
        self.gridScaleView.hidden = YES;
    }
}

- (void)showColorSelectedViewAnimated:(BOOL)animated {
    
    if(animated) {
        [UIView animateWithDuration:0.1 animations:^{

            self.colorSelectView.hidden = NO;
            self.colorSelectView.bottom = self.bottomView.top;

        } completion:^(BOOL finished) {

        }];
    }
    else
    {
        self.colorSelectView.hidden = NO;
        self.colorSelectView.bottom = self.bottomView.top;
    }
}

- (void)hiddenColorSelectedViewAnimated:(BOOL)animated {
    
    if(animated) {
        [UIView animateWithDuration:0.1 animations:^{
            self.colorSelectView.bottom = self.colorSelectView.bottom + 30;
        } completion:^(BOOL finished) {
            self.colorSelectView.hidden = YES;
        }];
    }
    else
    {
        self.colorSelectView.bottom = self.colorSelectView.bottom + 30;
        self.colorSelectView.hidden = YES;
    }
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
                [self hiddenColorSelectedViewAnimated:NO];
            }
            
            if(!self.gridScaleView.hidden) {
                [self hiddenGridScaleViewAnimated:NO];
            }
            
            if(self.gridSelectedView.hidden) {
                [self showGridSelectedViewAnimated:YES];
            }
            else
            {
                [self hiddenGridSelectedViewAnimated:YES];
            }
        }
            break;
        case 1:
        {
            
            if(!self.colorSelectView.hidden) {
                [self hiddenColorSelectedViewAnimated:NO];
            }
            
            if(!self.gridSelectedView.hidden) {
                [self hiddenGridSelectedViewAnimated:NO];
            }
            
            if(self.gridScaleView.hidden) {
                [self showGridScaleViewAnimated:YES];
            }
            else
            {
                [self hiddenGridScaleViewAnimated:YES];
            }
            
        }
            break;
        case 2:
        {
            if(!self.gridSelectedView.hidden) {
                [self hiddenGridSelectedViewAnimated:NO];
            }
            
            if(!self.gridScaleView.hidden) {
                [self hiddenGridScaleViewAnimated:NO];
            }
            
            if(self.colorSelectView.hidden) {
                [self showColorSelectedViewAnimated:YES];
            }
            else
            {
                [self hiddenColorSelectedViewAnimated:YES];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -photoViewDelegate

-(void)addPhotoView{
    HXPhotoView *photoView = [HXPhotoView photoManager:self.manager scrollDirection:UICollectionViewScrollDirectionVertical];
    photoView.frame = CGRectMake(0, 12, SCREEN_WIDTH, 0);
    photoView.collectionView.contentInset = UIEdgeInsetsMake(0, 12, 0, 12);
    photoView.delegate = self;
    photoView.outerCamera = NO;
    photoView.previewStyle = HXPhotoViewPreViewShowStyleDark;
    photoView.previewShowDeleteButton = YES;
    photoView.showAddCell = YES;
    [photoView.collectionView reloadData];
    [self.view addSubview:photoView];
    photoView.hidden = YES;
    self.photoView = photoView;
}

- (HXPhotoManager *)manager {
    if (!_manager) {
        _manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhoto];
        _manager.configuration.type = HXConfigurationTypeWXChat;
        //设定高级用户和普通选择图片数量
        _manager.configuration.maxNum = 1;
        _manager.configuration.photoListBottomView = ^(HXPhotoBottomView *bottomView) {
            
        };
        _manager.configuration.previewBottomView = ^(HXPhotoPreviewBottomView *bottomView) {
            
        };

    }
    return _manager;
}

-(void)photoNavigationViewController:(HXCustomNavigationController *)photoNavigationViewController didDoneWithResult:(HXPickerResult *)result{
    @weakify(self);
    for (HXPhotoModel *photoModel in result.models) {
        [Tools getImageWithAsset:photoModel.asset withBlock:^(UIImage * _Nonnull image) {
            @strongify(self);
            [self.gridsShowView changeSelectedShowImgViewWithImage:image];
        }];
    }
}

@end
