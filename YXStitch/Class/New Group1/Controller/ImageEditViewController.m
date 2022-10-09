//
//  ImageEditViewController.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/9/21.
//

#import "ImageEditViewController.h"
#import "ImageEditMarkView.h"
#import "WaterColorSelectView.h"
#import "ColorPlateView.h"
#import "WaterTitleView.h"
#import "SaveViewController.h"
#import "ImageEditBottomView.h"
#import "UnlockFuncView.h"
#import "BuyViewController.h"
#import "checkProView.h"
#import "PaintPath.h"
#import "UIBezierPath+GetAllPoints.h"
#import "MosaicStyleSelectView.h"
#import "UIBezierPath+Arrow.h"
#import "CustomScrollView.h"
#import "StitchingButton.h"
#import "UIView+directionBorder.h"
#import "ImageBorderSettingView.h"
#import "ImageShellSettingView.h"
#import "imageShellSelectView.h"


#define HEAD_LENGTH 100
#define HEAD_WIDTH 30
#define TAIL_WIDTH 8

#define LINE_WIDTH 3
#define FONT_SIZE 15

#define VerViewWidth 260
#define HorViewHeight 300

#define LAYERS @"layers"
#define REMOVED_LAYERS @"removedLayers"

@interface ImageEditViewController ()<WaterColorSelectViewDelegate,UIScrollViewDelegate,UnlockFuncViewDelegate,CheckProViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic ,strong)ImageEditMarkView *imgEditMarkView;
@property (nonatomic ,strong)WaterColorSelectView *colorSelectView;
@property (nonatomic ,strong)ImageEditBottomView *bottomView;
@property (nonatomic ,strong)ColorPlateView *colorPlateView;
@property (nonatomic ,strong)WaterTitleView *titleView;
@property (nonatomic ,strong)UnlockFuncView *tipsView;
@property (nonatomic ,strong)MosaicStyleSelectView *mosaicView;//马赛克
@property (nonatomic ,strong)ImageBorderSettingView *borderSettingView;//设置边框
@property (nonatomic ,strong)ImageShellSettingView *shellSettingView;//设置外壳
@property (nonatomic ,strong)imageShellSelectView *shellSelectView;//外框类型选择


@property (nonatomic ,strong)UIView *contentView;
@property (nonatomic ,strong)CustomScrollView *contentScrollView;
@property (nonatomic ,strong)UIImageView *imageView;
@property (nonatomic ,strong)UIView *bgView;
@property (nonatomic ,strong)CheckProView *checkProView;
@property (nonatomic ,strong)UIView *shellBkView;//套壳背景view
@property (nonatomic ,strong)UIImageView *shellBkImageView;//套壳背景imageview

@property (nonatomic ,assign)NSInteger editType;//编辑类型
@property (nonatomic ,assign)NSInteger markType;//标注类型
@property (nonatomic ,assign)NSInteger borderType;//边框类型
@property (nonatomic ,assign)CGFloat currentBorderValue;//当前border值
@property (nonatomic ,strong)UIPinchGestureRecognizer *pinchRecognizer;
@property (nonatomic ,strong)UIPanGestureRecognizer *panRecognizer;

@property (nonatomic, strong)NSMutableArray *dataArr;//维护单个画布的路径数组

@property (nonatomic, strong)NSMutableArray *imageViewsArr;//维护图片数组
@property (nonatomic, strong)NSMutableArray *originWidthArr;//图片原始宽度数组
@property (nonatomic, strong)NSMutableArray *originHeightArr;
@property (nonatomic, strong)NSMutableArray *originzTopArr;

@property (nonatomic, strong)NSMutableArray * layers;// 线条数组
@property (nonatomic, strong)NSMutableArray * removedLayers; //撤销的线条数组
@property (nonatomic, strong)UIBezierPath * __nullable path;//自己当前绘画的路径
@property (nonatomic, strong)UIBezierPath *currentPath;//当前选中的path
@property (nonatomic, assign)CGFloat pathWidth; //画笔宽度
@property (nonatomic, strong)UIColor *pathLineColor; //画笔颜色
@property (nonatomic, strong)CAShapeLayer *slayer;//当前操作layer层

@property (nonatomic, strong)UIView *selectView;//选中path的边框
@property (nonatomic, strong)UIView *borderView;//方框view
@property (nonatomic, strong)UIView *fillBorderView;//填充方框view
@property (nonatomic, assign)CGPoint stratPoint;
@property (nonatomic, assign)BOOL isSelectPath;
@property (nonatomic, assign)CGRect originRect;//记录被修改的原始路径，用于后面移动、修改重构时需要
@property (nonatomic, assign)NSInteger mosaicShape;//马赛克默认形状
@property (nonatomic, assign)NSInteger mosaicStyle;//马赛克默认样式
@property (nonatomic, strong)UIColor *fillColor;//填充颜色
@property (nonatomic, assign)BOOL isStartPaint;


@end

@implementation ImageEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.title = [NSString stringWithFormat:@"%@",_titleStr];
    _isSelectPath = NO;
    _isStartPaint = NO;
//    _dataArr = [NSMutableArray array];
//    _imageViewsArr = [NSMutableArray array];
//    _originWidthArr = [NSMutableArray array];
//    _originHeightArr = [NSMutableArray array];
//    _originzTopArr = [NSMutableArray array];
    [self setupViews];
    [self setupNavItems];
    [self addBottomView];
    
    [self addGestureRecognizer];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (@available(iOS 15.0, *)) {
        [Tools setNaviBarBKColorWith:self.navigationController andBKColor:[UIColor blackColor] andFontColor:[UIColor whiteColor]];
    }else{
        UIColor *color = [UIColor whiteColor];
        NSDictionary *dict = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
        self.navigationController.navigationBar.titleTextAttributes = dict;
    }
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    UIColor *color = [UIColor blackColor];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [Tools setNaviBarBKColorWith:self.navigationController andBKColor:[UIColor whiteColor] andFontColor:[UIColor blackColor]];
}

#pragma mark --initUI
-(void)setupViews{
    _contentView = [UIView new];
    _contentView.userInteractionEnabled = YES;
    _contentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_contentView];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    _contentScrollView = [CustomScrollView new];
    _contentScrollView.delegate = self;
    _contentScrollView.backgroundColor = [UIColor clearColor];
    _contentScrollView.userInteractionEnabled = YES;
    _contentScrollView.scrollEnabled = YES;
    [_contentView addSubview:_contentScrollView];
    
    UIPanGestureRecognizer *tapGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    _contentScrollView.delaysContentTouches = YES;
    tapGesture.delegate = self;
    [_contentScrollView addGestureRecognizer:tapGesture];
    
    CGFloat imageFakewidth = 0.0;
    CGFloat imageFakeHeight= 0.0;
    CGFloat scrollWidth= 0.0;
    CGFloat scrollHeight= 0.0;
    if(_isVer){
        imageFakewidth = 260;
        imageFakeHeight = (CGFloat)_screenshotIMG.size.height *imageFakewidth / _screenshotIMG.size.width;
        scrollWidth  = 260;
        scrollHeight = SCREEN_HEIGHT - Nav_HEIGHT - 80;
        _contentScrollView.contentSize = CGSizeMake(0, imageFakeHeight);
    }else{
        imageFakeHeight= 300;
        imageFakewidth= _screenshotIMG.size.width;
        scrollHeight = 300;
        scrollWidth = (CGFloat)(_screenshotIMG.size.width/_screenshotIMG.size.height) * 300;;
        _contentScrollView.contentSize = CGSizeMake(imageFakewidth, 0);
    }
    [_contentScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (_isVer){
            make.top.equalTo(@(Nav_H));
            make.centerX.equalTo(_contentView);
            make.width.equalTo(@(scrollWidth));
        }else{
            make.width.equalTo(@(SCREEN_WIDTH));
            make.centerY.equalTo(_contentView);
        }
        make.height.equalTo(@(scrollHeight));
    }];
    if (_isVer){
        //竖拼
        [self addVerticalContentView];
    }else{
        [self addHorizontalContentView];
    }
    
}

