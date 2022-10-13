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

#define MaxSCale 2.5  //最大缩放比例
#define MinScale 0.5  //最小缩放比例

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
@property (nonatomic ,strong)UIImageView *adjustView;
@property (nonatomic ,strong)UIImageView *guideIMG;
@property (nonatomic ,strong)UIButton *cutBtn;


@property (nonatomic ,strong)NSMutableArray *originTopArr;
@property (nonatomic ,strong)NSMutableArray *originBottomArr;
@property (nonatomic ,strong)NSMutableArray *originRightArr;
@property (nonatomic ,strong)NSMutableArray *imageViews;
@property (nonatomic ,strong)NSMutableArray *cutArr;
@property (nonatomic ,strong)NSMutableArray *editLabArr;

@property (nonatomic ,assign)CGPoint moveP;
@property (nonatomic ,assign)CGFloat offsetY;
@property (nonatomic ,assign)CGFloat topCurrentValue;
@property (nonatomic ,assign)CGFloat bottomCurrentValue;

@property (nonatomic ,strong)UIPanGestureRecognizer *panGesture;

@property (nonatomic ,assign)BOOL isTopPart;//是否是上半部分
@property (nonatomic ,assign)BOOL isCut; //是否在裁剪
@property (nonatomic ,assign)BOOL isMove;//是否在移动
@property (nonatomic ,assign)BOOL isSlicing;//是否正在切割
@property (nonatomic ,assign)BOOL isVerticalCut;//是否竖切，默认竖切
@property (nonatomic ,assign)BOOL isTurn;
@property (nonatomic ,assign)BOOL isStartCut;//是否开始剪切


@property (nonatomic ,assign)NSInteger posizition;
@property (nonatomic ,assign)NSInteger imgSelectIndex;
@property (nonatomic ,assign)NSInteger moveIndex;


@property (nonatomic ,strong)UIPanGestureRecognizer *panRecognizer;
@property (nonatomic ,strong)UIPinchGestureRecognizer *pinchRecognizer;

@property (nonatomic, strong)SZImageGenerator *generator;
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
    _topCurrentValue = 0;
    _offsetY = 0.0;
    _isCut = NO;
    _isMove = NO;
    _isSlicing = NO;
    _isVerticalCut = YES;
    _isTurn = NO;
    _imgSelectIndex = MAXFLOAT;
    _isStartCut = NO;
    [self setupViews];
    [self setupNavItems];
    [self addBottomView];
    _pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [_contentView addGestureRecognizer:_pinchRecognizer];

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
    XWNavigationController *nav = (XWNavigationController *)self.navigationController;
    [nav addNavBarShadowImageWithColor:[UIColor blackColor]];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    UIColor *color = [UIColor blackColor];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [Tools setNaviBarBKColorWith:self.navigationController andBKColor:[UIColor whiteColor] andFontColor:[UIColor blackColor]];
    XWNavigationController *nav = (XWNavigationController *)self.navigationController;
        [nav addNavBarShadowImageWithColor:RGB(255, 255, 255)];
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
        make.centerX.width.equalTo(_contentView);
        make.height.equalTo(@(SCREEN_HEIGHT - Nav_H));
    }];
    if (_type != 4){
        [self addVerticalContentView];
        if (_type == 1){
            [self addadjustView];
        }
    }else{
        //长图拼接
        [SVProgressHUD showWithStatus:@"图片正在拼接中..."];
        _queue = dispatch_queue_create("com.chenshaozhe.image.queue", 0);
        [self mergeImages:_dataArr
               completion:^(SZImageGenerator *generator, NSError *error) {
            generator.error = error;
            [weakSelf stitchImgWith:generator];
        }];
    }
    
}

-(void)addVerticalContentView{
    //竖拼
    CGFloat contentHeight = 0.0;
    UIImage *icon = _dataArr[0];
    StitchingButton *firstImageView = [[StitchingButton alloc]initWithFrame:CGRectMake(0, 0, VerViewWidth, (CGFloat)(icon.size.height/icon.size.width) * VerViewWidth)];
    firstImageView.image = icon;
    firstImageView.centerX = self.view.centerX;
    firstImageView.userInteractionEnabled = YES;
    contentHeight += firstImageView.height;
    firstImageView.tag = 100;
    [_contentScrollView addSubview:firstImageView];
    [self.originTopArr addObject:[NSNumber numberWithFloat:0]];
    [self.originBottomArr addObject:[NSNumber numberWithFloat:firstImageView.height]];
    [self.imageViews addObject:firstImageView];
    for (NSInteger i = 1; i < _dataArr.count; i ++) {
        UIImage *icon = _dataArr[i];
        CGFloat imgHeight = (CGFloat)(icon.size.height/icon.size.width) * VerViewWidth;
        StitchingButton *imageView = [[StitchingButton alloc]initWithFrame:CGRectMake(0, firstImageView.bottom, VerViewWidth, imgHeight)];
        imageView.image = icon;
        imageView.userInteractionEnabled = YES;
        imageView.centerX = firstImageView.centerX;
        imageView.tag = (i+1) * 100;
        contentHeight += imgHeight;
        [_contentScrollView addSubview:imageView];
        firstImageView = imageView;
        [self.originTopArr addObject:[NSNumber numberWithFloat:firstImageView.top]];
        [self.imageViews addObject:imageView];
        [self.originBottomArr addObject:[NSNumber numberWithFloat:contentHeight]];
        
    }
    _contentScrollView.contentSize = CGSizeMake(_contentScrollView.width,contentHeight);
    if (contentHeight < SCREEN_HEIGHT){
        //内容过小则重置imageView布局
        [self layoutContentView];
    }else{
        _contentScrollView.contentSize = CGSizeMake(_contentScrollView.width,contentHeight + Nav_HEIGHT + 80);
    }
}

