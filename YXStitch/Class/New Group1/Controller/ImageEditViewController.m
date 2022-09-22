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

@interface ImageEditViewController ()<WaterColorSelectViewDelegate,UIScrollViewDelegate,UnlockFuncViewDelegate,CheckProViewDelegate>
@property (nonatomic ,strong)ImageEditMarkView *imgEditMarkView;
@property (nonatomic ,strong)WaterColorSelectView *colorSelectView;
@property (nonatomic ,strong)ImageEditBottomView *bottomView;
@property (nonatomic ,strong)ColorPlateView *colorPlateView;
@property (nonatomic ,strong)WaterTitleView *titleView;
@property (nonatomic ,strong)UnlockFuncView *tipsView;

@property (nonatomic ,strong)UIView *contentView;
@property (nonatomic ,strong)UIScrollView *contentScrollView;
@property (nonatomic ,strong)UIImageView *imageView;
@property (nonatomic ,strong)UIView *bgView;
@property (nonatomic ,strong)CheckProView *checkProView;

@property (nonatomic ,assign)NSInteger editType;//编辑类型
@property (nonatomic ,strong)UIPinchGestureRecognizer *pinchRecognizer;
@property (nonatomic ,strong)UIPanGestureRecognizer *panRecognizer;

@property (nonatomic, strong)NSMutableArray *dataArr;//维护单个画布的路径数组
@property (nonatomic, strong)NSMutableArray * lines;// 线条数组
@property (nonatomic, strong)NSMutableArray * canceledLines; //撤销的线条数组
@property (nonatomic, strong)PaintPath * __nullable path;//自己当前绘画的路径
@property (nonatomic, assign)CGFloat pathWidth; //画笔宽度
@property (nonatomic, strong)UIColor *pathLineColor; //画笔颜色
@property (nonatomic, strong)CAShapeLayer *slayer;//当前操作layer层

@end

@implementation ImageEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.title = [NSString stringWithFormat:@"%@",_titleStr];
    _dataArr = [NSMutableArray array];
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
    CGFloat imageFakewidth = 0.0;
    CGFloat imageFakeHeight= 0.0;
    CGFloat scrollWidth= 0.0;
    CGFloat scrollHeight= 0.0;
    if(_isVer){
        imageFakewidth = 260;
        imageFakeHeight = (CGFloat)_screenshotIMG.size.height *imageFakewidth / _screenshotIMG.size.width;
        scrollWidth  = 260;
        scrollHeight = SCREEN_HEIGHT - Nav_HEIGHT - 80;
//        _contentScrollView.contentSize = CGSizeMake(0, imageFakeHeight);
    }else{
        imageFakeHeight= 300;
        imageFakewidth= _screenshotIMG.size.width;
        scrollHeight = 300;
        scrollWidth = (CGFloat)(_screenshotIMG.size.width/_screenshotIMG.size.height) * 300;;
        _contentScrollView.contentSize = CGSizeMake(imageFakewidth, 0);
    }
//    [_contentView addSubview:_contentScrollView];
//    [_contentScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(@(Nav_H));
//        make.centerX.width.equalTo(_contentView);
//        make.height.equalTo(@(scrollHeight));
//    }];
   // _contentScrollView.center = self.view.center;
    _imageView = [UIImageView new];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.userInteractionEnabled = YES;
    _imageView.image = _screenshotIMG;
    [_contentView addSubview:_imageView];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        if (_isVer){
            make.top.equalTo(@(Nav_HEIGHT));
        }else{
            make.centerY.equalTo(self.view);
        }
        make.width.equalTo(@(imageFakewidth));
        make.height.equalTo(@(imageFakeHeight));
    }];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.top.width.equalTo(_contentView);
//        make.height.equalTo(@(imageFakeHeight));
        make.edges.equalTo(_contentView);
    }];
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
    _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(selectonPanGesture:)];
    _panRecognizer.maximumNumberOfTouches = 1;
    [_contentView addGestureRecognizer:_panRecognizer];
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
        saveVC.screenshotIMG = [Tools imageFromView:_contentView rect:_contentView.frame];
        saveVC.isVer = weakSelf.isVer;
        saveVC.type = 2;
        [SVProgressHUD showSuccessWithStatus:@"图片已保存至拼图相册中"];
        [weakSelf.navigationController pushViewController:saveVC animated:YES];
//        [TYSnapshotScroll screenSnapshot:view finishBlock:^(UIImage *snapshotImage) {
           
//            if (GVUserDe.isAutoSaveIMGAlbum){
//                //保存到拼图相册
//                [Tools saveImageWithImage:saveVC.screenshotIMG albumName:@"拼图" withBlock:^(NSString * _Nonnull identify) {
//                    saveVC.identify = identify;
//                }];
//            }else{
//                UIImageWriteToSavedPhotosAlbum(snapshotImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
//            }
            
            
//        }];
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
    if(tag == 1){
        //标注
        if (_imgEditMarkView == nil){
            _imgEditMarkView = [[ImageEditMarkView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH,100)];
            [self.view addSubview:_imgEditMarkView];
//            [_imgEditMarkView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.width.left.equalTo(self.view);
//                make.height.equalTo(@100);
//                make.top.equalTo(self.view.mas_bottom);
//            }];

        }
        _imgEditMarkView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.imgEditMarkView.frame = CGRectMake(0, SCREEN_HEIGHT - weakSelf.imgEditMarkView.height, SCREEN_WIDTH, weakSelf.imgEditMarkView.height);
        }];
        _bottomView.hidden = YES;
        _imgEditMarkView.btnClick = ^(NSInteger tag) {
            [weakSelf imgEditViewBtnClickWithTag:tag];
        };
    }else if (tag ==2){
        //边框
    }else if (tag == 3){
        //套壳
        if (GVUserDe.isMember){
            
        }else{
            [self addTipsViewWithType:4];
        }
    }else{
        //水印
        if (GVUserDe.isMember){
            
        }else{
            [self addTipsViewWithType:2];
        }
    }
}