-(void)addVerticalContentView{
    //竖拼
    CGFloat contentHeight = 0.0;
    UIImage *icon = _imgArr[0];
    StitchingButton *firstImageView = [[StitchingButton alloc]initWithFrame:CGRectMake(0, 0, VerViewWidth, (CGFloat)(icon.size.height/icon.size.width) * VerViewWidth)];
    firstImageView.image = icon;
    firstImageView.userInteractionEnabled = YES;
    contentHeight += firstImageView.height;
    firstImageView.tag = 100;
    [_contentScrollView addSubview:firstImageView];
    [self.imageViewsArr addObject:firstImageView];
    [self.originWidthArr addObject:[NSNumber numberWithFloat:VerViewWidth]];
    [self.originHeightArr addObject:[NSNumber numberWithFloat:(CGFloat)(icon.size.height/icon.size.width) * VerViewWidth]];
    [self.originzTopArr addObject:[NSNumber numberWithFloat:0.0]];
    for (NSInteger i = 1; i < _imgArr.count; i ++) {
        UIImage *icon = _imgArr[i];
        CGFloat imgHeight = (CGFloat)(icon.size.height/icon.size.width) * VerViewWidth;
        StitchingButton *imageView = [[StitchingButton alloc]initWithFrame:CGRectMake(0, firstImageView.bottom, VerViewWidth, imgHeight)];
        imageView.userInteractionEnabled = YES;
        imageView.image = icon;
        imageView.centerX = firstImageView.centerX;
        contentHeight += imgHeight;
        [self.originWidthArr addObject:[NSNumber numberWithFloat:VerViewWidth]];
        [self.originHeightArr addObject:[NSNumber numberWithFloat:imgHeight]];
        [self.originzTopArr addObject:[NSNumber numberWithFloat:firstImageView.bottom]];
        [_contentScrollView addSubview:imageView];
        firstImageView = imageView;
        [self.imageViewsArr addObject:imageView];
        
    }
    _contentScrollView.contentSize = CGSizeMake(_contentScrollView.width,contentHeight);
    
    if (contentHeight < SCREEN_HEIGHT){
        [_contentScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@((SCREEN_HEIGHT - contentHeight)/2));
        }];
    }
}

//横拼
-(void)addHorizontalContentView{
    CGFloat contentWidth = 0.0;
    UIImage *icon = _imgArr[0];
    StitchingButton *firstImageView = [[StitchingButton alloc]initWithFrame:CGRectMake(0,0, (CGFloat)(icon.size.width / icon.size.height) * HorViewHeight, HorViewHeight)];
    firstImageView.image = icon;
    firstImageView.userInteractionEnabled = YES;
    contentWidth += firstImageView.width;
    firstImageView.tag = 100;
    //    [_originRightArr addObject:[NSNumber numberWithFloat:0]];
    [_contentScrollView addSubview:firstImageView];
    [self.imageViewsArr addObject:firstImageView];
    [self.originWidthArr addObject:[NSNumber numberWithFloat:(CGFloat)(icon.size.width / icon.size.height) * HorViewHeight]];
    [self.originHeightArr addObject:[NSNumber numberWithFloat:HorViewHeight]];
    for (NSInteger i = 1; i < _imgArr.count; i ++) {
        UIImage *icon = _imgArr[i];
        CGFloat imgWidth = (CGFloat)(icon.size.width/icon.size.height) * HorViewHeight;
        StitchingButton *imageView = [[StitchingButton alloc]initWithFrame:CGRectMake(firstImageView.right, firstImageView.top, imgWidth, HorViewHeight)];
        imageView.image = icon;
        imageView.userInteractionEnabled = YES;
        imageView.tag = (i+1) * 100;
        contentWidth += imgWidth;
        [_contentScrollView addSubview:imageView];
        firstImageView = imageView;
        [self.originWidthArr addObject:[NSNumber numberWithFloat:imgWidth]];
        [self.originHeightArr addObject:[NSNumber numberWithFloat:HorViewHeight]];
        [self.imageViewsArr addObject:imageView];
        
    }
    _contentScrollView.contentSize = CGSizeMake(contentWidth,HorViewHeight);
}

-(void)setupNavItems{
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    saveBtn.tag = 0;
    [saveBtn setBackgroundImage:IMG(@"水印保存") forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(checkBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc]initWithCustomView:saveBtn];
    self.navigationItem.rightBarButtonItem = saveItem;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    leftBtn.tag = 1;
    leftBtn.titleLabel.font = Font18;
    [leftBtn setTitle:@"返回" forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(checkBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = item;
}
-(void)addBottomView{
    MJWeakSelf
    
    _bottomView = [ImageEditBottomView new];
    _bottomView.btnClick = ^(NSInteger tag) {
        [weakSelf imageBottomViewClickWithTag:tag];
    };
    [self.view addSubview:_bottomView];
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.bottom.equalTo(self.view);
        make.height.equalTo(@80);
    }];
    
}

-(void)addGestureRecognizer{
    //    _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(selectonPanGesture:)];
    //    _panRecognizer.maximumNumberOfTouches = 1;
    //    [_contentView addGestureRecognizer:_panRecognizer];
    _pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [_contentView addGestureRecognizer:_pinchRecognizer];
}

#pragma mark ---btnClick && viewDelegateClick
-(void)checkBtnClick:(UIButton *)btn{
    MJWeakSelf
    if (btn.tag == 0){
        //[_cutBtn removeFromSuperview];
        [SVProgressHUD showWithStatus:@"正在生成图片中.."];
        //UIView *view;
        SaveViewController *saveVC = [SaveViewController new];
        //        saveVC.screenshotIMG = [Tools imageFromView:_contentView rect:_contentView.frame];
        saveVC.isVer = weakSelf.isVer;
        saveVC.type = 2;
        [TYSnapshotScroll screenSnapshot:_contentScrollView finishBlock:^(UIImage *snapshotImage) {
            [SVProgressHUD dismiss];
            saveVC.screenshotIMG = snapshotImage;
            [weakSelf.navigationController pushViewController:saveVC animated:YES];
            if (GVUserDe.isAutoSaveIMGAlbum){
                //保存到拼图相册
                [SVProgressHUD showSuccessWithStatus:@"图片已保存至拼图相册中"];
                [Tools saveImageWithImage:saveVC.screenshotIMG albumName:@"拼图" withBlock:^(NSString * _Nonnull identify) {
                    saveVC.identify = identify;
                }];
            }else{
                //                UIImageWriteToSavedPhotosAlbum(snapshotImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
            }
            
            
        }];
        //        [_contentScrollView DDGContentScrollScreenShot:^(UIImage *screenShotImage) {
        
        //        }];
        //判断是否是高级会员
        //    if(GVUserDe.isMember){
        //        GVUserDe.waterPosition = _toolView.selectIndex;
        //        _funcView = [UnlockFuncView new];
        //        _funcView.delegate = self;
        //        _funcView.type = 2;
        //        [self.view addSubview:_funcView];
        //        [_funcView mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.edges.equalTo(self.view);
        //        }];
        //    }else{
        //
        //    }
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSString *msg = nil;
    if (!error) {
        msg = @"下载成功，已为您保存至相册";
    }else {
        msg = @"系统未授权访问您的照片，请您在设置中进行权限设置后重试";
    }
    NSLog(@"msg=%@",msg);
}

-(void)imageBottomViewClickWithTag:(NSInteger )tag{
    MJWeakSelf
    _imgEditMarkView.hidden = YES;
    _selectView.hidden = YES;
    _borderSettingView.hidden = YES;
   // _bottomView.hidden = YES;
    _editType = tag;
    if(tag == 1){
        //标注
        if (_imgEditMarkView == nil){
            _imgEditMarkView = [[ImageEditMarkView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH,100)];
            _imgEditMarkView.isVer = _isVer;
            [self.view addSubview:_imgEditMarkView];
        }
        _imgEditMarkView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.imgEditMarkView.frame = CGRectMake(0, SCREEN_HEIGHT - weakSelf.imgEditMarkView.height, SCREEN_WIDTH, weakSelf.imgEditMarkView.height);
        }];
        _imgEditMarkView.btnClick = ^(NSInteger tag) {
            [weakSelf imgMarkEditViewBtnClickWithTag:tag];
        };
    }else if (tag ==2){
        //边框
        _borderType = 0;
        if (_borderSettingView == nil){
            _borderSettingView = [[ImageBorderSettingView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH,100)];
            _borderSettingView.isVer = _isVer;
            [self.view addSubview:_borderSettingView];
        }
        _borderSettingView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.borderSettingView.frame = CGRectMake(0, SCREEN_HEIGHT - weakSelf.borderSettingView.height, SCREEN_WIDTH, weakSelf.borderSettingView.height);
        }];
        
        _borderSettingView.btnClick = ^(NSInteger tag) {
            [weakSelf imageBorderSettingWithTag:tag];
        };
    }else if (tag == 3){
        //套壳
        if (_isVer){
            UIImageView *tmp = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _contentScrollView.width, _contentScrollView.contentSize.height)];
            tmp.image = IMG(@"刘海iphone14 Pro max金色");
            [_contentScrollView addSubview:tmp];
            [_contentScrollView bringSubviewToFront:tmp];
        }
        if (_shellSettingView == nil){
            _shellSettingView = [[ImageShellSettingView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH,100)];
            _shellSettingView.isVer = _isVer;
            [self.view addSubview:_shellSettingView];
        }
        _shellSettingView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.shellSettingView.frame = CGRectMake(0, SCREEN_HEIGHT - weakSelf.shellSettingView.height, SCREEN_WIDTH, weakSelf.shellSettingView.height);
        }];
        _shellSettingView.btnClick = ^(NSInteger tag, BOOL isSelected) {
            [weakSelf changeImageShellWithType:tag AndSelected:isSelected];
        };
        //        if (GVUserDe.isMember){
        //
        //        }else{
        //            [self addTipsViewWithType:4];
        //        }
    }else{
        //水印
        if (GVUserDe.isMember){
            
        }else{
            [self addTipsViewWithType:2];
        }
    }
}

