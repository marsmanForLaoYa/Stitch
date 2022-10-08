//
//  GridShowView.h
//  YXStitch
//
//  Created by mac_m11 on 2022/9/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GridShowView : UIView

@property (nonatomic, copy) NSArray *pictures;
@property (nonatomic, copy) NSDictionary *gridsDic;

@property (nonatomic, assign) CGFloat imagePadding;

- (void)setShowViewBackgroundColorWithHex:(NSString *)hex;

@end

@class GridShowImgView;
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

@protocol GridShowImgViewDelegate <NSObject>

- (void)leftOrRightPanX:(CGFloat)x
            panViewEdge:(PanViewEdge)panViewEdge
        gridElementView:(GridShowImgView *)gridElementView;

- (void)topOrBottomPanX:(CGFloat)y
            panViewEdge:(PanViewEdge)panViewEdge
        gridElementView:(GridShowImgView *)gridElementView;

- (void)panGestureBeganWithGridElementView:(GridShowImgView *)gridElementView
                               panViewEdge:(PanViewEdge)panViewEdge;

@end

@interface GridShowImgView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger column;
@property (nonatomic, copy) GridShowImgViewTapBlock gridShowImgViewTapBlock;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *leftPanGestureView;
@property (nonatomic, strong) UIView *topPanGestureView;
@property (nonatomic, strong) UIView *rightPanGestureView;
@property (nonatomic, strong) UIView *bottomPanGestureView;
@property (nonatomic, assign) GridPanEdge gridPanEdge;
@property (nonatomic, weak) id<GridShowImgViewDelegate> delegate;

- (void)showBorder;
- (void)clearBorder;
- (void)initGestureView;

@end

NS_ASSUME_NONNULL_END