//横拼
-(void)addHorizontalContentView{
    [_contentScrollView removeAllSubviews];
    CGFloat contentWidth = 0.0;
    UIImage *icon = _dataArr[0];
    StitchingButton *firstImageView = [[StitchingButton alloc]initWithFrame:CGRectMake(0,(SCREEN_HEIGHT - 450)/2, (CGFloat)(icon.size.width / icon.size.height) * HorViewHeight, HorViewHeight)];
    firstImageView.image = icon;
    contentWidth += firstImageView.width;
    firstImageView.tag = 100;
    [self.originRightArr addObject:[NSNumber numberWithFloat:0]];
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
        firstImageView = imageView;
        [_imageViews addObject:imageView];
        
    }
    _contentScrollView.contentSize = CGSizeMake(contentWidth,SCREEN_HEIGHT - 80 - Nav_H);
}

-(void)layoutContentView{
    NSInteger centenIndex = _imageViews.count / 2;
    CGFloat alignPointY = 0.0;
    StitchingButton *lastIMG;
    if (_imageViews.count < 5){
        centenIndex += 1;
    }
    for (NSInteger i = centenIndex - 1; i >= 0; i --) {
        StitchingButton *img = _imageViews[i];
        if (i == centenIndex - 1){
            img.bottom = self.view.centerY;
            alignPointY = img.bottom;
        }else{
            img.bottom = lastIMG.top;
        }
        lastIMG = img;
        _originTopArr[i] = [NSNumber numberWithFloat:img.top];
        _imageViews[i] = img;
    }
    for (NSInteger i = centenIndex; i < _imageViews.count; i ++) {
        StitchingButton *img = _imageViews[i];
        if (i == centenIndex){
            img.top = alignPointY;
        }else{
            img.top = lastIMG.bottom;
        }
        lastIMG = img;
        _originTopArr[i] = [NSNumber numberWithFloat:img.top];
        _imageViews[i] = img;
    }
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
    [saveBtn addTarget:self action:@selector(TopBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc]initWithCustomView:saveBtn];
    self.navigationItem.rightBarButtonItem = saveItem;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    leftBtn.tag = 1;
    [leftBtn setBackgroundImage:IMG(@"stitch_white_back") forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(TopBtnClick:) forControlEvents:UIControlEventTouchUpInside];
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
    for (NSInteger i = 0; i < _imageViews.count ; i ++) {
        StitchingButton *img = _imageViews[i];
        img.userInteractionEnabled = YES;
        if (img == nil){
            break;
        }
        NSArray *btnArr = @[@"上裁切线",@"左裁切线",@"下裁切线",@"右裁切线"];
        for (NSInteger j = 0 ; j < btnArr.count; j ++ ) {
            UIButton *cutBtn = [UIButton buttonWithType:UIButtonTypeSystem];
            [cutBtn addTarget:self action:@selector(cutBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            cutBtn.tag = j + (i + 1) * 100;
            [cutBtn setBackgroundImage:IMG(btnArr[j]) forState:UIControlStateNormal];
            if (j == 0 && i != 0){
                [cutBtn setBackgroundImage:nil forState:UIControlStateNormal];
            }
            [_cutArr addObject:cutBtn];
            [img addSubview:cutBtn];
            [img bringSubviewToFront:cutBtn];
            [cutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                if (j == 0){
                    make.centerX.width.top.equalTo(img);
                    make.height.equalTo(@20);
                }else if (j == 1){
                    make.height.left.top.equalTo(img);
                    make.width.equalTo(@20);
                }else if (j == 2){
                    make.width.left.bottom.equalTo(img);
                    make.height.equalTo(@20);
                }else{
                    make.top.height.right.equalTo(img);
                    make.width.equalTo(@20);
                }
            }];
        }
    }
}

-(void)addHorizontalCutView{
    for (NSInteger i = 0; i < _imageViews.count ; i ++) {
        StitchingButton *img = _imageViews[i];
        img.userInteractionEnabled = YES;
        NSArray *btnArr = @[@"左裁切线",@"右裁切线"];
        for (NSInteger j = 0 ; j < btnArr.count; j ++ ) {
            UIButton *cutBtn = [UIButton buttonWithType:UIButtonTypeSystem];
            cutBtn.tag = j + (i + 1) * 100;
            [cutBtn setBackgroundImage:IMG(btnArr[j]) forState:UIControlStateNormal];
            if (j == 0 && i != 0){
                [cutBtn setBackgroundImage:nil forState:UIControlStateNormal];
            }else{
                [cutBtn addTarget:self action:@selector(HorizontalCutBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            }
            [_cutArr addObject:cutBtn];
            [img addSubview:cutBtn];
            [img bringSubviewToFront:cutBtn];
            [cutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                if (j == 0){
                    make.height.left.top.equalTo(img);
                    make.width.equalTo(@20);
                }else{
                    make.top.height.right.equalTo(img);
                    make.width.equalTo(@20);
                }
            }];
        }
    }
}



#pragma mark Touches
- (CGPoint)pointWithTouches:(NSSet *)touches{
    UITouch *touch = [touches anyObject];
    return [touch locationInView:_contentScrollView];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint moveP = [self pointWithTouches:touches];
    MJWeakSelf
    if (_isCut){
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
            [weakSelf imgFuntionWithTag:tag andIMG:imgView];
        };
        for (StitchingButton *img in _imageViews) {
            for (UIView *vc in img.subviews) {
                if ([vc isMemberOfClass:[UIButton class]]){
                    [vc removeAllSubviews];
                }
            }
        }
        if (_imgSelectIndex != index && _imgSelectIndex != MAXFLOAT){
            for (UIView *vc in _selectIMG.subviews) {
                if (vc.tag >= 1000){
                    [vc removeFromSuperview];
                }
            }
        }
        NSArray *btnArr = @[@"上裁切线",@"左裁切线",@"下裁切线",@"右裁切线"];
        for (NSInteger i = 0 ;i < btnArr.count; i ++) {
            UIImageView *line = [UIImageView new];
            line.tag = (i + 1) * 1000;
            line.image = IMG(btnArr[i]);
            [imgView addSubview:line];
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                if (i == 0){
                    make.centerX.width.top.equalTo(imgView);
                    make.height.equalTo(@20);
                }else if (i == 1){
                    make.height.left.top.equalTo(imgView);
                    make.width.equalTo(@20);
                }else if (i == 2){
                    make.width.left.bottom.equalTo(imgView);
                    make.height.equalTo(@20);
                }else{
                    make.top.height.right.equalTo(imgView);
                    make.width.equalTo(@20);
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

#pragma mark --------- Method------------
#pragma mark - 合并图片
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
                    weakSelf.generator = generator;
                    
                }
            });
        });
}