#pragma mark --标注编辑
-(void)imgMarkEditViewBtnClickWithTag:(NSInteger )tag{
    
    MJWeakSelf
    [_colorSelectView removeFromSuperview];
    [_mosaicView removeFromSuperview];
    _isStartPaint = NO;
    if (tag == 0){
        //取消
        _markType = 0;
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.imgEditMarkView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, weakSelf.imgEditMarkView.height);
        } completion:^(BOOL finished) {
            weakSelf.imgEditMarkView.hidden = YES;
            //weakSelf.bottomView.hidden = NO;
        }];
    }else if (tag == 1 || tag == 4 || tag == 2){
        _pathWidth = 5;
        _pathLineColor = [UIColor orangeColor];
        if (tag == 2){
            //实心填充
            _markType = FILLRECTANGLE;
            [_colorSelectView removeFromSuperview];
            [self addColoeSelectedViewWithType:3];
        }else{
            //空心填充 //箭头
            [_colorSelectView removeFromSuperview];
            [self addColoeSelectedViewWithType:1];
            if (tag == 1){
                _markType = RECTANGLE;
            }else{
                _markType = ARROW;
            }
        }
    }else if(tag == 3){
        //马赛克
        _markType = MOSAIC;
        _mosaicView = [[MosaicStyleSelectView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 80)];
        _mosaicShape = 100;
        _mosaicStyle = 200;
        [self.view addSubview:_mosaicView];
        _pathWidth = 15;
        _pathLineColor = [UIColor orangeColor];
        //选择样式
        _mosaicView.shapeBtnClick = ^(NSInteger tag) {
            //weakSelf.mosaicShape = tag;
            if (tag == 100){
                weakSelf.markType = MOSAICRECTANGLE;
            }else if(tag == 101){
                weakSelf.markType = MOSAICOVAL;
            }else{
                weakSelf.markType = MOSAIC;
            }
        };
        //选择图案
        _mosaicView.styleBtnClick = ^(NSInteger tag) {
            weakSelf.mosaicStyle = tag;
        };
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.mosaicView.frame = CGRectMake(0, SCREEN_HEIGHT - 80 - weakSelf.mosaicView.height, SCREEN_WIDTH, weakSelf.mosaicView.height);
        }];
    }else if(tag == 5){
        //画笔
        _markType = LINE;
        _pathWidth = 5;
        _pathLineColor = [UIColor orangeColor];
        [_colorSelectView removeFromSuperview];
        [self addColoeSelectedViewWithType:2];
    }else if(tag == 6){
        //文本
        _markType = WORD;
        if (!_titleView){
            _titleView = [WaterTitleView new];
            _titleView.type = 2;
            [_titleView.titleTV becomeFirstResponder];
            _titleView.btnClick = ^(NSInteger tag) {
                weakSelf.titleView.hidden = YES;
                if (tag == 1){
                    [weakSelf addEditLabWithStr:weakSelf.titleView.titleTV.text];
                    [weakSelf addTipsViewWithType:1];
                }
            };
            [self.view.window addSubview:_titleView];
            [_titleView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
        }else{
            _titleView.hidden = NO;
        }
    }else if(tag == 100){
        //删除
        //_markType = DELETELAYER;
        [self undo];
    }else if(tag == 200){
        //撤销
       // _markType = UNDO;
        [self undo];
    }else{
        
    }
}
#pragma mark --边框编辑
-(void)imageBorderSettingWithTag:(NSInteger )tag{
    MJWeakSelf
    if (tag == 0){
        //取消
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.borderSettingView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, weakSelf.borderSettingView.height);
        } completion:^(BOOL finished) {
            weakSelf.borderSettingView.hidden = YES;
           // weakSelf.bottomView.hidden = NO;
        }];
    }else{
        if (_editType == 2 && _borderType <= 0 && _colorSelectView == nil){
//            [_colorSelectView removeFromSuperview];
            if (_colorSelectView == nil){
                [self addColoeSelectedViewWithType:4];
                _pathWidth = 1;
                _pathLineColor = [UIColor orangeColor];
            }
        }
        
        if (tag == 1){
            //无边框
            _pathWidth = 0;
            _pathLineColor = [UIColor clearColor];
        }
        _borderType = tag;
        [self changeImageBorderWithType:_borderType AndBorderWidth:_pathWidth AndColor:_pathLineColor];
        if (_borderType == 1){
            [UIView animateWithDuration:0.3 animations:^{
                weakSelf.colorSelectView.frame = CGRectMake(0, SCREEN_HEIGHT - 80, SCREEN_WIDTH, weakSelf.colorSelectView.height);
            } completion:^(BOOL finished) {
                [weakSelf.colorSelectView removeFromSuperview];
                weakSelf.colorSelectView = nil;
                weakSelf.borderType = 0;
            }];
            
        }
        
    }
}

