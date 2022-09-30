//
//  GridShowView.m
//  YXStitch
//
//  Created by mac_m11 on 2022/9/26.
//

#import "GridShowView.h"
@class GridShowImgView;

#define kGridElementMinWidth 60
#define kGridElementMinHeight 60

@interface GridShowView ()<GridShowImgViewDelegate>

@property (nonatomic, strong) NSMutableArray *gridsImageViews;
@property (nonatomic, strong) NSMutableArray *bottomBelowImageViews;
@property (nonatomic, strong) NSMutableArray *bottomAboveImageViews;
@property (nonatomic, strong) NSMutableArray *topBelowImageViews;
@property (nonatomic, strong) NSMutableArray *topAboveImageViews;

@property (nonatomic, strong) NSMutableArray *leftToLeftImageViews;
@property (nonatomic, strong) NSMutableArray *leftToRightImageViews;
@property (nonatomic, strong) NSMutableArray *rightToLeftImageViews;
@property (nonatomic, strong) NSMutableArray *rightToRightImageViews;

@end

@implementation GridShowView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame: frame]){

        self.backgroundColor = RGB(255, 255, 255);
    }
    return self;
}

CGFloat padding = 15;
- (void)setGridsDic:(NSDictionary *)gridsDic
{
    
    _gridsDic = gridsDic;
    
    NSInteger rowsCount = [gridsDic[@"rowsCount"] integerValue];
    NSArray *rows = gridsDic[@"rows"];
    
    NSInteger index = 0;
    for (int i = 0; i < rows.count; i++) {
        NSDictionary *dicRows = rows[i];
        CGFloat start = [dicRows[@"start"] integerValue];
        NSInteger columnsCount = [dicRows[@"columnsCount"] integerValue];
        NSArray *columns = dicRows[@"columns"];
        
        //矩形框在x轴分了columnsCount份，每份的宽度
        CGFloat subImgViewWidth = (self.width - (columnsCount + 1) * padding) / columnsCount;
        //矩形框在y轴分了rowsCount份，每份的高度
        CGFloat subImgViewHeight = (self.height - (rowsCount + 1) * padding) / rowsCount;
        
        CGFloat left = start * subImgViewWidth + padding * (start + 1);
        for (int j = 0; j < columns.count; j++) {
            NSDictionary *dicColumn = columns[j];
            CGFloat width = [dicColumn[@"width"] floatValue];
            CGFloat height = [dicColumn[@"height"] floatValue];
            CGFloat margin = [dicColumn[@"margin"] floatValue] * (subImgViewWidth + padding);
            CGFloat top = [dicColumn[@"top"] floatValue];

            UIImage *image = self.pictures[index];

            CGFloat imageScale = 0;
            CGFloat imageHeight = 0;
            if (image) {
                imageScale = SCREEN_WIDTH / image.size.width;
                imageHeight = image.size.height * imageScale;
            }
            
            GridShowImgView *imageView;
            // top * subImgViewHeight为前面所有视图所占高度 (top + 1) * padding为padding的高度
            CGFloat imgViewTop = top * subImgViewHeight + (top + 1) * padding;
            //width * subImgViewWidth为前面所有视图所占宽度 (width - 1) * padding为padding的宽度
            CGFloat imgViewWidth = width * subImgViewWidth + (width - 1) * padding;
            //height * subImgViewHeight为当前视图所占高度 (height - 1) * padding为当前视图所占的padding高度
            CGFloat imgViewHeight = height * subImgViewHeight + (height - 1) * padding;
            if(self.gridsImageViews.count < self.pictures.count)
            {
                imageView = [self creatSubviewsWithFrame:CGRectMake(left + margin, imgViewTop, SCREEN_WIDTH, imageHeight) viewHeight:imgViewHeight viewWidth:imgViewWidth];
                
                imageView.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, imageHeight);
            }
            else
            {
                imageView = self.gridsImageViews[index];
                imageView.frame = CGRectMake(left + margin,imgViewTop, imgViewWidth, imgViewHeight);
                imageView.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, imageHeight);
            }
            imageView.image = self.pictures[index];
            //初始化view
            [imageView initGestureView];
            
            imageView.gridPanEdge = [self getPanEdgeWithImageView:imageView];
            
            NSLog(@"imageView.bottom:%f self.bottom:%f", imageView.bottom + padding, self.bottom);
            
            index ++;
            left += width * subImgViewWidth + (width - 1) * padding + padding;
        }
    }
}