/*
 * @description assets数组生成获取图片，并开始合并
 */
- (SZImageGenerator *)imageGeneratorBy:(NSArray *)assets{
    NSMutableArray *images = [NSMutableArray array];
    for (PHAsset *asset in assets) {
      [Tools getImageWithAsset:asset withBlock:^(UIImage * _Nonnull image) {
          [images addObject:image];
      }];
    }
    if (!images.count) {
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
    _resultView = [StitchResultView new];
    _resultView.generator = generator;
    [_contentScrollView addSubview:_resultView];
    [_resultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(VerViewWidth));
        make.top.equalTo(@10);
        make.centerX.equalTo(_contentView.mas_centerX);
        make.height.equalTo(@(_contentScrollView.height - 100));
    }];
    [_contentScrollView setContentSize:CGSizeMake(_contentScrollView.width, _resultView.scrollView.contentSize.height + 80)];
   // self.imageViews = _resultView.imageViews;
    [SVProgressHUD showSuccessWithStatus:@"拼接完成"];
    StitchingButton *imageView;
    for (StitchingButton *img in _resultView.imageViews) {
        imageView = img;
        imageView.imgView = img.imageView;
        [self.imageViews addObject:imageView];
        [self.originTopArr addObject:[NSNumber numberWithFloat:img.top]];
        [self.originBottomArr addObject:[NSNumber numberWithFloat:img.height]];
    }
}


#pragma mark -- 图片竖屏裁切
-(void)cutBtnClick:(UIButton *)btn{
    //判断了哪一边
    NSInteger posizition = btn.tag % 100;
    //判断了点击第几行
    NSInteger index = btn.tag / 100 ;
//    NSLog(@"index==%ld",index);
    if (_isStartCut){
        _guideIMG.hidden = YES;
    }
    if (!_isStartCut){
        for (StitchingButton *img in _imageViews) {
            for (UIView *vc in img.subviews) {
                if ([vc isMemberOfClass:[UIButton class]]){
                    [vc removeAllSubviews];
                }
            }
        }
        _guideIMG.hidden = NO;
        //点击了左右则全部一起移动 ，点击了中间按钮则上下都可移动
        _posizition = posizition;
        if (posizition == 1 || posizition == 3){
            //点击了左右
            [self moveIMGWithIndex:index andPosizion:posizition];
        }else{
            if (posizition == 0){
                //点击了第一个则只能移动第一张
                if (index == 1){
                    //第一张整体偏移往上
                    [self moveIMGWithIndex:index andPosizion:posizition];
                }
            }else{
                if (index == 1){
                    //点击了第一张的下部分编辑开关
                    _moveIndex = 2;
                }
                [self moveIMGWithIndex:index andPosizion:posizition];
                
            }
        }
        _isStartCut = YES;
    }else{
        //取消
        _isStartCut = NO;
        for (StitchingButton *img in _imageViews) {
            for (UIView *vc in img.subviews) {
                if ([vc isMemberOfClass:[UIButton class]]){
                    [vc removeAllSubviews];
                }
            }
        }
    }
    
    
}

-(void)HorizontalCutBtnClick:(UIButton *)btn{
    //判断了哪一边
    NSInteger posizition = btn.tag % 100;
    //判断了点击第几行
    NSInteger index = btn.tag / 100 ;
    NSLog(@"posizition==%ld",posizition);
    NSLog(@"index==%ld",index);
    for (StitchingButton *img in _imageViews) {
        for (UIView *vc in img.subviews) {
            if ([vc isMemberOfClass:[UIButton class]]){
                [vc removeAllSubviews];
            }
        }
    }
    if (posizition == 0 && index == 1){
        index = 1;
    }else if (posizition == 1 && index == 1){
        index = 2;
    }else{
        index = index + 1;
    }
    [self moveHorizontalImgWithIndex:index];
    
    
}
-(void)moveIMGWithIndex:(NSInteger )index andPosizion:(NSInteger )posizion{
    if (posizion == 2 && index == 1){
        _moveIndex = 2;
    }else{
        _moveIndex = index;
    }
    _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panMoveGesture:)];
    _panGesture.delegate = self;
    [_contentScrollView addGestureRecognizer:_panGesture];
    if (_type == 4){
        _resultView.scrollView.scrollEnabled = NO;
    }
    if (_guideIMG == nil){
        _guideIMG = [UIImageView new];
        _guideIMG.layer.zPosition = MAXFLOAT;
        [_contentScrollView addSubview:_guideIMG];
        [_contentScrollView bringSubviewToFront:_guideIMG];
    }
    _guideIMG.hidden = NO;
    [self.view bringSubviewToFront:_guideIMG];
    StitchingButton *img = [StitchingButton new];
    CGFloat top = 0.0;
    if ((index == 1 && posizion == 0)){
        img = _imageViews[0];
        _moveIndex = 0;
    }else if((index == 1 && posizion == 2)){
        img = _imageViews[index];
        _moveIndex = 1;
        top = img.top - 20;
    }else{
        if (index == _imageViews.count){
            img = _imageViews[index - 1];
            top = img.bottom - 20;
        }else{
            img = _imageViews[index];
            top = img.top - 20;
        }
    }
    [_guideIMG mas_remakeConstraints:^(MASConstraintMaker *make) {
        switch (posizion) {
            case 0:
                _guideIMG.image = IMG(@"顶部裁切分界线");
                make.width.top.equalTo(img);
                make.left.equalTo(img);
                make.height.equalTo(@20);
                break;
            case 1:
                _guideIMG.image = IMG(@"左裁切分界线");
                if (_contentScrollView.contentSize.height > _contentScrollView.height){
                    make.height.equalTo(@(_contentScrollView.height));
                }else{
                    make.height.equalTo(@(_contentScrollView.contentSize.height));
                }
                make.top.equalTo(_contentScrollView);
                make.left.equalTo(img);
                make.width.equalTo(@30);
                break;
            case 2:
                _guideIMG.image = IMG(@"下裁切分界线");
                make.width.equalTo(img.mas_width);
                make.left.equalTo(img);
                if (_moveIndex == _imageViews.count){
                    make.bottom.equalTo(@(_contentScrollView.contentSize.height));
                }else{
                    make.top.equalTo(@(top));
                }
                make.height.equalTo(@20);
                break;
            case 3:
                _guideIMG.image = IMG(@"右裁切分界线");
                if (_contentScrollView.contentSize.height > _contentScrollView.height){
                    make.height.equalTo(@(_contentScrollView.height));
                }else{
                    make.height.equalTo(@(_contentScrollView.contentSize.height));
                }
                
                make.right.equalTo(img);
                make.width.equalTo(@30);
                make.top.equalTo(_contentScrollView);
                break;
            default:
                break;
        }
    }];
}