#pragma mark -- 改变边框
-(void)changeImageBorderWithType:(NSInteger)type AndBorderWidth:(CGFloat)width AndColor:(UIColor *)color{
    CGFloat changeScale = 1 - width / 100;
    if (type == 2){
        StitchingButton *image = _imageViewsArr[0];
        image.backgroundColor = color;
        CGFloat imgWidth  = [_originWidthArr[0]floatValue];
        CGFloat imgHeight = [_originHeightArr[0]floatValue];
        image.imgView.bottom = image.bottom;
        image.imgView.width = imgWidth * changeScale;
        image.imgView.height = imgHeight *changeScale;
        image.imgView.centerX = image.centerX;
        StitchingButton *firstImage = image;
        for (NSInteger i = 1; i < _imageViewsArr.count ; i ++) {
            StitchingButton *imageView = _imageViewsArr[i];
            imageView.backgroundColor = color;
            CGFloat imgWidth  = [_originWidthArr[i]floatValue];
            CGFloat imgHeight = [_originHeightArr[i]floatValue];
            CGFloat imgTop = [_originzTopArr[i]floatValue];
            imageView.imgView.width = imgWidth * changeScale;
            imageView.imgView.height = imgHeight *changeScale;
            imageView.imgView.top = 0;
            if (i != 1){
                imageView.top = imgTop * changeScale;
            }else{
                imageView.top = firstImage.bottom;
            }
            imageView.imgView.centerX = image.centerX;
            firstImage = imageView;
        }
    }else if (type == 3){
        
    }else if (type == 4){
        
    }else{
        for (NSInteger i = 0; i < _imageViewsArr.count; i ++) {
            StitchingButton *image = _imageViewsArr[i];
            image.backgroundColor = color;
            CGFloat imgWidth  = [_originWidthArr[i]floatValue];
            CGFloat imgHeight = [_originHeightArr[i]floatValue];
            CGFloat top = [_originzTopArr[i] floatValue];
            image.frame = CGRectMake(0, top, imgWidth, imgHeight);
            image.imgView.frame = CGRectMake(0, 0, imgWidth, imgHeight);
        }
    }
    for (NSInteger i = 0; i < _imageViewsArr.count ; i ++) {
        StitchingButton *image = _imageViewsArr[i];
        image.backgroundColor = color;
        CGFloat imgWidth  = [_originWidthArr[i]floatValue];
        CGFloat imgHeight = [_originHeightArr[i]floatValue];
        //[image.layer removeAllSublayers];
        if (type != 1){
            if (type == 2){
                //外边框
                if (_isVer){
//                    image.imgView.frame = CGRectMake(image.imgView.origin.x, image.imgView.origin.y, imgWidth * changeScale, imgHeight * changeScale);
                   // image.imgView.bottom = image.bottom;
                    //image.imgView.centerX = image.centerX;
                    if (i == 0){
                        //[image setDirectionBorderWithTop:YES left:YES bottom:NO right:YES borderColor:color withBorderWidth:width];
                    }else if (i == _imageViewsArr.count - 1){
                       // [image setDirectionBorderWithTop:NO left:YES bottom:YES right:YES borderColor:color withBorderWidth:width];
                    }else{
                        //[image setDirectionBorderWithTop:NO left:YES bottom:NO right:YES borderColor:color withBorderWidth:width];
                    }
                }else{
                    if (i == 0){
                        //[image setDirectionBorderWithTop:YES left:YES bottom:YES right:NO borderColor:color withBorderWidth:width];
                    }else if (i == _imageViewsArr.count - 1){
                       // [image setDirectionBorderWithTop:YES left:NO bottom:YES right:YES borderColor:color withBorderWidth:width];
                    }else{
                       // [image setDirectionBorderWithTop:YES left:NO bottom:YES right:NO borderColor:color withBorderWidth:width];
                    }
                }
                
                
            }else if (type == 3){
                //内边框
                if (_isVer){
                    if (i == 0){
                        [image setDirectionBorderWithTop:NO left:NO bottom:YES right:NO borderColor:color withBorderWidth:width];
                    }else if (i == _imageViewsArr.count - 1){
                        [image setDirectionBorderWithTop:YES left:NO bottom:NO right:NO borderColor:color withBorderWidth:width];
                    }else{
                        [image setDirectionBorderWithTop:YES left:NO bottom:YES right:NO borderColor:color withBorderWidth:width];
                    }
                }else{
                    if (i != 0 && i != _imageViewsArr.count - 1){
                        [image setDirectionBorderWithTop:NO left:YES bottom:NO right:YES borderColor:color withBorderWidth:width];
                    }
                }
                
            }else{
                //全边框
//                image.width = image.width - width / 10;
                [image setDirectionBorderWithTop:YES left:YES bottom:YES right:YES borderColor:color withBorderWidth:width];
            }
        }
        
    }
//    if (width >= _currentBorderValue){
//        if (_isVer){
//            [_contentScrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                if (_isVer){
//                    make.top.equalTo(@(Nav_HEIGHT));
//                    make.height.equalTo(@(SCREEN_HEIGHT - 80 - Nav_HEIGHT));
//                    make.center.equalTo(_contentView);
//                    make.width.equalTo(@(_contentScrollView.width + width));
//                }else{
//                    make.width.equalTo(@(SCREEN_WIDTH));
//                    make.centerY.equalTo(_contentView);
//                }
//            }];
//
//        }else{
//            _contentScrollView.frame = CGRectMake(_contentScrollView.top, _contentScrollView.left, _contentScrollView.width, _contentScrollView.height + width);
//            _contentScrollView.center = _contentView.center;
//        }
//    }else{
//        if (_isVer){
//            _contentScrollView.frame = CGRectMake(_contentScrollView.top, _contentScrollView.left, _contentScrollView.width - width, _contentScrollView.height);
//            _contentScrollView.center = _contentView.center;
//        }else{
//            _contentScrollView.frame = CGRectMake(_contentScrollView.top, _contentScrollView.left, _contentScrollView.width, _contentScrollView.height - width);
//            _contentScrollView.center = _contentView.center;
//        }
//    }
    _currentBorderValue = width;
}
#pragma mark -- 编辑外壳
-(void)changeImageShellWithType:(NSInteger)type AndSelected:(BOOL)isSelected{
    MJWeakSelf
    if (type == 0){
        //取消
        [self shellSelectViewDiss];
    }else if (type == 100){
        //机型选择
        if (!isSelected){
            if (_shellSelectView == nil){
                _shellSelectView = [[imageShellSelectView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 80, SCREEN_WIDTH,325)];
                [self.view addSubview:_shellSelectView];
            }
            _shellSelectView.hidden = NO;
            [UIView animateWithDuration:0.3 animations:^{
                weakSelf.shellSelectView.frame = CGRectMake(0, SCREEN_HEIGHT - weakSelf.shellSelectView.height - 80, SCREEN_WIDTH, weakSelf.shellSelectView.height);
            }];
            _shellSelectView.selectClick = ^(NSString * _Nonnull str, UIColor * _Nonnull color) {
                weakSelf.shellSettingView.phoneTypeLab.text = str;
                weakSelf.shellSettingView.phoneBKIMG.backgroundColor = color;
            };
        }else{
            [UIView animateWithDuration:0.3 animations:^{
                weakSelf.shellSelectView.frame = CGRectMake(0, SCREEN_HEIGHT - 80, SCREEN_WIDTH, weakSelf.shellSelectView.height);
            } completion:^(BOOL finished) {
                weakSelf.shellSelectView.hidden = YES;
            }];
        }
        
                
    }else{
        //[self shellSelectViewDiss];
        if (type == 1){
            //横竖切换
            if (_isVer){
                //竖屏进来
                if (!isSelected){
                    //切换成横屏
                    _isVer = NO;
                    [self changeShellViewWithType:2];
                }else{
                    //竖屏
                    _isVer = YES;
                    [self changeShellViewWithType:1];
                }
            }else{
                //横屏进入
                if (!isSelected){
                    //切换成竖屏
                    _isVer = YES;
                    [self changeShellViewWithType:1];
                }else{
                    //切换成横屏
                    _isVer = NO;
                    [self changeShellViewWithType:2];
                }
            }
            
        }else if (type == 2){
            //背景调整
            if(!isSelected){
                [_colorSelectView removeFromSuperview];
                [self addColoeSelectedViewWithType:4];
            }else{
                [self colorViewDismiss];
            }
            
        }else{
            if (!isSelected){
                //无刘海
            }else{
                //有刘海
            }
        }
    }
}

-(void)shellSelectViewDiss{
    MJWeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.shellSettingView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, weakSelf.shellSettingView.height);
    } completion:^(BOOL finished) {
        weakSelf.shellSettingView.hidden = YES;
    }];
}

-(void)changeShellViewWithType:(NSInteger )type{
    if (type == 1){
        //竖屏
    }else{
        //横屏
    }
}

#pragma mark --撤销
- (void)undo{
    _selectView.hidden = YES;
    if (!self.layers.count) return;
    [self.dataArr removeLastObject];
    [[self mutableArrayValueForKey:REMOVED_LAYERS] addObject:self.layers.lastObject];
    [self.layers.lastObject removeFromSuperlayer];
    [[self mutableArrayValueForKey:LAYERS] removeLastObject];
    if (_markType == LINE){
        _selectView.hidden = YES;
    }
    if (self.layers.count == 0){
        [_imgEditMarkView.deleteBtn setBackgroundImage:IMG(@"删除垃圾桶_unSelected") forState:UIControlStateNormal];
        [_imgEditMarkView.backBtn setBackgroundImage:IMG(@"撤销_unSelected") forState:UIControlStateNormal];
    }
    
}