GridShowImgView *lastShowImgView;
- (GridShowImgView *)creatSubviewsWithFrame:(CGRect)frame viewHeight:(CGFloat)viewHeight viewWidth:(CGFloat)viewWidth {
    GridShowImgView *subImgView = [[GridShowImgView alloc] initWithFrame:frame];
    @weakify(self);
    subImgView.gridShowImgViewTapBlock = ^(GridShowImgView * _Nonnull showImgView) {
        @strongify(self);
        //清除上一个边框
        [lastShowImgView clearBorder];
        //显示当前选中view的边框
        [showImgView showBorder];
        //记录当前选中的view
        lastShowImgView = showImgView;
    };
    subImgView.delegate = self;
    [self addSubview:subImgView];
    [self.gridsImageViews addObject:subImgView];
    subImgView.frame = CGRectMake(frame.origin.x, frame.origin.y, viewWidth, viewHeight);
    
//    NSLog(@"%@", NSStringFromCGRect(frame));
    return subImgView;
}

- (GridPanEdge)getPanEdgeWithImageView:(GridShowImgView *)imageView {
    GridPanEdge panEdge = GridPanEdgeNone;
    if(imageView.left != padding) {
        panEdge = panEdge | GridPanEdgeLeft;
    }
    
    if(imageView.top != padding) {
        panEdge = panEdge | GridPanEdgeTop;
    }
    
    if(imageView.right + padding != self.width) {
        panEdge = panEdge | GridPanEdgeRight;
    }
    
    if(imageView.bottom + padding != self.height) {
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

#pragma mark - GridShowImgViewDelegate
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

                    obj.right = obj.right + changeX;
                    //解决加起来要大于maxbottom的bug
                    if(obj.right > maxRight) {
                        obj.right = obj.right - (obj.right - maxRight);
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
                    obj.left = maxRight + padding;
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
                    obj.top = maxBottom + padding;
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

#pragma mark - analysis
- (void)getBottomBelowAndAbovePanViewArray:(GridShowImgView *)gridElementView array:(NSArray *)gridsArray {
    self.bottomBelowImageViews = [NSMutableArray array];
    self.bottomAboveImageViews = [NSMutableArray array];
    NSMutableArray *belowArray = [NSMutableArray array];
    @weakify(self);
    
    [self.bottomAboveImageViews addObject:gridElementView];
    //检测下方交叉的view
    [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if(![gridElementView isEqual:subImgView]) {
            if(fabs(gridElementView.bottom + padding - subImgView.top) <= 1) {
                
                if(![self judgeBottomAndTopIsNoOverlapBetweenView1:subImgView secondView:gridElementView])
                {//重叠
                    [belowArray addObject:subImgView];
                }
                
            }
        }
    }];
    
    [self.bottomBelowImageViews addObjectsFromArray:belowArray];
    
    NSMutableArray *aboveArray = [NSMutableArray array];
    //检测上方交叉的view
    [belowArray enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if(![gridElementView isEqual:subImgView]) {

            [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(![gridElementView isEqual:obj]) {
                    if(fabs(subImgView.top - padding - obj.bottom) <= 1) {
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
    
    NSMutableArray *secondBelowArray = [NSMutableArray array];
    //检测下方交叉的view
    [aboveArray enumerateObjectsUsingBlock:^(GridShowImgView *  _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        
        [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if(![gridElementView isEqual:obj]) {
                if(fabs(subImgView.bottom + padding - obj.top) <= 1) {
                    if(![self judgeBottomAndTopIsNoOverlapBetweenView1:obj secondView:subImgView])
                    {//重叠
                        if(![self.bottomBelowImageViews containsObject:obj]) {
                            [secondBelowArray addObject:obj];
                        }
                    }
                }
            }
        }];
    }];
    
    [self.bottomBelowImageViews addObjectsFromArray:secondBelowArray];
    
    NSMutableArray *secondAboveArray = [NSMutableArray array];
    //检测上方交叉的view
    [secondBelowArray enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if(![gridElementView isEqual:subImgView]) {

            [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(![gridElementView isEqual:obj]) {
                    if(fabs(subImgView.top - padding - obj.bottom) <= 1) {
                        if(![self judgeBottomAndTopIsNoOverlapBetweenView1:subImgView secondView:obj])
                        {//重叠
                            if(![self.bottomAboveImageViews containsObject:obj]) {
                                [secondAboveArray addObject:obj];
                            }
                        }
                    }
                }
            }];
        }
    }];
    [self.bottomAboveImageViews addObjectsFromArray:secondAboveArray];
    
    NSMutableArray *thirdBelowArray = [NSMutableArray array];
    //检测下方交叉的view
    [secondAboveArray enumerateObjectsUsingBlock:^(GridShowImgView *  _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        
        [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if(![gridElementView isEqual:obj]) {
                if(fabs(subImgView.bottom + padding - obj.top) <= 1) {
                    if(![self judgeBottomAndTopIsNoOverlapBetweenView1:obj secondView:subImgView])
                    {//重叠
                        if(![self.bottomBelowImageViews containsObject:obj]) {
                            [thirdBelowArray addObject:obj];
                        }
                    }
                }
            }
        }];
    }];
    
    [self.bottomBelowImageViews addObjectsFromArray:thirdBelowArray];
    
    NSMutableArray *thirdAboveArray = [NSMutableArray array];
    //检测上方交叉的view
    [thirdBelowArray enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if(![gridElementView isEqual:subImgView]) {

            [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(![gridElementView isEqual:obj]) {
                    if(fabs(subImgView.top - padding - obj.bottom) <= 1) {
                        if(![self judgeBottomAndTopIsNoOverlapBetweenView1:subImgView secondView:obj])
                        {//重叠
                            if(![self.bottomAboveImageViews containsObject:obj]) {
                                [thirdAboveArray addObject:obj];
                            }
                        }
                    }
                }
            }];
        }
    }];
    [self.bottomAboveImageViews addObjectsFromArray:thirdAboveArray];
}

- (void)getTopBelowAndAbovePanViewArray:(GridShowImgView *)gridElementView array:(NSArray *)gridsArray {
    self.topBelowImageViews = [NSMutableArray array];
    self.topAboveImageViews = [NSMutableArray array];
    NSMutableArray *aboveArray = [NSMutableArray array];
    
    [self.topBelowImageViews addObject:gridElementView];
    @weakify(self);
    //检测上方的view
    [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if(![gridElementView isEqual:subImgView]) {
            if(fabs(gridElementView.top - padding - subImgView.bottom) <= 1) {
                
                if(![self judgeBottomAndTopIsNoOverlapBetweenView1:subImgView secondView:gridElementView])
                {//重叠
                    [aboveArray addObject:subImgView];
                }
            }
        }
    }];
    
    [self.topAboveImageViews addObjectsFromArray:aboveArray];
    
    NSMutableArray *belowArray = [NSMutableArray array];
    //检测下方的view
    [aboveArray enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if(![gridElementView isEqual:subImgView]) {

            [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(![gridElementView isEqual:obj]) {
                    if(fabs(subImgView.bottom + padding - obj.top) <= 1) {
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
    
    NSMutableArray *secondAboveArray = [NSMutableArray array];
    //检测上方的view
    [belowArray enumerateObjectsUsingBlock:^(GridShowImgView *  _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        
        [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if(![gridElementView isEqual:obj]) {
                if(fabs(subImgView.top - padding - obj.bottom) <= 1) {
                    if(![self judgeBottomAndTopIsNoOverlapBetweenView1:obj secondView:subImgView])
                    {//重叠
                        if(![self.topAboveImageViews containsObject:obj]) {
                            [secondAboveArray addObject:obj];
                        }
                    }
                }
            }
        }];
    }];
    
    [self.topAboveImageViews addObjectsFromArray:secondAboveArray];
    
    NSMutableArray *secondBelowArray = [NSMutableArray array];
    //检测下方的view
    [secondAboveArray enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if(![gridElementView isEqual:subImgView]) {

            [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(![gridElementView isEqual:obj]) {
                    if(fabs(subImgView.bottom + padding - obj.top) <= 1) {
                        if(![self judgeBottomAndTopIsNoOverlapBetweenView1:subImgView secondView:obj])
                        {//重叠
                            if(![self.topBelowImageViews containsObject:obj]) {
                                [secondBelowArray addObject:obj];
                            }
                        }
                    }
                }
            }];
        }
    }];
    [self.topBelowImageViews addObjectsFromArray:secondBelowArray];
    
    NSMutableArray *thirdAboveArray = [NSMutableArray array];
    //检测上方的view
    [secondBelowArray enumerateObjectsUsingBlock:^(GridShowImgView *  _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        
        [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if(![gridElementView isEqual:obj]) {
                if(fabs(subImgView.top - padding - obj.bottom) <= 1) {
                    if(![self judgeBottomAndTopIsNoOverlapBetweenView1:obj secondView:subImgView])
                    {//重叠
                        if(![self.topAboveImageViews containsObject:obj]) {
                            [thirdAboveArray addObject:obj];
                        }
                    }
                }
            }
        }];
    }];
    
    [self.topAboveImageViews addObjectsFromArray:thirdAboveArray];
    
    NSMutableArray *thirdBelowArray = [NSMutableArray array];
    //检测下方的view
    [thirdAboveArray enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if(![gridElementView isEqual:subImgView]) {

            [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(![gridElementView isEqual:obj]) {
                    if(fabs(subImgView.bottom + padding - obj.top) <= 1) {
                        if(![self judgeBottomAndTopIsNoOverlapBetweenView1:subImgView secondView:obj])
                        {//重叠
                            if(![self.topBelowImageViews containsObject:obj]) {
                                [thirdBelowArray addObject:obj];
                            }
                        }
                    }
                }
            }];
        }
    }];
    [self.topBelowImageViews addObjectsFromArray:thirdBelowArray];
}

