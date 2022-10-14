//
//  SelectPictureViewController.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/18.
//

#import "SelectPictureViewController.h"
#import "CaptionViewController.h"
#import "UIView+HXExtension.h"
//#import "KSViewController.h"
#import "UnlockFuncView.h"
#import "BuyViewController.h"
#import "CheckProView.h"
#import "PictureLayoutController.h"

static const CGFloat kPhotoViewMargin = 12.0;
@interface SelectPictureViewController ()<HXPhotoViewDelegate,UIImagePickerControllerDelegate, HXPhotoViewCellCustomProtocol,HXCustomNavigationControllerDelegate,UnlockFuncViewDelegate,CheckProViewDelegate>

@property (strong, nonatomic) HXPhotoManager *manager;
@property (weak, nonatomic) HXPhotoView *photoView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (nonatomic ,strong)HXPhotoBottomView *bottomView;
@property (assign, nonatomic) BOOL needDeleteItem;
@property (assign, nonatomic) BOOL showHud;
@property (nonatomic, strong)NSTimer *reTimer;
@property (nonatomic ,assign)BOOL isOpenAlbum;
@property (nonatomic ,assign)NSInteger showBottomViewStatus;
@property (nonatomic ,strong)UIButton *clearBtn;
@property (nonatomic ,assign)NSInteger selectInex;
@property (nonatomic ,strong)UnlockFuncView *funcView;
@property (nonatomic ,strong)UIView *bgView;
@property (nonatomic ,strong)CheckProView *checkProView;

@end



@implementation SelectPictureViewController



- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
#ifdef __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
        [self preferredStatusBarUpdateAnimation];
        [self changeStatus];
    }
#endif
}
- (UIStatusBarStyle)preferredStatusBarStyle {
#ifdef __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
        if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            return UIStatusBarStyleLightContent;
        }
    }
#endif
    return UIStatusBarStyleDefault;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self changeStatus];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _reTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerMethod) userInfo:nil repeats:YES];
    [self changeStatus];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (_reTimer != nil){
        [self destoryTimer];
    }
}

#pragma mark 定时器检测图片选择器状态
-(void)timerMethod{
    MJWeakSelf
    if (_isOpenAlbum){
        if (self.manager.selectedCount == 0){
            _showBottomViewStatus = 0;
            if (_showBottomViewStatus == 0){
                _clearBtn.hidden = YES;
                _showBottomViewStatus = 1;
                [self setupBottomViewWithType:1];
            }
        }else {
            if (_clearBtn == nil){
                _clearBtn = [UIButton buttonWithType:UIButtonTypeSystem];
                [_clearBtn setBackgroundImage:IMG(@"清空") forState:UIControlStateNormal];
                [_clearBtn addTarget:self action:@selector(clearSelectIMG) forControlEvents:UIControlEventTouchUpInside];
                [self.view.window addSubview:_clearBtn];
                [_clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(@70);
                    make.height.equalTo(@30);
                    make.bottom.equalTo(@-100);
                    make.left.equalTo(@(SCREEN_WIDTH - 86));
                }];
                
            }
            _clearBtn.hidden = NO;
            [self.view.window bringSubviewToFront:_clearBtn];
            if (self.manager.selectedCount == 1){
               _showBottomViewStatus = 1;
               if (_showBottomViewStatus == 1){
                   _showBottomViewStatus = 2;
                   [self setupBottomViewWithType:2];
               }
           }else{
               _showBottomViewStatus = 2;
               if (_showBottomViewStatus == 2){
                   _showBottomViewStatus = 0;
                   [self setupBottomViewWithType:3];
               }
           }
        }
        
    }
}


//打开相册
-(void)openAlbum:(NSNotification *)noti{
    _isOpenAlbum = YES;
}
//关闭相册
-(void)closeAlbum:(NSNotification *)noti{
    _isOpenAlbum = NO;
    _showBottomViewStatus = 0;
    _clearBtn.hidden = YES;
}


