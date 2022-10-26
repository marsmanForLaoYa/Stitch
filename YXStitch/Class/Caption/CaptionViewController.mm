//
//  CaptionViewController.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/19.
//

#import "CaptionViewController.h"
#import "UnlockFuncView.h"
#import "CheckProView.h"
#import "BuyViewController.h"
#import "CaptionBottomView.h"
#import "UIScrollView+UITouch.h"
#import "StitchingButton.h"
#import "IMGFuctionView.h"
#import "SaveViewController.h"
#import "SZImageMergeInfo.h"
#import "SZImageGenerator.h"
#import <Photos/Photos.h>
#import "StitchResultView.h"
#import "ImageEditViewController.h"
#import "CustomScrollView.h"
#import "SZStichingImageView.h"
#import "XWOpenCVHelper.h"

#define MaxSCale 2.5  //最大缩放比例
#define MinScale 0.5  //最小缩放比例

#define MinWidth 80 //图片裁切最小宽度
#define MinHeight 80 //图片裁切最小高度

#define LayoutHeight 500 //临界重新布局调整高度

#define VerViewWidth 260
#define HorViewHeight 300


@interface CaptionViewController ()<UnlockFuncViewDelegate,CheckProViewDelegate,UIGestureRecognizerDelegate,HXCustomNavigationControllerDelegate,HXPhotoViewDelegate,HXPhotoViewDelegate,UIScrollViewDelegate>
@property (weak, nonatomic) HXPhotoView *photoView;
@property (strong, nonatomic)HXPhotoManager *manager;
@property (nonatomic ,strong)UnlockFuncView *funcView;
@property (nonatomic ,strong)CheckProView *checkProView;
@property (nonatomic ,strong)StitchingButton *selectIMG;
@property (nonatomic ,strong)CaptionBottomView *bottomView;
@property (nonatomic ,strong)IMGFuctionView *imgFunctionView;
@property (nonatomic ,strong)CustomScrollView *contentScrollView;

@property (nonatomic ,strong)UIView *contentView;
@property (nonatomic ,strong)UIView *bgView;
@property (nonatomic ,strong)UIImageView *adjustView;//字幕调整按钮view
@property (nonatomic ,strong)UIButton *guideBtn;//裁切指引Btn
@property (nonatomic ,strong)UIButton *slicingBtn; //切割btn
@property (nonatomic ,strong)UIButton *leftCutBtn;//左边裁切btn
@property (nonatomic ,strong)UIButton *rightCutBtn;//右边裁切btn


@property (nonatomic ,strong)NSMutableArray *originTopArr;
@property (nonatomic ,strong)NSMutableArray *originBottomArr;
@property (nonatomic ,strong)NSMutableArray *originRightArr;
@property (nonatomic ,strong)NSMutableArray *originHeightArr;
@property (nonatomic ,strong)NSMutableArray *originWidthArr;
@property (nonatomic ,strong)NSMutableArray *imageViews;
@property (nonatomic ,strong)NSMutableArray *cutArr;
@property (nonatomic ,strong)NSMutableArray *editLabArr;

@property (nonatomic ,assign)CGPoint moveP;
@property (nonatomic ,assign)CGFloat offsetY;
@property (nonatomic ,assign)CGFloat topCurrentValue;
@property (nonatomic ,assign)CGFloat bottomCurrentValue;
@property (nonatomic ,strong)StitchingButton *centenIMG;
@property (nonatomic ,strong)NSURL *videoURL;

@property (nonatomic ,strong)UIPanGestureRecognizer *panGesture;

@property (nonatomic ,assign)BOOL isTopPart;//是否是上半部分
@property (nonatomic ,assign)BOOL isCut; //是否在裁剪
@property (nonatomic ,assign)BOOL isMove;//是否在移动
@property (nonatomic ,assign)BOOL isSlicing;//是否正在切割
@property (nonatomic ,assign)BOOL isVerticalCut;//是否竖切，默认竖切
@property (nonatomic ,assign)BOOL isTurn;//图片是否翻转
@property (nonatomic ,assign)BOOL isStartCut;//是否开始剪切
@property (nonatomic ,assign)BOOL isScrollViewScroll;


@property (nonatomic ,assign)NSInteger posizition;
@property (nonatomic ,assign)NSInteger imgSelectIndex;
@property (nonatomic ,assign)NSInteger moveIndex;


@property (nonatomic ,strong)UIPanGestureRecognizer *panRecognizer;
@property (nonatomic ,strong)UIPinchGestureRecognizer *pinchRecognizer;

@property (nonatomic, strong)dispatch_queue_t queue;
@property (nonatomic, strong)StitchResultView *resultView;


@end

typedef void(^SZImageMergeBlock)(SZImageGenerator *generator,NSError *error);

@implementation CaptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGB(25, 25, 25);
    self.title = [NSString stringWithFormat:@"%ld张图片",_dataArr.count];
    _cutArr = [NSMutableArray array];
    [self viewInitSetting];
    [self setupViews];
    [self setupNavItems];
    [self addBottomView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenRecordFinish:) name:kScreenRecordFinishNotification object:nil];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    XWNavigationController *nav = (XWNavigationController *)self.navigationController;
    [nav addNavBarShadowImageWithColor:[UIColor blackColor]];
    NSDictionary *titleAttr= @{
        NSForegroundColorAttributeName:RGB(255, 255, 255),
        NSFontAttributeName:[UIFont systemFontOfSize:18]
    };
    //设置导航栏标题字体颜色、分割线颜色
    [nav addNavBarTitleTextAttributes:titleAttr barShadowHidden:NO shadowColor:[UIColor blackColor]];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    XWNavigationController *nav = (XWNavigationController *)self.navigationController;
    [nav addNavBarShadowImageWithColor:RGB(255, 255, 255)];
    NSDictionary *titleAttr= @{
        NSForegroundColorAttributeName:RGB(0, 0, 0),
        NSFontAttributeName:[UIFont systemFontOfSize:18]
    };
    //设置导航栏标题字体颜色、分割线颜色
    [nav addNavBarTitleTextAttributes:titleAttr barShadowHidden:NO shadowColor:RGB(233, 233, 233)];
    
}
#pragma mark --initUI
-(void)setupViews{
    MJWeakSelf
    _contentView = [UIView new];
    _contentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_contentView];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    _contentScrollView = [CustomScrollView new];
    _contentScrollView.delegate = self;
    _contentScrollView.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:_contentScrollView];
    [_contentScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(Nav_H));
        make.centerX.equalTo(_contentView.mas_centerX);
        make.height.equalTo(@(SCREEN_HEIGHT - Nav_HEIGHT - 80));
        make.width.equalTo(@(VerViewWidth));
    }];
    
    if (_type != 4){
        [self addVerticalContentView];
        if (_type == 1){
            [self addadjustView];
        }
    }else{
        //长图拼接
        [SVProgressHUD showWithStatus:@"图片正在拼接中..."];
        if (_gengrator){
            [self stitchImgWith:_gengrator];
        }else{
            _queue = dispatch_queue_create("com.chenshaozhe.image.queue", 0);
            [self mergeImages:_dataArr
                   completion:^(SZImageGenerator *generator, NSError *error) {
                NSLog(@"error==%@",error);
                generator.error = error;
                if (error){
                    [SVProgressHUD showInfoWithStatus:@"请重新选择图片拼接"];
                    [self.navigationController popViewControllerAnimated:YES];
                }else{
                    [weakSelf stitchImgWith:generator];
                }
                
            }];
        }
        
        
        
    }
    _pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [_contentView addGestureRecognizer:_pinchRecognizer];
    
}

-(void)addVerticalContentView{
    //竖拼
    CGFloat contentHeight = 0.0;
    UIImage *icon = _dataArr[0];
    CGFloat imgHeight = (CGFloat)(icon.size.height/icon.size.width) * VerViewWidth;
    StitchingButton *firstImageView = [[StitchingButton alloc]initWithFrame:CGRectMake(0, 0, VerViewWidth, imgHeight)];
    [_contentScrollView addSubview:firstImageView];
    firstImageView.image = icon;
    firstImageView.userInteractionEnabled = YES;
    contentHeight += firstImageView.height;
    firstImageView.tag = 100;
    
    [self.originTopArr addObject:[NSNumber numberWithFloat:0]];
    [self.originBottomArr addObject:[NSNumber numberWithFloat:firstImageView.height]];
    [self.originHeightArr addObject:[NSNumber numberWithFloat:firstImageView.height]];
    [self.imageViews addObject:firstImageView];
    for (NSInteger i = 1; i < _dataArr.count; i ++) {
        UIImage *icon = _dataArr[i];
        imgHeight = (CGFloat)(icon.size.height/icon.size.width) * VerViewWidth;
        StitchingButton *imageView = [[StitchingButton alloc]initWithFrame:CGRectMake(0, firstImageView.bottom, VerViewWidth, imgHeight)];
        imageView.image = icon;
        imageView.userInteractionEnabled = YES;
        //imageView.centerX = firstImageView.centerX;
        imageView.tag = (i+1) * 100;
        contentHeight += imgHeight;
        [_contentScrollView addSubview:imageView];
        firstImageView = imageView;
        [self.originTopArr addObject:[NSNumber numberWithFloat:firstImageView.top]];
        [self.imageViews addObject:imageView];
        [self.originBottomArr addObject:[NSNumber numberWithFloat:contentHeight]];
        [self.originHeightArr addObject:[NSNumber numberWithFloat:imageView.height]];
        
    }
    if (contentHeight < LayoutHeight){
        //内容过小则重置imageView布局
        [self layoutContentViewWithContent:contentHeight];
    }
    [self updateContentScrollViewContentSize];

}

//横拼
-(void)addHorizontalContentView{
    [_contentScrollView removeAllSubviews];
    CGFloat contentWidth = 0.0;
    UIImage *icon = _dataArr[0];
    StitchingButton *firstImageView = [[StitchingButton alloc]initWithFrame:CGRectMake(0,0, (CGFloat)(icon.size.width / icon.size.height) * HorViewHeight, HorViewHeight)];
    firstImageView.image = icon;
    contentWidth += firstImageView.width;
    firstImageView.tag = 100;
    [self.originRightArr addObject:[NSNumber numberWithFloat:0]];
    [self.originTopArr addObject:[NSNumber numberWithFloat:firstImageView.top]];
    [self.originWidthArr addObject:[NSNumber numberWithFloat:firstImageView.width]];
    [_contentScrollView addSubview:firstImageView];
    [self.imageViews addObject:firstImageView];
    for (NSInteger i = 1; i < _dataArr.count; i ++) {
        UIImage *icon = _dataArr[i];
        CGFloat imgWidth = (CGFloat)(icon.size.width/icon.size.height) * HorViewHeight;
        StitchingButton *imageView = [[StitchingButton alloc]initWithFrame:CGRectMake(firstImageView.right, firstImageView.top, imgWidth, HorViewHeight)];
        imageView.image = icon;
        imageView.tag = (i+1) * 100;
        contentWidth += imgWidth;
        [_contentScrollView addSubview:imageView];
        [_originRightArr addObject:[NSNumber numberWithFloat:firstImageView.right]];
        [self.originWidthArr addObject:[NSNumber numberWithFloat:imageView.width]];
        firstImageView = imageView;
        [_imageViews addObject:imageView];
        
    }
    if (contentWidth < SCREEN_WIDTH){
        [self layoutContentViewWithContent:contentWidth];
    }
    [self updateContentScrollViewContentSize];
    
}