- (void)getLeftPanEdgeLeftAndRightPanViewArray:(GridShowImgView *)gridElementView array:(NSArray *)gridsArray {
    self.leftToLeftImageViews = [NSMutableArray array];
    self.leftToRightImageViews = [NSMutableArray array];
    
    NSMutableArray *leftArray = [NSMutableArray array];
    [self.leftToRightImageViews addObject:gridElementView];
    @weakify(self);
    //向左检测交叉的view
    [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if(![gridElementView isEqual:subImgView]) {
            if(fabs(gridElementView.left - padding - subImgView.right) <= 1) {
                
                if(![self judgeLeftAndRightIsNoOverlapBetweenView1:subImgView secondView:gridElementView])
                {//重叠
                    [leftArray addObject:subImgView];
                }
            }
        }
    }];
    [self.leftToLeftImageViews addObjectsFromArray:leftArray];
    
    NSMutableArray *rightArray = [NSMutableArray array];
    //向右检测交叉的view
    [leftArray enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if(![gridElementView isEqual:subImgView]) {

            [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(![gridElementView isEqual:obj]) {
                    if(fabs(subImgView.right + padding - obj.left) <= 1) {
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
    
    NSMutableArray *secondLeftArray = [NSMutableArray array];
    //向左检测交叉的view
    [rightArray enumerateObjectsUsingBlock:^(GridShowImgView *  _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        
        [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if(![gridElementView isEqual:obj]) {
                if(fabs(subImgView.left - padding - obj.right) <= 1) {
                    if(![self judgeLeftAndRightIsNoOverlapBetweenView1:obj secondView:subImgView])
                    {//重叠
                        if(![self.leftToLeftImageViews containsObject:obj]) {
                            [secondLeftArray addObject:obj];
                        }
                    }
                }
            }
        }];
    }];
    
    [self.leftToLeftImageViews addObjectsFromArray:secondLeftArray];
    
    NSMutableArray *secondRightArray = [NSMutableArray array];
    //向右检测交叉的view
    [secondLeftArray enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if(![gridElementView isEqual:subImgView]) {

            [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(![gridElementView isEqual:obj]) {
                    if(fabs(subImgView.right + padding - obj.left) <= 1) {
                        if(![self judgeLeftAndRightIsNoOverlapBetweenView1:subImgView secondView:obj])
                        {//重叠
                            if(![self.leftToRightImageViews containsObject:obj]) {
                                [secondRightArray addObject:obj];
                            }
                        }
                    }
                }
            }];
        }
    }];
    
    [self.leftToRightImageViews addObjectsFromArray:secondRightArray];
    
    NSMutableArray *thirdLeftArray = [NSMutableArray array];
    //向左检测交叉的view
    [secondRightArray enumerateObjectsUsingBlock:^(GridShowImgView *  _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        
        [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if(![gridElementView isEqual:obj]) {
                if(fabs(subImgView.left - padding - obj.right) <= 1) {
                    if(![self judgeLeftAndRightIsNoOverlapBetweenView1:obj secondView:subImgView])
                    {//重叠
                        if(![self.leftToLeftImageViews containsObject:obj]) {
                            [thirdLeftArray addObject:obj];
                        }
                    }
                }
            }
        }];
    }];
    
    [self.leftToLeftImageViews addObjectsFromArray:thirdLeftArray];
    
    NSMutableArray *thirdRightArray = [NSMutableArray array];
    //向右检测交叉的view
    [thirdLeftArray enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if(![gridElementView isEqual:subImgView]) {

            [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(![gridElementView isEqual:obj]) {
                    if(fabs(subImgView.right + padding - obj.left) <= 1) {
                        if(![self judgeLeftAndRightIsNoOverlapBetweenView1:subImgView secondView:obj])
                        {//重叠
                            if(![self.leftToRightImageViews containsObject:obj]) {
                                [thirdRightArray addObject:obj];
                            }
                        }
                    }
                }
            }];
        }
    }];
    
    [self.leftToRightImageViews addObjectsFromArray:thirdRightArray];
}