#pragma mark --非会员弹出提示
-(void)addTipsViewWithType:(NSInteger)type{
    _tipsView = [UnlockFuncView new];
    _tipsView.delegate = self;
    _tipsView.type = type;
    [self.view.window addSubview:_tipsView];
    [_tipsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

-(void)btnClickWithTag:(NSInteger)tag{
    MJWeakSelf
    if (tag == 1) {
        [_tipsView removeFromSuperview];
        [self.navigationController pushViewController:[BuyViewController new] animated:YES];
        
    }else{
        if (_bgView == nil){
            _bgView = [Tools addBGViewWithFrame:self.view.frame];
            [self.view addSubview:_bgView];
        }
        _bgView.hidden = NO;
        [self.view bringSubviewToFront:_bgView];
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
            weakSelf.checkProView.frame = CGRectMake(0, SCREEN_HEIGHT+ 100 , SCREEN_WIDTH , weakSelf.checkProView.height);
            weakSelf.bgView.hidden = YES;
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.checkProView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 550);
        } completion:^(BOOL finished) {
            weakSelf.bgView.hidden = YES;
            [weakSelf.checkProView removeFromSuperview];
        }];
        [_tipsView removeFromSuperview];
        
        [self.navigationController pushViewController:[BuyViewController new] animated:YES];
    }
}
#pragma mark --添加颜色选择view
-(void)addColoeSelectedViewWithType:(NSInteger)type{
    MJWeakSelf
    _colorSelectView = [[WaterColorSelectView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 80, SCREEN_WIDTH, type == 1?100:160)];
    _colorSelectView.type = type;
    _colorSelectView.delegate = self;
    _colorSelectView.moreColorClick = ^{
        [weakSelf addColorPlateView];
    };
    [self.view addSubview:_colorSelectView];
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.colorSelectView.frame = CGRectMake(0, SCREEN_HEIGHT - 80 - weakSelf.colorSelectView.height, weakSelf.colorSelectView.width, weakSelf.colorSelectView.height);
    }];
}