-(void)layoutContentViewWithContent:(CGFloat )concentH{
    
    CGFloat top = 0.0;
    if (_isVerticalCut){
        top = (SCREEN_HEIGHT - concentH) / 2;
        [_contentScrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(top));
            make.width.equalTo(@(VerViewWidth));
            make.height.equalTo(@(concentH));
            make.centerX.equalTo(_contentView.mas_centerX);
        }];
    }else{
        top = (SCREEN_WIDTH - concentH) / 2;
        [_contentScrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(top));
            make.height.equalTo(@(HorViewHeight));
            make.width.equalTo(@(concentH));
            make.centerY.equalTo(_contentView.mas_centerY);
        }];
    }
    
    
//    NSInteger centenIndex = _imageViews.count / 2;
//    CGFloat alignPointY = 0.0;
//    StitchingButton *lastIMG;
//    if (_imageViews.count < 5){
//        centenIndex += 1;
//    }
//    if (_isVerticalCut){
//        for (NSInteger i = centenIndex - 1; i >= 0; i --) {
//            StitchingButton *img = _imageViews[i];
//            if (i == centenIndex - 1){
//                img.bottom = self.view.centerY;
//                alignPointY = img.bottom;
//                _centenIMG = img;
//            }else{
//                img.bottom = lastIMG.top;
//            }
//            lastIMG = img;
//            _originTopArr[i] = [NSNumber numberWithFloat:img.top];
//            _imageViews[i] = img;
//        }
//        for (NSInteger i = centenIndex; i < _imageViews.count; i ++) {
//            StitchingButton *img = _imageViews[i];
//            if (i == centenIndex){
//                img.top = alignPointY;
//            }else{
//                img.top = lastIMG.bottom;
//            }
//            lastIMG = img;
//            _originTopArr[i] = [NSNumber numberWithFloat:img.top];
//            _imageViews[i] = img;
//        }
//    }else{
//        if (_imageViews.count == 2){
//            centenIndex = 1;
//        }
//        for (NSInteger i = centenIndex - 1; i >= 0; i --) {
//            StitchingButton *img = _imageViews[i];
//            if (i == centenIndex - 1){
//                if (_imageViews.count == 1){
//                    img.centerX = self.view.centerX;
//                    alignPointY = img.centerX;
//                }else{
//                    img.right = self.view.centerX;
//                    alignPointY = img.right;
//                }
//                _centenIMG = img;
//            }else{
//                img.left = lastIMG.right;
//            }
//            lastIMG = img;
//            _originRightArr[i] = [NSNumber numberWithFloat:img.left];
//            _imageViews[i] = img;
//        }
//        for (NSInteger i = centenIndex; i < _imageViews.count; i ++) {
//            StitchingButton *img = _imageViews[i];
//            if (i == centenIndex){
//                img.left = alignPointY;
//            }else{
//                img.left = lastIMG.right;
//            }
//            lastIMG = img;
//            _originRightArr[i] = [NSNumber numberWithFloat:img.left];
//            _imageViews[i] = img;
//        }
//
//
//    }
//    StitchingButton *firstIamge = _imageViews.firstObject;
//    StitchingButton *lastImage = _imageViews.lastObject;
//   // NSLog(@"rect==%@",@(lastImage.frame));
//    _contentScrollView.top = firstIamge.top;
//    if (_isVerticalCut){
//        _contentScrollView.contentSize = CGSizeMake(_contentScrollView.width, lastImage.bottom);
//    }else{
//        _contentScrollView.contentSize = CGSizeMake(lastIMG.right, _contentScrollView.height);
//    }
}

-(void)addadjustView{
    _adjustView = [UIImageView new];
    _adjustView.userInteractionEnabled = YES;
    _adjustView.image = IMG(@"调整背景");
    [self.view addSubview:_adjustView];
    [self.view bringSubviewToFront:_adjustView];
    [_adjustView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@28);
        make.centerY.equalTo(self.view);
        make.height.equalTo(@300);
        make.right.equalTo(_contentScrollView.mas_right).offset(-20);
    }];
    for (NSInteger i = 0; i < 1; i ++) {
        //滑块图片
        UIImage *thumbImage = IMG(@"调整icon");
        //左右轨的图片
        UISlider *paintSlider = [UISlider new];;
        if (i == 0){
            // 设置颜色
            paintSlider.minimumValue = 3;
            paintSlider.maximumValue = 8;
            paintSlider.maximumTrackTintColor = HexColor(@"#282B30");
            paintSlider.minimumTrackTintColor = [UIColor whiteColor];
            paintSlider.value = 3;
            paintSlider.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
        }else{
            // 设置颜色
            paintSlider.maximumTrackTintColor = [UIColor whiteColor];
            paintSlider.minimumTrackTintColor = HexColor(@"#282B30");
            paintSlider.minimumValue = 1;
            paintSlider.maximumValue = 50;
            paintSlider.value = 100;
            paintSlider.transform = CGAffineTransformMakeRotation(M_PI * 1.5);
        }
        paintSlider.userInteractionEnabled = YES;
        
        //注意这里要加UIControlStateHightlighted的状态，否则当拖动滑块时滑块将变成原生的控件
        [paintSlider setThumbImage:thumbImage forState:UIControlStateHighlighted];
        [paintSlider setThumbImage:thumbImage forState:UIControlStateNormal];
        //滑块拖动时的事件
        paintSlider.tag = i;
        [paintSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_adjustView addSubview:paintSlider];
        paintSlider.backgroundColor = [UIColor clearColor];
        [paintSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(240));
            make.centerX.equalTo(_adjustView);
            make.height.equalTo(@28);
            make.top.equalTo(@140);
        }];
    }
}

-(void)setupNavItems{
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    saveBtn.tag = 0;
    [saveBtn setBackgroundImage:IMG(@"水印保存") forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(topBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc]initWithCustomView:saveBtn];
    self.navigationItem.rightBarButtonItem = saveItem;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    leftBtn.tag = 1;
    [leftBtn setBackgroundImage:IMG(@"stitch_white_back") forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(topBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = item;
}

-(void)addBottomView{
    MJWeakSelf
    _bottomView = [CaptionBottomView new];
    _bottomView.type = _type;
    _bottomView.btnClick = ^(NSInteger tag) {
        [weakSelf bottomBtnClick:tag];
    };
    [self.view addSubview:_bottomView];
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.bottom.equalTo(self.view);
        make.height.equalTo(@80);
    }];
}

-(void)addVerticalCutView{
    NSInteger count = _imageViews.count;
    if (count == 1){
        count ++;
    }
    for (NSInteger i = 0; i < count ; i ++) {
        StitchingButton *img;
        if (_imageViews.count == 1){
            img = _imageViews.firstObject;
        }else{
            img = _imageViews[i];
        }    
        img.userInteractionEnabled = YES;
        if (img == nil){
            break;
        }
        img.layer.borderWidth = 3;
        img.layer.borderColor = HexColor(@"#0A58F6").CGColor;
        if (_imageViews.count == 1){
            _imageViews[0] = img;
            _originTopArr[0] = [NSNumber numberWithFloat:img.top];
            _originBottomArr[0] = [NSNumber numberWithFloat:img.height];
            _originHeightArr[0] = [NSNumber numberWithFloat:img.height];
        }else{
            _imageViews[i] = img;
            _originTopArr[i] = [NSNumber numberWithFloat:img.top];
            _originBottomArr[i] = [NSNumber numberWithFloat:img.height];
            _originHeightArr[i] = [NSNumber numberWithFloat:img.height];
        }
        UIButton *cutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cutBtn addTarget:self action:@selector(cutBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        cutBtn.tag = (i + 1) * 10000;
        [_contentScrollView addSubview:cutBtn];
        if (i == 0){
            [cutBtn setBackgroundImage:IMG(@"topCutIcon") forState:UIControlStateNormal];
            [cutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.top.equalTo(img);
                make.height.equalTo(@22);
                make.width.equalTo(@60);
            }];
        }else if (i == _imageViews.count - 1 || _imageViews.count == 1){
            [cutBtn setBackgroundImage:IMG(@"bottomCutIcon") forState:UIControlStateNormal];
            cutBtn.tag = (i + 2 ) * 10000;
            [cutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.bottom.equalTo(img);
                make.height.equalTo(@22);
                make.width.equalTo(@60);
            }];
            if (_imageViews.count != 1){
                UIButton *topBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [topBtn addTarget:self action:@selector(cutBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                topBtn.tag = (i + 1) * 10000;
                [topBtn setBackgroundImage:IMG(@"centerCutIcon") forState:UIControlStateNormal];
                [_contentScrollView addSubview:topBtn];
                [topBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(img);
                    make.top.equalTo(img.mas_top).offset(-14);
                    make.height.equalTo(@28);
                    make.width.equalTo(@60);
                }];
            }
        }else{
            [cutBtn setBackgroundImage:IMG(@"centerCutIcon") forState:UIControlStateNormal];
            [cutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(img);
                make.top.equalTo(img.mas_top).offset(-14);
                make.height.equalTo(@28);
                make.width.equalTo(@60);
            }];
        }
    }
    StitchingButton *firstIMG = _imageViews.firstObject;
    _leftCutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftCutBtn.tag = 1 ;
    [_leftCutBtn addTarget:self action:@selector(cutBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_leftCutBtn setBackgroundImage:IMG(@"leftCutIcon") forState:UIControlStateNormal];
    [_contentScrollView addSubview:_leftCutBtn];
    [_contentScrollView bringSubviewToFront:_leftCutBtn];
    _rightCutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightCutBtn.tag = 3;
    [_rightCutBtn addTarget:self action:@selector(cutBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_rightCutBtn setBackgroundImage:IMG(@"rightCutIcon") forState:UIControlStateNormal];
    [_contentScrollView addSubview:_rightCutBtn];
    [_contentScrollView bringSubviewToFront:_rightCutBtn];
    if (_imageViews.count == 1){
        [_leftCutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@22);
            make.height.equalTo(@60);
            make.left.equalTo(firstIMG.mas_left);
            make.centerY.equalTo(firstIMG.mas_centerY);
        }];
        
    }else{
        [_leftCutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@22);
            make.height.equalTo(@60);
            make.left.equalTo(firstIMG.mas_left);
            if (_contentScrollView.contentSize.height < LayoutHeight){
                make.centerY.equalTo(_contentScrollView.mas_top);
            }else{
                make.centerY.equalTo(self.view.mas_centerY);
            }
            
        }];
    }
    [_rightCutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(firstIMG.mas_right);
        make.centerY.width.height.equalTo(_leftCutBtn);
    }];
    
    
}
-(void)addHorizontalCutView{
    NSInteger count = _imageViews.count;
    if (count == 1){
        count ++;
    }
    for (NSInteger i = 0; i < count ; i ++) {
        StitchingButton *img;
        if (_imageViews.count == 1){
            img = _imageViews.firstObject;
        }else{
            img = _imageViews[i];
        }
        img.userInteractionEnabled = YES;
        if (img == nil){
            break;
        }
        img.layer.borderWidth = 3;
        img.layer.borderColor = HexColor(@"#0A58F6").CGColor;
        if (_imageViews.count == 1){
            _imageViews[0] = img;
            _originRightArr[0] = [NSNumber numberWithFloat:img.left];
            _originWidthArr[0] = [NSNumber numberWithFloat:img.width];
        }else{
            _imageViews[i] = img;
            _originRightArr[i] = [NSNumber numberWithFloat:img.left];
            _originWidthArr[i] = [NSNumber numberWithFloat:img.width];
        }
        UIButton *cutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cutBtn addTarget:self action:@selector(horizontalCutBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        cutBtn.tag = (i + 1) * 10000;
        [_contentScrollView addSubview:cutBtn];
        if (i == 0){
            [cutBtn setBackgroundImage:IMG(@"leftCutIcon") forState:UIControlStateNormal];
            [cutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.left.equalTo(img);
                make.width.equalTo(@22);
                make.height.equalTo(@60);
            }];
        }else if (i == _imageViews.count - 1 || _imageViews.count == 1){
            [cutBtn setBackgroundImage:IMG(@"rightCutIcon") forState:UIControlStateNormal];
            cutBtn.tag = (i + 2 ) * 10000;
            [cutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.right.equalTo(img);
                make.width.equalTo(@22);
                make.height.equalTo(@60);
            }];
            if (_imageViews.count != 1){
                UIButton *topBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [topBtn addTarget:self action:@selector(horizontalCutBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                topBtn.tag = (i + 1) * 10000;
                [topBtn setBackgroundImage:IMG(@"horCenterCutIcon") forState:UIControlStateNormal];
                [_contentScrollView addSubview:topBtn];
                [topBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(img);
                    make.left.equalTo(img.mas_left).offset(-14);
                    make.width.equalTo(@28);
                    make.height.equalTo(@60);
                }];
            }
        }else{
            [cutBtn setBackgroundImage:IMG(@"horCenterCutIcon") forState:UIControlStateNormal];
            [cutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(img);
                make.left.equalTo(img.mas_left).offset(-14);
                make.width.equalTo(@28);
                make.height.equalTo(@60);
            }];
        }
        
    }
    
    StitchingButton *firstIMG = _imageViews.firstObject;
    _leftCutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftCutBtn.tag = 1 ;
    [_leftCutBtn addTarget:self action:@selector(horizontalCutBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_leftCutBtn setBackgroundImage:IMG(@"topCutIcon") forState:UIControlStateNormal];
    [_contentScrollView addSubview:_leftCutBtn];
    [_contentScrollView bringSubviewToFront:_leftCutBtn];
    _rightCutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightCutBtn.tag = 3;
    [_rightCutBtn addTarget:self action:@selector(horizontalCutBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_rightCutBtn setBackgroundImage:IMG(@"bottomCutIcon") forState:UIControlStateNormal];
    [_contentScrollView addSubview:_rightCutBtn];
    [_contentScrollView bringSubviewToFront:_rightCutBtn];
    if (_imageViews.count == 1){
        [_leftCutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@22);
            make.width.equalTo(@60);
            make.top.equalTo(firstIMG.mas_top);
            make.centerX.equalTo(firstIMG.mas_centerX);
        }];
        
    }else{
        [_leftCutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@22);
            make.width.equalTo(@60);
            make.top.equalTo(firstIMG.mas_top);
            if (_contentScrollView.contentSize.height < LayoutHeight){
                make.centerX.equalTo(_contentScrollView.mas_centerX);
            }else{
                make.centerX.equalTo(self.view.mas_centerX);
            }
            
        }];
    }
    [_rightCutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(firstIMG.mas_bottom);
        make.centerX.width.height.equalTo(_leftCutBtn);
    }];
}
-(void)addGuideBtn{
    _guideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_guideBtn addTarget:self action:@selector(guideBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_contentScrollView addSubview:_guideBtn];
    [_contentScrollView bringSubviewToFront:_guideBtn];
}

