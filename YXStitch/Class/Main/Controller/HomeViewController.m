//
//  HomeViewController.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/8.
//

#import "HomeViewController.h"
#import "HomeSettingViewController.h"
#import "MoveCollectionViewCell.h"
#import "EnterURLViewController.h"
#import "SettingViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <ReplayKit/ReplayKit.h>
#import "ScrrenStitchHintView.h"
#import "SaveViewController.h"
#import "GuiderVisitorView.h"
#import "WaterMarkViewController.h"
#import "SelectPictureViewController.h"
#import "CaptionViewController.h"
#import "CustomScrollView.h"
#import "UIScrollView+UITouch.h"

@interface HomeViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,MoveCollectionViewCellDelegate,ScrrenStitchHintViewDelegate>

@property (nonatomic ,strong)UIView *iconView;
@property (nonatomic ,strong)UICollectionView *MJColloctionView;
@property (nonatomic ,strong)NSMutableArray *iconArr;
@property (nonatomic ,strong)UIView * shotView;
@property (nonatomic ,strong)NSIndexPath * indexPath;
@property (nonatomic ,strong)NSIndexPath * nextIndexPath;
@property (nonatomic ,weak) MoveCollectionViewCell * originalCell;
@property (nonatomic, strong)SZImageGenerator *generator;
@property (nonatomic ,strong)ScrrenStitchHintView *checkScreenStitchView;
@property (nonatomic ,strong)UIView *bgView;
@property (nonatomic ,strong)StitchResultView *resultView;
@property (nonatomic ,strong)GuiderVisitorView *guiderView;

@property (nonatomic ,strong)NSMutableArray *stitchArr;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"首页";
    if (GVUserDe.waterPosition <= 1){
        GVUserDe.waterPosition = 1;
    }
    if (GVUserDe.selectColorArr.count == 0){
        GVUserDe.selectColorArr = [NSMutableArray arrayWithObject:@"#E35AF6"];
    }
    
    if (GVUserDe.homeIconArr.count >0){
        _iconArr = [NSMutableArray arrayWithArray:GVUserDe.homeIconArr];
    }else{
        _iconArr = [NSMutableArray arrayWithObjects:@"截长屏",@"网页滚动截图",@"拼图",@"水印",@"设置",@"更多功能",nil];
    }
    [self setupViews];
    [self setupLayout];
    [self setupNavItems];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noty:) name:@"homeChange" object:nil];
//    [self.view bringSubviewToFront:_imageView];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
//    NSString *path = [paths objectAtIndex:0];
//    NSLog(@"path==%@",path);
  //  [self getByAppGroup2];
    //检测连续截图
    if (GVUserDe.isAutoCheckRecentlyIMG) {
        [SVProgressHUD showWithStatus:@"自动检测到有连续截图"];
        [self screenStitchWithType:1];
    }    
}


- (void)sliderValueChanged:(UISlider *)slider{
    // Slider当前位置的值
    NSLog(@"%f", slider.value);
}

#pragma mark - NSFileManager
- (void)getByAppGroup2{
    //获取分组的共享目录
    NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.test.appgroup"];//此处id要与开发者中心创建时一致
    NSURL *fileURL = [groupURL URLByAppendingPathComponent:@"demo.txt"];
    //读取文件
    NSString *str = [NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"str = %@", str);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];   
}

- (void)noty:(NSNotification *)noty {
    NSDictionary *dict = noty.userInfo;
    _iconArr = dict[@"iconArr"];
    GVUserDe.homeIconArr = _iconArr;
    [_MJColloctionView reloadData];
}

#pragma mark - UI
-(void)setupViews{
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat sizeWidth = (CGFloat) 168 / 375  * SCREEN_WIDTH;
    CGFloat sizeHeight = (CGFloat) 160 / 667  * SCREEN_HEIGHT;
//    CGFloat sizeHeight = 160;
    layout.itemSize = CGSizeMake(sizeWidth, sizeHeight);
    _MJColloctionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, Nav_H,SCREEN_WIDTH,SCREEN_HEIGHT - Nav_H) collectionViewLayout:layout];
    [_MJColloctionView registerClass:[MoveCollectionViewCell class] forCellWithReuseIdentifier:@"MoveCollectionViewCell"];
    _MJColloctionView.dataSource = self;
    _MJColloctionView.delegate = self;
    _MJColloctionView.backgroundColor = HexColor(BKGrayColor);
    [self.view addSubview:_MJColloctionView];
}

-(void)setupLayout{
    
}

