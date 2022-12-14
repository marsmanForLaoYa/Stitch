//
//  GridShowView.m
//  YXStitch
//
//  Created by mac_m11 on 2022/9/26.
//

#import "GridShowView.h"

#define kGridElementMinWidth 55
#define kGridElementMinHeight 55
#define kCompensatePrecision 0.1
@interface GridShowView ()<GridShowImgViewDelegate>
{
    CGPoint _startPoint;    //手势滑动的起始点
    CGPoint _originCenter;
    CGRect _originBounds;
}

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) NSMutableArray <GridShowImgView *>*gridsImageViews;
@property (nonatomic, strong) NSMutableArray *gridsImageViewFrame;
@property (nonatomic, strong) NSMutableArray *bottomBelowImageViews;
@property (nonatomic, strong) NSMutableArray *bottomAboveImageViews;
@property (nonatomic, strong) NSMutableArray *topBelowImageViews;
@property (nonatomic, strong) NSMutableArray *topAboveImageViews;

@property (nonatomic, strong) NSMutableArray *leftToLeftImageViews;
@property (nonatomic, strong) NSMutableArray *leftToRightImageViews;
@property (nonatomic, strong) NSMutableArray *rightToLeftImageViews;
@property (nonatomic, strong) NSMutableArray *rightToRightImageViews;

@property (nonatomic, strong) GridShowImgView *overlapImgView;

@end

@implementation GridShowView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame: frame]){

        self.backgroundColor = RGB(255, 255, 255);
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = RGB(255, 255, 255);
        [self addSubview:bgView];
        _bgView = bgView;
    }
    return self;
}

- (void)setImagePadding:(CGFloat)imagePadding
{
    _imagePadding = imagePadding;
    self.bgView.frame = CGRectMake(0, 0, self.bounds.size.width - _imagePadding, self.bounds.size.height - _imagePadding);
    CGFloat scaleWidth = self.bgView.bounds.size.width / self.bounds.size.width;
    CGFloat scaleHeight = self.bgView.bounds.size.height / self.bounds.size.height;
    
    for (int i = 0; i < self.gridsImageViews.count; i++) {
        GridShowImgView *showImgView = self.gridsImageViews[i];
        NSString *frameString = self.gridsImageViewFrame[i];
        CGRect frame = CGRectFromString(frameString);
        showImgView.width = frame.size.width * scaleWidth;
        showImgView.height = frame.size.height * scaleHeight;
        showImgView.top = frame.origin.y * scaleHeight;
        showImgView.left = frame.origin.x * scaleWidth;
        showImgView.imagePadding = imagePadding;
    }
}

//更新缓存的frame值
- (void)updateGridsImageViewFrame {

    [self.gridsImageViewFrame removeAllObjects];
    CGFloat scaleWidth = self.bgView.bounds.size.width / self.bounds.size.width;
    CGFloat scaleHeight = self.bgView.bounds.size.height / self.bounds.size.height;
    for (GridShowImgView *showImgView in self.gridsImageViews) {
        //记录padding为0的值
        CGRect frame = CGRectMake(showImgView.left / scaleWidth, showImgView.top / scaleHeight, showImgView.width / scaleWidth, showImgView.height / scaleHeight);
        [self.gridsImageViewFrame addObject:NSStringFromCGRect(frame)];
    }
}

- (void)setShowViewBackgroundColorWithHex:(NSString *)hex {
    
    self.bgView.backgroundColor = HexColor(hex);
    self.backgroundColor = HexColor(hex);
}

- (void)setGridsDic:(NSDictionary *)gridsDic
{
    self.bgView.frame = CGRectMake(0, 0, self.bounds.size.width - _imagePadding, self.bounds.size.height - _imagePadding);
    //清除上一个边框
    [self.lastShowImgView clearEditBorder];
    _gridsDic = gridsDic;
    [self createLayoutSubImageViewWithGridsDic:gridsDic];
}

- (void)createLayoutSubImageViewWithGridsDic:(NSDictionary *)gridsDic
{
    [self.gridsImageViewFrame removeAllObjects];
    NSInteger rowsCount = [gridsDic[@"rowsCount"] integerValue];
    NSArray *rows = gridsDic[@"rows"];
    
    NSInteger index = 0;
    for (int i = 0; i < rows.count; i++) {
        NSDictionary *dicRows = rows[i];
        CGFloat start = [dicRows[@"start"] integerValue];
        NSInteger columnsCount = [dicRows[@"columnsCount"] integerValue];
        NSArray *columns = dicRows[@"columns"];
        
        //矩形框在x轴分了columnsCount份，每份的宽度
        CGFloat subImgViewWidth = self.bgView.width / columnsCount;
        //矩形框在y轴分了rowsCount份，每份的高度
        CGFloat subImgViewHeight = self.bgView.height / rowsCount;

        CGFloat left = start * subImgViewWidth;
        for (int j = 0; j < columns.count; j++) {
            NSDictionary *dicColumn = columns[j];
            CGFloat width = [dicColumn[@"width"] floatValue];
            CGFloat height = [dicColumn[@"height"] floatValue];
            CGFloat margin = [dicColumn[@"margin"] floatValue] * subImgViewWidth;
            CGFloat top = [dicColumn[@"top"] floatValue];

            GridShowImgView *showImgView;
            // top * subImgViewHeight为前面所有视图所占高度 (top + 1) * padding为padding的高度
            CGFloat imgViewTop = top * subImgViewHeight;
            //width * subImgViewWidth为前面所有视图所占宽度 (width - 1) * padding为padding的宽度
            CGFloat imgViewWidth = width * subImgViewWidth;
            //height * subImgViewHeight为当前视图所占高度 (height - 1) * padding为当前视图所占的padding高度
            CGFloat imgViewHeight = height * subImgViewHeight;
            
            if(self.gridsImageViews.count < self.pictures.count)
            {
                showImgView = [self creatSubviewsWithFrame:CGRectMake(left + margin, imgViewTop, imgViewWidth, imgViewHeight)];
            }
            else
            {
                showImgView = self.gridsImageViews[index];
                showImgView.frame = CGRectMake(left + margin,imgViewTop, imgViewWidth, imgViewHeight);
            }
            //记录imagepadding为0的frame值
            CGFloat scaleWidth = self.bgView.bounds.size.width / self.bounds.size.width;
            CGFloat scaleHeight = self.bgView.bounds.size.height / self.bounds.size.height;
            CGRect frame = CGRectMake(showImgView.left / scaleWidth, showImgView.top / scaleHeight, showImgView.width / scaleWidth, showImgView.height / scaleHeight);
            [self.gridsImageViewFrame addObject:NSStringFromCGRect(frame)];
            
            showImgView.image = self.pictures[index];
            showImgView.index = index;
            //初始化可拖动view
            [showImgView initGestureView];
            //设置可编辑的边缘
            showImgView.gridPanEdge = [self getPanEdgeWithImageView:showImgView];

            index ++;
            left += width * subImgViewWidth;
        }
    }
}

- (GridShowImgView *)creatSubviewsWithFrame:(CGRect)frame {
    GridShowImgView *subImgView = [[GridShowImgView alloc] initWithFrame:frame];
    @weakify(self);
    subImgView.gridShowImgViewTapBlock = ^(GridShowImgView * _Nonnull showImgView) {
        @strongify(self);
        //清除上一个边框
        [self.lastShowImgView clearEditBorder];
        //显示当前选中view的边框
        [showImgView showEditBorder];
        //记录当前选中的view
        self.lastShowImgView = showImgView;
        //把选中的view放在最上层
        [self.bgView bringSubviewToFront:showImgView];
        if(self.gridShowViewSelecedImageBlock) {
            self.gridShowViewSelecedImageBlock(showImgView.image);
        }
    };
    subImgView.delegate = self;
    [self.bgView addSubview:subImgView];
    [self.gridsImageViews addObject:subImgView];
    return subImgView;
}