#pragma mark -- 添加文本lab
-(void)addEditLabWithStr:(NSString *)str{
    
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


#pragma mark -- colorSelectViewDelegate
- (void)changeWaterFontSize:(NSInteger)size{
    
    if (_editType == 1){
        //标注
        _pathWidth = size / 2 ;
        //改变大小
        if (_isStartPaint){
            NSInteger index = [_layers indexOfObject:_slayer];
            if (_markType == RECTANGLE || _markType == LINE){
                //修改边框 //修改画笔
                if (_slayer != nil){
                    _path.lineWidth = size / 2;
                    _slayer.lineWidth = size / 2;
                    //        [self rectDrawBy:size / 2 AndColor:_currentPath.color];
                    [self rectDrawBy:index];
                }
                
            }else if (_markType == WORD){
                //修改文本
                
            }else if(_markType == ARROW){
                //修改箭头
                if (_slayer != nil){
                    _pathWidth = size / 2;
                    _slayer.lineWidth = _pathWidth;
                    [self rectDrawBy:index];
                }
                
            }
        }
    }else if (_editType == 2){
        _pathWidth = size ;
        [self changeImageBorderWithType:_borderType AndBorderWidth:_pathWidth AndColor:_pathLineColor];
    }
    
    
}
- (void)changeWaterFontColor:(NSString *)color{
    //改变颜色
    _pathLineColor = HexColor(color);
    if (_editType == 1){
        NSInteger index = [_layers indexOfObject:_slayer];
        if (_markType == RECTANGLE || _markType == FILLRECTANGLE || _markType == LINE){
            //修改边框
            if (_markType == RECTANGLE){
                //空心填充方框
                //_borderView.layer.borderColor = ;
                _slayer.strokeColor = HexColor(color).CGColor;
            }else if (_markType == LINE){
                //修改画笔
               // _path.pathColor = HexColor(color);
                _slayer.strokeColor = HexColor(color).CGColor;
            }else{
                //实心填充方框
                _slayer.fillColor = HexColor(color).CGColor;
                _slayer.strokeColor = HexColor(color).CGColor;
            }
            if (_slayer != nil){
                [self rectDrawBy:index];
            }
        }else if (_markType == WORD){
            //修改文本
            
        }else if(_markType == ARROW){
            //修改箭头
            if (_slayer != nil){
                _pathLineColor = HexColor(color);
                _slayer.fillColor = _pathLineColor.CGColor;
                [self rectDrawBy:index];
            }
        }
    }else if (_editType == 2){
        //边框
        if (color.length <= 0){
            _pathLineColor = [UIColor whiteColor];
        }
        [self changeImageBorderWithType:_borderType AndBorderWidth:_pathWidth AndColor:_pathLineColor];
    }else if (_editType == 3){
        //套壳
        self.view.backgroundColor = HexColor(color);
    }
    
}

-(void)changeFillBKImageWith:(NSInteger)tag{
    UIImage *image;
    switch (tag) {
        case 100:
            image = IMG(@"彩虹fill");
            break;
        case 200:
            image = IMG(@"灰色fill");
            break;
        case 300:
            image = IMG(@"蓝色fill");
            break;
        case 400:
            image = IMG(@"绿色fill");
            break;
        case 500:
            image = IMG(@"橘子fill");
            break;
        case 600:
            image = IMG(@"斑条fill");
            break;
        case 700:
            image = IMG(@"狗头fill");
            break;
        case 800:
            image = IMG(@"小猫fill");
            break;
        default:
            break;
    }
    _fillColor = [UIColor colorWithPatternImage:image];
    _pathLineColor = [UIColor colorWithPatternImage:image];
    if (_isStartPaint){
        if (_markType == FILLRECTANGLE){
            //改变borderview填充内容
            if (_slayer != nil){
                NSInteger index = [_layers indexOfObject:_slayer];
                
                //        _fillBorderView.backgroundColor = _fillColor;
                _slayer.strokeColor = _fillColor.CGColor;
                _slayer.fillColor = _fillColor.CGColor;
                [self rectDrawBy:index];
            }
            
        }else if (_markType == LINE){
            //改变贝塞尔曲线填充内容
            _slayer.strokeColor = _pathLineColor.CGColor;
        }else{
            
        }
    }
    
    
}

#pragma mark -------------画笔事件-------------
#pragma mark tagGesture事件
- (void)tapGestureAction:(UIPanGestureRecognizer *)gesture{
    CGPoint point = [gesture locationInView:_contentScrollView];
    if (_editType == 1){
        if (gesture.state == UIGestureRecognizerStateBegan){
            _stratPoint = point;
            _isStartPaint = YES;
            if (_markType != 0 && _markType != UNDO && _markType != DELETELAYER){
                //[_contentView removeGestureRecognizer:_panRecognizer];
                [_contentView removeGestureRecognizer:_pinchRecognizer];
                if ([self judgleIsAtPathRectWithStartP:point] && _markType == LINE){
                    _isSelectPath = YES;
                    [self addSelectBorderView];
                }else{
                    [self colorViewDismiss];
                    if (_markType == LINE || _markType == MOSAIC){
                        UIBezierPath *path = [UIBezierPath pathWitchColor:_pathLineColor lineWidth:_pathWidth];
                        [path moveToPoint:point];
                        _path = path;
                    }else if(_markType == ARROW){
                        _path = [UIBezierPath arrow:point toEnd:point tailWidth:0 headWidth:0 headLength:0];
                    }else if(_markType == RECTANGLE || _markType == FILLRECTANGLE|| _markType == MOSAICRECTANGLE){
                        _path = [UIBezierPath bezierPathWithRect:CGRectMake(point.x, point.y, 0, 0)];
                    }else if(_markType == MOSAICOVAL){
                        _path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(point.x, point.y, 0, 0)];
                    }
                    if (_markType > 0 && _markType != WORD) {
                        
                        CAShapeLayer * slayer = [CAShapeLayer layer];
                        _path.lineWidth = _pathWidth;
                        if (_markType == LINE){
                            _path.boundRect = CGPathGetPathBoundingBox(_path.CGPath);
                        }
                       
                        slayer.path = _path.CGPath;
                        slayer.backgroundColor = [UIColor clearColor].CGColor;
                        if (_markType == LINE || _markType == RECTANGLE || _markType == MOSAICOVAL || _markType == MOSAIC || _markType == MOSAICRECTANGLE || _markType == FILLRECTANGLE ) {
                            if (_markType == MOSAICOVAL || _markType == MOSAIC  || _markType == MOSAICRECTANGLE){
                                //slayer.fillColor = [UIColor clearColor].CGColor;
                                if (_mosaicStyle == 200){
                                    if (_markType != MOSAIC){
                                        slayer.fillColor = [UIColor colorWithPatternImage:IMG(@"马赛克填充_03")].CGColor;
                                    
                                    }else{
                                        slayer.fillColor = [UIColor clearColor].CGColor;
                                    }
                                    
                                    slayer.strokeColor = [UIColor colorWithPatternImage:IMG(@"马赛克填充_03")].CGColor;
                                }else if (_mosaicStyle == 201){
                                    if (_markType != MOSAIC){
                                        slayer.fillColor = [UIColor colorWithPatternImage:IMG(@"马赛克填充_02")].CGColor;
                                    }else{
                                        slayer.fillColor = [UIColor clearColor].CGColor;
                                    }
                                    slayer.strokeColor = [UIColor colorWithPatternImage:IMG(@"马赛克填充_02")].CGColor;
                                }else{
                                    if (_markType != MOSAIC){
                                        slayer.fillColor = [UIColor colorWithPatternImage:IMG(@"马赛克填充_01")].CGColor;
                                    }else{
                                        slayer.fillColor = [UIColor clearColor].CGColor;
                                    }
                                    slayer.strokeColor = [UIColor colorWithPatternImage:IMG(@"马赛克填充_01")].CGColor;
                                }
                            }else if (_markType == FILLRECTANGLE){
                                slayer.strokeColor = _pathLineColor.CGColor;
                                slayer.fillColor = _pathLineColor.CGColor;
                            }else{
                                slayer.strokeColor = _pathLineColor.CGColor;
                                slayer.fillColor = [UIColor clearColor].CGColor;
                            }
                            
                        }else if(_markType == ARROW){
                            slayer.fillColor = _pathLineColor.CGColor;
                        }
                        slayer.lineCap = kCALineCapRound;
                        slayer.lineJoin = kCALineJoinRound;
                        slayer.lineWidth = _path.lineWidth;
                       // slayer.opacity = 0.8;
                        [_contentScrollView.layer addSublayer:slayer];
                        [self.dataArr addObject:_path];
                        _slayer = slayer;
                        [[self mutableArrayValueForKey:REMOVED_LAYERS] removeAllObjects];
                        [[self mutableArrayValueForKey:LAYERS] addObject:_slayer];
                    }
                    
                }
            }
        }else if (gesture.state == UIGestureRecognizerStateChanged){
            if (!_isSelectPath && _path != nil){
                if (CGPointEqualToPoint(_stratPoint, point)) {
                    return;
                }
                //计算缩放倍率
                double distance = [self distanceFromPoints:_stratPoint endPoint:point];
                double rate = distance / [UIScreen mainScreen].bounds.size.width;
                
                if (_markType == LINE || _markType == MOSAIC) {
                    [_path addLineToPoint:point];
                }else if(_markType == ARROW){
                    [self.layers removeObject:_path];
                    _path = [UIBezierPath arrow:_stratPoint toEnd:point tailWidth:TAIL_WIDTH *rate headWidth:HEAD_WIDTH * rate headLength:HEAD_LENGTH * rate];
                }else if(_markType == RECTANGLE || _markType == MOSAICRECTANGLE || _markType == FILLRECTANGLE){
                    [self.layers removeObject:_path];
                    _path = [UIBezierPath bezierPathWithRect:CGRectMake(_stratPoint.x, _stratPoint.y, point.x - _stratPoint.x, point.y - _stratPoint.y)];
                }else if(_markType == MOSAICOVAL){
                    [self.layers removeObject:_path];
                    _path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(_stratPoint.x, _stratPoint.y, point.x - _stratPoint.x, point.y - _stratPoint.y)];
                }
                
                if (_markType > 0 && _markType != WORD && _markType != UNDO && _markType != DELETELAYER) {
                    if (_markType == LINE){
                        _path.boundRect = CGPathGetPathBoundingBox(_path.CGPath);
                    }
                    _slayer.path = _path.CGPath;
                    if (_dataArr.count - 1 <= _dataArr.count){
                        _dataArr[_dataArr.count - 1] = _path;
                        _layers[_dataArr.count - 1] = _slayer;
                    }
                }
            }
        }else{
            if (!_isSelectPath && (_markType > 0 && _markType != UNDO && _markType != DELETELAYER && _markType != WORD) && _path != nil){
                if ((_markType == LINE || _markType == MOSAIC)){
                    NSArray *arr = [_path points];
                    NSMutableArray *dataArr = [NSMutableArray array];
                    for (NSInteger i = 0; i < arr.count; i ++) {
                        CGPoint point = [arr[i] CGPointValue];
                        NSValue *v0 = [NSValue valueWithCGPoint:point];
                        [dataArr addObject:v0];
                    }
                    if (dataArr.count == arr.count){
                        [self smoothedPathWithPoints:dataArr andGranularity:2 andType:1 AndPath:_path];
                    }
                    [self addGestureRecognizer];
                    _isSelectPath = YES;
                    [_colorSelectView removeFromSuperview];
                    _currentPath = _path;
                    if (_markType != MOSAIC){
                        [self addColoeSelectedViewWithType:2];
                        [self addSelectBorderView];
                    }
                    
                }else if (_markType == RECTANGLE){
                    //画矩形
                    [_colorSelectView removeFromSuperview];
                    [self addColoeSelectedViewWithType:1];
                }else if (_markType == ARROW){
                    _currentPath = _path;
                }else if (_markType == FILLRECTANGLE){
                    [_colorSelectView removeFromSuperview];
                    [self addColoeSelectedViewWithType:2];
                }
                if (_dataArr.count > 0){
                    [_imgEditMarkView.deleteBtn setBackgroundImage:IMG(@"删除垃圾桶_selected") forState:UIControlStateNormal];
                    [_imgEditMarkView.backBtn setBackgroundImage:IMG(@"撤销_selected") forState:UIControlStateNormal];
                }
                    
                _path = nil;
            }
        }
    }
    
}
#pragma mark touches事件
- (CGPoint)pointWithTouches:(NSSet *)touches{
    UITouch *touch = [touches anyObject];
    return [touch locationInView:_contentScrollView];
}

#pragma mark -- touchesBegan

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint startP = [self pointWithTouches:touches];
    _stratPoint = startP;
    
    if (CGRectContainsPoint(_contentScrollView.frame, startP)){
        //点击不在
        //[self colorViewDismiss];
    }
    
   // CGRectContainsPoint(_contentView.frame,startP
//    if (_markType == LINE || (_markType == MOSAIC && _mosaicShape == 102) ){
//        //画笔模式
//        //先判断是不是点击在某个画笔的范围内
//
//        if (_markType == LINE){
//
//        }else{
//            _mosaicView.hidden = YES;
//            [self startAddNewPathWithPoint:startP andType:2];
//        }
//    }else if (_markType == RECTANGLE || _markType == FILLRECTANGLE || _markType == MOSAIC){
//        //画矩形
//        [_contentView removeGestureRecognizer:_panRecognizer];
//        [_contentView removeGestureRecognizer:_pinchRecognizer];
//
//        if (_markType == RECTANGLE){
//            _borderView = [UIView new];
//            _borderView.layer.borderWidth = 1;
//            _borderView.layer.borderColor = [UIColor whiteColor].CGColor;
//            [_contentView addSubview:_borderView];
//        }else if (_markType == FILLRECTANGLE){
//            _fillBorderView = [UIView new];
//            if (!_fillColor){
//                _fillBorderView.backgroundColor = [UIColor whiteColor];
//            }else{
//                _fillBorderView.backgroundColor = _fillColor;
//            }
//
//            [_contentView addSubview:_fillBorderView];
//        }else{
//            //马赛克
//        }
//
//
//    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint moveP = [self pointWithTouches:touches];