#pragma mark -- 清空选择图片
- (void)clearSelectIMG {
    if (self.manager.selectedCount > 0 ){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"clearData" object:nil];
        _showBottomViewStatus = 0;
        _clearBtn.hidden = YES;
        [self setupBottomViewWithType:1];
       
    }else{
        [SVProgressHUD showInfoWithStatus:@"您未选择任何图片"];
    }
}

-(void)btnClickWithTag:(NSInteger)tag{
    MJWeakSelf
    if (tag == 1) {
        [_funcView removeFromSuperview];
//        [self.navigationController pushViewController:[BuyViewController new] animated:YES];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"dismiss" object:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.navigationController pushViewController:[BuyViewController new ] animated:YES];
        });
    }else{
        MJWeakSelf
        if (_bgView == nil){
            _bgView = [Tools addBGViewWithFrame:self.view.frame];
            [self.view addSubview:_bgView];
        }else{
            _bgView.hidden = NO;
            [self.view bringSubviewToFront:_bgView];
        }
        if (_checkProView == nil){
            _checkProView = [[CheckProView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 550)];
            _checkProView.delegate = self;
            [self.view.window addSubview:_checkProView];
        }
        _checkProView.hidden = NO;
        [self.view.window bringSubviewToFront:_checkProView];
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.checkProView.frame = CGRectMake(0, SCREEN_HEIGHT - weakSelf.checkProView.height, SCREEN_WIDTH , weakSelf.checkProView.height);
        }];
    }
}

-(void)cancelClickWithTag:(NSInteger)tag{
    MJWeakSelf
    if (tag == 1){
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.checkProView.frame = CGRectMake(0, SCREEN_HEIGHT + 100, SCREEN_WIDTH , weakSelf.checkProView.height);
            weakSelf.bgView.hidden = YES;
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.checkProView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 550);
        } completion:^(BOOL finished) {
            weakSelf.bgView.hidden = YES;
            [weakSelf.checkProView removeFromSuperview];
        }];
        [_funcView removeFromSuperview];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"dismiss" object:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.navigationController pushViewController:[BuyViewController new] animated:YES];
        });
    }
}

//销毁定时器
-(void)destoryTimer{
    if (_reTimer) {
        [_reTimer setFireDate:[NSDate distantFuture]];
        [_reTimer invalidate];
        _reTimer = nil;
    }
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
- (void)changeStatus {
#ifdef __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
        if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
            return;
        }
    }
#endif
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}
#pragma clang diagnostic pop

- (HXPhotoManager *)manager {
    MJWeakSelf
    if (!_manager) {
        _manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhoto];
        _manager.configuration.type = HXConfigurationTypeWXChat;
        //设定高级用户和普通选择图片数量
        _manager.configuration.maxNum = 10000;
        _manager.configuration.photoListBottomView = ^(HXPhotoBottomView *bottomView) {
            bottomView.backgroundColor = [UIColor whiteColor];
            weakSelf.bottomView = bottomView;
            [weakSelf.bottomView removeAllSubviews];
            [weakSelf setupBottomViewWithType:1];
            
        };
        _manager.configuration.previewBottomView = ^(HXPhotoPreviewBottomView *bottomView) {
            //preview
        };

    }
    return _manager;
}