//清除选中的view上的样式
- (void)clearSelectedShowImgView {
    //清除上一个边框
    [self.lastShowImgView clearEditBorder];
    self.lastShowImgView = nil;
}

//替换image
- (void)changeSelectedShowImgViewWithImage:(UIImage *)image {
    if(image == nil) {
        return;
    }
 
    self.lastShowImgView.image = image;
    
    NSMutableArray *arrImages = [NSMutableArray array];
    for (int i = 0; i < self.pictures.count; i++) {
        UIImage *picImage = self.pictures[i];
        if(i == self.lastShowImgView.index) {
            [arrImages addObject:image];
        }
        else
        {
            [arrImages addObject:picImage];
        }
    }

    self.pictures = [NSArray arrayWithArray:arrImages];
}

#pragma mark - 判断可以拖动的方向
- (GridPanEdge)getPanEdgeWithImageView:(GridShowImgView *)imageView {
    GridPanEdge panEdge = GridPanEdgeNone;
    if(imageView.left > kCompensatePrecision) {
        panEdge = panEdge | GridPanEdgeLeft;
    }
    
    if(imageView.top > kCompensatePrecision ) {
        panEdge = panEdge | GridPanEdgeTop;
    }
    
    if(fabs(imageView.right - self.bgView.width) > kCompensatePrecision) {
        panEdge = panEdge | GridPanEdgeRight;
    }
    
    if(fabs(imageView.bottom - self.bgView.height) > kCompensatePrecision) {
        panEdge = panEdge | GridPanEdgeBottom;
    }
    return panEdge;
}

#pragma mark - lazy
- (NSMutableArray *)gridsImageViews
{
    if(!_gridsImageViews)
    {
        _gridsImageViews = [[NSMutableArray alloc] init];
        
    }
    return _gridsImageViews;
}

- (NSMutableArray *)gridsImageViewFrame
{
    if(!_gridsImageViewFrame)
    {
        _gridsImageViewFrame = [[NSMutableArray alloc] init];
        
    }
    return _gridsImageViewFrame;
}

#pragma mark - GridShowImgViewDelegate panGesture
- (void)panGestureBeganWithGridElementView:(GridShowImgView *)gridElementView panViewEdge:(PanViewEdge)panViewEdge
{
    if(panViewEdge == PanViewEdgeBottom) {
        
        [self getBottomBelowAndAbovePanViewArray:gridElementView array:self.gridsImageViews];
    } else if(panViewEdge == PanViewEdgeTop) {
        
        [self getTopBelowAndAbovePanViewArray:gridElementView array:self.gridsImageViews];
    } else if(panViewEdge == PanViewEdgeLeft) {
        
        [self getLeftPanEdgeLeftAndRightPanViewArray:gridElementView array:self.gridsImageViews];
    } else if(panViewEdge == PanViewEdgeRight) {
        
        [self getRightPanEdgeLeftAndRightPanViewArray:gridElementView array:self.gridsImageViews];
    }
}

- (void)panGestureEndWithGridElementView:(GridShowImgView *)gridElementView
{
    //更新缓存的frame值
    [self updateGridsImageViewFrame];
}

- (void)leftOrRightPanX:(CGFloat)x panViewEdge:(PanViewEdge)panViewEdge gridElementView:(GridShowImgView *)gridElementView {
    
    
    if(panViewEdge == PanViewEdgeLeft) {

        if(x > 0) {//向右
            
            if(x >= kGridElementMinWidth) {
                x = kGridElementMinWidth;
            }
            CGFloat imageWidth = 0;
            for (GridShowImgView *_Nonnull imageView in self.leftToRightImageViews) {
                if(imageView.width == kGridElementMinWidth) {
                    
                    imageWidth = imageView.width;
                    break;
                }
            }
            if(imageWidth == kGridElementMinWidth) return;
            
            __block BOOL isMin = NO;
            __block CGFloat minLeft = 0;
            __block CGFloat changeX = 0;
            [self.leftToRightImageViews enumerateObjectsUsingBlock:^(GridShowImgView *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(obj.width > kGridElementMinWidth) {
                    obj.left += x;
                    obj.width -= x;
                    
                    //强制宽度为最大
                    if(obj.width < kGridElementMinWidth) {
                        changeX = kGridElementMinWidth - obj.width;
                        obj.left = obj.left - changeX;
                        obj.width = kGridElementMinWidth;
                        minLeft = obj.left;
                    }
                }
                else
                {
                    isMin = YES;
                }
            }];
            
            [self.leftToRightImageViews enumerateObjectsUsingBlock:^(GridShowImgView *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(changeX != 0 && minLeft != obj.left) {
                    obj.left = minLeft;
                    obj.width = obj.width + changeX;
                }
            }];
            
            [self.leftToLeftImageViews enumerateObjectsUsingBlock:^(GridShowImgView  * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

                if(changeX != 0) {
                    obj.width += x;
                    obj.width = obj.width - changeX;
                }
                else
                {
                    if(!isMin) {
                        obj.width += x;
                    }
                }
            }];

        }
        else
        {//向左
            if(x <= -kGridElementMinWidth) {
                x = -kGridElementMinWidth;
            }
            
            CGFloat imageWidth = 0;
            for (GridShowImgView *_Nonnull imageView in self.leftToLeftImageViews) {
                if(imageView.width == kGridElementMinWidth) {
                    
                    imageWidth = imageView.width;
                    break;
                }
            }
            if(imageWidth == kGridElementMinWidth) return;
            
            __block BOOL isMin = NO;
            __block CGFloat maxRight = 0;
            __block CGFloat changeX = 0;
            [self.leftToLeftImageViews enumerateObjectsUsingBlock:^(GridShowImgView *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if(obj.width > kGridElementMinWidth) {

                    obj.width += x;
                    if(obj.width < kGridElementMinWidth) {
                        
                        changeX = kGridElementMinWidth - obj.width;
                        obj.width = obj.width + changeX;
                        
                        maxRight = obj.right;
                    }
                }
                else
                {
                    isMin = YES;
                }
            }];
            
            [self.leftToLeftImageViews enumerateObjectsUsingBlock:^(GridShowImgView *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

                if(changeX != 0 && maxRight != obj.right) {

                    obj.width = obj.width + changeX;
                    //解决加起来要大于maxRight的bug
                    if(obj.right > maxRight) {
                        obj.width = obj.width - (obj.right - maxRight);
                    }
                }
            }];
            
            [self.leftToRightImageViews enumerateObjectsUsingBlock:^(GridShowImgView *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if(changeX != 0) {
                    obj.left += x;
                    obj.left = obj.left + changeX;
                    obj.width -= x;
                    obj.width = obj.width - changeX;
                }
                else
                {
                    if(!isMin) {
                        obj.left += x;
                        obj.width -= x;
                    }
                }
            }];
        }
    }
    else if(panViewEdge == PanViewEdgeRight)
    {
        if(x < 0) {//向左
            
            if(x <= -kGridElementMinWidth) {
                x = -kGridElementMinWidth;
            }
            
            CGFloat imageWidth = 0;
            for (GridShowImgView *_Nonnull imageView in self.rightToLeftImageViews) {
                if(imageView.width == kGridElementMinWidth) {
                    
                    imageWidth = imageView.width;
                    break;
                }
            }
            if(imageWidth == kGridElementMinWidth) return;
            
            __block BOOL isMin = NO;
            __block CGFloat maxRight = 0;
            __block CGFloat changeX = 0;
            [self.rightToLeftImageViews enumerateObjectsUsingBlock:^(GridShowImgView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if(obj.width > kGridElementMinHeight) {
                    
                    obj.width += x;
                    
                    //强制高度为最大
                    if(obj.width <= kGridElementMinWidth) {
                        
                        changeX = kGridElementMinWidth - obj.width;
                        obj.width = kGridElementMinWidth;
                        maxRight = obj.right;
                    }
                }
                else
                {
                    isMin = YES;
                }
            }];
            
            [self.rightToLeftImageViews enumerateObjectsUsingBlock:^(GridShowImgView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if(changeX != 0 && maxRight != obj.right) {
                    obj.width = obj.width + changeX;
                    obj.right = maxRight;
                }
            }];
            
            [self.rightToRightImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

                if(changeX != 0) {
                    obj.left = maxRight;
                    obj.width -= x;
                    obj.width = obj.width - changeX;
                }
                else
                {
                    if(!isMin) {
                        obj.left += x;
                        obj.width -= x;
                    }
                }
            }];
        }
        else
        {//向右
            
            //防止x大于最小宽度引起的bug
            if(x >= kGridElementMinWidth) {
                x = kGridElementMinWidth;
            }
            
            CGFloat imageWidth = 0;
            for (GridShowImgView *_Nonnull imageView in self.rightToRightImageViews) {
                if(imageView.width == kGridElementMinWidth) {
                    
                    imageWidth = imageView.width;
                    break;
                }
            }
            if(imageWidth == kGridElementMinWidth) return;
            
            __block CGFloat minLeft = 0;
            __block CGFloat changeX = 0;
            __block BOOL isMin = NO;
            [self.rightToRightImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
  
                if(obj.width > kGridElementMinWidth) {
                    obj.left += x;
                    obj.width -= x;
                    //强制高度为最大
                    if(obj.width <= kGridElementMinWidth) {

                        changeX = kGridElementMinWidth - obj.width;
                        obj.left = obj.left - changeX;
                        obj.width = obj.width + changeX;
                        minLeft = obj.left;
                    }
                }
                else
                {
                    isMin = YES;
                }
            }];
            
            [self.rightToRightImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
  
                if(changeX != 0 && obj.left != minLeft) {
                    obj.left = minLeft;
                    obj.width = obj.width + changeX;
                }
            }];
            
            [self.rightToLeftImageViews enumerateObjectsUsingBlock:^(GridShowImgView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(changeX != 0) {
                    obj.width += x;
                    obj.width = obj.width - changeX;
                }
                else
                {
                    if(!isMin) {
                        obj.width += x;
                    }
                }
            }];
        }
    }
}