-(void)viewInitSetting{
    _topCurrentValue = 0;
    _offsetY = 0.0;
    _isCut = NO;
    _isMove = NO;
    _isSlicing = NO;
    _isVerticalCut = YES;
    _isTurn = NO;
    _imgSelectIndex = MAXFLOAT;
    _isStartCut = NO;
    _isScrollViewScroll = NO;
}

- (void)screenRecordFinish:(NSNotification *)noty{
    //录屏结束通知 拼接图片
    [SVProgressHUD showWithStatus:@"检测到新的滚动截图，正在为你生成图片"];
    NSDictionary *dict = noty.userInfo;
    _videoURL = dict[@"videoURL"];
    GVUserDe.isHaveScreenData = NO;
    GVUserDe.isScorllScreen = YES;
    [self addScrrenData];
}

-(void)addScrrenData{
    MJWeakSelf
    [self.dataArr removeAllObjects];
    [self.view removeAllSubviews];
    [SVProgressHUD dismiss];
    NSMutableArray *tempArr = [NSMutableArray array];
    __block NSInteger allSameCount = 1;
    
    if (_videoURL){
        [[HandlerVideo sharedInstance]splitVideo:_videoURL fps:1 progressImageBlock:^(CGFloat progress) {
            if (progress >= 1) {
                for (NSInteger i = 0 ; i < tempArr.count; i ++) {
                    if ( i < tempArr.count - 1){
                        cv::Mat matImage = [XWOpenCVHelper cvMatFromUIImage:tempArr[i]];
                        cv::Mat matNextImage = [XWOpenCVHelper cvMatFromUIImage:tempArr[i + 1]];
                        int hashValue = aHash(matImage, matNextImage);
                        if (hashValue >= 5){
                            [weakSelf.dataArr addObject:tempArr[i]];
                        }
                        if (hashValue == 0){
                            allSameCount ++;
                        }
                    }
                }
                if (allSameCount == tempArr.count){
                    [weakSelf.dataArr addObject:tempArr.firstObject];
                }
                if (tempArr.count > 0){
                    [weakSelf.dataArr addObject:tempArr.lastObject];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    [weakSelf setupViews];
                   
                });
                
            }
        } splitCompleteBlock:^(BOOL success, UIImage *splitimg) {
            if (success && splitimg) {
                [tempArr addObject:splitimg];
            }
        }];
    }
}

#pragma mark --Touches
- (CGPoint)pointWithTouches:(NSSet *)touches{
    UITouch *touch = [touches anyObject];
    return [touch locationInView:_contentScrollView];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    MJWeakSelf
    CGPoint moveP = [self pointWithTouches:touches];
    if (_isScrollViewScroll){
        return;
    }
   
    if (_isCut && !_isStartCut){
        [self deleteContentScorllViewSubViews];
        _guideBtn.hidden = YES;
        NSInteger index = 0;
        for (StitchingButton *image in _imageViews) {
            if (CGRectContainsPoint(image.frame, moveP)){
                index = image.tag / 100 - 1;
                break;
            }
        }
        StitchingButton *imgView = _imageViews[index];
        if (_imgFunctionView == nil){
            _imgFunctionView = [IMGFuctionView new];
            [self.view addSubview:_imgFunctionView];
            _bottomView.hidden = YES;
            [_imgFunctionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(_bottomView);
            }];
        }
        _imgFunctionView.btnClick = ^(NSInteger tag) {
            [weakSelf imgFuntionWithTag:tag andIMG:imgView andIMGIndex:index];
        };
 
        if (_imgSelectIndex != index && _imgSelectIndex != MAXFLOAT){
            for (UIView *vc in _selectIMG.subviews) {
                if (vc.tag >= 1000){
                    [vc removeFromSuperview];
                }
            }
        }
        imgView.layer.borderWidth = 3;
        imgView.layer.borderColor = HexColor(@"#0A58F6").CGColor;
        NSArray *btnArr = @[@"topCutIcon",@"leftCutIcon",@"bottomCutIcon",@"rightCutIcon"];
        for (NSInteger i = 0 ;i < btnArr.count; i ++) {
            UIImageView *line = [UIImageView new];
            line.tag = (i + 1) * 1000;
            line.image = IMG(btnArr[i]);
            [imgView addSubview:line];
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                if (i == 0){
                    make.centerX.top.equalTo(imgView);
                    make.height.equalTo(@22);
                    make.width.equalTo(@60);
                }else if (i == 1){
                    make.left.centerY.equalTo(imgView);
                    make.width.equalTo(@22);
                    make.height.equalTo(@60);
                }else if (i == 2){
                    make.centerX.bottom.equalTo(imgView);
                    make.height.equalTo(@22);
                    make.width.equalTo(@60);
                }else{
                    make.centerY.right.equalTo(imgView);
                    make.width.equalTo(@22);
                    make.height.equalTo(@60);
                }
            }];
        }
        _imgFunctionView.hidden = NO;
        _selectIMG = imgView;
        _imgSelectIndex = index;
    }
}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    // CGPoint moveP = [self pointWithTouches:touches];
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    // CGPoint moveP = [self pointWithTouches:touches];
}
-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}

#pragma mark --Gesture
- (void)selectonPanGesture:(UIPanGestureRecognizer *)gesture {
    if (!_isCut){
        if (gesture.state == UIGestureRecognizerStateBegan){
            _contentScrollView.userInteractionEnabled = NO;
        }
        if (gesture.state == UIGestureRecognizerStateEnded){
            _contentScrollView.userInteractionEnabled = YES;
        }
        CGPoint translatedPoint = [gesture translationInView:self.view];
        CGPoint newCenter = CGPointMake(gesture.view.center.x+ translatedPoint.x, gesture.view.center.y + translatedPoint.y);
        gesture.view.center = newCenter;
        [gesture setTranslation:CGPointMake(0, 0) inView:self.view];
        
    }
    
}

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    CGFloat scale = recognizer.scale;
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, scale, scale);
    recognizer.scale = 1;
}
//保证拖动手势和UIScrollView上的拖动手势互不影响
-(BOOL)gestureRecognizer:(UIGestureRecognizer*) gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer{
    if ([gestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
        return NO;
    }else {
        return YES;
    }
}



#pragma mark --------- Method------------
#pragma mark --合并图片
- (void)mergeImages:(NSArray *)assets
         completion:(SZImageMergeBlock)completion{
    MJWeakSelf
    dispatch_async(_queue, ^{
        CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
        SZImageGenerator *generator = [self imageGeneratorBy:assets];
        if (!generator) {
            return ;
        }
        NSError *error = [generator error];
        CFAbsoluteTime nextTime = CFAbsoluteTimeGetCurrent() - time;
        NSLog(@"合并时间%@",@(nextTime));
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (completion) {
                generator.stiching = NO;
                completion(generator,error);
                weakSelf.gengrator = generator;
            }
        });
    });
}

/*
 * @description assets数组生成获取图片，并开始合并
 */