//保证拖动手势和UIScrollView上的拖动手势互不影响
-(BOOL)gestureRecognizer:(UIGestureRecognizer*) gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer{
    if ([gestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
        return NO;
    }else {
        return YES;
    }
}
-(void)panMoveGesture:(UIPanGestureRecognizer *)recognizer{
    CGPoint translatedPoint = [recognizer translationInView:self.view];
    CGPoint locationPoint = [recognizer locationInView:recognizer.view];
    if (!_isMove){
        for (StitchingButton *imageView in _imageViews) {
            if (CGRectContainsPoint(imageView.frame,locationPoint)){
                if (_isVerticalCut == YES){
                    if (imageView.tag / 100 <= _moveIndex){
                        _isTopPart = YES;
                    }else{
                        _isTopPart = NO;
                    }
                }else{
                    if (imageView.tag / 100 < _moveIndex){
                        _isTopPart = YES;
                    }else{
                        _isTopPart = NO;
                    }
                }
                
            }
        }
    }
    if (recognizer.state == UIGestureRecognizerStateChanged){
        _guideIMG.hidden = YES;
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
                [self horizontalMoveWithoffsetP:translatedPoint.x];
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
            _guideIMG.hidden = NO;
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
//                imageView.width = imageView.width - offsetP;
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
                        imageView.width = 0;
                        imageView.centerX = _contentView.centerX;
                       // return;
                    }else{
                        imageView.width = tmpF;
                    }
                }
                imageView.left = imageView.left + offsetP;
            }
            
        }
    }else{
        if (_moveIndex == 0){
             //移动第一张顶部
            //点击了顶部 整体偏移往上
            StitchingButton *imageView = self.imageViews[_moveIndex];
            if ((offsetP < 0 && imageView.imgView.bottom < 0) || (offsetP > 0 && imageView.imgView.top > 0) ){
                return;
            }
            CGFloat tmpF = imageView.height + offsetP;
            imageView.height = tmpF  ;
            imageView.imgView.top = offsetP+ imageView.imgView.top;
            //底部跟随
            StitchingButton *lastStichimageView = imageView;
            for (NSInteger i = 1; i < _imageViews.count ; i ++) {
                StitchingButton *changeImageView = self.imageViews[i];
                changeImageView.top = changeImageView.top + offsetP;
                lastStichimageView = changeImageView;
            }
        }else if (_moveIndex == 1){
            //移动第一张下部分编辑
            if(_isTopPart){
                StitchingButton *imageView = self.imageViews[_moveIndex - 1];
                CGFloat tmpF = imageView.height - offsetP;
                if (offsetP > 0){
                    if (tmpF <= 0){
                        imageView.height = 0;
                    }else{
                        imageView.height = tmpF;
                    }
                }else{
                    if (tmpF >= imageView.imgView.height) {
                        imageView.height = imageView.imgView.height;
                        imageView.top = [_originTopArr[0]floatValue];
                        return;
                    }else{
                        imageView.height = tmpF;
                    }
                }
                imageView.top = imageView.top + offsetP;
                
            }else{
                StitchingButton *imageView = self.imageViews[_moveIndex];
                if ((imageView.imgView.bottom <= 0 && offsetP < 0)|| (offsetP > 0 && imageView.imgView.top >= 0)){
                    return;
                }
                imageView.height = imageView.height + offsetP ;
                imageView.imgView.top = offsetP+ imageView.imgView.top;
                //底部跟随
                StitchingButton *lastStichimageView = imageView;
                for (NSInteger i = _moveIndex + 1; i < _imageViews.count ; i ++) {
                    StitchingButton *changeImageView = self.imageViews[i];
                    changeImageView.top = lastStichimageView.bottom;
                    lastStichimageView = changeImageView;
                }
            }
           
        }else if (_moveIndex == _imageViews.count){
            //编辑最后一个不能超过他原先的top
            StitchingButton *imageView = self.imageViews[_moveIndex - 1];
            imageView.height = imageView.height - offsetP;
            if (imageView.height <= 0){
                imageView.height = 0;
                return;
            }
            if(offsetP < 0 && imageView.height >= imageView.imgView.height){
                imageView.height = imageView.imgView.height;
                return;
            }
            imageView.top = offsetP+ imageView.top;
    //        //顶部跟随
            for (NSInteger i = _moveIndex - 2; i >= 0; i --) {
                StitchingButton *changeImageView = self.imageViews[i];
                changeImageView.top = changeImageView.top + offsetP;
            }
        }else{
            if(_isTopPart){
                StitchingButton *imageView = self.imageViews[_moveIndex - 1];
                CGFloat tmpF = imageView.height - offsetP;
                if (offsetP > 0){
                    if (tmpF < 0){
                        imageView.height = 0;
                        return;
                    }else{
                        imageView.height = tmpF;
                    }
                }else{
                    if (tmpF >= imageView.imgView.height){
                        imageView.height = imageView.imgView.height;
                        imageView.top = [_originTopArr[_moveIndex - 1] floatValue];
                        return;
                    }else{
                        imageView.height = tmpF;
                    }
                }
                imageView.top = imageView.top + offsetP;
              //顶部跟随
                StitchingButton *lastStichimageView = imageView;
                for (NSInteger i = _moveIndex - 2; i >= 0; i --) {
                    StitchingButton *changeImageView = self.imageViews[i];
                    changeImageView.bottom = lastStichimageView.top;
                    changeImageView.height = changeImageView.imgView.height;
                    changeImageView = lastStichimageView;
                }
            }else{
                StitchingButton *imageView = self.imageViews[_moveIndex];
                if ((imageView.imgView.bottom <= 0 && offsetP < 0)|| (offsetP > 0 && imageView.imgView.top >= 0)){
                    return;
                }
                imageView.height = imageView.height + offsetP ;
                imageView.imgView.top = offsetP+ imageView.imgView.top;
                //底部跟随
                StitchingButton *lastStichimageView = imageView;
                for (NSInteger i = _moveIndex + 1; i < _imageViews.count ; i ++) {
                    StitchingButton *changeImageView = self.imageViews[i];
                    changeImageView.top = lastStichimageView.bottom;
                    lastStichimageView = changeImageView;
                }
            }
        }
    }
}