- (void)topOrBottomPanX:(CGFloat)y panViewEdge:(PanViewEdge)panViewEdge gridElementView:(GridShowImgView *)gridElementView {
    if(panViewEdge == PanViewEdgeTop)
    {
        if(y > 0) {//向下
            if(y >= kGridElementMinHeight) {
                y = kGridElementMinHeight;
            }
            __block BOOL isMin = NO;
            __block CGFloat minTop = 0;
            __block CGFloat changeY = 0;
            
            CGFloat imageHeight = 0;
            for (GridShowImgView *_Nonnull imageView in self.topBelowImageViews) {
                if(imageView.height == kGridElementMinHeight) {
                    
                    imageHeight = imageView.height;
                    break;
                }
            }
            if(imageHeight == kGridElementMinHeight) return;
            
            [self.topBelowImageViews enumerateObjectsUsingBlock:^(GridShowImgView *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(obj.height > kGridElementMinHeight) {
                    
                    obj.top += y;
                    obj.height -= y;
                    
                    //强制高度为最大
                    if(obj.height < kGridElementMinHeight) {
                        
                        changeY = kGridElementMinHeight - obj.height;
                        obj.top = obj.top - changeY;
                        obj.height = kGridElementMinHeight;
                        minTop = obj.top;
                    }
                }
                else
                {
                    isMin = YES;
                }
            }];
            [self.topBelowImageViews enumerateObjectsUsingBlock:^(GridShowImgView *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if(changeY != 0 && minTop != obj.top) {
                    obj.top = minTop;
                    obj.height = obj.height + changeY;
                }
            }];
            
            [self.topAboveImageViews enumerateObjectsUsingBlock:^(GridShowImgView  * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

                if(changeY != 0) {
                    obj.height += y;
                    obj.height = obj.height - changeY;
                }
                else
                {
                    if(!isMin) {
                        obj.height += y;
                    }
                }
            }];
        }
        else
        {//向上
            if(y <= -kGridElementMinHeight) {
                y = -kGridElementMinHeight;
            }
            
            CGFloat imageHeight = 0;
            for (GridShowImgView *_Nonnull imageView in self.topAboveImageViews) {
                if(imageView.height == kGridElementMinHeight) {
                    
                    imageHeight = imageView.height;
                    break;
                }
            }
            if(imageHeight == kGridElementMinHeight) return;
            
            __block BOOL isMin = NO;
            __block CGFloat maxBottom = 0;
            __block CGFloat changeY = 0;
            [self.topAboveImageViews enumerateObjectsUsingBlock:^(GridShowImgView *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if(obj.height > kGridElementMinHeight) {

                    obj.height += y;
                    if(obj.height < kGridElementMinHeight) {
                        
                        changeY = kGridElementMinHeight - obj.height;
                        obj.height = obj.height + changeY;
                        
                        NSLog(@"obj.height1:%f", obj.height);
                        maxBottom = obj.bottom;
                    }
                }
                else
                {
                    isMin = YES;
                }
            }];
            
            [self.topAboveImageViews enumerateObjectsUsingBlock:^(GridShowImgView *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

                if(changeY != 0 && maxBottom != obj.bottom) {

                    obj.height = obj.height + changeY;
                    //解决加起来要大于maxbottom的bug
                    if(obj.bottom > maxBottom) {
                        obj.height = obj.height - (obj.bottom - maxBottom);
                    }
                }
            }];
            
            [self.topBelowImageViews enumerateObjectsUsingBlock:^(GridShowImgView *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if(changeY != 0) {
                    obj.top += y;
                    obj.top = obj.top + changeY;
                    obj.height -= y;
                    obj.height = obj.height - changeY;
                }
                else
                {
                    if(!isMin) {
                        obj.top += y;
                        obj.height -= y;
                    }
                }
            }];
        }
    }
    else if(panViewEdge == PanViewEdgeBottom)
    {
        if(y < 0) {//向上
            if(y <= -kGridElementMinHeight) {
                y = -kGridElementMinHeight;
            }
            
            CGFloat imageHeight = 0;
            for (GridShowImgView *_Nonnull imageView in self.bottomAboveImageViews) {
                if(imageView.height == kGridElementMinHeight) {
                    
                    imageHeight = imageView.height;
                    break;
                }
            }
            if(imageHeight == kGridElementMinHeight) return;
            
            __block BOOL isMin = NO;
            __block CGFloat maxBottom = 0;
            __block CGFloat changeY = 0;
            [self.bottomAboveImageViews enumerateObjectsUsingBlock:^(GridShowImgView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if(obj.height > kGridElementMinHeight) {
                    
                    obj.height += y;
                    
                    //强制高度为最大
                    if(obj.height <= kGridElementMinHeight) {
                        
                        changeY = kGridElementMinHeight - obj.height;
                        obj.height = kGridElementMinHeight;
                        maxBottom = obj.bottom;
                    }
                }
                else
                {
                    isMin = YES;
                }
            }];
            
            [self.bottomAboveImageViews enumerateObjectsUsingBlock:^(GridShowImgView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if(changeY != 0 && maxBottom != obj.bottom) {
                    obj.height = obj.height + changeY;
                    obj.bottom = maxBottom;
                }
            }];
            
            [self.bottomBelowImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

                if(changeY != 0) {
                    obj.top = maxBottom;
                    obj.height -= y;
                    obj.height = obj.height - changeY;
                }
                else
                {
                    if(!isMin) {
                        obj.top += y;
                        obj.height -= y;
                    }
                }
            }];
        }
        else
        {
        
            //防止y大于最小高度引起的bug
            if(y >= kGridElementMinHeight) {
                y = kGridElementMinHeight;
            }
            
            CGFloat imageHeight = 0;
            for (GridShowImgView *_Nonnull imageView in self.bottomBelowImageViews) {
                if(imageView.height == kGridElementMinHeight) {
                    
                    imageHeight = imageView.height;
                    break;
                }
            }
            if(imageHeight == kGridElementMinHeight) return;
            
            __block CGFloat minTop = 0;
            __block CGFloat changeY = 0;
            __block BOOL isMin = NO;
            [self.bottomBelowImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
  
                if(obj.height > kGridElementMinHeight) {
                    obj.top += y;
                    obj.height -= y;
                    //强制高度为最大
                    if(obj.height <= kGridElementMinHeight) {

                        changeY = kGridElementMinHeight - obj.height;
                        obj.top = obj.top - changeY;
                        obj.height = obj.height + changeY;
                        minTop = obj.top;
                    }
                }
                else
                {
                    isMin = YES;
                }
            }];
            
            [self.bottomBelowImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
  
                if(changeY != 0 && obj.top != minTop) {
                    obj.top = minTop;
                    obj.height = obj.height + changeY;
                }
            }];
            
            [self.bottomAboveImageViews enumerateObjectsUsingBlock:^(GridShowImgView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(changeY != 0) {
                    obj.height += y;
                    obj.height = obj.height - changeY;
                }
                else
                {
                    if(!isMin) {
                        obj.height += y;
                    }
                }
            }];
        }
    }
}