- (void)getRightPanEdgeLeftAndRightPanViewArray:(GridShowImgView *)gridElementView array:(NSArray *)gridsArray {
    
    self.rightToLeftImageViews = [NSMutableArray array];
    self.rightToRightImageViews = [NSMutableArray array];
    
    [self.rightToLeftImageViews addObject:gridElementView];
    
    NSMutableArray *rightArray = [NSMutableArray array];
    @weakify(self);
    //向右检测view
    [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if(![gridElementView isEqual:subImgView]) {
            if(fabs(gridElementView.right + padding - subImgView.left) <= 1) {
                
                if(![self judgeLeftAndRightIsNoOverlapBetweenView1:subImgView secondView:gridElementView])
                {//重叠
                    [rightArray addObject:subImgView];
                }
            }
        }
    }];
    
    [self.rightToRightImageViews addObjectsFromArray:rightArray];
    
    NSMutableArray *leftArray = [NSMutableArray array];
    //向左检测交叉的view
    [rightArray enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if(![gridElementView isEqual:subImgView]) {

            [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(![gridElementView isEqual:obj]) {
                    if(fabs(subImgView.left - padding - obj.right) <= 1) {
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
    
    NSMutableArray *secondRightArray = [NSMutableArray array];
    //向右检测交叉的view
    [leftArray enumerateObjectsUsingBlock:^(GridShowImgView *  _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        
        [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if(![gridElementView isEqual:obj]) {
                if(fabs(subImgView.right + padding - obj.left) <= 1) {
                    if(![self judgeLeftAndRightIsNoOverlapBetweenView1:obj secondView:subImgView])
                    {//重叠
                        if(![self.rightToRightImageViews containsObject:obj]) {
                            [secondRightArray addObject:obj];
                        }
                    }
                }
            }
        }];
    }];
    
    [self.rightToRightImageViews addObjectsFromArray:secondRightArray];
    
    NSMutableArray *secondLeftArray = [NSMutableArray array];
    //向左检测交叉的view
    [secondRightArray enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if(![gridElementView isEqual:subImgView]) {

            [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(![gridElementView isEqual:obj]) {
                    if(fabs(subImgView.left - padding - obj.right) <= 1) {
                        if(![self judgeLeftAndRightIsNoOverlapBetweenView1:subImgView secondView:obj])
                        {//重叠
                            if(![self.rightToLeftImageViews containsObject:obj]) {
                                [secondLeftArray addObject:obj];
                            }
                        }
                    }
                }
            }];
        }
    }];
    
    [self.rightToLeftImageViews addObjectsFromArray:secondLeftArray];
    
    NSMutableArray *thirdRightArray = [NSMutableArray array];
    //向右检测交叉的view
    [secondLeftArray enumerateObjectsUsingBlock:^(GridShowImgView *  _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        
        [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if(![gridElementView isEqual:obj]) {
                if(fabs(subImgView.right + padding - obj.left) <= 1) {
                    if(![self judgeLeftAndRightIsNoOverlapBetweenView1:obj secondView:subImgView])
                    {//重叠
                        if(![self.rightToRightImageViews containsObject:obj]) {
                            [thirdRightArray addObject:obj];
                        }
                    }
                }
            }
        }];
    }];
    
    [self.rightToRightImageViews addObjectsFromArray:thirdRightArray];
    
    NSMutableArray *thirdLeftArray = [NSMutableArray array];
    //向左检测交叉的view
    [thirdRightArray enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull subImgView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if(![gridElementView isEqual:subImgView]) {

            [self.gridsImageViews enumerateObjectsUsingBlock:^(GridShowImgView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(![gridElementView isEqual:obj]) {
                    if(fabs(subImgView.left - padding - obj.right) <= 1) {
                        if(![self judgeLeftAndRightIsNoOverlapBetweenView1:subImgView secondView:obj])
                        {//重叠
                            if(![self.rightToLeftImageViews containsObject:obj]) {
                                [thirdLeftArray addObject:obj];
                            }
                        }
                    }
                }
            }];
        }
    }];
    
    [self.rightToLeftImageViews addObjectsFromArray:thirdLeftArray];
}