-(void)setupNavItems{
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"水滴"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(leftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = item;
}
        
#pragma mark -- CollectionDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _iconArr.count;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(20, 10, 10, 10);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MoveCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MoveCollectionViewCell" forIndexPath:indexPath];
    cell.p_MoveCollectionViewCellDelegate = self;
    cell.cellName = [_iconArr objectAtIndex:indexPath.row];
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //得到的cell
    MoveCollectionViewCell * cell = (MoveCollectionViewCell *)[self collectionView:collectionView cellForItemAtIndexPath:indexPath];
    NSString *cellName = cell.cellName;
    //跳转
    UIViewController *vc;
    if ([cellName isEqualToString:@"截长屏"]){
        [self screenStitchWithType:2];
    }else if ([cellName isEqualToString:@"网页滚动截图"]){
        vc = [EnterURLViewController new];
    }else if ([cellName isEqualToString:@"拼图"]){
        vc = [SelectPictureViewController new];
    }else if ([cellName isEqualToString:@"水印"]){
        vc = [WaterMarkViewController new];
    }else if ([cellName isEqualToString:@"设置"]){
        vc = [SettingViewController new];
    }else{
        //更多功能
        vc = [HomeSettingViewController new];
    }
    [self.navigationController pushViewController:vc animated:YES];
}



-(void)GesturePressDelegate:(UIGestureRecognizer *)gestureRecognizer
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >9) {
        switch (gestureRecognizer.state) {
            case UIGestureRecognizerStateBegan:{
                //判断手势落点位置是否在路径上
                NSIndexPath *indexPath = [_MJColloctionView indexPathForItemAtPoint:[gestureRecognizer locationInView:self.MJColloctionView]];
                if (indexPath == nil) {
                    break;
                }
                //在路径上则开始移动该路径上的cell
                [_MJColloctionView beginInteractiveMovementForItemAtIndexPath:indexPath];
            }
                break;
            case UIGestureRecognizerStateChanged:
                //移动过程当中随时更新cell位置
                [_MJColloctionView updateInteractiveMovementTargetPosition:[gestureRecognizer locationInView:self.MJColloctionView]];
                break;
            case UIGestureRecognizerStateEnded:
                //移动结束后关闭cell移动
                [_MJColloctionView endInteractiveMovement];
                break;
            default:
                [_MJColloctionView cancelInteractiveMovement];
                break;
        }

    }else{
        MoveCollectionViewCell* cell = (MoveCollectionViewCell*)gestureRecognizer.view;
        static CGPoint startPoint;
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            _shotView = [cell snapshotViewAfterScreenUpdates:NO];
            _shotView.center = cell.center;
            
            NSLog(@"%@",cell.description);
            NSLog(@"%@",_shotView.description);
            [_MJColloctionView addSubview:_shotView];
            _indexPath = [_MJColloctionView indexPathForCell:cell];
            _originalCell = cell;
            _originalCell.hidden = YES;
            startPoint = [gestureRecognizer locationInView:_MJColloctionView];
        }else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
        {
            //获取移动量
            CGFloat tranX = [gestureRecognizer locationOfTouch:0 inView:_MJColloctionView].x - startPoint.x;
            CGFloat tranY = [gestureRecognizer locationOfTouch:0 inView:_MJColloctionView].y - startPoint.y;
            
            //进行移动
            _shotView.center = CGPointApplyAffineTransform(_shotView.center, CGAffineTransformMakeTranslation(tranX, tranY));
            //更新初始位置
            startPoint = [gestureRecognizer locationOfTouch:0 inView:_MJColloctionView];
            for (UICollectionViewCell *cellVisible in [_MJColloctionView visibleCells])
            {
                //移动的截图与目标cell的center直线距离
                CGFloat space = sqrtf(pow(_shotView.center.x - cellVisible.center.x, 2) + powf(_shotView.center.y - cellVisible.center.y, 2));
                //判断是否替换位置，通过直接距离与重合程度
                if (space <= _shotView.frame.size.width/2&&(fabs(_shotView.center.y-cellVisible.center.y) <= _shotView.bounds.size.height/2)) {
                    _nextIndexPath = [_MJColloctionView indexPathForCell:cellVisible];
                    if (_nextIndexPath.item > _indexPath.item)
                    {
                        for(NSInteger i = _indexPath.item; i <_nextIndexPath.item;i++)
                        {
                            //移动数据源位置
                            [_iconArr exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                        }
                    }else
                    {
                        for(NSInteger i = _indexPath.item; i <_nextIndexPath.item;i--)
                        {
                            //移动数据源位置
                            [_iconArr exchangeObjectAtIndex:i withObjectAtIndex:i-1];
                        }
                    }
                    //移动视图cell位置
                    [_MJColloctionView moveItemAtIndexPath:_indexPath toIndexPath:_nextIndexPath];
                    //更新移动视图的数据
                    _indexPath = _nextIndexPath;
                    break;
                }
            }
        }else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
        {
            [_shotView removeFromSuperview];
            [_originalCell setHidden:NO];
        }

    }
}