#pragma mark --图片横拼裁切
-(void)moveHorizontalImgWithIndex:(NSInteger )index{
    _moveIndex = index;
    _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panMoveGesture:)];
    _panGesture.delegate = self;
    [_contentScrollView addGestureRecognizer:_panGesture];
    if (_guideIMG == nil){
        _guideIMG = [UIImageView new];
        _guideIMG.image = IMG(@"左裁切分界线");
        _guideIMG.layer.zPosition = MAXFLOAT;
        [_contentScrollView addSubview:_guideIMG];
        [_contentScrollView bringSubviewToFront:_guideIMG];
    }
    _guideIMG.hidden = NO;
    [self.view bringSubviewToFront:_guideIMG];
    StitchingButton *img = _imageViews[_moveIndex - 1];
    if (index == 2){
        img = _imageViews[0];
    }
    [_guideIMG mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (index == 2){
            make.right.top.height.equalTo(img);
            _guideIMG.image = IMG(@"右裁切分界线");
        }else{
            make.left.top.height.equalTo(img);
            _guideIMG.image = IMG(@"左裁切分界线");
        }
        make.width.equalTo(@20);
    }];
}
-(void)horizontalMoveWithoffsetP:(CGFloat)offsetP{
    if (_moveIndex == 1){
        //移动最左边
        StitchingButton *imageView = _imageViews[_moveIndex - 1];
        CGFloat tmpF = imageView.width + offsetP;
        if (offsetP < 0){
            if (tmpF <= 0){
                imageView.width = 0;
                return;
            }else{
                imageView.imgView.left = imageView.imgView.left + offsetP;
               // imageView.width = imageView.width + offsetP;
            }
        }else{
            if (tmpF > imageView.imgView.width){
                imageView.width = imageView.imgView.width;
                imageView.left = 0;
                return;
            }else{
                imageView.imgView.left = imageView.imgView.left + offsetP;
            }
        }
        imageView.width = tmpF;
        //右边跟随
        StitchingButton *lastStichimageView = imageView;
        for (NSInteger i = _moveIndex; i < _imageViews.count ; i ++) {
            StitchingButton *changeImageView = self.imageViews[i];
            changeImageView.left = lastStichimageView.right;
            lastStichimageView = changeImageView;
        }
       
    }else if(_moveIndex == _imageViews.count + 1){
        //移动最后一张右边 只能
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
        for (NSInteger i = _imageViews.count - 2; i >= 0  ; i --) {
            StitchingButton *changeImageView = self.imageViews[i];
            changeImageView.right = lastStichimageView.left;
            lastStichimageView = changeImageView;
        }
    }else{
        //中间部分
        if (_isTopPart){
            //左边移动
            StitchingButton *imageView = _imageViews[_moveIndex - 2];
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
                    imageView.left = [_originRightArr[_moveIndex - 2] floatValue];
                    return;
                }else{
                    imageView.left = imageView.left + offsetP;
                    imageView.width = tmpF;
                }
            }
            //左边跟随
            StitchingButton *lastStichimageView = imageView;
            for (NSInteger i = _moveIndex - 3; i >= 0  ; i --) {
                StitchingButton *changeImageView = self.imageViews[i];
                changeImageView.right = lastStichimageView.left;
                lastStichimageView = changeImageView;
            }
        }else{
            StitchingButton *imageView = _imageViews[_moveIndex - 1];
            CGFloat tmpF = imageView.width + offsetP;
            
            if (offsetP > 0){
                if (tmpF > imageView.imgView.width){
                    imageView.width = imageView.imgView.width;
                    imageView.imgView.left = 0;
                    return;
                }else{
                    imageView.imgView.left = imageView.imgView.left + offsetP;
                    imageView.width = tmpF;
                }
            }else{
                if (tmpF < 0){
                    imageView.width = 0;
                    return;
                }else{
                    imageView.width = tmpF;
                    imageView.imgView.left = imageView.imgView.left + offsetP;
                }
            }
            //右边跟随
            StitchingButton *lastStichimageView = imageView;
            for (NSInteger i = _moveIndex; i < _imageViews.count ; i ++) {
                StitchingButton *changeImageView = self.imageViews[i];
                changeImageView.left = lastStichimageView.right;
                lastStichimageView = changeImageView;
            }
        }
        
    }
}

-(void)updateContentScrollViewContentSize{
    CGFloat totalHeight = 0;
    CGFloat totalWidth = 0;
    StitchingButton *lastImageView;
    for (StitchingButton *imageView in self.imageViews) {
        totalHeight += imageView.height;
        totalWidth = imageView.width;
//        if (imageView.tag == 100){
//            imageView.top = 0;
//        }else{
//            imageView.top = lastImageView.bottom;
//        }
//        lastImageView = imageView;
    }
    //self.contentScrollView.contentSize = CGSizeMake(totalWidth, totalHeight);
    self.contentScrollView.center = self.view.center;    [self.contentScrollView setScrollEnabled:YES];
    //[self.contentScrollView setScrollsToTop:YES];
}