//判断左右边距 是否重叠
- (BOOL)judgeBottomAndTopIsNoOverlapBetweenView1:(GridShowImgView *)view1 secondView:(GridShowImgView *)view2 {
    if(
        (view1.left <= view2.left && view1.right + padding > view2.left && view1.right <= view2.right) ||
        (view1.left >= view2.left && view1.right <= view2.right) ||
        (view1.left >= view2.left && view1.left - padding < view2.right && view1.right >= view2.right) ||
        (view1.left <= view2.left && view1.right >= view2.right)
       ) {//重叠

        return NO;
    }
    
    return YES;
}

//判断上下边距 是否重叠
- (BOOL)judgeLeftAndRightIsNoOverlapBetweenView1:(GridShowImgView *)view1 secondView:(GridShowImgView *)view2 {
    if(
       (view1.top <= view2.top && view1.bottom + padding > view2.top && view1.bottom < view2.bottom) ||
       (view1.top >= view2.top && view1.bottom < view2.bottom) ||
       (view1.top > view2.top && view1.top - padding < view2.bottom && view1.bottom >= view2.bottom) ||
       (view1.top <= view2.top && view1.bottom >= view2.bottom)
       ) {//重叠

        return NO;
    }
    
    return YES;
}

@end

#define kCanPanViewMaxHeight 100
#define kCanPanViewMinHeight 30
#define kCanPanViewWidth 10
@interface GridShowImgView ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIView *leftCanPanView;
@property (nonatomic, strong) UIView *topCanPanView;
@property (nonatomic, strong) UIView *rightCanPanView;
@property (nonatomic, strong) UIView *bottomCanPanView;

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
        self.clipsToBounds = YES;

        [self configViews];
    }
    return self;
}