//    if ((_markType == LINE || _markType == MOSAIC) && !_isSelectPath){
//        [_path addLineToPoint:moveP];
//        _path.boundRect = CGPathGetPathBoundingBox(_path.CGPath);
//        _slayer.path = _path.CGPath;
//        if (_dataArr.count - 1 <= _dataArr.count){
//            _dataArr[_dataArr.count - 1] = _path;
//            _layers[_dataArr.count - 1] = _slayer;
//        }
//    }else if (_markType == RECTANGLE ||_markType == FILLRECTANGLE){
//        //画矩形
//        CGFloat offsetX = moveP.x - _stratPoint.x ;
//        CGFloat offsetY = moveP.y- _stratPoint.y;
//        if (_markType == 1){
//            _borderView.frame = CGRectMake(_stratPoint.x,_stratPoint.y, offsetX, offsetY);
//        }else{
//            _fillBorderView.frame = CGRectMake(_stratPoint.x,_stratPoint.y, offsetX, offsetY);
//        }
//
//    }
    
    
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
  //  CGPoint endP = [self pointWithTouches:touches];
   
    
}
-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint endP = [self pointWithTouches:touches];
}

//--开始新增一个路径
-(void)startAddNewPathWithPoint:(CGPoint )startP andType:(NSInteger )type{
    _path = [PaintPath paintPathWithLineWidth:_pathWidth
                                                   startPoint:startP];
    //_path.pathColor = _pathLineColor;
    [self.dataArr addObject:_path];
    CAShapeLayer * slayer = [CAShapeLayer layer];
    slayer.path = _path.CGPath;
    slayer.backgroundColor = [UIColor clearColor].CGColor;
    slayer.fillColor = [UIColor clearColor].CGColor;
    if (type == 1){
        //普通画笔
        slayer.lineCap = kCALineCapRound;
        slayer.lineJoin = kCALineJoinRound;
        slayer.strokeColor = _pathLineColor.CGColor;
    }else{
        //马赛克样式
        slayer.lineCap = kCALineCapRound;
        slayer.lineJoin = kCALineJoinRound;
        if (_mosaicStyle == 200){
            slayer.strokeColor = [UIColor colorWithPatternImage:IMG(@"马赛克样式_03")].CGColor;
        }else if (_mosaicStyle == 201){
            slayer.strokeColor = [UIColor colorWithPatternImage:IMG(@"马赛克样式_02")].CGColor;
        }else{
            slayer.strokeColor = [UIColor colorWithPatternImage:IMG(@"马赛克样式_01")].CGColor;
        }
        
    }
    
    slayer.lineWidth = _path.lineWidth;
    [_contentScrollView.layer addSublayer:slayer];
    _slayer = slayer;
    [self.layers addObject:_slayer];
    [[self mutableArrayValueForKey:@"canceledlayers"] removeAllObjects];
}

//- 画笔结束添加选中view
-(void)addSelectBorderView{
   // [_selectView removeFromSuperview];
    if (_selectView == nil){
        _selectView = [UIView new];
        _originRect = _selectView.frame;
        _selectView.layer.borderWidth = 1;
        _selectView.layer.borderColor = [UIColor redColor].CGColor;
        [_contentScrollView addSubview:_selectView];
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(selectPathPanGesture:)];
        panGestureRecognizer.maximumNumberOfTouches = 1;
        [_selectView addGestureRecognizer:panGestureRecognizer];
    }
    _selectView.frame =  CGRectMake(_currentPath.boundRect.origin.x - 5, _currentPath.boundRect.origin.y - 5, _currentPath.boundRect.size.width + 10, _currentPath.boundRect.size.height + 10);
    _originRect = _selectView.frame;
    _selectView.hidden = NO;
        
}
#pragma makr -- 判断点是否在二阶曲线上
-(BOOL)judgleIsAtPathRectWithStartP:(CGPoint )startP{
    NSMutableArray *tmpArr = [NSMutableArray array];
    for (NSInteger i = 0; i < _dataArr.count; i ++) {
        PaintPath *path = _dataArr[i];
        if (CGRectContainsPoint(path.boundRect,startP) ||[self _xb_containsPointForCurveLineType:startP And:path]){
            //如果点在范围内或者二阶曲线的范围内
            [tmpArr addObject:path];
            _isSelectPath = YES;
           // [_selectView removeFromSuperview];
           // return YES;
        }
    }
    if (tmpArr.count > 0){
        //如果有多条路径叠在一起取最后一个
        _currentPath = [tmpArr lastObject];
        return YES;
    }
    _isSelectPath = NO;
    return NO;
}
#pragma mark  重赋值path路径
-(void)rectDrawBy:(NSInteger )index{
    //NSInteger index = [_dataArr indexOfObject:_currentPath];
    if (index <= _dataArr.count - 1){
//        [self.layers[index] removeFromSuperlayer];
//        [[self mutableArrayValueForKey:@"layers"] removeObjectAtIndex:index];
        //_currentPath.lineWidth = width;
        //_dataArr[index] = _path;
        _layers[index] = _slayer;
//        [_dataArr replaceObjectAtIndex:index withObject:_currentPath];
//        [_layers replaceObjectAtIndex:index withObject:_slayer];
    }
}

-(void)colorViewDismiss{
    MJWeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.colorSelectView.frame = CGRectMake(0, SCREEN_HEIGHT - 80, SCREEN_WIDTH, weakSelf.colorSelectView.height);
    } completion:^(BOOL finished) {
        weakSelf.colorSelectView.hidden = YES;
    }];
}

#pragma mark --补充点算法
#define POINT(_INDEX_) [(NSValue *)[points objectAtIndex:_INDEX_] CGPointValue]
- (void)smoothedPathWithPoints:(NSArray *) pointsArray andGranularity:(NSInteger)granularity andType:(NSInteger )type AndPath:(UIBezierPath *)path {
    NSMutableArray *points = [pointsArray mutableCopy];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextSetLineWidth(context, 0.6);
    UIBezierPath *smoothedPath = [UIBezierPath bezierPath];
    if (points.count > 0){
        [points insertObject:[points objectAtIndex:0] atIndex:0];
        [points addObject:[points lastObject]];
        [smoothedPath moveToPoint:POINT(0)];
        for (NSUInteger index = 1; index < points.count - 2; index++) {
            CGPoint p0 = POINT(index - 1);
            CGPoint p1 = POINT(index);
            CGPoint p2 = POINT(index + 1);
            CGPoint p3 = POINT(index + 2);
//            NSMutableDictionary *pDic = [NSMutableDictionary dictionary];
            for (int i = 1; i < granularity; i++) {
                float t = (float) i * (1.0f / (float) granularity);
                float tt = t * t;
                float ttt = tt * t;
                CGPoint pi; // intermediate point
                pi.x = 0.5 * (2*p1.x+(p2.x-p0.x)*t + (2*p0.x-5*p1.x+4*p2.x-p3.x)*tt + (3*p1.x-p0.x-3*p2.x+p3.x)*ttt);
                pi.y = 0.5 * (2*p1.y+(p2.y-p0.y)*t + (2*p0.y-5*p1.y+4*p2.y-p3.y)*tt + (3*p1.y-p0.y-3*p2.y+p3.y)*ttt);
                //NSLog(@"pi.x==%lf,pi.y==%lf",pi.x,pi.y);
                [smoothedPath addLineToPoint:pi];
            }
            // Now add p2
            [smoothedPath addLineToPoint:p2];
        }
        path.boundRect = CGPathGetPathBoundingBox(smoothedPath.CGPath);
        path.allPoints = smoothedPath.points;
        _dataArr[_dataArr.count - 1] = path;
        _currentPath = path;
        
    }
}