#pragma mark - longPress

- (void)longPressBeganWithGridElementView:(GridShowImgView *)gridElementView gesture:(UILongPressGestureRecognizer *)longPressGesture {
    UIView *view = longPressGesture.view;
    _startPoint = [longPressGesture locationInView:view];
    _originCenter = gridElementView.center;
    _originBounds = gridElementView.bounds;
    
    for (GridShowImgView *showImgView in self.gridsImageViews) {
       
        [showImgView clearBorderOnly];
    }
}

- (void)longPressChangedWithGridElementView:(GridShowImgView *)gridElementView withPoint:(CGPoint)viewPoint {

    //应用移动后的X坐标
    CGFloat deltaX = viewPoint.x - _startPoint.x;
    //应用移动后的Y坐标
    CGFloat deltaY = viewPoint.y - _startPoint.y;
    //拖动的应用跟随手势移动
    gridElementView.center = CGPointMake(gridElementView.center.x + deltaX, gridElementView.center.y + deltaY);
    CGPoint newPoint = CGPointMake(gridElementView.left + viewPoint.x,gridElementView.top + viewPoint.y);
    self.overlapImgView = [self getGridShowImgViewWithPoint:newPoint gridElementView:gridElementView];
    [self.overlapImgView showBorderOnly];
}

- (void)longPressEndWithGridElementView:(GridShowImgView *)gridElementView {
    //清除掉所有的laryer border
    for (GridShowImgView *showImgView in self.gridsImageViews) {
       
        [showImgView clearBorderOnly];
    }
    
    if(self.overlapImgView) {
        //交换位置
        gridElementView.center = self.overlapImgView.center;
        gridElementView.bounds = self.overlapImgView.bounds;
        self.overlapImgView.center = _originCenter;
        self.overlapImgView.bounds = _originBounds;
        //交换上下左右可拖动的view
        GridPanEdge tempPanEdge = self.overlapImgView.gridPanEdge;
        self.overlapImgView.gridPanEdge = gridElementView.gridPanEdge;
        gridElementView.gridPanEdge = tempPanEdge;
        //交换选中状态
        BOOL tempGridEditing = self.overlapImgView.gridEditing;
        self.overlapImgView.gridEditing = gridElementView.gridEditing;
        gridElementView.gridEditing = tempGridEditing;
        //更新frame的记录
        [self updateGridsImageViewFrame];
    }
    else
    {
        self.lastShowImgView.gridEditing = self.lastShowImgView.gridEditing;
        gridElementView.gridEditing = gridElementView.gridEditing;
        gridElementView.center = _originCenter;
    }
}

- (GridShowImgView *)getGridShowImgViewWithPoint:(CGPoint)point gridElementView:(GridShowImgView *)gridElementView {
    GridShowImgView *imgView = nil;
    
    for (GridShowImgView *showImgView in self.gridsImageViews) {
       
        [showImgView clearBorderOnly];
    }
    
    for (GridShowImgView *showImgView in self.gridsImageViews) {
       
        if(![gridElementView isEqual:showImgView]) {
            if(gridElementView) {
                if(CGRectContainsPoint(showImgView.frame, point)) {
                    imgView = showImgView;
                    break;
                }
            }
        }
    }
    return imgView;
}

#pragma mark - analysis
//下部移动手势
- (void)getBottomBelowAndAbovePanViewArray:(GridShowImgView *)gridElementView array:(NSArray *)gridsArray {
    self.bottomBelowImageViews = [NSMutableArray array];
    self.bottomAboveImageViews = [NSMutableArray array];
    
    [self.bottomAboveImageViews addObjectsFromArray:@[gridElementView]];
    [self getBottomPanEdgeArrayWithGridElementView:gridElementView originArray:@[gridElementView]];
}

- (void)getBottomPanEdgeArrayWithGridElementView:(GridShowImgView *)gridElementView originArray:(NSArray *)originArray {
    
    if(originArray.count == 0) {
        return;
    }
    
    NSMutableArray *belowArray = [NSMutableArray array];
    @weakify(self);
    //检测下方交叉的view
    [originArray enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);

        [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if(![gridElementView isEqual:obj]) {
                if(fabs(subImgView.bottom - obj.top) <= 1) {
                    if(![self judgeBottomAndTopIsNoOverlapBetweenView1:obj secondView:subImgView])
                    {//重叠
                        if(![self.bottomBelowImageViews containsObject:obj]) {
                            [belowArray addObject:obj];
                        }
                    }
                }
            }
        }];
    }];
    
    [self.bottomBelowImageViews addObjectsFromArray:belowArray];
    
    NSMutableArray *aboveArray = [NSMutableArray array];
    //检测上方交叉的view
    [belowArray enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if(![gridElementView isEqual:subImgView]) {

            [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(![gridElementView isEqual:obj]) {
                    if(fabs(subImgView.top - obj.bottom) <= 1) {
                        if(![self judgeBottomAndTopIsNoOverlapBetweenView1:subImgView secondView:obj])
                        {//重叠
                            if(![self.bottomAboveImageViews containsObject:obj]) {
                                [aboveArray addObject:obj];
                            }
                        }
                    }
                }
            }];
        }
    }];
    
    [self.bottomAboveImageViews addObjectsFromArray:aboveArray];
    //递归调用
    [self getBottomPanEdgeArrayWithGridElementView:gridElementView originArray:aboveArray];
}