- (void)configViews{
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSelectedViewAction)];
    [self addGestureRecognizer:tap];
    
    self.scrollView.frame = self.bounds;
    [self addSubview:self.scrollView];
    
    [self addSubview:self.leftCanPanView];
    [self addSubview:self.rightCanPanView];
    [self addSubview:self.topCanPanView];
    [self addSubview:self.bottomCanPanView];
    
    [self addSubview:self.leftPanGestureView];
    [self addSubview:self.topPanGestureView];
    [self addSubview:self.rightPanGestureView];
    [self addSubview:self.bottomPanGestureView];

    [self addGestureWithView:self.leftPanGestureView action:@selector(leftPanGestureView:)];
    [self addGestureWithView:self.topPanGestureView action:@selector(topPanGestureView:)];
    [self addGestureWithView:self.rightPanGestureView action:@selector(rightPanGestureView:)];
    [self addGestureWithView:self.bottomPanGestureView action:@selector(bottomPanGestureView:)];
    
    self.imageView.frame = self.bounds;
    self.imageView.width = SCREEN_WIDTH;
    [self.scrollView addSubview:self.imageView];
}

#pragma mark - setter
- (void)setImage:(UIImage *)image{
    _image = image;
    _imageView.image = image;
}

- (void)setGridPanEdge:(GridPanEdge)gridPanEdge
{
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

- (void)layoutSubviews
{
    CGFloat edge = 20;
    self.leftPanGestureView.frame = CGRectMake(0, 0, edge, self.height);
    self.rightPanGestureView.frame = CGRectMake(self.width - edge, 0, edge, self.height);
    self.topPanGestureView.frame = CGRectMake(0, 0, self.width, edge);
    self.bottomPanGestureView.frame = CGRectMake(0, self.height - edge, self.width, edge);
    self.scrollView.frame = self.bounds;
    
    CGFloat fixMarginMax = 40;
    CGFloat marginMin = 20;
    CGFloat leftCanPanViewHeitht = 0;
    if(self.height > fixMarginMax * 2 + kCanPanViewMaxHeight) {
        leftCanPanViewHeitht = kCanPanViewMaxHeight;
    }
    
    
    self.leftCanPanView.frame = CGRectMake(0, 0, edge, self.height);
    self.rightCanPanView.frame = CGRectMake(self.width - edge, 0, edge, self.height);
    self.topCanPanView.frame = CGRectMake(0, 0, self.width, edge);
    self.bottomCanPanView.frame = CGRectMake(0, self.height - edge, self.width, edge);
    
//    self.leftCanPanView.width = kCanPanViewWidth;
//    if(self.leftCanPanView.height < kCanPanViewMaxHeight && self.leftCanPanView.height > kCanPanViewMinHeight) {
//
//        self.leftCanPanView.left = - kCanPanViewWidth / 2;
//        self.leftCanPanView.height = self.height - 2 * 20;
//        self.leftCanPanView.centerY = self.centerY;
//    }
//    else {
//        if(self.leftCanPanView.height <= kCanPanViewMinHeight) {
//            self.leftCanPanView.left = - kCanPanViewWidth / 2;
//            self.leftCanPanView.height = kCanPanViewMinHeight;
//            self.leftCanPanView.centerY = self.centerY;
//        }
//
//        if(self.leftCanPanView.height >= kCanPanViewMaxHeight) {
//            self.leftCanPanView.left = - kCanPanViewWidth / 2;
//            self.leftCanPanView.height = kCanPanViewMaxHeight;
//            self.leftCanPanView.centerY = self.centerY;
//        }
//    }
}

#pragma mark - Method
- (void)initGestureView {
    self.leftPanGestureView.hidden = YES;
    self.rightPanGestureView.hidden = YES;
    self.topPanGestureView.hidden = YES;
    self.bottomPanGestureView.hidden = YES;
}

- (void)showBorder
{
    self.leftCanPanView.hidden = YES;
    self.rightCanPanView.hidden = YES;
    self.topCanPanView.hidden = YES;
    self.bottomCanPanView.hidden = YES;
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
    self.layer.borderColor = RGB(0, 74, 274).CGColor;
    self.layer.borderWidth = 3.0;
}

- (void)addGestureWithView:(UIView *)view action:(nullable SEL)action {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:action];
    [view addGestureRecognizer:pan];
}