- (SZImageGenerator *)imageGeneratorBy:(NSArray *)assets{
    NSMutableArray *images = [NSMutableArray array];
    __block NSInteger index = 0;
    if (!GVUserDe.isScorllScreen){
        for (PHAsset *asset in assets) {
            [Tools getImageWithAsset:asset withBlock:^(UIImage * _Nonnull image) {
                [images addObject:image];
                index++;
            }];
        }
    }else{
        index = assets.count;
        [images addObjectsFromArray:assets];
    }
    if (!images.count && index != assets.count) {
        [SVProgressHUD showInfoWithStatus:@"请重新选择图片！"];
        [self.navigationController popViewControllerAnimated:YES];
        return nil;
    }
    /*
     这里是合成代码，合成图片
     SZImageGenerator 包含合成信息，数据
     */
    SZImageGenerator *generator = [[SZImageGenerator alloc] init];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;
    CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
    for (UIImage *image in images){
        [generator feedImage:image];
    }
    CFAbsoluteTime next = CFAbsoluteTimeGetCurrent() - time;
    NSLog(@"总共消耗的时间：%@",@(next));
    return generator;
}
-(void)stitchImgWith:(SZImageGenerator *)generator{
    MJWeakSelf
    __block CGFloat contentHeight = 0.0;
    SZImageMergeInfo *firstInfo = generator.infos.firstObject;
    if (!firstInfo.firstImage){
        return;
    }
    CGFloat firstImagescale = VerViewWidth / firstInfo.firstImage.size.width;
    __block StitchingButton *firstImageView = [[StitchingButton alloc] initWithFrame:CGRectMake(0, 0, VerViewWidth, firstInfo.firstImage.size.height * firstImagescale)];
    [_contentScrollView addSubview:firstImageView];
    firstImageView.image = firstInfo.firstImage;
    firstImageView.userInteractionEnabled = YES;
    contentHeight += firstImageView.height;
    firstImageView.tag = 100;
    [self.originTopArr addObject:[NSNumber numberWithFloat:0]];
    [self.originHeightArr addObject:[NSNumber numberWithFloat:firstImageView.height]];
    [self.originBottomArr addObject:[NSNumber numberWithFloat:firstImageView.height]];
    [self.imageViews addObject:firstImageView];
    __block NSInteger tagIndex = 2;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (SZImageMergeInfo *info in generator.infos) {
            if (!info.secondImage){
                continue;
            }
            CGFloat scale = VerViewWidth / info.secondImage.size.width;
            CGFloat secondImageH = info.secondImage.size.height * scale;
            StitchingButton *imageView = [[StitchingButton alloc] initWithFrame:CGRectMake(0, firstImageView.bottom, VerViewWidth, secondImageH)];
            imageView.image = info.secondImage;
            imageView.tag = tagIndex * 100;
            [weakSelf.contentScrollView addSubview:imageView];
            if (!info.error) {
                firstImageView.height = firstImageView.height - (info.firstOffset) * scale;
                imageView.top = firstImageView.bottom;
                imageView.height = (info.secondOffset) * scale;
                imageView.imgView.top = - secondImageH + (info.secondOffset) * scale;
            }
            contentHeight += imageView.height;
            [weakSelf.originTopArr addObject:[NSNumber numberWithFloat:imageView.top]];
            [weakSelf.originBottomArr addObject:[NSNumber numberWithFloat:contentHeight]];
            [weakSelf.originHeightArr addObject:[NSNumber numberWithFloat:imageView.height]];
            [weakSelf.imageViews addObject:imageView];
            firstImageView = imageView;
            tagIndex ++;
        }
        weakSelf.contentScrollView.contentSize = CGSizeMake(0,contentHeight);
       //weakSelf.title = [NSString stringWithFormat:@"%ld张图片",generator.infos.count];
        
        if (contentHeight < SCREEN_HEIGHT){
            //内容过小则重置imageView布局
            [weakSelf layoutContentViewWithContent:contentHeight];
        }else{
            weakSelf.contentScrollView.contentSize = CGSizeMake(0,firstImageView.bottom);
        }
        [SVProgressHUD showSuccessWithStatus:@"拼接完成"];
    }); 
}


#pragma mark -- 图片竖屏裁切
-(void)cutBtnClick:(UIButton *)btn{
    //判断了哪一边 0==上 1==左 2=下 3=右
    //判断了点击第几行
    NSInteger index = btn.tag / 10000 ;
    NSLog(@"index==%ld",index);
    NSLog(@"btn.tag==%ld",btn.tag);
    _isCut = YES;
    if (btn.tag < 10000 ){
        _posizition = btn.tag;
        index = 1;
    }
//    if (_imageViews.count == 1){
//        //单张图裁切
//        _posizition = btn.tag;
//        _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panMoveGesture:)];
//        _panGesture.delegate = self;
//        [_contentScrollView addGestureRecognizer:_panGesture];
//    }else{
//
//    }
    [self deleteContentScorllViewSubViews];
    if (_isStartCut){
        _guideBtn.hidden = YES;
        if (_isVerticalCut){
            [self addVerticalCutView];
        }else{
            [self addHorizontalCutView];
        }
    }
    if (!_isStartCut){
        _guideBtn.hidden = NO;
        //点击了左右则全部一起移动 ，点击了中间按钮则上下都可移动
        _moveIndex = index;
        [self moveIMGWithIndex:index andPosizion:_posizition];
        _isStartCut = YES;
    }else{
        //取消
        _isStartCut = NO;
        [self deleteContentScorllViewSubViews];
    }
}



-(void)moveIMGWithIndex:(NSInteger )index andPosizion:(NSInteger )posizion{
    _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panMoveGesture:)];
    _panGesture.delegate = self;
    [_contentScrollView addGestureRecognizer:_panGesture];
    if (_type == 4){
        _resultView.scrollView.scrollEnabled = NO;
    }
    if (_guideBtn == nil){
        [self addGuideBtn];
    }
    _guideBtn.selected = YES;
    _guideBtn.hidden = NO;
    [_contentScrollView bringSubviewToFront:_guideBtn];
    StitchingButton *img;
    if (_moveIndex - 1 >= _imageViews.count){
        img = _imageViews.lastObject;
    }else{
        img = _imageViews[_moveIndex - 1];
    }
    
    if (_posizition == 1 || _posizition == 3){
        [_guideBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(img.mas_top);
            make.width.equalTo(@30);
            if (_contentScrollView.contentSize.height < LayoutHeight){
                make.height.equalTo(@(_contentScrollView.contentSize.height));
            }else{
                if (_imageViews.count == 1){
                    make.height.equalTo(@(img.height));
                }else{
                    make.height.equalTo(@(_contentScrollView.height));
                }
                
            }
            if (_posizition == 1){
                //左边
                [_guideBtn setBackgroundImage:IMG(@"左裁切分界线") forState:UIControlStateNormal];
                make.left.equalTo(img.mas_left);
            }else{
                //右边
                [_guideBtn setBackgroundImage:IMG(@"右裁切分界线") forState:UIControlStateNormal];
                make.right.equalTo(img.mas_right);
            }
        }];
    }else{
        if (index == 1){
            //顶部
            [_guideBtn setBackgroundImage:IMG(@"上裁切分界线") forState:UIControlStateNormal];
            [_guideBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(img.mas_width);
                make.left.equalTo(img.mas_left);
                make.top.equalTo(img.mas_top);
                make.height.equalTo(@20);
            }];
            
        }else{
            [_guideBtn setBackgroundImage:IMG(@"下裁切分界线") forState:UIControlStateNormal];
            [_guideBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(img.mas_width);
                make.left.equalTo(img.mas_left);
                if (_moveIndex == _imageViews.count + 1 || _imageViews.count == 1){
                    make.bottom.equalTo(img.mas_bottom);
                }else{
                    make.top.equalTo(img.mas_top).offset(-20);
                }
                make.height.equalTo(@20);
            }];
        }
    }
}



-(void)panMoveGesture:(UIPanGestureRecognizer *)recognizer{
    CGPoint translatedPoint = [recognizer translationInView:self.view];
    CGPoint locationPoint = [recognizer locationInView:recognizer.view];
    if (!_isMove){
        for (StitchingButton *imageView in _imageViews) {
            if (CGRectContainsPoint(imageView.frame,locationPoint)){
                if (_isVerticalCut == YES){
                    if (imageView.tag / 100 < _moveIndex){
                        _isTopPart = YES;
                    }else{
                        _isTopPart = NO;
                    }
                }else{
                    if (imageView.tag / 100 < _moveIndex){
                        //左边
                        _isTopPart = YES;
                    }else{
                        //右边
                        _isTopPart = NO;
                        
                    }
                }
                
            }
        }
    }
    if (recognizer.state == UIGestureRecognizerStateChanged){
        _guideBtn.hidden = YES;
        _isMove = YES;
        if (_isCut){
            [self.contentScrollView setScrollEnabled:NO];
            if (_isVerticalCut){
                if (_posizition == 1 || _posizition == 3){
                    [self moveWithoffsetP:translatedPoint.x];
                }else{
                    [self moveWithoffsetP:translatedPoint.y];
                }
            }else{
                if (_posizition == 1 || _posizition == 3){
                    [self horizontalMoveWithoffsetP:translatedPoint.y];
                }else{
                    [self horizontalMoveWithoffsetP:translatedPoint.x];
                }
                
            }
        }
    }else if (recognizer.state == UIGestureRecognizerStateBegan){
        if (_isCut){
            [self.contentScrollView setScrollEnabled:NO];
        }
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self updateContentScrollViewContentSize];
        [self.contentScrollView setScrollEnabled:YES];
        if (_isCut){
            _isMove = NO;
            _guideBtn.hidden = NO;
        }
        
    }
    if (self.contentScrollView.isDragging && _isCut) {
        return;
    }
    [recognizer setTranslation:CGPointZero inView:recognizer.view.superview];
}

-(void)moveWithoffsetP:(CGFloat)offsetP{
    if (_posizition == 1 || _posizition == 3) {
        /*
         移动左边或者右边 整体向该边进行偏移
         imageView.width改变，imageView.imgView.left改变
         */
        for (StitchingButton *imageView in _imageViews) {
            if (_posizition == 1){
                CGFloat tmpF = imageView.imgView.left + offsetP;
                if (offsetP < 0){
                    if (imageView.right <= 0){
                        imageView.right = 0;
                        imageView.width = imageView.width - offsetP;
                        //return;
                    }else{
                        imageView.imgView.left = tmpF;
                    }
                }else{
                    if (imageView.width >= VerViewWidth){
                        imageView.width = VerViewWidth;
                        imageView.centerX = self.view.centerX;
                        imageView.imgView.left = 0;
                        //return;
                    }else{
                        imageView.imgView.left = tmpF;
                    }
                }
                imageView.width = imageView.width + offsetP;
            }else{
                CGFloat tmpF = imageView.width - offsetP;
                if (offsetP < 0){
                    if (tmpF >= VerViewWidth){
                        imageView.width = VerViewWidth;
                        imageView.centerX = _contentView.centerX;
                        // return;
                    }else{
                        imageView.width = tmpF;
                    }
                }else{
                    if (tmpF <= 0){
                        imageView.width = imageView.imgView.width;
                        imageView.centerX = _contentView.centerX;
                         return;
                    }else{
                        imageView.width = tmpF;
                    }
                }
                imageView.left = imageView.left + offsetP;
            }
            
        }
    }else{
        if (_moveIndex == 1){
            //移动第一张顶部
            //点击了顶部 整体偏移往上
            NSLog(@"offp==%lf",offsetP);
            StitchingButton *imageView = self.imageViews[0];
            CGFloat top = [_originTopArr[0]floatValue];
            CGFloat viewHeight = [_originHeightArr[0] floatValue];
            CGFloat height;
            if (_imageViews.count == 1){
                height = imageView.imgView.height;
            }else{
                height = [_originTopArr[1]floatValue];
            }
            CGFloat tmpF = imageView.height + offsetP;
            if (offsetP <= 0){
                if (tmpF <= 0){
                    imageView.height = 0;
//                    return;
                }else{
                    imageView.height = tmpF  ;
                    imageView.imgView.top = offsetP+ imageView.imgView.top;
                }
            }else{
                if (tmpF >= viewHeight){
                    imageView.top = top;
                    imageView.height = viewHeight;
                  //  return;
                }else{
                    imageView.height = tmpF  ;
                    imageView.imgView.top = offsetP+ imageView.imgView.top;
                }
            }    
            //底部跟随
            if (_imageViews.count > 1){
                [self bottomFollow:imageView isIndex:_moveIndex];
            }
        }else if (_moveIndex == _imageViews.count + 1){
            //编辑最后一个不能超过他原先的top
            StitchingButton *imageView = self.imageViews[_moveIndex - 2];
            CGFloat viewHeight = [_originHeightArr[_moveIndex - 2]floatValue];
            CGFloat tmpF = imageView.height - offsetP;
            if (offsetP > 0){
                if (tmpF < 0){
                    imageView.height = 0;
                    return;
                }else{
                    imageView.height = tmpF;
                }
            }else{
                if (tmpF >= viewHeight){
                    imageView.height = viewHeight;
                    imageView.top = [_originTopArr[_moveIndex - 2] floatValue];
                    return;
                }else{
                    imageView.height = tmpF;
                }
            }
            imageView.top = imageView.top + offsetP;
            //顶部跟随
            if (_moveIndex - 3 >= 0){
                [self topFollow:imageView offsetY:offsetP AndIndex:_moveIndex - 3];
            }
            
        }else{
            if(_isTopPart){
                if (_imageViews.count == 1){
                    _moveIndex = 2;
                }
                StitchingButton *imageView = self.imageViews[_moveIndex - 2];
                CGFloat viewHeight = [_originHeightArr[_moveIndex - 2]floatValue];
                CGFloat tmpF = imageView.height - offsetP;
                if (offsetP > 0){
                    if (tmpF < 0){
                        imageView.height = 0;
                        return;
                    }else{
                        imageView.height = tmpF;
                    }
                }else{
                    if (tmpF >= viewHeight){
                        imageView.height = viewHeight;
                        imageView.top = [_originTopArr[_moveIndex - 2] floatValue];
                        return;
                    }else{
                        imageView.height = tmpF;
                    }
                }
                imageView.top = imageView.top + offsetP;
                //顶部跟随
                if (_moveIndex - 3 >= 0 && _imageViews.count > 1){
                    [self topFollow:imageView offsetY:offsetP AndIndex:_moveIndex - 3];
                }
                
            }else{
                StitchingButton *imageView = self.imageViews[_moveIndex - 1];
                CGFloat viewHeight = [_originHeightArr[_moveIndex - 1]floatValue];
                CGFloat top = [_originTopArr[_moveIndex -1]floatValue];
                CGFloat tmp = imageView.height + offsetP;
                if (offsetP < 0){
                    if (tmp <= 0){
                        imageView.top = top;
                        imageView.height = 0;
                    }else{
                        imageView.height = tmp ;
                        imageView.imgView.top = offsetP+ imageView.imgView.top;
                    }
                }else{
                    if (tmp >= viewHeight){
                        imageView.top = top;
                        imageView.height = viewHeight;
                        imageView.imgView.top = 0;
                    }else{
                        imageView.height = tmp ;
                        imageView.imgView.top = offsetP+ imageView.imgView.top;
                    }
                }
                //底部跟随
                if (_moveIndex <= _imageViews.count - 1){
                    [self bottomFollow:imageView isIndex:_moveIndex];
                }
            }
        }
    }
}