#pragma mark 切割
-(void)userCutBtnClick{
    if (!_cutBtn.selected){
        NSInteger index = 0;
        for (StitchingButton *imageView in _imageViews) {
            //找到btn所在位置
            if (CGRectContainsPoint(imageView.frame,_cutBtn.center)){
                _moveIndex = imageView.tag / 100;
                index = _moveIndex - 1;
            }
            [imageView removeFromSuperview];
        }
        //上半部分
        NSMutableArray *topArr = [NSMutableArray array];
        for (NSInteger i = 0 ; i <= index; i ++) {
            [topArr addObject:_dataArr[i]];
        }
        //下半部分
        NSMutableArray *bottomArr = [NSMutableArray array];
        for (NSInteger i = index; i < _dataArr.count; i ++) {
            [bottomArr addObject:_dataArr[i]];
        }
        CGFloat top = [_originTopArr[0]floatValue];
        [_imageViews removeAllObjects];
        [_originTopArr removeAllObjects];
        [_originBottomArr removeAllObjects];
        [_originRightArr removeAllObjects];
        if (_isVerticalCut){
            CGFloat contentHeight = 0.0;
            UIImage *icon = topArr[0];
            
           StitchingButton *firstImageView = [[StitchingButton alloc]initWithFrame:CGRectMake(0, top, VerViewWidth, (CGFloat)(icon.size.height/icon.size.width) * VerViewWidth)];
            
            firstImageView.image = icon;
            firstImageView.centerX = self.view.centerX;
            contentHeight += firstImageView.height;
            firstImageView.tag = 100;
            [_contentScrollView addSubview:firstImageView];
            [_originTopArr addObject:[NSNumber numberWithFloat:0]];
            [_originBottomArr addObject:[NSNumber numberWithFloat:firstImageView.height]];
            [_imageViews addObject:firstImageView];
            if (_moveIndex == 1){
                //如果是从第一张开始切割
                firstImageView.height = _cutBtn.top;
            }
            for (NSInteger i = 1; i < topArr.count; i ++) {
                UIImage *icon = topArr[i];
                CGFloat imgHeight = (CGFloat)(icon.size.height/icon.size.width) * VerViewWidth;
                StitchingButton *imageView = [[StitchingButton alloc]initWithFrame:CGRectMake(0, firstImageView.bottom, VerViewWidth, imgHeight)];
                imageView.image = icon;
                imageView.centerX = firstImageView.centerX;
                imageView.tag = (i+1) * 100;
                contentHeight += imgHeight;
                [_contentScrollView addSubview:imageView];
                if (i == index){
                    imageView.height = _cutBtn.top -  firstImageView.bottom;
                    //imageView.imgView.top = - (_cutBtn.top -  firstImageView.bottom);
                }
                firstImageView = imageView;
                [_originTopArr addObject:[NSNumber numberWithFloat:firstImageView.top]];
                [_imageViews addObject:imageView];
                [_originBottomArr addObject:[NSNumber numberWithFloat:contentHeight]];
            }
            for (NSInteger i = 0; i < bottomArr.count; i ++) {
                UIImage *icon = bottomArr[i];
                CGFloat imgHeight = (CGFloat)(icon.size.height/icon.size.width) * VerViewWidth;
                StitchingButton *imageView = [[StitchingButton alloc]initWithFrame:CGRectMake(0,i==0?_cutBtn.top: firstImageView.bottom, VerViewWidth, imgHeight)];
                imageView.image = icon;
                imageView.centerX = firstImageView.centerX;
                imageView.tag = (index + 1 + i) * 100;
                contentHeight += imgHeight;
                [_contentScrollView addSubview:imageView];
                if (i == 0){
                    imageView.imgView.top = - (_cutBtn.bottom - firstImageView.bottom);
                    imageView.height = imageView.bottom - _cutBtn.bottom;
                }
                firstImageView = imageView;
                [_originTopArr addObject:[NSNumber numberWithFloat:firstImageView.top]];
                [_imageViews addObject:imageView];
                [_originBottomArr addObject:[NSNumber numberWithFloat:contentHeight]];
            }
            _contentScrollView.contentSize = CGSizeMake(_contentScrollView.width,contentHeight);
        }else{
            CGFloat contentWidth = 0.0;
            UIImage *icon = topArr[0];
            StitchingButton *firstImageView = [[StitchingButton alloc]initWithFrame:CGRectMake(0,(SCREEN_HEIGHT - 450)/2, (CGFloat)(icon.size.width / icon.size.height) * HorViewHeight, HorViewHeight)];
            firstImageView.image = icon;
            contentWidth += firstImageView.width;
            firstImageView.tag = 100;
            [_originRightArr addObject:[NSNumber numberWithFloat:0]];
            [_contentScrollView addSubview:firstImageView];
            [_imageViews addObject:firstImageView];
            
            if (_moveIndex == 1){
                //如果是从第一张开始切割
                firstImageView.width = _cutBtn.right;
            }
            
            for (NSInteger i = 1; i < topArr.count; i ++) {
                UIImage *icon = topArr[i];
                CGFloat imgWidth = (CGFloat)(icon.size.width/icon.size.height) * HorViewHeight;
                StitchingButton *imageView = [[StitchingButton alloc]initWithFrame:CGRectMake(firstImageView.right, firstImageView.top, imgWidth, HorViewHeight)];
                imageView.image = icon;
                imageView.tag = (i+1) * 100;
                contentWidth += imgWidth;
                if (i == index){
                    imageView.width = _cutBtn.centerX - firstImageView.right;
                }
                [_contentScrollView addSubview:imageView];
                [_originRightArr addObject:[NSNumber numberWithFloat:firstImageView.right]];
                firstImageView = imageView;
                [_imageViews addObject:imageView];
            }
            for (NSInteger i = 0; i < bottomArr.count; i ++) {
                UIImage *icon = bottomArr[i];
                CGFloat imgWidth = (CGFloat)(icon.size.width/icon.size.height) * HorViewHeight;
                StitchingButton *imageView = [[StitchingButton alloc]initWithFrame:CGRectMake(i==0?_cutBtn.left:firstImageView.right, firstImageView.top, imgWidth, HorViewHeight)];
                imageView.image = icon;
                imageView.tag = (i+1) * 100;
                contentWidth += imgWidth;
               
                if (i == 0){
                    imageView.width = imageView.right - _cutBtn.right ;
                    imageView.imgView.left = -(_cutBtn.right - firstImageView.right);
                }
                firstImageView = imageView;
                [_contentScrollView addSubview:imageView];
                [_originRightArr addObject:[NSNumber numberWithFloat:firstImageView.right]];
                [_imageViews addObject:imageView];
            }
            
            _contentScrollView.contentSize = CGSizeMake(contentWidth,_contentScrollView.height);
        }
        
        _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(cutPanMoveGesture:)];
        _panGesture.delegate = self;
        [_contentScrollView addGestureRecognizer:_panGesture];
        [_contentScrollView bringSubviewToFront:_cutBtn];
        self.title = [NSString stringWithFormat:@"%ld张图片",_imageViews.count];
    }else{
        _cutBtn.hidden = YES;
    }
    _cutBtn.selected = !_cutBtn.selected;

}
-(void)cutImgMoveGesture:(UIPanGestureRecognizer *)gesture{
    if (_isSlicing){
        CGPoint translatedPoint = [gesture translationInView:self.view];
        if (gesture.state == UIGestureRecognizerStateBegan){
            [_contentScrollView setScrollEnabled:NO];
        }
        if (gesture.state == UIGestureRecognizerStateChanged){
//            if (_cutBtn.top + translatedPoint.y <= Nav_H + 10 || _cutBtn.top + translatedPoint.y >= SCREEN_HEIGHT - 100){
//                return;
//            }
            if (_isVerticalCut){
                if (gesture.view.left + translatedPoint.x <= 0 || gesture.view.right + translatedPoint.x >= SCREEN_WIDTH){
                    gesture.view.left = 0;
                }
                [_cutBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.centerX.equalTo(self.contentScrollView);
                    make.top.equalTo(@(_cutBtn.top + translatedPoint.y));
                    make.height.equalTo(@30);
                }];
            }else{
                if (gesture.view.right + translatedPoint.x >= SCREEN_WIDTH){
                    gesture.view.right = SCREEN_WIDTH;
                    return;
                }
                if (gesture.view.left + translatedPoint.x <= 10){
                    gesture.view.left = 10;
                    return;
                }
                [_cutBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.height.top.equalTo(self.contentScrollView);
                    make.left.equalTo(@(_cutBtn.left + translatedPoint.x));
                    make.width.equalTo(@30);
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
            if (locationPoint.y <= _cutBtn.top){
                _isTopPart = YES;
            }else{
                _isTopPart = NO;
            }
        }else{
            if (locationPoint.x <= _cutBtn.left){
                _isTopPart = YES;
            }else{
                _isTopPart = NO;
            }
        }
        
    }
    if (recognizer.state == UIGestureRecognizerStateChanged){
        _isMove = YES;
        if (_isCut){
            _cutBtn.hidden = YES;
        }
        if (_isVerticalCut){
            if(_isTopPart){
                StitchingButton *imageView = self.imageViews[_moveIndex - 1];
                CGFloat tmpF = imageView.height - offsetP;
                if (offsetP > 0){
                    if (tmpF <= 0){
                        imageView.height = 0;
                        return;
                    }else{
                        imageView.height = tmpF;
                    }
                }else{
                    if (tmpF >= imageView.imgView.height){
                        imageView.bottom = _cutBtn.top;
                        StitchingButton *lastStichimageView = imageView;
                        for (NSInteger i = _moveIndex - 2; i >= 0; i --) {
                            StitchingButton *changeImageView = self.imageViews[i];
                            changeImageView.bottom = imageView.top;
                            lastStichimageView = changeImageView;
                        }
                        return;
                    }else{
                        imageView.height = tmpF;
                    }
                }
                imageView.top = offsetP+ imageView.top;
                //顶部跟随
                for (NSInteger i = _moveIndex - 2; i >= 0; i --) {
                    StitchingButton *changeImageView = self.imageViews[i];
                    changeImageView.top = changeImageView.top + offsetP;
                }
            }else{
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
                StitchingButton *lastStichimageView = imageView;
                for (NSInteger i = _moveIndex + 1; i < _imageViews.count ; i ++) {
                    StitchingButton *changeImageView = self.imageViews[i];
                    changeImageView.top = lastStichimageView.bottom;
                    lastStichimageView = changeImageView;
                }
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
        _isMove = NO;
        _cutBtn.hidden = NO;
    }
    if (self.contentScrollView.isDragging && _isCut) {
        return;
    }
    [recognizer setTranslation:CGPointZero inView:recognizer.view.superview];
    
}

#pragma mark -- slider电影字幕拼接
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

#pragma mark -- scrollviewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat tmpF = 0.0;
    if (_isVerticalCut == YES){
        if (_isStartCut == YES){
            if (_offsetY == 0){
                tmpF = scrollView.contentOffset.y;
            }else{
                tmpF = scrollView.contentOffset.y - _offsetY;
            }
            [_cutBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.centerX.equalTo(self.contentScrollView);
                make.top.equalTo(@(_cutBtn.top + tmpF));
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
            [_cutBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.height.top.equalTo(self.contentScrollView);
                make.left.equalTo(@(_cutBtn.left + tmpF));
                make.width.equalTo(@30);
            }];
            _offsetY = scrollView.contentOffset.x;
        }
        
    }
}

#pragma mark ----------btnClick && viewDelegateClick-------------
-(void)TopBtnClick:(UIButton *)btn{
    MJWeakSelf
    if (btn.tag == 0){
        [_cutBtn removeFromSuperview];
        [SVProgressHUD showWithStatus:@"正在生成图片中.."];
        UIView *view;
        if (_type == 4){
            view = _resultView.scrollView;
        }else{
            view = _contentScrollView;
        }
        [TYSnapshotScroll screenSnapshot:view finishBlock:^(UIImage *snapshotImage) {
            [SVProgressHUD showSuccessWithStatus:@"图片已保存至拼图相册中"];
            SaveViewController *saveVC = [SaveViewController new];
            saveVC.screenshotIMG = snapshotImage;
//            if (GVUserDe.isAutoSaveIMGAlbum){
//                //保存到拼图相册
//                [Tools saveImageWithImage:saveVC.screenshotIMG albumName:@"拼图" withBlock:^(NSString * _Nonnull identify) {
//                    saveVC.identify = identify;
//                }];
//            }else{
//                UIImageWriteToSavedPhotosAlbum(snapshotImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
//            }
            
            saveVC.isVer = weakSelf.isVerticalCut;
            saveVC.type = 2;
            [weakSelf.navigationController pushViewController:saveVC animated:YES];
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

-(void)image:(UIImage *)image didFinishSavingWithErrorf:(NSError *)error contextInfo:(void *)contextInfo{
    NSString *msg = nil;
    if (!error) {
        msg = @"下载成功，已为您保存至相册";
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

/** 获取scrollView的长截图*/
- (UIImage *)getLongImage:(UIScrollView *)scrollView{
    UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, NO, [UIScreen mainScreen].scale);
    //这里需要你修改下layer的frame,不然只会截出在屏幕显示的部分
    scrollView.layer.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
    [scrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
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
-(void)imgFuntionWithTag:(NSInteger)tag andIMG:(StitchingButton* )imgView{
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
        if (_isVerticalCut == YES) {
            [self addVerticalCutView];
        }else{
            [self addHorizontalCutView];
        }
        _imgFunctionView.hidden = YES;
        _bottomView.hidden = NO;
        
    }
    
}

-(void)bottomBtnClick:(NSInteger )tag{
    MJWeakSelf
    _guideIMG.hidden = YES;
    if (tag == 1){
        if (_type == 2){
            [_contentScrollView removeAllSubviews];
            for (StitchingButton *img in _imageViews) {
                for (UIView *vc in img.subviews) {
                    if ([vc isMemberOfClass:[UIButton class]]){
                        [vc removeAllSubviews];
                    }
                }
            }
            [_imageViews removeAllObjects];
            [_originTopArr removeAllObjects];
            [_originBottomArr removeAllObjects];
            [_originRightArr removeAllObjects];
            _isSlicing = NO;
            _isCut = NO;
            if ([_bottomView.typeLab.text isEqualToString:@"竖拼"]){
                //竖拼切换成横拼
                _isVerticalCut = NO;
                [self addHorizontalContentView];
                if (_isCut){
                    [self addHorizontalCutView];
                }
            }else{
                //横拼切换成竖屏
                _isVerticalCut = YES;
                [self addVerticalContentView];
                if (_isCut){
                    [self addVerticalCutView];
                }
            }
        }else if (_type == 3 || _type == 4) {
            if ([_bottomView.typeLab.text isEqualToString:@"擦除滚动条"]){
                //擦除滚动条
                if (_type == 4){
                    NSLog(@"_result.views%ld",_resultView.scrollView.subviews.count);
                }else{
                    for (StitchingButton *btn in self.imageViews) {
                        btn.imgView.left = 5;
                    }
                }
                
            }else{
                //恢复滚动条
                if (_type == 4){
                    
                }else{
                    for (StitchingButton *btn in self.imageViews) {
                        btn.imgView.left = 0;
                    }
                }
                
            }
        }else{
            _isCut = NO;
            if (_adjustView == nil){
                
            }
            _adjustView.hidden = !_adjustView.hidden;
            _cutBtn.hidden = YES;
        }
        
    }else{
        _adjustView.hidden = YES;
        _cutBtn.hidden = YES;
        _isSlicing = NO;
        if (tag == 2){
            //裁切
            if ([_bottomView.preLab.text isEqualToString:@"预览"]){
                _isCut = YES;
                _cutBtn.hidden = YES;
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
                _guideIMG.hidden = YES;
                _isCut = NO;
                [_contentScrollView removeGestureRecognizer:_panGesture];
                for (StitchingButton *img in _imageViews) {
                    for (UIView *vc in img.subviews) {
                        if ([vc isMemberOfClass:[UIButton class]]){
                            [vc removeAllSubviews];
                        }
                    }
                }
            }
            
        }else if (tag == 3){
            _guideIMG.hidden = YES;
            _isCut = NO;
            [_contentScrollView removeGestureRecognizer:_panGesture];
            for (StitchingButton *img in _imageViews) {
                for (UIView *vc in img.subviews) {
                    if ([vc isMemberOfClass:[UIButton class]]){
                        [vc removeAllSubviews];
                    }
                }
            }
            if (!_isSlicing){
                if (_cutBtn == nil){
                    _cutBtn = [UIButton buttonWithType:UIButtonTypeSystem];
                    [_cutBtn setBackgroundImage:IMG(@"裁切分界线") forState:UIControlStateNormal];
                    _cutBtn.selected = NO;
                    [_cutBtn addTarget:self action:@selector(userCutBtnClick) forControlEvents:UIControlEventTouchUpInside];
                    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(cutImgMoveGesture:)];
                    panGes.delegate = self;
                    [_cutBtn addGestureRecognizer:panGes];
                    [self.contentScrollView addSubview:_cutBtn];
                    
                }
                [self.contentScrollView bringSubviewToFront:_cutBtn];
                _cutBtn.hidden = NO;
                [_cutBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    if (_isVerticalCut == YES){
                        make.width.centerX.centerY.equalTo(self.view);
                        make.height.equalTo(@30);
                    }else{
                        make.height.centerX.centerY.equalTo(self.contentScrollView);
                        make.width.equalTo(@30);
                        [_cutBtn setBackgroundImage:IMG(@"横切裁切分界线") forState:UIControlStateNormal];
                    }
                }];
                
            }else{
                _cutBtn.hidden = YES;
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




#pragma mark -photoViewDelegate

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
-(NSMutableArray *)imageViews{
    if (!_imageViews){
        self.imageViews = [NSMutableArray array];
    }
    return _imageViews;
}



@end