/**
判断点在二阶贝塞尔曲线上
*/
- (BOOL)_xb_containsPointForCurveLineType:(CGPoint)point And:(PaintPath *)path{
    CGPoint p0 = [path.allPoints.firstObject CGPointValue];///我是贝塞尔曲线的起始点
    CGPoint p1 = [path.allPoints.firstObject CGPointValue];//我是贝塞尔曲线终点
    CGPoint p2 = [path.allPoints.lastObject CGPointValue];//控制点
    CGPoint tempPoint1 = p0;
    CGPoint tempPoint2 = CGPointZero;
    //这里我取了100个点，基本上满足要求了
    for (int i = 1; i < 101; i ++) {
    //计算出终点
        tempPoint2 = XBPointOnPowerCurveLine(p0, p1, p2, i / 100.0f);
        //调用我们解决第一种情况的方法，判断点是否在这两点构成的直线上
        if ([self _xb_point:point isInLineByTwoPoint:tempPoint1 p1:tempPoint2]) {
        //如果在可以认为点在这条贝塞尔曲线上，直接跳出循环返回即可
            return YES;
        }
        //如果不在则赋值准备下一次循环
        tempPoint1 = tempPoint2;
    }
    return NO;
}
/**
*判断点point是否在p0 和 p1两点构成的线段上
*/
- (BOOL)_xb_point:(CGPoint)point isInLineByTwoPoint:(CGPoint)p0 p1:(CGPoint)p1{
    //先设置一个所允许的最大值，点到线段的最短距离小于该值说明点在线段上
    CGFloat maxAllowOffsetLength = 15;
    //通过直线方程的两点式计算出一般式的ABC参数，具体可以自己拿起笔换算一下，很容易
    CGFloat A = p1.y - p0.y;
    CGFloat B = p0.x - p1.x;
    CGFloat C = p1.x * p0.y - p0.x * p1.y;
    //带入点到直线的距离公式求出点到直线的距离dis
    CGFloat dis = fabs((A * point.x + B * point.y + C) / sqrt(pow(A, 2) + pow(B, 2)));
    //如果该距离大于允许值说明则不在线段上
    if (dis > maxAllowOffsetLength || isnan(dis)) {
        return NO;
    }else{
    //否则我们要进一步判断，投影点是否在线段上，根据公式求出投影点的X坐标jiaoX
        CGFloat D = (A * point.y - B * point.x);
        CGFloat jiaoX = -(A * C + B *D) / (pow(B, 2) + pow(A, 2));
        //判断jiaoX是否在线段上，t如果在0~1之间说明在线段上，大于1则说明不在线段且靠近端点p1，小于0则不在线段上且靠近端点p0，这里用了插值的思想
        CGFloat t = (jiaoX - p0.x) / (p1.x - p0.x);
        if (t > 1  || isnan(t)) {
        //最小距离为到p1点的距离
            dis = XBLengthOfTwoPoint(p1, point);
        }else if (t < 0){
        //最小距离为到p2点的距离
            dis = XBLengthOfTwoPoint(p0, point);
        }
        //再次判断真正的最小距离是否小于允许值，小于则该点在直线上，反之则不在
        if (dis <= maxAllowOffsetLength) {
            return YES;
        }else{
            return NO;
        }
    }
}

//这里是求两点距离公式
static inline CGFloat XBLengthOfTwoPoint(CGPoint point1, CGPoint point2){
    return sqrt(pow(point1.x - point2.x, 2) + pow(point1.y - point2.y, 2));
}

//我们首先提供一个函数，将上述公式转换成代码
static inline CGPoint XBPointOnPowerCurveLine(CGPoint p0, CGPoint p1, CGPoint p2, CGFloat t){
    CGFloat x = (pow(1 - t, 2) * p0.x + 2 * t * (1 - t) * p1.x + pow(t, 2) * p2.x);
    CGFloat y = (pow(1 - t, 2) * p0.y + 2 * t * (1 - t) * p1.y + pow(t, 2) * p2.y);
    return CGPointMake(x, y);
}

/**
 计算两点间距离

 @param startPoint 起点
 @param endPoint 终点
 @return 距离
 */
- (double)distanceFromPoints:(CGPoint)startPoint endPoint:(CGPoint)endPoint{
    double dx = (endPoint.x -startPoint.x);
    double dy = (endPoint.y - startPoint.y);
    return sqrt(dx*dx + dy*dy);
}

#pragma mark -- UIGestureRecognizerDelegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer*) gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer{
    if ([gestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
        return NO;
    }else {
        return YES;
        
    }
}

#pragma mark -- 处理放大缩小手势
- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    CGFloat scale = recognizer.scale;
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, scale, scale);
    recognizer.scale = 1;
}

#pragma mark -- 处理拖动手势
- (void)selectonPanGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint translatedPoint = [gesture translationInView:self.view];
    CGPoint newCenter = CGPointMake(gesture.view.center.x+ translatedPoint.x, gesture.view.center.y + translatedPoint.y);
    
    gesture.view.center = newCenter;
    [gesture setTranslation:CGPointMake(0, 0) inView:self.view];
}

//处理选中path拖动问题
-(void)selectPathPanGesture:(UIPanGestureRecognizer *)gesture {
    [self colorViewDismiss];
    CGPoint translatedPoint = [gesture translationInView:self.view];
    CGPoint newCenter = CGPointMake(gesture.view.center.x+ translatedPoint.x, gesture.view.center.y + translatedPoint.y);
    [gesture setTranslation:CGPointMake(0, 0) inView:self.view];
    if ( gesture.view.top + translatedPoint.y <= 0 || gesture.view.left + translatedPoint.x < _contentView.left || gesture.view.right + translatedPoint.x > _contentView.right || gesture.view.bottom + translatedPoint.y >= SCREEN_HEIGHT){
        return;
    }
    gesture.view.center = newCenter;
    CGAffineTransform move = CGAffineTransformMakeTranslation(translatedPoint.x, translatedPoint.y);
    [_currentPath applyTransform:move];
    NSInteger index = [_dataArr indexOfObject:_currentPath];
    _slayer = [_layers objectAtIndex:index];
    _slayer.path = _currentPath.CGPath;
    static NSInteger tempCount = 0;
    NSMutableArray *tempArr = [NSMutableArray array];
    NSMutableArray *pointArr = [NSMutableArray array];
    CGFloat distanceX =  _selectView.frame.origin.x - _originRect.origin.x;
    CGFloat distanceY = _selectView.frame.origin.y - _originRect.origin.y;
    for (NSInteger i = 0; i < _currentPath.allPoints.count ; i ++) {
        tempCount = i + 1;
        CGPoint point = [_currentPath.allPoints[i] CGPointValue];
        point.x = point.x + distanceX ;
        point.y = point.y + distanceY ;
        [tempArr addObject:[NSValue valueWithCGPoint:point]];
        
        NSMutableDictionary *pointDic = [NSMutableDictionary dictionary];
        pointDic[@"x"] = [NSNumber numberWithFloat:point.x];
        pointDic[@"y"] = [NSNumber numberWithFloat:point.y];
        [pointArr addObject:pointDic];
        
    }
    if (tempCount == _currentPath.allPoints.count && tempArr.count > 1 ){
        _currentPath.allPoints = tempArr;
    }
    if (_currentPath.points.count < 5){
        _currentPath.boundRect = _selectView.frame;
    }else{
        _currentPath.boundRect = CGPathGetBoundingBox(_currentPath.CGPath);
    }
    [_dataArr replaceObjectAtIndex:index withObject:_currentPath];
    _originRect = _selectView.frame;
    
}




#pragma mark --lazy
-(NSMutableArray *)layers{
    if (!_layers ){
        self.layers = [NSMutableArray array];
    }
    return _layers;
}
-(NSMutableArray *)removedLayers{
    if (!_removedLayers ){
        self.removedLayers = [NSMutableArray array];
    }
    return _removedLayers;
}

-(NSMutableArray *)originWidthArr{
    if (!_originWidthArr){
        self.originWidthArr = [NSMutableArray array];
    }
    return _originWidthArr;
}

-(NSMutableArray *)originHeightArr{
    if (!_originHeightArr){
        self.originHeightArr = [NSMutableArray array];
    }
    return _originHeightArr;
}
-(NSMutableArray *)originzTopArr{
    if (!_originzTopArr){
        self.originzTopArr = [NSMutableArray array];
    }
    return _originzTopArr;
}
-(NSMutableArray *)imageViewsArr{
    if (!_imageViewsArr){
        self.imageViewsArr = [NSMutableArray array];
    }
    return _imageViewsArr;
}
-(NSMutableArray *)dataArr{
    if (!_dataArr){
        self.dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

@end