- (void)topFollow:(StitchingButton *)stichingImageView offsetY:(CGFloat) offsetY AndIndex:(NSInteger) index{
    /*
     * 顶部跟随
     * stichingImageView 需要跟随谁的顶部
     * index 从哪一张开始跟随
     */
    StitchingButton *lastStichimageView = stichingImageView;
    for (NSInteger i = index; i >= 0; i --) {
        StitchingButton *changeImageView = self.imageViews[i];
        changeImageView.top = changeImageView.top + offsetY;
        lastStichimageView = changeImageView;
    }
}

- (void)bottomFollow:(StitchingButton *)stichingImageView isIndex:(NSInteger) index{
    /*
     * 底部跟随
     * stichingImageView 需要跟随谁的底部
     * index 从哪一张开始跟随
     */
    StitchingButton *lastStichimageView = stichingImageView;
    for (NSInteger i = index; i < _imageViews.count ; i ++) {
        StitchingButton *changeImageView = self.imageViews[i];
        changeImageView.top = lastStichimageView.bottom;
        lastStichimageView = changeImageView;
    }
    
}



#pragma mark --图片横拼裁切
-(void)horizontalCutBtnClick:(UIButton *)btn{
    //判断了点击第几个
    NSInteger index = btn.tag / 10000 ;
    NSLog(@"tag==%ld",btn.tag);
    if (btn.tag < 10000){
        _posizition = btn.tag;
        _moveIndex = 1;
    }else{
        _moveIndex = index;
        if (_imageViews.count == 1 && btn.tag == 30000){
            _moveIndex = 2;
        }
        _posizition = 0;
    }
    [self moveHorizontalImgWithPosizition:_posizition andTag:btn.tag];
    [self deleteContentScorllViewSubViews];
}
-(void)moveHorizontalImgWithPosizition:(NSInteger )posizition andTag:(NSInteger)tag{
    _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panMoveGesture:)];
    _panGesture.delegate = self;
    [_contentScrollView addGestureRecognizer:_panGesture];
    if (_type == 4){
        _resultView.scrollView.scrollEnabled = NO;
    }
    if (_guideBtn == nil){
        [self addGuideBtn];
    }
    _guideBtn.selected = YES;
    _guideBtn.hidden = NO;
    [_contentScrollView bringSubviewToFront:_guideBtn];
    StitchingButton *img;
    if (_moveIndex - 1 >= _imageViews.count){
        img = _imageViews.lastObject;
    }else{
        img = _imageViews[_moveIndex - 1];
    }
    if (_posizition == 1 || _posizition == 3){
        [_guideBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(img.mas_left);
            make.height.equalTo(@22);
            if (_contentScrollView.contentSize.width < SCREEN_WIDTH){
                NSLog(@"width===%lf",_contentScrollView.contentSize.width);
                make.width.equalTo(@(_contentScrollView.contentSize.width));
            }else{
                make.width.equalTo(@(_contentScrollView.width));
            }
            if (_posizition == 1){
                //上边
                [_guideBtn setBackgroundImage:IMG(@"上裁切分界线") forState:UIControlStateNormal];
                make.top.equalTo(img.mas_top);
            }else{
                //下
                [_guideBtn setBackgroundImage:IMG(@"下裁切分界线") forState:UIControlStateNormal];
                make.bottom.equalTo(img.mas_bottom);
            }
        }];
    }else{
        if (_moveIndex == 1){
            //最左边
            [_guideBtn setBackgroundImage:IMG(@"左裁切分界线") forState:UIControlStateNormal];
            [_guideBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.height.top.equalTo(img);
                make.left.equalTo(img);
                make.width.equalTo(@22);
            }];
            
        }else{
            [_guideBtn setBackgroundImage:IMG(@"右裁切分界线") forState:UIControlStateNormal];
            [_guideBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.height.top.equalTo(img);
                if (_moveIndex == _imageViews.count + 1 || _imageViews.count == 1){
                    make.right.equalTo(img.mas_right);
                }else{
                    make.left.equalTo(img.mas_left).offset(-22);
                }
                make.width.equalTo(@22);
            }];
        }
    }
}
-(void)horizontalMoveWithoffsetP:(CGFloat)offsetP{
    if (_posizition == 1 || _posizition == 3){
        /*
         移动顶部或者地步 整体向该边进行偏移
         imageView.height改变，imageView.imgView.top改变
         */
        for (StitchingButton *imageView in _imageViews) {
            CGFloat top = [_originTopArr[0]floatValue];
            if (_posizition == 1){
                //移动顶部
                CGFloat tmpF =  imageView.height + offsetP;
                if (offsetP <= 0){
                    if (tmpF <= 0){
                        imageView.bottom = top;
                        imageView.height = 0;
                        imageView.imgView.bottom = 0;
                    }else{
                        imageView.height = tmpF;
                        imageView.imgView.top = imageView.imgView.top + offsetP;
                    }
                }else{
                    if (imageView.height >= HorViewHeight){
                        imageView.height = HorViewHeight;
                        imageView.top = top;
                        imageView.imgView.top = 0;
                        imageView.imgView.height = HorViewHeight;
                    }else{
                        imageView.height= tmpF;
                        imageView.imgView.top = imageView.imgView.top + offsetP;
                    }
                }
                
            }else{
                //移动底部
                CGFloat tmpF = imageView.height - offsetP;
                if (offsetP > 0){
                    if (tmpF < 0){
                        imageView.height = 0;
                       // return;
                    }else{
                        imageView.height = tmpF;
                    }
                }else{
                    if (tmpF >= imageView.imgView.height){
                        imageView.height = imageView.imgView.height;
                        imageView.top = top;
                        //return;
                    }else{
                        imageView.height = tmpF;
                    }
                }
                imageView.top = imageView.top + offsetP;
                
            }
            
        }
    }else{
        if (_moveIndex == 1){
            //移动最左边
            StitchingButton *imageView = _imageViews[0];
            CGFloat left = [_originRightArr[0]floatValue];
            CGFloat tmpF = imageView.width + offsetP;
            CGFloat viewWidth = [_originWidthArr[0]floatValue];
            if (offsetP <= 0){
                if (tmpF <= 0){
                    imageView.left = left;
                    imageView.width = 0;
                    //return;
                }else{
                    imageView.imgView.left = imageView.imgView.left + offsetP;
                    imageView.width = tmpF;
                }
            }else{
                if (tmpF >= viewWidth){
                    imageView.width = viewWidth;
                    imageView.left = left;
                    imageView.imgView.left = 0;
                    //return;
                }else{
                    imageView.imgView.left = imageView.imgView.left + offsetP;
                    imageView.width = tmpF;
                }
            }
            if (_imageViews.count > 1){
                //右边跟随
                [self rightFollow:imageView isIndex:_moveIndex ];
            }
        }else if (_moveIndex == _imageViews.count + 1){
            //移动最右边
            StitchingButton *imageView = _imageViews[_moveIndex - 2];
            CGFloat left = [_originRightArr[_moveIndex - 2]floatValue];
            CGFloat tmpF = imageView.width - offsetP;
            CGFloat viewWidth = [_originWidthArr[_moveIndex - 2]floatValue];
            if (offsetP <= 0){
                if (tmpF >= viewWidth){
                    imageView.width = viewWidth;
                    imageView.left = left;
                    // return;
                }else{
                    imageView.width = tmpF;
                    imageView.left = imageView.left + offsetP;
                }
            }else{
                if (tmpF <= 0){
                    imageView.width = 0;
                    imageView.left = left + imageView.imgView.width;
                    // return;
                }else{
                    imageView.width = tmpF;
                    imageView.left = imageView.left + offsetP;
                }
            }
            //左边跟随
            if (_moveIndex - 3 >= 0){
                [self leftFollow:imageView isIndex:_moveIndex - 3];
            }
        }else{
            //中间部分移动 和 移动第一张右边
            if (_isTopPart){
                //左边移动
                StitchingButton *imageView;
                CGFloat left = 0.0;
                CGFloat viewWidth = 0.0;
                if(_imageViews.count == 1){
                    //移动第一张右边
                    imageView = _imageViews[0];
                    left = [_originRightArr[0]floatValue];
                    viewWidth = [_originWidthArr[0]floatValue];
                }else{
                    imageView  = _imageViews[_moveIndex - 2];
                    left = [_originRightArr[_moveIndex - 2]floatValue];
                    viewWidth = [_originWidthArr[_moveIndex - 2]floatValue];
                }
                CGFloat tmpF = imageView.width - offsetP;
                if (offsetP <= 0){
                    if (tmpF >= viewWidth){
                        imageView.width = viewWidth;
                        imageView.left = left;
                        imageView.imgView.left = 0;
                    }else{
                        imageView.width = tmpF;
                        imageView.left = imageView.left + offsetP;
                       // imageView.imgView.left = imageView.imgView.left + offsetP;
                    }
                }else{
                    if (tmpF <= 0){
                        imageView.width = 0;
                        imageView.left = left + viewWidth;
                    }else{
                        imageView.width = tmpF;
//                        imageView.imgView.left = imageView.imgView.left + offsetP;
                        imageView.left = imageView.left + offsetP;
                    }
                }
                //左边跟随
                if (_moveIndex - 3 >= 0){
                    [self leftFollow:imageView isIndex:_moveIndex - 3];
                }
            }else{
                //右边移动
                StitchingButton *imageView;
                CGFloat left = 0.0;
                CGFloat viewWidth = 0.0;
                if(_moveIndex == 1){
                    //移动第一张右边
                    imageView = _imageViews[0];
                    left = [_originRightArr[1]floatValue];
                    viewWidth = [_originWidthArr[0]floatValue];
                }else{
                    imageView  = _imageViews[_moveIndex - 1];
                    left = [_originRightArr[_moveIndex - 1]floatValue];
                    viewWidth = [_originWidthArr[_moveIndex - 1]floatValue];
                }
                CGFloat tmpF = imageView.width + offsetP;
                if (offsetP <= 0){
                    //左边移动
                    if (tmpF <= 0){
                        imageView.width = 0;
                        imageView.right = left;
                        imageView.imgView.right = 0;
                    }else{
                        imageView.width = tmpF;
                        imageView.imgView.left = imageView.imgView.left + offsetP;
                    }
                }else{
                    if (tmpF >= viewWidth){
                        imageView.width = viewWidth;
                        imageView.left = left;
                        imageView.imgView.left = 0;
                    }else{
                        imageView.width = tmpF;
                        imageView.imgView.left = imageView.imgView.left + offsetP;
                    }
                }
                //右边跟随
                if (_moveIndex <= _imageViews.count - 1){
                    [self rightFollow:imageView isIndex:_moveIndex];
                }
            }
        }
    }
    
}