-(void)imgEditViewBtnClickWithTag:(NSInteger )tag{
    MJWeakSelf
    _editType = tag;
    [_colorSelectView removeFromSuperview];
    if (tag == 0){
        //取消
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.imgEditMarkView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, weakSelf.imgEditMarkView.height);
        } completion:^(BOOL finished) {
            weakSelf.imgEditMarkView.hidden = YES;
            weakSelf.bottomView.hidden = NO;
        }];
    }else if (tag == 1 || tag == 4 || tag == 2){
        //空心填充 //箭头
        if (tag == 2){
            [self addColoeSelectedViewWithType:2];
        }else{
            [self addColoeSelectedViewWithType:1];
        }
    }else if(tag == 3){
        //马赛克
    }else if(tag == 5){
        //画笔
        _pathWidth = 5;
        _pathLineColor = [UIColor orangeColor];
    }else if(tag == 6){
        //文本
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
        //撤销
    }else if(tag == 200){
        //删除
    }else{
        
    }
}

-(void)addTipsViewWithType:(NSInteger)type{
    //非会员弹出提示
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

-(void)addColoeSelectedViewWithType:(NSInteger)type{
    MJWeakSelf
    _colorSelectView = [WaterColorSelectView new];
    _colorSelectView.type = type;
    _colorSelectView.delegate = self;
    _colorSelectView.moreColorClick = ^{
        [weakSelf addColorPlateView];
    };
    [self.view addSubview:_colorSelectView];
    [_colorSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(self.view);
        make.bottom.equalTo(_imgEditMarkView.mas_top).offset(20);
        if (type == 1){
            make.height.equalTo(@100);
        }else{
            make.height.equalTo(@160);
        }
        
    }];
}

-(void)addEditLabWithStr:(NSString *)str{
    
}

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
    //改变大小
    if (_editType == 1){
        //修改边框
    }else if (_editType == 5){
        //修改箭头
    }else if (_editType == 6){
        //修改文本
    }
}
- (void)changeWaterFontColor:(NSString *)color{
    //改变颜色
    if (_editType == 1){
        //修改边框
    }else if (_editType == 5){
        //修改箭头
    }else if (_editType == 6){
        //修改文本
    }
}

#pragma mark -------------画笔事件-------------
#pragma mark touches事件
- (CGPoint)pointWithTouches:(NSSet *)touches{
    UITouch *touch = [touches anyObject];
    return [touch locationInView:_contentView];
}

#pragma mark -- touchesBegan

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint startP = [self pointWithTouches:touches];
   // CGRectContainsPoint(_contentView.frame,startP
    if (_editType == 5 ){
        //画笔模式
        [_contentView removeGestureRecognizer:_panRecognizer];
        [_contentView removeGestureRecognizer:_pinchRecognizer];
        _path = [PaintPath paintPathWithLineWidth:_pathWidth
                                                       startPoint:startP];
        _path.pathColor = _pathLineColor;
        [self.dataArr addObject:_path];
        CAShapeLayer * slayer = [CAShapeLayer layer];
        slayer.path = _path.CGPath;
        slayer.backgroundColor = [UIColor clearColor].CGColor;
        slayer.fillColor = [UIColor clearColor].CGColor;
        slayer.lineCap = kCALineCapRound;
        slayer.lineJoin = kCALineJoinRound;
        slayer.strokeColor = _path.pathColor.CGColor;
        slayer.lineWidth = _path.lineWidth;
        [_contentView.layer addSublayer:slayer];
        _slayer = slayer;
        [self.lines addObject:_slayer];
        [[self mutableArrayValueForKey:@"canceledLines"] removeAllObjects];
    }
}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint moveP = [self pointWithTouches:touches];
    if (_editType == 5){
        [_path addLineToPoint:moveP];
        _path.boundRect = CGPathGetPathBoundingBox(_path.CGPath);
        _slayer.path = _path.CGPath;
        if (_dataArr.count - 1 <= _dataArr.count){
            _dataArr[_dataArr.count - 1] = _path;
            _lines[_dataArr.count - 1] = _slayer;
        }
    }
    
    
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint endP = [self pointWithTouches:touches];
    if (_editType == 5 ){
        [_path addLineToPoint:endP];
        _path.boundRect = CGPathGetPathBoundingBox(_path.CGPath);
        _slayer.path = _path.CGPath;
        if (_dataArr.count - 1 <= _dataArr.count){
            _dataArr[_dataArr.count - 1] = _path;
            _lines[_dataArr.count - 1] = _slayer;
        }
        [self addGestureRecognizer];
    }
}
-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint endP = [self pointWithTouches:touches];
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


#pragma mark --set方法
-(NSMutableArray *)lines{
    if (_lines == nil){
        _lines = [NSMutableArray array];
    }
    return _lines;
}
-(NSMutableArray *)canceledLines{
    if (_canceledLines == nil){
        _canceledLines = [NSMutableArray array];
    }
    return _canceledLines;
}
@end