//上部移动手势
- (void)getTopBelowAndAbovePanViewArray:(GridShowImgView *)gridElementView array:(NSArray *)gridsArray {
    self.topBelowImageViews = [NSMutableArray array];
    self.topAboveImageViews = [NSMutableArray array];
    
    [self.topBelowImageViews addObjectsFromArray:@[gridElementView]];
    [self getTopPanEdgeArrayWithGridElementView:gridElementView originArray:@[gridElementView]];
}

- (void)getTopPanEdgeArrayWithGridElementView:(GridShowImgView *)gridElementView originArray:(NSArray *)originArray {
    
    if(originArray.count == 0) {
        return;
    }
    
    NSMutableArray *aboveArray = [NSMutableArray array];
    @weakify(self);
    //检测上方的view
    [originArray enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        
        [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if(![gridElementView isEqual:obj]) {
                if(fabs(subImgView.top - obj.bottom) <= 1) {
                    if(![self judgeBottomAndTopIsNoOverlapBetweenView1:obj secondView:subImgView])
                    {//重叠
                        if(![self.topAboveImageViews containsObject:obj]) {
                            [aboveArray addObject:obj];
                        }
                    }
                }
            }
        }];
    }];
    
    [self.topAboveImageViews addObjectsFromArray:aboveArray];
    
    NSMutableArray *belowArray = [NSMutableArray array];
    //检测下方的view
    [aboveArray enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if(![gridElementView isEqual:subImgView]) {

            [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(![gridElementView isEqual:obj]) {
                    if(fabs(subImgView.bottom - obj.top) <= 1) {
                        if(![self judgeBottomAndTopIsNoOverlapBetweenView1:subImgView secondView:obj])
                        {//重叠
                            if(![self.topBelowImageViews containsObject:obj]) {
                                [belowArray addObject:obj];
                            }
                        }
                    }
                }
            }];
        }
    }];
    
    [self.topBelowImageViews addObjectsFromArray:belowArray];
    //递归调用
    [self getTopPanEdgeArrayWithGridElementView:gridElementView originArray:belowArray];
}

//左部移动手势
- (void)getLeftPanEdgeLeftAndRightPanViewArray:(GridShowImgView *)gridElementView array:(NSArray *)gridsArray {
    self.leftToLeftImageViews = [NSMutableArray array];
    self.leftToRightImageViews = [NSMutableArray array];

    [self.leftToRightImageViews addObjectsFromArray:@[gridElementView]];
    [self getLeftPanEdgeArrayWithGridElementView:gridElementView originArray:@[gridElementView]];
}

- (void)getLeftPanEdgeArrayWithGridElementView:(GridShowImgView *)gridElementView originArray:(NSArray *)originArray {
    
    if(originArray.count == 0) {
        return;
    }
    
    NSMutableArray *leftArray = [NSMutableArray array];
    @weakify(self);
    //向左检测交叉的view
    [originArray enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        
        [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if(![gridElementView isEqual:obj]) {
                if(fabs(subImgView.left - obj.right) <= 1) {
                    if(![self judgeLeftAndRightIsNoOverlapBetweenView1:obj secondView:subImgView])
                    {//重叠
                        if(![self.leftToLeftImageViews containsObject:obj]) {
                            [leftArray addObject:obj];
                        }
                    }
                }
            }
        }];
    }];
    [self.leftToLeftImageViews addObjectsFromArray:leftArray];
    
    NSMutableArray *rightArray = [NSMutableArray array];
    //向右检测交叉的view
    [leftArray enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if(![gridElementView isEqual:subImgView]) {

            [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(![gridElementView isEqual:obj]) {
                    if(fabs(subImgView.right - obj.left) <= 1) {
                        if(![self judgeLeftAndRightIsNoOverlapBetweenView1:subImgView secondView:obj])
                        {//重叠
                            if(![self.leftToRightImageViews containsObject:obj]) {
                                [rightArray addObject:obj];
                            }
                        }
                    }
                }
            }];
        }
    }];
    
    [self.leftToRightImageViews addObjectsFromArray:rightArray];
    //递归调用
    [self getLeftPanEdgeArrayWithGridElementView:gridElementView originArray:rightArray];
}

//右部移动手势
- (void)getRightPanEdgeLeftAndRightPanViewArray:(GridShowImgView *)gridElementView array:(NSArray *)gridsArray {
    
    self.rightToLeftImageViews = [NSMutableArray array];
    self.rightToRightImageViews = [NSMutableArray array];
    
    [self.rightToLeftImageViews addObjectsFromArray:@[gridElementView]];
    [self getRightPanEdgeArrayWithGridElementView:gridElementView originArray:@[gridElementView]];
}

- (void)getRightPanEdgeArrayWithGridElementView:(GridShowImgView *)gridElementView originArray:(NSArray *)originArray {
    
    if(originArray.count == 0) {
        return;
    }
        
    NSMutableArray *rightArray = [NSMutableArray array];
    @weakify(self);
    //向右检测view
    [originArray enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        
        [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if(![gridElementView isEqual:obj]) {
                if(fabs(subImgView.right - obj.left) <= 1) {
                    if(![self judgeLeftAndRightIsNoOverlapBetweenView1:obj secondView:subImgView])
                    {//重叠
                        if(![self.rightToRightImageViews containsObject:obj]) {
                            [rightArray addObject:obj];
                        }
                    }
                }
            }
        }];
    }];
    
    [self.rightToRightImageViews addObjectsFromArray:rightArray];
    
    NSMutableArray *leftArray = [NSMutableArray array];
    //向左检测交叉的view
    [rightArray enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if(![gridElementView isEqual:subImgView]) {

            [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(![gridElementView isEqual:obj]) {
                    if(fabs(subImgView.left - obj.right) <= 1) {
                        if(![self judgeLeftAndRightIsNoOverlapBetweenView1:subImgView secondView:obj])
                        {//重叠
                            if(![self.rightToLeftImageViews containsObject:obj]) {
                                [leftArray addObject:obj];
                            }
                        }
                    }
                }
            }];
        }
    }];
    
    [self.rightToLeftImageViews addObjectsFromArray:leftArray];
    
    //递归调用
    [self getRightPanEdgeArrayWithGridElementView:gridElementView originArray:leftArray];
}


//判断左右边距 是否重叠 NO重叠 YES不重叠
- (BOOL)judgeBottomAndTopIsNoOverlapBetweenView1:(GridShowImgView *)view1 secondView:(GridShowImgView *)view2 {
//    NSLog(@"view1 left:%f view2 left:%f view1 right:%f view2 right:%f", view1.left, view2.left, view1.right, view2.right);
//
//    NSLog(@"%d %d %d %d", view1.left <= view2.left && view1.right > view2.left && view1.right <= view2.right, view1.left >= view2.left && view1.right <= view2.right, view1.left >= view2.left && view1.left < view2.right && view1.right >= view2.right, view1.left <= view2.left && view1.right >= view2.right);
//
//    NSLog(@"%f", view1.right - view2.left);
//    NSLog(@"%d", view1.right > view2.left);
    if(
        (view1.left <= view2.left && view1.right - view2.left > kCompensatePrecision && view1.right <= view2.right) ||
        (view1.left >= view2.left && view1.right <= view2.right) ||
        (view1.left >= view2.left && view2.right - view1.left > kCompensatePrecision && view1.right >= view2.right) ||
        (view1.left <= view2.left && view1.right >= view2.right)
       ) {//重叠

        return NO;
    }
    
    return YES;
}