- (void)leftFollow:(StitchingButton *)stichingImageView isIndex:(NSInteger) index{
    /*
     * 左边跟随
     * stichingImageView 需要跟随谁的左边
     * index 从哪一张开始跟随
     */
    StitchingButton *lastStichimageView = stichingImageView;
    for (NSInteger i = index; i >= 0  ; i --) {
        StitchingButton *changeImageView = self.imageViews[i];
        changeImageView.right = lastStichimageView.left;
        lastStichimageView = changeImageView;
    }
}
- (void)rightFollow:(StitchingButton *)stichingImageView isIndex:(NSInteger) index{
    /*
     * 右边跟随
     * stichingImageView 需要跟随谁的右边
     * index 从哪一张开始跟随
     */
    StitchingButton *lastStichimageView = stichingImageView;
    for (NSInteger i = index; i < _imageViews.count ; i ++) {
        StitchingButton *changeImageView = self.imageViews[i];
        changeImageView.left = lastStichimageView.right;
        lastStichimageView = changeImageView;
    }
}

-(void)updateContentScrollViewContentSize{
    //更新滚动范围
    StitchingButton *imageView = self.imageViews.lastObject;
    if (_isVerticalCut){
        self.contentScrollView.contentSize = CGSizeMake(VerViewWidth, imageView.bottom);
    }else{
        self.contentScrollView.contentSize = CGSizeMake(imageView.right, HorViewHeight);
    }
}

#pragma mark --图片切割
-(void)userCutBtnClick{
    if (!_slicingBtn.selected){
//        _isSlicing = YES;
        [_slicingBtn setBackgroundImage:IMG(@"切割分界线") forState:UIControlStateNormal];
        NSInteger index = 0;
        for (StitchingButton *imageView in _imageViews) {
            //找到btn所在位置
            if (CGRectContainsPoint(imageView.frame,_slicingBtn.center)){
                _moveIndex = imageView.tag / 100;
                index = _moveIndex - 1;
            }
            [imageView removeFromSuperview];
        }
        //上半部分
        NSMutableArray *topArr = [NSMutableArray array];
        for (NSInteger i = 0 ; i <= index; i ++) {
            [topArr addObject:_imageViews[i]];
        }
        //下半部分
        NSMutableArray *bottomArr = [NSMutableArray array];
        for (NSInteger i = index; i < _imageViews.count; i ++) {
            [bottomArr addObject:_imageViews[i]];
        }
        [_originHeightArr removeAllObjects];
        [_originBottomArr removeAllObjects];
        [_originRightArr removeAllObjects];
        if (_isVerticalCut){
            CGFloat top = [_originTopArr[0]floatValue];
            [_originTopArr removeAllObjects];
            [_imageViews removeAllObjects];
            CGFloat contentHeight = 0.0;
            CGFloat imgHeight = 0.0;
            StitchingButton *icon = topArr[0];
            if (_type == 4){
                SZImageMergeInfo *firstInfo = _gengrator.infos.firstObject;
                if (!firstInfo.firstImage){
                    return;
                }
                imgHeight = firstInfo.firstImage.size.height * (VerViewWidth / firstInfo.firstImage.size.width);
            }else{
                imgHeight = icon.imgView.height;
            }
            StitchingButton *firstImageView = [[StitchingButton alloc]initWithFrame:CGRectMake(0, top, icon.width, imgHeight)];
            firstImageView.image = icon.image;
            contentHeight += firstImageView.height;
            firstImageView.tag = 100;
            [_contentScrollView addSubview:firstImageView];
            [self.originTopArr addObject:[NSNumber numberWithFloat:0]];
            [self.originBottomArr addObject:[NSNumber numberWithFloat:firstImageView.height]];
            [self.originHeightArr addObject:[NSNumber numberWithFloat:firstImageView.height]];
            
            [_imageViews addObject:firstImageView];
            if (_moveIndex == 1){
                //如果是从第一张开始切割
                firstImageView.height = _slicingBtn.top;
            }
            [_originHeightArr addObject:[NSNumber numberWithFloat:firstImageView.height]];
            for (NSInteger i = 1; i < topArr.count; i ++) {
                StitchingButton *icon = topArr[i];
                if (_type != 4){
                    imgHeight = icon.imgView.height;
                }
                StitchingButton *imageView = [[StitchingButton alloc]initWithFrame:CGRectMake(0, firstImageView.bottom, VerViewWidth, imgHeight)];
                imageView.image = icon.image;
                imageView.tag = (i+1) * 100;
                
                [_contentScrollView addSubview:imageView];
                if (i == index){
                    CGFloat bottom = 0.0;
                    CGFloat top = 0.0;
                    if (_moveIndex > 1){
                        bottom = [self.originBottomArr[_moveIndex - 2]floatValue];
                        top = [self.originTopArr[_moveIndex - 2]floatValue];
                    }else{
                        bottom = [self.originBottomArr[_moveIndex - 1]floatValue];
                        top = [self.originTopArr[_moveIndex - 2]floatValue];
                    }
                    imageView.height = bottom - _slicingBtn.bottom;
                    imageView.imgView.top = _slicingBtn.centerY - top;
                }
                contentHeight += imageView.height;
                firstImageView = imageView;
                [_originTopArr addObject:[NSNumber numberWithFloat:firstImageView.top]];
                [_imageViews addObject:imageView];
                [self.originTopArr addObject:[NSNumber numberWithFloat:imageView.top]];
                [self.originBottomArr addObject:[NSNumber numberWithFloat:contentHeight]];
                [self.originHeightArr addObject:[NSNumber numberWithFloat:imageView.height]];
            }
            for (NSInteger i = 0; i < bottomArr.count; i ++) {
                StitchingButton *icon = bottomArr[i];
                if (_type != 4){
                    imgHeight = icon.imgView.height;
                }
                StitchingButton *imageView = [[StitchingButton alloc]initWithFrame:CGRectMake(0,i==0?_slicingBtn.top: firstImageView.bottom, VerViewWidth, imgHeight)];
                imageView.image = icon.image;
                imageView.tag = (index + 1 + i) * 100;
                [_contentScrollView addSubview:imageView];
                if (i == 0){
                    CGFloat bottom = [self.originBottomArr[_moveIndex - 1]floatValue];
                    CGFloat top = [self.originTopArr[_moveIndex - 1]floatValue];
                    imageView.height = bottom - _slicingBtn.centerY;
                    imageView.imgView.top = -(_slicingBtn.top - top);
                }
                contentHeight += imageView.height;
                firstImageView = imageView;
                [_imageViews addObject:imageView];
                [self.originTopArr addObject:[NSNumber numberWithFloat:imageView.top]];
                [self.originBottomArr addObject:[NSNumber numberWithFloat:contentHeight]];
                [self.originHeightArr addObject:[NSNumber numberWithFloat:imageView.height]];
            }
            if (contentHeight < LayoutHeight){
                //内容过小则重置imageView布局
                [self layoutContentViewWithContent:contentHeight];
            }
            [self updateContentScrollViewContentSize];
        }else{
            [_originTopArr removeAllObjects];
            [_imageViews removeAllObjects];
            CGFloat contentWidth = 0.0;
            StitchingButton *icon = topArr[0];
            StitchingButton *firstImageView = [[StitchingButton alloc]initWithFrame:CGRectMake(0,(SCREEN_HEIGHT - 450)/2, (CGFloat)(icon.size.width / icon.size.height) * HorViewHeight, HorViewHeight)];
            firstImageView.image = icon.image;
            contentWidth += firstImageView.width;
            firstImageView.tag = 100;
            [_originRightArr addObject:[NSNumber numberWithFloat:0]];
            [_originTopArr addObject:[NSNumber numberWithFloat:firstImageView.top]];
            [_contentScrollView addSubview:firstImageView];
            [_imageViews addObject:firstImageView];
            if (_moveIndex == 1){
                //如果是从第一张开始切割
                firstImageView.width = _slicingBtn.right;
            }
            
            for (NSInteger i = 1; i < topArr.count; i ++) {
                StitchingButton *icon = topArr[i];
                CGFloat imgWidth = (CGFloat)(icon.size.width/icon.size.height) * HorViewHeight;
                StitchingButton *imageView = [[StitchingButton alloc]initWithFrame:CGRectMake(firstImageView.right, firstImageView.top, imgWidth, HorViewHeight)];
                imageView.image = icon.image;
                imageView.tag = (i+1) * 100;
                contentWidth += imgWidth;
                if (i == index){
                    imageView.width = _slicingBtn.centerX - firstImageView.right;
                }
                [_contentScrollView addSubview:imageView];
                [_originRightArr addObject:[NSNumber numberWithFloat:firstImageView.right]];
                firstImageView = imageView;
                [_imageViews addObject:imageView];
            }
            for (NSInteger i = 0; i < bottomArr.count; i ++) {
                StitchingButton *icon = bottomArr[i];
                CGFloat imgWidth = (CGFloat)(icon.size.width/icon.size.height) * HorViewHeight;
                StitchingButton *imageView = [[StitchingButton alloc]initWithFrame:CGRectMake(i==0?_slicingBtn.left:firstImageView.right, firstImageView.top, imgWidth, HorViewHeight)];
                imageView.image = icon.image;
                imageView.tag = (i+1) * 100;
                contentWidth += imgWidth;
               
                if (i == 0){
                    imageView.width = imageView.right - _slicingBtn.right ;
                    imageView.imgView.left = -(_slicingBtn.right - firstImageView.right);
                }
                firstImageView = imageView;
                [_contentScrollView addSubview:imageView];
                [_originRightArr addObject:[NSNumber numberWithFloat:firstImageView.right]];
                [_imageViews addObject:imageView];
            }
            if (contentWidth < SCREEN_WIDTH){
                //内容过小则重置imageView布局
                [self layoutContentViewWithContent:contentWidth];
            }
            [self updateContentScrollViewContentSize];
        }
        _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(cutPanMoveGesture:)];
        _panGesture.delegate = self;
        [_contentScrollView addGestureRecognizer:_panGesture];
        [_contentScrollView bringSubviewToFront:_slicingBtn];
        self.title = [NSString stringWithFormat:@"%ld张图片",_imageViews.count];
    }else{
       // _isSlicing = NO;
        [_slicingBtn setBackgroundImage:IMG(@"裁切分界线") forState:UIControlStateNormal];
        [_contentScrollView removeGestureRecognizer:_panGesture];
        [_contentScrollView setScrollEnabled:YES];
    }
    _slicingBtn.selected = !_slicingBtn.selected;
    
}
-(void)cutImgMoveGesture:(UIPanGestureRecognizer *)gesture{
    if (_isSlicing){
        CGPoint translatedPoint = [gesture translationInView:self.view];
        if (gesture.state == UIGestureRecognizerStateBegan){
            [_contentScrollView setScrollEnabled:NO];
        }
        if (gesture.state == UIGestureRecognizerStateChanged){

            if (_isVerticalCut){
                if (gesture.view.left + translatedPoint.x <= 0 || gesture.view.right + translatedPoint.x >= SCREEN_WIDTH){
                    gesture.view.left = 0;
                }
                [_slicingBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.contentScrollView);
                    make.width.equalTo(_slicingBtn.mas_width);
                    make.top.equalTo(@(_slicingBtn.top + translatedPoint.y));
                    make.height.equalTo(@30);
                }];
            }else{
                StitchingButton *img = _imageViews.firstObject;
                if (gesture.view.right + translatedPoint.x >= SCREEN_WIDTH){
                    gesture.view.right = SCREEN_WIDTH;
                    return;
                }
                if (gesture.view.left + translatedPoint.x <= 10){
                    gesture.view.left = 10;
                    return;
                }
                [_slicingBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(img.mas_top);
                    make.left.equalTo(@(_slicingBtn.left + translatedPoint.x));
                    make.width.equalTo(@30);
                    make.height.equalTo(img.mas_height);
                }];
            }
            
            [_contentScrollView setScrollEnabled:YES];
        }
        if (gesture.state == UIGestureRecognizerStateEnded){
            //手势结束
            [_contentScrollView setScrollEnabled:YES];
            
        }
        if (self.contentScrollView.isDragging && _isSlicing) {
            return;
        }
        [gesture setTranslation:CGPointMake(0, 0) inView:self.view];
        
    }
}