-(BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath {
    id objc = [_iconArr objectAtIndex:sourceIndexPath.item];
    [_iconArr removeObject:objc];
    [_iconArr insertObject:objc atIndex:destinationIndexPath.item];
    GVUserDe.homeIconArr = _iconArr;
}

#pragma mark --长图识别
-(void)screenStitchWithType:(NSInteger)type{
    //自动识别长图
    if (type == 2){
        [SVProgressHUD showWithStatus:@"正在检测是否有连续截图..."];
    }
    
    _stitchArr = [Tools detectionScreenShotIMG];
    //触发提示
    MJWeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        if (weakSelf.bgView == nil){
            weakSelf.bgView = [Tools addBGViewWithFrame:self.view.frame];
            [weakSelf.view addSubview:weakSelf.bgView];
        }else{
            weakSelf.bgView.hidden = NO;
        }
        if (weakSelf.checkScreenStitchView == nil){
            weakSelf.checkScreenStitchView = [ScrrenStitchHintView new];
            weakSelf.checkScreenStitchView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, RYRealAdaptWidthValue(550));
            weakSelf.checkScreenStitchView.delegate = self;
            if (weakSelf.stitchArr.count > 1){
                //连续截图数量大于2才能去拼接
                [SVProgressHUD showWithStatus:@"正在拼接中..."];
                weakSelf.checkScreenStitchView.type = 2;
                weakSelf.checkScreenStitchView.arr = weakSelf.stitchArr;
            }else{
                weakSelf.checkScreenStitchView.type = 1;
            }
            weakSelf.checkScreenStitchView.delegate = self;
            [weakSelf.view addSubview:weakSelf.checkScreenStitchView];
        }
        weakSelf.checkScreenStitchView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.checkScreenStitchView.frame = CGRectMake(0, SCREEN_HEIGHT - weakSelf.checkScreenStitchView.height, SCREEN_WIDTH , weakSelf.checkScreenStitchView.height);
        }];
    });
}


#pragma mark -- btn触发事件
-(void)leftBtnClick:(UIButton *)btn{
    //滚动截图指引
    MJWeakSelf
    if (_bgView == nil){
        _bgView = [Tools addBGViewWithFrame:self.view.frame];
        [self.view addSubview:_bgView];
    }else{
        _bgView.hidden = NO;
    }
    if (_guiderView == nil){
        _guiderView = [GuiderVisitorView new];
        _guiderView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, RYRealAdaptWidthValue(565));
       
        [self.view addSubview:_guiderView];
    }
    
    _guiderView.btnClick = ^{
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.guiderView.frame = CGRectMake(0, SCREEN_HEIGHT + 100, SCREEN_WIDTH , weakSelf.guiderView.height);
        } completion:^(BOOL finished) {
            weakSelf.bgView.hidden = YES;
            weakSelf.guiderView.pageC.currentPage = 0;
        }];
    };
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.guiderView.frame = CGRectMake(0, SCREEN_HEIGHT - weakSelf.guiderView.height, SCREEN_WIDTH , weakSelf.guiderView.height);
    }];
}


#pragma mark -- viewDelegate
-(void)btnClickWithTag:(NSInteger)tag{
    MJWeakSelf
    if (tag == 4){
        [weakSelf checkScreenStitchViewDiss];
    }else if (tag == 5){
        //导出
        [SVProgressHUD showWithStatus:@"正在生成图片中.."];
        [_resultView.scrollView DDGContentScrollScreenShot:^(UIImage *screenShotImage) {
            [SVProgressHUD dismiss];
            SaveViewController *saveVC = [SaveViewController new];
            saveVC.screenshotIMG = screenShotImage;
            saveVC.isVer = YES;
            saveVC.type = 2;
            [weakSelf checkScreenStitchViewDiss];
            [weakSelf.navigationController pushViewController:saveVC animated:YES];
        }];
       
    }else {
        //字幕//拼接//裁切
        CaptionViewController *vc = [CaptionViewController new];  
        __block NSMutableArray *tmpArr = [NSMutableArray array];
        for (PHAsset *asset in _stitchArr) {
            [Tools getImageWithAsset:asset withBlock:^(UIImage * _Nonnull image) {
                [tmpArr addObject:image];
            }];
        }
        vc.dataArr = tmpArr;
        if (tag == 1){
            vc.type = 2;
        }else if (tag == 2){
            vc.type = 1;
        }else{
            vc.type = 3;
        }
        
        [weakSelf checkScreenStitchViewDiss];
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    
}
-(void)checkScreenStitchViewDiss{
    MJWeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.checkScreenStitchView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH , weakSelf.checkScreenStitchView.height);
    } completion:^(BOOL finished) {
        weakSelf.bgView.hidden = YES;
    }];
}

-(void)showResult:(SZImageGenerator *)result{
    [SVProgressHUD dismiss];
    if (!result) {
        return;
    }
    _generator = result;
    //点击了拼接，而且还没结束识别的时候；
//    if (_needJumpToPreviewController) {
//        [self startMergeImage:nil];
//    }
    
    _resultView = [StitchResultView new];
    _resultView.generator = _generator;
    [_checkScreenStitchView addSubview:_resultView];
    [_resultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@23);
        make.width.equalTo(@(SCREEN_WIDTH  - 46));
        make.top.equalTo(@50);
        make.height.equalTo(@(_checkScreenStitchView.height - 128));
    }];
    
    
}



#pragma mark -- set
-(NSMutableArray *)stitchArr{
    if (_stitchArr == nil){
        _stitchArr = [NSMutableArray array];
    }
    return _stitchArr;
}

@end