//判断上下边距 是否重叠
- (BOOL)judgeLeftAndRightIsNoOverlapBetweenView1:(GridShowImgView *)view1 secondView:(GridShowImgView *)view2 {
    if(
       (view1.top <= view2.top && view1.bottom - view2.top > kCompensatePrecision && view1.bottom < view2.bottom) ||
       (view1.top >= view2.top && view1.bottom < view2.bottom) ||
       (view1.top > view2.top && view2.bottom - view1.top > kCompensatePrecision && view1.bottom >= view2.bottom) ||
       (view1.top <= view2.top && view1.bottom >= view2.bottom)
       ) {//重叠

        return NO;
    }
    
    return YES;
}

@end


//左右
#define kCanPanViewMaxHeight 100
#define kCanPanViewMinHeight 30
#define kCanPanViewWidth 10
//上下
#define kCanPanViewMaxWidth 100
#define kCanPanViewMinWidth 30
#define kCanPanViewHeight 10
#define kViewBorderWidth 3
//捏合手势放大最大比例
#define kPinchMaxScale 3
@interface GridShowImgView ()

@property (nonatomic, strong) UIView *subBgView;

@property (nonatomic, strong) UIView *leftCanPanView;
@property (nonatomic, strong) UIView *topCanPanView;
@property (nonatomic, strong) UIView *rightCanPanView;
@property (nonatomic, strong) UIView *bottomCanPanView;
//缩放比例
@property(nonatomic, assign) CGFloat pinchScale;

@property(nonatomic, assign) CGFloat originImgViewWidth;
@property(nonatomic, assign) CGFloat originImgViewHeight;
@property(nonatomic, assign) BOOL isMoving;

@end
@implementation GridShowImgView
{
    CGPoint _startPoint;    //手势滑动的起始点
    CGPoint _lastPoint;     //记录上次滑动的点
    BOOL    _isStartPan;    //记录手势开始滑动
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = NO;
        _pinchScale = 1.0;
        self.backgroundColor = [UIColor clearColor];
        [self configViews];
    }
    return self;
}

- (void)configViews{
    //添加点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSelectedViewAction)];
    [self addGestureRecognizer:tap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressMoving:)];
    [self addGestureRecognizer:longPress];
    
    [self addSubview:self.subBgView];
    self.subBgView.frame = self.bounds;
    
    self.scrollView.frame = self.subBgView.bounds;
    [self.subBgView addSubview:self.scrollView];
    
    [self.subBgView addSubview:self.leftCanPanView];
    [self.subBgView addSubview:self.rightCanPanView];
    [self.subBgView addSubview:self.topCanPanView];
    [self.subBgView addSubview:self.bottomCanPanView];
    
    [self.subBgView addSubview:self.leftPanGestureView];
    [self.subBgView addSubview:self.topPanGestureView];
    [self.subBgView addSubview:self.rightPanGestureView];
    [self.subBgView addSubview:self.bottomPanGestureView];

    [self addGestureWithView:self.leftPanGestureView action:@selector(leftPanGestureView:)];
    [self addGestureWithView:self.topPanGestureView action:@selector(topPanGestureView:)];
    [self addGestureWithView:self.rightPanGestureView action:@selector(rightPanGestureView:)];
    [self addGestureWithView:self.bottomPanGestureView action:@selector(bottomPanGestureView:)];
    //添加imageView
    [self.scrollView addSubview:self.imageView];
    
    //添加缩放手势
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchSelectedViewAction:)];
    [self.imageView addGestureRecognizer:pinch];
}

#pragma mark - setter
- (void)setImage:(UIImage *)image{
    _image = image;
    _imageView.image = image;
    //改变imageview的frame
    [self changeImageViewFrame];
}

- (void)setGridEditing:(BOOL)gridEditing {
    _gridEditing = gridEditing;
    if(gridEditing) {
        if(_gridShowImgViewTapBlock) {
            _gridShowImgViewTapBlock(self);
        }
    }
    else
    {
        [self clearEditBorder];
    }
}

- (void)changeImageViewFrame {
    if (self.image == nil) {
        return;
    }
    //计算imageview的宽高
    CGFloat imageHeight = self.image.size.height;
    CGFloat imageWidth = self.image.size.width;
    CGFloat scaleWH = imageWidth / imageHeight;
    
    CGFloat imageMinWidth = 100;
    CGFloat imageMinHeight = 200;

    imageWidth = self.width;
    if(imageWidth < imageMinWidth) {
        imageWidth = imageMinWidth;
    }
    
    imageHeight = imageWidth / scaleWH;
    if(imageHeight < imageMinHeight) {
        imageHeight = imageMinHeight;
    }
    
    if(imageHeight < self.subBgView.height) {
        imageHeight = self.subBgView.height;
    }
    imageWidth = scaleWH * imageHeight;
    
    _originImgViewWidth = imageWidth;
    _originImgViewHeight = imageHeight;
    //设置contentSize
    self.scrollView.contentSize = CGSizeMake(imageWidth, imageHeight);
    //设置imageview的大小
    self.imageView.frame = CGRectMake(0, 0, imageWidth, imageHeight);
    
    //scrollview滚动到中间
    [self scrollToCenter];
}

//scrollview滚动到中间
- (void)scrollToCenter {
    CGPoint offset = self.scrollView.contentOffset;
    offset.y = (self.scrollView.contentSize.height - self.scrollView.bounds.size.height + self.scrollView.contentInset.bottom) / 2;
    offset.x = (self.scrollView.contentSize.width - self.scrollView.bounds.size.width + self.scrollView.contentInset.right) / 2;
    [self.scrollView setContentOffset:offset animated:NO];
}

- (void)setGridPanEdge:(GridPanEdge)gridPanEdge
{
    [self initGestureView];
    _gridPanEdge = gridPanEdge;
    if(gridPanEdge & GridPanEdgeTop) {
        self.topPanGestureView.hidden = NO;
    }

    if(gridPanEdge & GridPanEdgeLeft) {
        self.leftPanGestureView.hidden = NO;
    }

    if(gridPanEdge & GridPanEdgeRight) {
        self.rightPanGestureView.hidden = NO;
    }

    if(gridPanEdge & GridPanEdgeBottom) {
        self.bottomPanGestureView.hidden = NO;
    }
}

- (void)setImagePadding:(CGFloat)imagePadding {
    _imagePadding = imagePadding;
    self.subBgView.frame = CGRectMake(_imagePadding, _imagePadding, self.bounds.size.width - _imagePadding, self.bounds.size.height - _imagePadding);
}