-(void)cutPanMoveGesture:(UIPanGestureRecognizer *)recognizer{
    CGPoint translatedPoint = [recognizer translationInView:self.view];
    CGFloat offsetP = translatedPoint.y;
    CGPoint locationPoint = [recognizer locationInView:_contentScrollView];
    if (!_isMove){
        if (_isVerticalCut){
            if (locationPoint.y <= _slicingBtn.top){
                _isTopPart = YES;
            }else{
                _isTopPart = NO;
            }
        }else{
            if (locationPoint.x <= _slicingBtn.left){
                _isTopPart = YES;
            }else{
                _isTopPart = NO;
            }
        }
        
    }
    if (recognizer.state == UIGestureRecognizerStateChanged){
        if (!_slicingBtn.isSelected){
            return;
        }else{
            _slicingBtn.hidden = YES;
        }
        _isMove = YES;
        if (_isVerticalCut){
            if(_isTopPart){
                StitchingButton *imageView = self.imageViews[_moveIndex - 1];
                CGFloat viewHeight = [self.originHeightArr[_moveIndex - 1]floatValue];
                CGFloat tmpF = imageView.height - offsetP;
                if (offsetP > 0){
                    if (tmpF <= 0){
                        imageView.height = 0;
                        return;
                    }else{
                        imageView.height = tmpF;
                    }
                }else{
                    if (tmpF >= viewHeight){
                        imageView.bottom = _slicingBtn.top;
                        StitchingButton *lastStichimageView = imageView;
                        for (NSInteger i = _moveIndex - 2; i >= 0; i --) {
                            StitchingButton *changeImageView = self.imageViews[i];

                            changeImageView.top = imageView.top;
                            lastStichimageView = changeImageView;
                        }
                        return;
                    }else{
                        imageView.height = tmpF;
                    }
                }
                imageView.top = offsetP+ imageView.top;
                //顶部跟随
                if (_moveIndex - 2 >= 0){
                    [self topFollow:imageView offsetY:offsetP AndIndex:_moveIndex - 2];
                }
                
            }else{
                if (_moveIndex >= _imageViews.count){
                    return;
                }
                StitchingButton *imageView = self.imageViews[_moveIndex];
                imageView.imgView.top = offsetP+ imageView.imgView.top;
                if (imageView.imgView.bottom <= 0 && offsetP < 0){
                    imageView.height = 0;
                    imageView.imgView.bottom = 0;
                    return;
                }
                if(offsetP > 0 && imageView.imgView.top >= 0){
                    imageView.height = imageView.imgView.height;
                    imageView.imgView.top = 0;
                    return;
                }
                imageView.height = imageView.height + offsetP ;
                //底部跟随
                [self bottomFollow:imageView isIndex:_moveIndex + 1];
            }
        }else{
            //中间部分
            offsetP = translatedPoint.x;
            if (_isTopPart){
                //左边移动
                StitchingButton *imageView = _imageViews[_moveIndex - 1];
                CGFloat tmpF = imageView.width - offsetP;
                if (offsetP > 0 ){
                    if (tmpF <= 0){
                        imageView.width = 0;
                        return;
                    }else{
                        imageView.left = imageView.left + offsetP;
                        imageView.width = tmpF;
                    }
                }else{
                    if (tmpF >= imageView.imgView.width){
                        imageView.width = imageView.imgView.width;
                        return;
                    }else{
                        imageView.left = imageView.left + offsetP;
                        imageView.width = tmpF;
                    }
                }
                //左边跟随
                StitchingButton *lastStichimageView = imageView;
                for (NSInteger i = _moveIndex - 2; i >= 0  ; i --) {
                    StitchingButton *changeImageView = self.imageViews[i];
                    changeImageView.right = lastStichimageView.left;
                    lastStichimageView = changeImageView;
                }
            }else{
                StitchingButton *imageView = _imageViews[_moveIndex];
                CGFloat tmpF = imageView.width + offsetP;
                if (offsetP > 0){
                    if (tmpF > imageView.imgView.width){
                        imageView.width = imageView.imgView.width;
                        return;
                    }else{
                        imageView.imgView.left = imageView.imgView.left + offsetP;
                        imageView.width = tmpF;
                    }
                }else{
                    if (tmpF <= 0){
                        imageView.width = 0;
                        return;
                    }else{
                        imageView.width = tmpF;
                        imageView.imgView.left = imageView.imgView.left + offsetP;
                    }
                }
                //右边跟随
                StitchingButton *lastStichimageView = imageView;
                for (NSInteger i = _moveIndex + 1; i < _imageViews.count ; i ++) {
                    StitchingButton *changeImageView = self.imageViews[i];
                    changeImageView.left = lastStichimageView.right;
                    lastStichimageView = changeImageView;
                }
            }
        }
        
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self updateContentScrollViewContentSize];
        _isMove = NO;
        _slicingBtn.hidden = NO;
    }
    if (self.contentScrollView.isDragging && _isSlicing) {
        return;
    }
    [recognizer setTranslation:CGPointZero inView:recognizer.view.superview];
    
}
-(void)sliderValueChanged:(UISlider *)slider{
    StitchingButton *imageView = self.imageViews[1];
    if (slider.value > _topCurrentValue || slider.value ==  slider.maximumValue){
        CGFloat tmpH = 0.0;
        tmpH = imageView.height - slider.value ;
        if (tmpH <= 0){
            imageView.height = 0;
            return;
        }else{
            imageView.height = tmpH;
        }
        imageView.imgView.top = imageView.imgView.top - slider.value ;
        //底部跟随
        StitchingButton *lastStichimageView = imageView;
        for (NSInteger i = 2; i < _imageViews.count ; i ++) {
            StitchingButton *changeImageView = self.imageViews[i];
            changeImageView.top = lastStichimageView.bottom;
            changeImageView.height = changeImageView.height - slider.value;
            changeImageView.imgView.top = changeImageView.imgView.top - slider.value;
            lastStichimageView = changeImageView;
        }
    }else{
        CGFloat tmpH = 0.0;
        tmpH = imageView.height + slider.value ;
        if (tmpH >= imageView.imgView.height){
            tmpH = imageView.imgView.height;
            imageView.imgView.top = 0;
            return;
        }else{
            imageView.height = tmpH ;
        }
        imageView.imgView.top = imageView.imgView.top + slider.value ;
        
        //底部跟随
        StitchingButton *lastStichimageView = imageView;
        for (NSInteger i = 2; i < _imageViews.count ; i ++) {
            StitchingButton *changeImageView = self.imageViews[i];
            changeImageView.top = lastStichimageView.bottom;
            changeImageView.height = changeImageView.height + slider.value;
            changeImageView.imgView.top = changeImageView.imgView.top + slider.value;
            lastStichimageView = changeImageView;
        }
    }
    _topCurrentValue = slider.value;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat tmpF = 0.0;
    if (_isVerticalCut == YES){
        if (_isStartCut == YES){
            if (_offsetY == 0){
                tmpF = scrollView.contentOffset.y;
            }else{
                tmpF = scrollView.contentOffset.y - _offsetY;
            }
            [_slicingBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.contentScrollView);
                make.width.equalTo(_slicingBtn.mas_width);
                make.top.equalTo(@(_slicingBtn.top + tmpF));
                make.height.equalTo(@30);
            }];
            _offsetY = scrollView.contentOffset.y;
        }
 
    }else{
        if (_isStartCut == YES){
            if (_offsetY == 0){
                tmpF = scrollView.contentOffset.x;
            }else{
                tmpF = scrollView.contentOffset.x - _offsetY;
            }
            [_slicingBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.height.top.equalTo(self.contentScrollView);
                make.left.equalTo(@(_slicingBtn.left + tmpF));
                make.width.equalTo(@30);
            }];
            _offsetY = scrollView.contentOffset.x;
        }
        
    }
}

#pragma mark ----------btnClick && viewDelegateClick-------------
-(void)topBtnClick:(UIButton *)btn{
    MJWeakSelf
    if (btn.tag == 0){
        [_slicingBtn removeFromSuperview];
        [self deleteContentScorllViewSubViews];
        [_guideBtn removeFromSuperview];
        [SVProgressHUD showWithStatus:@"正在生成图片中.."];
        NSLog(@"cgrect==%@",@(_contentScrollView.contentSize));
        [TYSnapshotScroll screenSnapshot:_contentScrollView finishBlock:^(UIImage *snapshotImage) { 
            SaveViewController *saveVC = [SaveViewController new];
            saveVC.screenshotIMG = snapshotImage;
            if (GVUserDe.isAutoSaveIMGAlbum){
                //保存到拼图相册
                [SVProgressHUD showSuccessWithStatus:@"图片已保存至拼图相册中"];
                [Tools saveImageWithImage:saveVC.screenshotIMG albumName:@"拼图" withBlock:^(NSString * _Nonnull identify) {
                    saveVC.identify = identify;
                }];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"图片已保存至系统相册中"];
                if (!GVUserDe.isAutoDeleteOriginIMG){
                    UIImageWriteToSavedPhotosAlbum(snapshotImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
                }
            }
            saveVC.isVer = weakSelf.isVerticalCut;
            saveVC.type = 2;
            [weakSelf.navigationController pushViewController:saveVC animated:YES];
        }];
    }else{
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}


-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSString *msg = nil;
    if (!error) {
        msg = @"保存成功，已为您保存至相册";
    }else {
        msg = @"系统未授权访问您的照片，请您在设置中进行权限设置后重试";
    }
    NSLog(@"msg=%@",msg);
}