- (void)clearBorder {
    self.layer.borderColor = [UIColor clearColor].CGColor;
    self.layer.borderWidth = 0.0;
}

#pragma mark - gesture
- (void)tapSelectedViewAction {
    if(_gridShowImgViewTapBlock) {
        _gridShowImgViewTapBlock(self);
    }
}

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

    }
}

#pragma mark - lazy
- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (UIScrollView *)scrollView
{
    if(!_scrollView)
    {
        _scrollView = [[UIScrollView alloc] init];
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
        _leftPanGestureView.backgroundColor = [UIColor redColor];
        _leftPanGestureView.hidden = YES;
    }
    return _leftPanGestureView;
}

- (UIView *)rightPanGestureView
{
    if(!_rightPanGestureView) {
        _rightPanGestureView = [[UIView alloc] init];
        _rightPanGestureView.backgroundColor = [UIColor redColor];
        _rightPanGestureView.hidden = YES;
    }
    return _rightPanGestureView;
}

- (UIView *)topPanGestureView
{
    if(!_topPanGestureView) {
        _topPanGestureView = [[UIView alloc] init];
        _topPanGestureView.backgroundColor = [UIColor redColor];
        _topPanGestureView.hidden = YES;
    }
    return _topPanGestureView;
}

- (UIView *)bottomPanGestureView
{
    if(!_bottomPanGestureView) {
        _bottomPanGestureView = [[UIView alloc] init];
        _bottomPanGestureView.backgroundColor = [UIColor redColor];
        _bottomPanGestureView.hidden = YES;
    }
    return _bottomPanGestureView;
}