- (void)layoutSubviews
{
    if(_isMoving) return;
    self.subBgView.frame = CGRectMake(_imagePadding, _imagePadding, self.bounds.size.width - _imagePadding, self.bounds.size.height - _imagePadding);
    self.scrollView.frame = self.subBgView.bounds;
    
    CGFloat edge = 20;
    self.leftPanGestureView.frame = CGRectMake(0, 0, edge, self.subBgView.height);
    self.rightPanGestureView.frame = CGRectMake(self.subBgView.width - edge, 0, edge, self.subBgView.height);
    self.topPanGestureView.frame = CGRectMake(0, 0, self.subBgView.width, edge);
    self.bottomPanGestureView.frame = CGRectMake(0, self.subBgView.height - edge, self.subBgView.width, edge);
    
    CGFloat fixMarginYMin = 10;
    CGFloat leftCanPanViewHeight = 0;
    CGFloat leftCanPanViewTop = 0;
    if(self.subBgView.height >= fixMarginYMin * 2 + kCanPanViewMaxHeight) {
        leftCanPanViewHeight = kCanPanViewMaxHeight;
        leftCanPanViewTop = (self.subBgView.height - leftCanPanViewHeight) / 2;
    }
    else
    {
        leftCanPanViewTop = fixMarginYMin;
        leftCanPanViewHeight = self.subBgView.height - 2 * leftCanPanViewTop;
    }
    
    self.leftCanPanView.frame = CGRectMake(- kCanPanViewWidth / 2 + kViewBorderWidth / 2, leftCanPanViewTop, kCanPanViewWidth, leftCanPanViewHeight);
    self.rightCanPanView.frame = CGRectMake(self.subBgView.width - kCanPanViewWidth / 2 - kViewBorderWidth / 2, leftCanPanViewTop, kCanPanViewWidth, leftCanPanViewHeight);
    
    
    CGFloat fixMarginXMin = 10;
    CGFloat topCanPanViewWidth = 0;
    CGFloat topCanPanViewLeft = 0;
    if(self.subBgView.width >= fixMarginXMin * 2 + kCanPanViewMaxWidth) {
        topCanPanViewWidth = kCanPanViewMaxWidth;
        topCanPanViewLeft = (self.subBgView.width - topCanPanViewWidth) / 2;
    }
    else
    {
        topCanPanViewLeft = fixMarginXMin;
        topCanPanViewWidth = self.subBgView.width - 2 * topCanPanViewLeft;
    }
    self.topCanPanView.frame = CGRectMake(topCanPanViewLeft, - kCanPanViewWidth / 2+ kViewBorderWidth / 2, topCanPanViewWidth, kCanPanViewHeight);
    self.bottomCanPanView.frame = CGRectMake(topCanPanViewLeft, self.subBgView.height - kCanPanViewWidth / 2 - kViewBorderWidth / 2, topCanPanViewWidth, kCanPanViewHeight);
    //改变imageview的frame
    [self changeImageViewFrame];
}

#pragma mark - Method
- (void)initGestureView {
    self.leftPanGestureView.hidden = YES;
    self.rightPanGestureView.hidden = YES;
    self.topPanGestureView.hidden = YES;
    self.bottomPanGestureView.hidden = YES;
}

- (void)showEditBorder
{
    if(self.gridPanEdge & GridPanEdgeTop) {
        self.topCanPanView.hidden = NO;
    }
    
    if(self.gridPanEdge & GridPanEdgeLeft) {
        self.leftCanPanView.hidden = NO;
    }
    
    if(self.gridPanEdge & GridPanEdgeRight) {
        self.rightCanPanView.hidden = NO;
    }
    
    if(self.gridPanEdge & GridPanEdgeBottom) {
        self.bottomCanPanView.hidden = NO;
    }

    _gridEditing = YES;
    [self showBorderOnly];
}

- (void)showBorderOnly {
    self.subBgView.layer.borderColor = RGB(0, 74, 274).CGColor;
    self.subBgView.layer.borderWidth = kViewBorderWidth;
}

- (void)addGestureWithView:(UIView *)view action:(nullable SEL)action {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:action];
    [view addGestureRecognizer:pan];
}

- (void)clearEditBorder {
    self.subBgView.layer.borderColor = [UIColor clearColor].CGColor;
    self.subBgView.layer.borderWidth = 0.0;
    self.leftCanPanView.hidden = YES;
    self.rightCanPanView.hidden = YES;
    self.topCanPanView.hidden = YES;
    self.bottomCanPanView.hidden = YES;
    
    _gridEditing = NO;
}

- (void)clearBorderOnly {
    self.subBgView.layer.borderColor = [UIColor clearColor].CGColor;
    self.subBgView.layer.borderWidth = 0.0;
    self.leftCanPanView.hidden = YES;
    self.rightCanPanView.hidden = YES;
    self.topCanPanView.hidden = YES;
    self.bottomCanPanView.hidden = YES;
}

#pragma mark - gesture
- (void)tapSelectedViewAction {
    if(_gridShowImgViewTapBlock) {
        _gridShowImgViewTapBlock(self);
    }
}

- (void)longPressMoving:(UILongPressGestureRecognizer *)longGesture {
    
    UIView *view = longGesture.view;
    CGPoint touPoint = [longGesture locationInView:view];

    CGFloat scale = 1.1;
    switch (longGesture.state) {
          case UIGestureRecognizerStateBegan: {
              _isMoving = YES;
              [self.superview bringSubviewToFront:self];
              self.transform = CGAffineTransformMakeScale(scale, scale);
              if(self.delegate && [self.delegate respondsToSelector:@selector(longPressBeganWithGridElementView:gesture:)]) {
                  [self.delegate longPressBeganWithGridElementView:self gesture:longGesture];
              }
          }
              break;
          case UIGestureRecognizerStateChanged: {
              if(self.delegate && [self.delegate respondsToSelector:@selector(longPressChangedWithGridElementView:withPoint:)]) {
                  [self.delegate longPressChangedWithGridElementView:self withPoint:touPoint];
              }
          }
              break;
          case UIGestureRecognizerStateEnded: {
              ///手势结束(比如手离开了屏幕)
              self.transform = CGAffineTransformIdentity;
              _isMoving = NO;
              if(self.delegate && [self.delegate respondsToSelector:@selector(longPressEndWithGridElementView:)]) {
                  [self.delegate longPressEndWithGridElementView:self];
              }
          }
          default:
              break;
      }
}

#pragma mark - 边缘拖动手势
- (void)leftPanGestureView:(UIPanGestureRecognizer *)panGesture{
    [self panAction:panGesture edge:PanViewEdgeLeft];
}

- (void)topPanGestureView:(UIPanGestureRecognizer *)panGesture{
    [self panAction:panGesture edge:PanViewEdgeTop];
}

- (void)rightPanGestureView:(UIPanGestureRecognizer *)panGesture{
    [self panAction:panGesture edge:PanViewEdgeRight];
}

- (void)bottomPanGestureView:(UIPanGestureRecognizer *)panGesture {
    [self panAction:panGesture edge:PanViewEdgeBottom];
}