-(void)setupBottomViewWithType:(NSInteger )type{
    [_bottomView removeAllSubviews];
    if(type == 1){
        UILabel *tipLab = [UILabel new];
        tipLab.text = @"点击或滑动来选择图片";
        tipLab.font = FontBold(16);
        tipLab.textAlignment = NSTextAlignmentCenter;
        [_bottomView addSubview:tipLab];
        [tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.equalTo(_bottomView);
        }];
    }else {
        NSArray *iconArr ;
        NSArray *textArr;
        if (type == 2){
            iconArr = @[@"裁切icon",@"黑编辑icon"];
            textArr = @[@"裁切",@"编辑"];
        }else{
            iconArr = @[@"截长屏icon",@"拼接icon",@"布局icon",@"字幕icon"];
            textArr = @[@"截长屏",@"拼接",@"布局",@"字幕"];
        }
        CGFloat btnWidth = _bottomView.width / iconArr.count;
        for (NSInteger i = 0; i < iconArr.count; i ++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
            btn.tag = type * 100 + i;
            [btn addTarget:self action:@selector(imgEdit:) forControlEvents:UIControlEventTouchUpInside];
            [_bottomView addSubview:btn];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(btnWidth));
                make.height.top.equalTo(_bottomView);
                make.left.equalTo(@( i * btnWidth));
            }];
            
            UIImageView *icon = [UIImageView new];
            icon.image = IMG(iconArr[i]);
            [btn addSubview:icon];
            [icon mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.height.equalTo(@22);
                make.centerX.equalTo(btn);
                make.top.equalTo(@8);
            }];
            
            UILabel *textLab = [UILabel new];
            textLab.textAlignment = NSTextAlignmentCenter;
            textLab.text = textArr[i];
            textLab.font = Font13;
            textLab.textColor = [UIColor blackColor];
            [btn addSubview:textLab];
            [textLab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.left.equalTo(btn);
                make.top.equalTo(icon.mas_bottom).offset(4);
            }];   
        }
    }
}

#pragma mark -- 图片编辑btn事件 
-(void)imgEdit:(UIButton *)btn{
    MJWeakSelf
    if (btn.tag < 300){
        if (btn.tag == 200){
            //选择一图裁切
        }else{
            //选择一图编辑
        }
    }else{
        _isOpenAlbum = NO;
        [_clearBtn removeFromSuperview];
        _clearBtn = nil;
        if (!User.checkIsVipMember && self.manager.selectedCount > 9){
            //非会员弹出提示
            _funcView = [UnlockFuncView new];
            _funcView.delegate = weakSelf;
            _funcView.type = 3;
            [self.view.window addSubview:_funcView];
            [_funcView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
        }else{
            if (btn.tag == 300){
                //多图截长屏
                CaptionViewController *vc = [CaptionViewController new];
                vc.type = 4;
                __block NSMutableArray *arr = [NSMutableArray array];
                for (HXPhotoModel *photoModel in [self.manager selectedArray]) {
                    [arr addObject:photoModel.asset];
                }
                vc.dataArr = arr;
                [[NSNotificationCenter defaultCenter]postNotificationName:@"dismiss" object:nil];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                });
            }else if(btn.tag == 301){
                //多图拼接
                CaptionViewController *vc = [CaptionViewController new];
                vc.type = 2;
                __block NSMutableArray *arr = [NSMutableArray array];
                for (HXPhotoModel *photoModel in [self.manager selectedArray]) {
                    [Tools getImageWithAsset:photoModel.asset withBlock:^(UIImage * _Nonnull image) {
                        [arr addObject:image];
                    }];
                }
                
                vc.dataArr = arr;
                [[NSNotificationCenter defaultCenter]postNotificationName:@"dismiss" object:nil];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                });
                
            }else if(btn.tag == 302){
                //多图布局
                PictureLayoutController *layoutVC = [[PictureLayoutController alloc] init];
                
                __block NSMutableArray *arr = [NSMutableArray array];
                for (HXPhotoModel *photoModel in [self.manager selectedArray]) {
                    [Tools getImageWithAsset:photoModel.asset withBlock:^(UIImage * _Nonnull image) {
                        [arr addObject:image];
                    }];
                }
                
                layoutVC.pictures = arr;
                
                [[NSNotificationCenter defaultCenter]postNotificationName:@"dismiss" object:nil];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController pushViewController:layoutVC animated:YES];
                });

            }else{
                //多图字幕
                if ([self.manager selectedArray].count > 1){
                    
                    CaptionViewController *vc = [CaptionViewController new];
                    vc.type = 1;
                    __block NSMutableArray *arr = [NSMutableArray array];
                    for (HXPhotoModel *photoModel in [self.manager selectedArray]) {
                        [Tools getImageWithAsset:photoModel.asset withBlock:^(UIImage * _Nonnull image) {
                            [arr addObject:image];
                        }];
                    }
                    
                    vc.dataArr = arr;
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"dismiss" object:nil];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakSelf.navigationController pushViewController:vc animated:YES];
                    });
                }else{
                    [SVProgressHUD showInfoWithStatus:@"电影截图拼接至少2张图片"];
                }
                
            }
        }
        
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    HXWeakSelf
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (self.manager.configuration.saveSystemAblum) {
            [HXPhotoTools savePhotoToCustomAlbumWithName:self.manager.configuration.customAlbumName photo:image location:nil complete:^(HXPhotoModel *model, BOOL success) {
                if (success) {
                    if (weakSelf.manager.configuration.useCameraComplete) {
                        weakSelf.manager.configuration.useCameraComplete(model);
                    }
                }else {
                    [weakSelf.view hx_showImageHUDText:@"保存图片失败"];
                }
            }];
        }else {
            HXPhotoModel *model = [HXPhotoModel photoModelWithImage:image];
            if (self.manager.configuration.useCameraComplete) {
                self.manager.configuration.useCameraComplete(model);
            }
        }
    }else  if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *url = info[UIImagePickerControllerMediaURL];
        
        if (self.manager.configuration.saveSystemAblum) {
            [HXPhotoTools saveVideoToCustomAlbumWithName:self.manager.configuration.customAlbumName videoURL:url location:nil complete:^(HXPhotoModel *model, BOOL success) {
                if (success) {
                    if (weakSelf.manager.configuration.useCameraComplete) {
                        weakSelf.manager.configuration.useCameraComplete(model);
                    }
                }else {
                    [weakSelf.view hx_showImageHUDText:@"保存视频失败"];
                }
            }];
        }else {
            HXPhotoModel *model = [HXPhotoModel photoModelWithVideoURL:url];
            if (self.manager.configuration.useCameraComplete) {
                self.manager.configuration.useCameraComplete(model);
            }
        }
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)dealloc {
    NSSLog(@"dealloc");
}