-(void)btnClickWithTag:(NSInteger)tag{
    if (tag == 1) {
        [_funcView removeFromSuperview];
        [self.navigationController pushViewController:[BuyViewController new] animated:YES];
    }else{
        //触发购买
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
            [self.view addSubview:_checkProView];
        }
        _checkProView.hidden = NO;
        [self.view bringSubviewToFront:_checkProView];
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
        _checkProView.hidden = YES;
        _checkProView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 550);
        _bgView.hidden = YES;
        [self.navigationController pushViewController:[BuyViewController new] animated:YES];
    }
}
-(void)imgFuntionWithTag:(NSInteger)tag andIMG:(StitchingButton* )imgView andIMGIndex:(NSInteger)index{
    /*
        UIImageOrientationUp,            // 默认方向
        UIImageOrientationDown,          // 180°旋转
        UIImageOrientationLeft,          // 逆时针旋转90°
        UIImageOrientationRight,         // 顺时针旋转90°
        UIImageOrientationUpMirrored,    // 垂直翻转(向上)
        UIImageOrientationDownMirrored,  // 垂直翻转(向下)
        UIImageOrientationLeftMirrored,  // 水平翻转（向左）
        UIImageOrientationRightMirrored, // 水平翻转 （向右）
     */
    UIImage *flipImage;
    if (tag <= 2){
        if (tag == 0){
            //旋转
            flipImage = [Tools image:imgView.imgView.image rotation:UIImageOrientationDown];
        }else if (tag == 1){
            //水平镜像
            flipImage = [Tools turnImageWith:imgView.imgView.image AndType:1 AndisTurn:_isTurn];
            _isTurn = !_isTurn;
        }else{
            //垂直镜像
            flipImage = [Tools turnImageWith:imgView.imgView.image AndType:2 AndisTurn:_isTurn];
        }
        imgView.imgView.image = flipImage;
    }else if (tag == 3){
        //更换图片
        HXCustomNavigationController *nav = [[HXCustomNavigationController alloc] initWithManager:self.manager delegate:self];
        nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
        nav.modalPresentationCapturesStatusBarAppearance = YES;
        [self.view.viewController presentViewController:nav animated:YES completion:nil];
    }else if (tag == 4){
        //删除图片
        if (_imageViews.count <= 1){
            [SVProgressHUD showInfoWithStatus:@"最后一张图片无法删除！"];
            return;
        }
        if (_imgSelectIndex <= _imageViews.count){
            StitchingButton *lastImg = _imageViews[_imgSelectIndex - 1];
            [_imageViews removeObjectAtIndex:_imgSelectIndex];
            [imgView removeFromSuperview];
            for (NSInteger i = _imgSelectIndex; i < _imageViews.count; i ++) {
                StitchingButton *imageView = _imageViews[i];
                imageView.tag = (i + 1) * 100;
                if (_isVerticalCut){
                    //底部跟随
                    imageView.top = lastImg.bottom;
                }else{
                    //右边跟随
                    imageView.left = lastImg.right;
                }
                lastImg = imageView;
            }
            self.title = [NSString stringWithFormat:@"%ld张图片",_imageViews.count];
            [_cutArr removeAllObjects];
            _funcView.hidden = YES;
        }
        
    }else{
        //取消
        for (UIView *vc in imgView.subviews) {
            if (vc.tag >= 1000){
                [vc removeFromSuperview];
            }
        }
        imgView.layer.borderWidth = 0;
        _imageViews[index] = imgView;
        _imgFunctionView.hidden = YES;
        _bottomView.hidden = NO;
        if (_isVerticalCut == YES) {
            [self addVerticalCutView];
        }else{
            [self addHorizontalCutView];
        }  
    }
    
}

-(void)bottomBtnClick:(NSInteger )tag{
    _guideBtn.hidden = YES;
    if (tag == 1){
        if (_type == 2){
            [_contentScrollView removeAllSubviews];
            [self deleteContentScorllViewSubViews];
            [_imageViews removeAllObjects];
            [_originTopArr removeAllObjects];
            [_originBottomArr removeAllObjects];
            [_originRightArr removeAllObjects];
            if ([_bottomView.typeLab.text isEqualToString:@"竖拼"]){
                //竖拼切换成横拼
                _isVerticalCut = NO;
                [_contentScrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(@(SCREEN_WIDTH));
                    make.centerY.equalTo(_contentView);
                    make.height.equalTo(@(HorViewHeight));
                }];
                [self addHorizontalContentView];
                if (_isCut){
                    [self addHorizontalCutView];
                }
            }else{
                //横拼切换成竖屏
                _isVerticalCut = YES;
                [_contentScrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(@(Nav_H));
                    make.centerX.equalTo(_contentView);
                    make.height.equalTo(@(SCREEN_HEIGHT - Nav_HEIGHT - 80));
                    make.width.equalTo(@(VerViewWidth));
                }];
                [self addVerticalContentView];
                if (_isCut){
                    [self addVerticalCutView];
                }
            }
            if (_isSlicing){
                CGFloat top = [_originTopArr[0]floatValue];
                [_slicingBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    if (_isVerticalCut == YES){
                        make.centerX.centerY.equalTo(self.view);
                        make.width.equalTo(@(VerViewWidth));
                        make.height.equalTo(@30);
                    }else{
                        make.height.equalTo(@(HorViewHeight));
                        make.width.equalTo(@30);
                        make.top.equalTo(@(top));
                        make.centerX.equalTo(self.view);
                        [_slicingBtn setBackgroundImage:IMG(@"横切裁切分界线") forState:UIControlStateNormal];
                    }
                }];
            }
        }else if (_type == 3 || _type == 4) {
            if ([_bottomView.typeLab.text isEqualToString:@"擦除滚动条"]){
                //恢复滚动条
                if (_type == 4){
                    for (StitchingButton *btn in self.imageViews) {
                        btn.imgView.left = 0;
                    }
                }
                
            }else{
                //擦除滚动条
                if (_type == 4){
                    for (StitchingButton *btn in self.imageViews) {
                        btn.imgView.left = 5;
                    }
                }
            }
        }else{
            _isCut = NO;
            _adjustView.hidden = !_adjustView.hidden;
            _slicingBtn.hidden = YES;
        }
        
    }else{
        _adjustView.hidden = YES;
        _slicingBtn.hidden = YES;
        if (tag == 2){
            //裁切
            _isSlicing = NO;
            if ([_bottomView.preLab.text isEqualToString:@"预览"]){
                _isCut = YES;
                _slicingBtn.hidden = YES;
                if (_type != 4){
                    if (_isVerticalCut){
                        [self addVerticalCutView];
                    }else{
                        [self addHorizontalCutView];
                    }
                }else{
                    //长图裁切
                    [self addVerticalCutView];
                }
                
                
            }else{
                _guideBtn.hidden = YES;
                _isCut = NO;
                _isStartCut = NO;
                [_contentScrollView removeGestureRecognizer:_panGesture];
                [self deleteContentScorllViewSubViews];
                
            }
            
        }else if (tag == 3){
            _guideBtn.hidden = YES;
            _isCut = NO;
            [self deleteContentScorllViewSubViews];
            if (!_isSlicing){
                if (_slicingBtn == nil){
                    _slicingBtn = [UIButton buttonWithType:UIButtonTypeSystem];
                    _slicingBtn.selected = NO;
                    [_slicingBtn addTarget:self action:@selector(userCutBtnClick) forControlEvents:UIControlEventTouchUpInside];
                    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(cutImgMoveGesture:)];
                    panGes.delegate = self;
                    [_slicingBtn addGestureRecognizer:panGes];    
                }
                [self.contentScrollView addSubview:_slicingBtn];
                [self.contentScrollView bringSubviewToFront:_slicingBtn];
                _slicingBtn.hidden = NO;
                if (_isVerticalCut){
                    [_slicingBtn setBackgroundImage:IMG(@"裁切分界线") forState:UIControlStateNormal];
                    [_slicingBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.centerX.centerY.equalTo(_contentScrollView);
                        make.width.equalTo(@(VerViewWidth));
                        make.height.equalTo(@30);
                    }];
                    
                }else{
                    [_slicingBtn setBackgroundImage:IMG(@"横切裁切分界线") forState:UIControlStateNormal];
                    [_slicingBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.height.equalTo(@(HorViewHeight));
                        make.width.equalTo(@30);
                        make.centerX.equalTo(self.contentScrollView.mas_centerX);
                        make.centerY.equalTo(self.contentScrollView.mas_centerY);
                    }];
                }
                
            }else{
                [self.contentScrollView setScrollEnabled:YES];
                [_contentScrollView removeGestureRecognizer:_panGesture];
                _slicingBtn.hidden = YES;
            }
            _isSlicing = !_isSlicing;
        }else{
            //编辑
            _isCut = NO;
            __block ImageEditViewController *vc = [ImageEditViewController new];
            vc.isVer = _isVerticalCut;
            vc.type = _type;
            vc.titleStr = self.title;
            if (_type == 4){
                vc.imgArr = _editImgArr;
            }else{
                vc.imgArr = _dataArr;
            }
            [self.navigationController pushViewController:vc animated:YES];    
        }
    }
    
}

-(UIImage *)changeIMGWithImageName:(NSString *)name{
    UIImage *newImage = IMG(name);
    newImage = [newImage stretchableImageWithLeftCapWidth:10 topCapHeight:5];
    return newImage;
}

-(void)deleteContentScorllViewSubViews{
    for (UIView *vc in _contentScrollView.subviews) {
        if (vc.tag >= 10000){
            [vc removeFromSuperview];
        }
    }
    for (StitchingButton *img in _imageViews) {
        img.layer.borderWidth = 0;
    }
    [_leftCutBtn removeFromSuperview];
    [_rightCutBtn removeFromSuperview];
}
-(void)guideBtnClick:(UIButton *)btn{
    _guideBtn.hidden = YES;
    if (_isVerticalCut){
        [self addVerticalCutView];
    }else{
        [self addHorizontalCutView];
    }
    _isCut = NO;
    _isStartCut = NO;
    [_contentScrollView removeGestureRecognizer:_panGesture];
}



#pragma mark --photoViewDelegate

-(HXPhotoView *)photoView{
    if (!_photoView){
        _photoView = [HXPhotoView photoManager:self.manager scrollDirection:UICollectionViewScrollDirectionVertical];
        _photoView.frame = CGRectMake(0, 12, SCREEN_WIDTH, 0);
        _photoView.collectionView.contentInset = UIEdgeInsetsMake(0, 12, 0, 12);
        _photoView.delegate = self;
        _photoView.outerCamera = NO;
        _photoView.previewStyle = HXPhotoViewPreViewShowStyleDark;
        _photoView.previewShowDeleteButton = YES;
        _photoView.showAddCell = YES;
        [_photoView.collectionView reloadData];
        _photoView.hidden = YES;
        [self.contentScrollView addSubview:_photoView];
    }
    return _photoView;
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
    MJWeakSelf
    for (HXPhotoModel *photoModel in result.models) {
        [Tools getImageWithAsset:photoModel.asset withBlock:^(UIImage * _Nonnull image) {
            NSInteger index = [weakSelf.imageViews indexOfObject:weakSelf.selectIMG];
            weakSelf.selectIMG.image = image;
            weakSelf.imageViews[index] = weakSelf.selectIMG;
        }];
    }
}

#pragma mark -- scrollviewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _isScrollViewScroll = YES;
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    _isScrollViewScroll = NO;
}
#pragma mark --lazy
-(NSMutableArray *)editLabArr{
    if (!_editLabArr){
        _editLabArr = [[NSMutableArray alloc]init];
    }
    return _editLabArr;
}

-(NSMutableArray *)originTopArr{
    if (!_originTopArr){
        self.originTopArr = [NSMutableArray array];
    }
    return _originTopArr;
}
-(NSMutableArray *)originRightArr{
    if (!_originRightArr){
        self.originRightArr = [NSMutableArray array];
    }
    return _originRightArr;
}
-(NSMutableArray *)originBottomArr{
    if (!_originBottomArr){
        self.originBottomArr = [NSMutableArray array];
    }
    return _originBottomArr;
}
-(NSMutableArray *)originHeightArr{
    if (!_originHeightArr){
        self.originHeightArr = [NSMutableArray array];
    }
    return _originHeightArr;
}
-(NSMutableArray *)imageViews{
    if (!_imageViews){
        self.imageViews = [NSMutableArray array];
    }
    return _imageViews;
}
-(NSMutableArray *)originWidthArr{
    if (!_originWidthArr){
        self.originWidthArr = [NSMutableArray array];
    }
    return _originWidthArr;
}



@end