//平移手势
- (void)panAction:(UIPanGestureRecognizer *)panGesture edge:(PanViewEdge)panViewEdge {
    UIView *view = panGesture.view;
    CGPoint touPoint = [panGesture translationInView:view];

    static int changeXorY = 0;    //0:X:左右   1:Y：上下
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        _startPoint = touPoint;
        _lastPoint = touPoint;
        _isStartPan = YES;
        changeXorY = 0;
        if(self.delegate && [self.delegate respondsToSelector:@selector(panGestureBeganWithGridElementView:panViewEdge:)]) {
            [self.delegate panGestureBeganWithGridElementView:self panViewEdge:panViewEdge];
        }
    }else if (panGesture.state == UIGestureRecognizerStateChanged){
        CGFloat change_X = touPoint.x - _startPoint.x;
        CGFloat change_Y = touPoint.y - _startPoint.y;
        
        if (_isStartPan) {
            
            if (fabs(change_X) > fabs(change_Y)) {
                changeXorY = 0;
            }else{
                changeXorY = 1;
            }
            _isStartPan = NO;
        }
        if (changeXorY == 0) {//左右
            
            if(panViewEdge == PanViewEdgeLeft) {
                if(self.delegate && [self.delegate respondsToSelector:@selector(leftOrRightPanX:panViewEdge:gridElementView:)]){
                    [self.delegate leftOrRightPanX:(touPoint.x - _lastPoint.x) panViewEdge:PanViewEdgeLeft gridElementView:self];
                }
            }
            else if(panViewEdge == PanViewEdgeRight)
            {
                if(self.delegate && [self.delegate respondsToSelector:@selector(leftOrRightPanX:panViewEdge:gridElementView:)]){
                    [self.delegate leftOrRightPanX:(touPoint.x - _lastPoint.x) panViewEdge:PanViewEdgeRight gridElementView:self];
                }
            }
            _lastPoint = touPoint;

        }else{//上下
            if(panViewEdge == PanViewEdgeTop)
            {
                if(self.delegate && [self.delegate respondsToSelector:@selector(topOrBottomPanX:panViewEdge:gridElementView:)]){
                    [self.delegate topOrBottomPanX:(touPoint.y - _lastPoint.y) panViewEdge:PanViewEdgeTop gridElementView:self];
                }
            }
            else if(panViewEdge == PanViewEdgeBottom)
            {
                if(self.delegate && [self.delegate respondsToSelector:@selector(topOrBottomPanX:panViewEdge:gridElementView:)]){
                    [self.delegate topOrBottomPanX:(touPoint.y - _lastPoint.y) panViewEdge:PanViewEdgeBottom gridElementView:self];
                }
            }
            _lastPoint = touPoint;
        }
        
    }else if (panGesture.state == UIGestureRecognizerStateEnded){
        if(self.delegate && [self.delegate respondsToSelector:@selector(panGestureEndWithGridElementView:)]){
            [self.delegate panGestureEndWithGridElementView:self];
        }
    }
}

//缩放手势
- (void)pinchSelectedViewAction:(UIPinchGestureRecognizer *)pinchGesture {
    
    CGFloat maxScale = kPinchMaxScale;
    
    if (pinchGesture.state == UIGestureRecognizerStateEnded)
    {
        if (self.imageView.width <= _originImgViewWidth) {

            self.imageView.width = self.originImgViewWidth;
            self.imageView.height = self.originImgViewHeight;
        }
        else if (self.imageView.width >= _originImgViewWidth * maxScale){

            self.imageView.width = self.originImgViewWidth * maxScale;
            self.imageView.height = self.originImgViewHeight * maxScale;
        }
        //设置contentSize
        self.scrollView.contentSize = CGSizeMake(self.imageView.width, self.imageView.height);
    }
    else
    {
//        NSLog(@"recognizer.scale:%f", pinchGesture.scale);
        CGFloat w = self.imageView.width * pinchGesture.scale;
        CGFloat h = self.imageView.height * pinchGesture.scale;
        
        if (w <= _originImgViewWidth)
        {
            w = _originImgViewWidth;
            h = _originImgViewHeight;
        }
        else if (w >= self.width * maxScale)
        {
            w = _originImgViewWidth * maxScale;
            h = _originImgViewHeight * maxScale;
        }

        CGFloat offsetX = w - self.imageView.width;
        CGFloat offsetY = h - self.imageView.height;
        self.imageView.width = w;
        self.imageView.height = h;
        pinchGesture.scale = 1.0;
        
        //设置contentSize
        self.scrollView.contentSize = CGSizeMake(self.imageView.width, self.imageView.height);
        //scrollView缩放从中间向四周扩散
        CGPoint offset = self.scrollView.contentOffset;
        offset.y = offset.y + offsetY / 2;
        offset.x = offset.x + offsetX / 2;
        
        if(offset.y < 0) {
            offset.y = 0;
        }
        
        if(offset.x < 0) {
            offset.x = 0;
        }
        
        [self.scrollView setContentOffset:offset animated:NO];
    }
    _pinchScale = self.imageView.width / self.width;
}

#pragma mark - lazy

- (UIView *)subBgView
{
    if(!_subBgView) {
        _subBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _subBgView.backgroundColor = [UIColor clearColor];
    }
    return _subBgView;
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.userInteractionEnabled = YES;
    }
    return _imageView;
}

- (UIScrollView *)scrollView
{
    if(!_scrollView)
    {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.alwaysBounceVertical = YES;// 垂直
        _scrollView.alwaysBounceHorizontal = YES; // 水平
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIView *)leftPanGestureView
{
    if(!_leftPanGestureView) {
        _leftPanGestureView = [[UIView alloc] init];
        _leftPanGestureView.backgroundColor = [UIColor clearColor];
        _leftPanGestureView.hidden = YES;
    }
    return _leftPanGestureView;
}

- (UIView *)rightPanGestureView
{
    if(!_rightPanGestureView) {
        _rightPanGestureView = [[UIView alloc] init];
        _rightPanGestureView.backgroundColor = [UIColor clearColor];
        _rightPanGestureView.hidden = YES;
    }
    return _rightPanGestureView;
}

- (UIView *)topPanGestureView
{
    if(!_topPanGestureView) {
        _topPanGestureView = [[UIView alloc] init];
        _topPanGestureView.backgroundColor = [UIColor clearColor];
        _topPanGestureView.hidden = YES;
    }
    return _topPanGestureView;
}

- (UIView *)bottomPanGestureView
{
    if(!_bottomPanGestureView) {
        _bottomPanGestureView = [[UIView alloc] init];
        _bottomPanGestureView.backgroundColor = [UIColor clearColor];
        _bottomPanGestureView.hidden = YES;
    }
    return _bottomPanGestureView;
}

- (UIView *)leftCanPanView
{
    if(!_leftCanPanView) {
        _leftCanPanView = [[UIView alloc] initWithFrame:CGRectZero];
        _leftCanPanView.backgroundColor = RGB(0, 74, 274);
        _leftCanPanView.hidden = YES;
        _leftCanPanView.layer.masksToBounds = YES;
        _leftCanPanView.layer.cornerRadius = kCanPanViewWidth / 2;
    }
    return _leftCanPanView;
}

- (UIView *)rightCanPanView
{
    if(!_rightCanPanView) {
        _rightCanPanView = [[UIView alloc] initWithFrame:CGRectZero];
        _rightCanPanView.backgroundColor = RGB(0, 74, 274);
        _rightCanPanView.hidden = YES;
        _rightCanPanView.layer.masksToBounds = YES;
        _rightCanPanView.layer.cornerRadius = kCanPanViewWidth / 2;
    }
    return _rightCanPanView;
}

- (UIView *)topCanPanView
{
    if(!_topCanPanView) {
        _topCanPanView = [[UIView alloc] initWithFrame:CGRectZero];
        _topCanPanView.backgroundColor = RGB(0, 74, 274);
        _topCanPanView.hidden = YES;
        _topCanPanView.layer.masksToBounds = YES;
        _topCanPanView.layer.cornerRadius = kCanPanViewWidth / 2;
    }
    return _topCanPanView;
}

- (UIView *)bottomCanPanView
{
    if(!_bottomCanPanView) {
        _bottomCanPanView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomCanPanView.backgroundColor = RGB(0, 74, 274);
        _bottomCanPanView.hidden = YES;
        _bottomCanPanView.layer.masksToBounds = YES;
        _bottomCanPanView.layer.cornerRadius = kCanPanViewWidth / 2;
    }
    return _bottomCanPanView;
}

@end