#pragma mark --photoViewDelegate

- (void)photoView:(HXPhotoView *)photoView changeComplete:(NSArray<HXPhotoModel *> *)allList photos:(NSArray<HXPhotoModel *> *)photos videos:(NSArray<HXPhotoModel *> *)videos original:(BOOL)isOriginal {
    
}
- (void)photoViewCurrentSelected:(NSArray<HXPhotoModel *> *)allList photos:(NSArray<HXPhotoModel *> *)photos videos:(NSArray<HXPhotoModel *> *)videos original:(BOOL)isOriginal {
    for (HXPhotoModel *photoModel in allList) {
        NSSLog(@"当前选择----> %@", photoModel.selectIndexStr);
//        photoModel.asset
    }
}
- (void)photoView:(HXPhotoView *)photoView deleteNetworkPhoto:(NSString *)networkPhotoUrl {
    NSSLog(@"%11@",networkPhotoUrl);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _isOpenAlbum = NO;
    _showBottomViewStatus = 0;
    _selectInex = 0;
    self.title  = @"拼图";
#ifdef __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor hx_colorWithHexStr:@"#191918"];
            }
            return UIColor.whiteColor;
        }];
    }
#endif
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
//
//    CGFloat width = scrollView.frame.size.width;
    HXPhotoView *photoView = [HXPhotoView photoManager:self.manager scrollDirection:UICollectionViewScrollDirectionVertical];
    photoView.frame = CGRectMake(0, kPhotoViewMargin, SCREEN_WIDTH, 0);
    photoView.collectionView.contentInset = UIEdgeInsetsMake(0, kPhotoViewMargin, 0, kPhotoViewMargin);