- (UIView *)leftCanPanView
{
    if(!_leftCanPanView) {
        _leftCanPanView = [[UIView alloc] initWithFrame:CGRectMake(0, -kCanPanViewWidth / 2, kCanPanViewWidth, self.height)];
        _leftCanPanView.backgroundColor = RGB(0, 74, 274);
        _leftCanPanView.hidden = YES;
    }
    return _leftCanPanView;
}

- (UIView *)rightCanPanView
{
    if(!_rightCanPanView) {
        _rightCanPanView = [[UIView alloc] initWithFrame:CGRectZero];
        _rightCanPanView.backgroundColor = RGB(0, 74, 274);
        _rightCanPanView.hidden = YES;
    }
    return _rightCanPanView;
}

- (UIView *)topCanPanView
{
    if(!_topCanPanView) {
        _topCanPanView = [[UIView alloc] initWithFrame:CGRectZero];
        _topCanPanView.backgroundColor = RGB(0, 74, 274);
        _topCanPanView.hidden = YES;
    }
    return _topCanPanView;
}

- (UIView *)bottomCanPanView
{
    if(!_bottomCanPanView) {
        _bottomCanPanView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomCanPanView.backgroundColor = RGB(0, 74, 274);
        _bottomCanPanView.hidden = YES;
    }
    return _bottomCanPanView;
}

@end
