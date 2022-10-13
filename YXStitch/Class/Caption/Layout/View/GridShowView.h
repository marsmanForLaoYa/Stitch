//
//  GridShowView.h
//  YXStitch
//
//  Created by mac_m11 on 2022/9/26.
//

#import <UIKit/UIKit.h>
@class GridShowImgView;
NS_ASSUME_NONNULL_BEGIN
typedef void(^GridShowViewSelecedImageBlock) (UIImage *image);
@interface GridShowView : UIView

@property (nonatomic, copy) NSArray *pictures;
@property (nonatomic, copy) NSDictionary *gridsDic;
@property (nonatomic, assign) CGFloat imagePadding;
@property (nonatomic, copy) GridShowViewSelecedImageBlock gridShowViewSelecedImageBlock;
@property (nonatomic, strong) GridShowImgView *lastShowImgView;
- (void)setShowViewBackgroundColorWithHex:(NSString *)hex;
- (void)clearSelectedShowImgView;
//清除选中的view上的样式
- (void)changeSelectedShowImgViewWithImage:(UIImage *)image;

@end

typedef void (^GridShowImgViewTapBlock)(GridShowImgView *showImgView);

typedef NS_OPTIONS(NSUInteger, GridPanEdge) {
    GridPanEdgeNone   = 0,
    GridPanEdgeTop    = 1 << 0,
    GridPanEdgeLeft   = 1 << 1,
    GridPanEdgeBottom = 1 << 2,
    GridPanEdgeRight  = 1 << 3,
    GridPanEdgeAll    = GridPanEdgeTop | GridPanEdgeLeft | GridPanEdgeBottom | GridPanEdgeRight
};

typedef NS_ENUM(NSUInteger, PanViewEdge) {
    PanViewEdgeTop    = 0,
    PanViewEdgeLeft,
    PanViewEdgeBottom,
    PanViewEdgeRight,
};

//typedef NS_OPTIONS(NSUInteger, PaddingEdge) {
//
//    PaddingEdgeNone   = 0,
//    PaddingEdgeTop    = 1 << 0,
//    PaddingEdgeLeft   = 1 << 1,
//    PaddingEdgeBottom = 1 << 2,
//    PaddingEdgeRight  = 1 << 3,
//    PaddingEdgeAll    = PaddingEdgeTop | PaddingEdgeLeft | PaddingEdgeBottom | PaddingEdgeRight
//};

@protocol GridShowImgViewDelegate <NSObject>

- (void)leftOrRightPanX:(CGFloat)x
            panViewEdge:(PanViewEdge)panViewEdge
        gridElementView:(GridShowImgView *)gridElementView;

- (void)topOrBottomPanX:(CGFloat)y
            panViewEdge:(PanViewEdge)panViewEdge
        gridElementView:(GridShowImgView *)gridElementView;

- (void)panGestureBeganWithGridElementView:(GridShowImgView *)gridElementView
                               panViewEdge:(PanViewEdge)panViewEdge;
- (void)panGestureEndWithGridElementView:(GridShowImgView *)gridElementView;

@end

@interface GridShowImgView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) CGFloat imagePadding;
@property (nonatomic, copy) GridShowImgViewTapBlock gridShowImgViewTapBlock;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *leftPanGestureView;
@property (nonatomic, strong) UIView *topPanGestureView;
@property (nonatomic, strong) UIView *rightPanGestureView;
@property (nonatomic, strong) UIView *bottomPanGestureView;
@property (nonatomic, assign) GridPanEdge gridPanEdge;
//@property (nonatomic, assign) PaddingEdge paddingEdge;
@property (nonatomic, weak) id<GridShowImgViewDelegate> delegate;

- (void)showBorder;
- (void)clearBorder;
- (void)initGestureView;

@end

NS_ASSUME_NONNULL_END