//    photoView.spacing = kPhotoViewMargin;
//    photoView.lineCount = 1;
    photoView.delegate = self;
//    photoView.cellCustomProtocol = self;
    photoView.outerCamera = NO;
    photoView.previewStyle = HXPhotoViewPreViewShowStyleDark;
    photoView.previewShowDeleteButton = YES;
    photoView.showAddCell = YES;
//    photoView.showDeleteNetworkPhotoAlert = YES;
//    photoView.adaptiveDarkness = NO;
//    photoView.previewShowBottomPageControl = NO;
    [photoView.collectionView reloadData];
    [scrollView addSubview:photoView];
    self.photoView = photoView;
    
    
//    HXCustomNavigationController *nav = [[HXCustomNavigationController alloc] initWithManager:self.manager delegate:self];
//    nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
//    nav.modalPresentationCapturesStatusBarAppearance = YES;
//    [self.view.viewController presentViewController:nav animated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openAlbum:) name:@"openAlbum" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeAlbum:) name:@"closeAlbum" object:nil];
    
}


- (void)photoView:(HXPhotoView *)photoView updateFrame:(CGRect)frame {
    NSSLog(@"%@",NSStringFromCGRect(frame));
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, CGRectGetMaxY(frame) + kPhotoViewMargin);
    
}
- (void)photoView:(HXPhotoView *)photoView currentDeleteModel:(HXPhotoModel *)model currentIndex:(NSInteger)index {
    NSSLog(@"%@ --> index - %ld",model,index);
}
- (BOOL)photoView:(HXPhotoView *)photoView collectionViewShouldSelectItemAtIndexPath:(NSIndexPath *)indexPath model:(HXPhotoModel *)model {
    NSLog(@"111");
    return YES;
}

- (BOOL)photoViewShouldDeleteCurrentMoveItem:(HXPhotoView *)photoView gestureRecognizer:(UILongPressGestureRecognizer *)longPgr indexPath:(NSIndexPath *)indexPath {
    return self.needDeleteItem;
}
- (void)photoView:(HXPhotoView *)photoView gestureRecognizerBegan:(UILongPressGestureRecognizer *)longPgr indexPath:(NSIndexPath *)indexPath {
    [UIView animateWithDuration:0.25 animations:^{
        //self.bottomView.alpha = 0.5;
    }];
    NSSLog(@"长按手势开始了 - %ld",indexPath.item);
}
- (void)photoView:(HXPhotoView *)photoView gestureRecognizerChange:(UILongPressGestureRecognizer *)longPgr indexPath:(NSIndexPath *)indexPath {
    CGPoint point = [longPgr locationInView:self.view];
//    if (point.y >= self.bottomView.hx_y) {
//        [UIView animateWithDuration:0.25 animations:^{
//            self.bottomView.alpha = 1;
//        }];
//    }else {
//        [UIView animateWithDuration:0.25 animations:^{
//            self.bottomView.alpha = 0.5;
//        }];
//    }
    NSSLog(@"长按手势改变了 %@ - %ld",NSStringFromCGPoint(point), indexPath.item);
}
- (void)photoView:(HXPhotoView *)photoView gestureRecognizerEnded:(UILongPressGestureRecognizer *)longPgr indexPath:(NSIndexPath *)indexPath {
   // CGPoint point = [longPgr locationInView:self.view];
//    if (point.y >= self.bottomView.hx_y) {
//        self.needDeleteItem = YES;
//        [self.photoView deleteModelWithIndex:indexPath.item];
//    }else {
//        self.needDeleteItem = NO;
//    }
//    NSSLog(@"长按手势结束了 - %ld",indexPath.item);
//    [UIView animateWithDuration:0.25 animations:^{
//        self.bottomView.alpha = 0;
//    }];
}

@end
