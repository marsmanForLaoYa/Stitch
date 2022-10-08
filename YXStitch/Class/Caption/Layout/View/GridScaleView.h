//
//  GridScaleView.h
//  YXStitch
//
//  Created by mac_m11 on 2022/10/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^GridScaleItemSelectedBlock)(NSInteger scaleWidth, NSInteger scaleHeight);
@interface GridScaleView : UIView

@property (nonatomic, copy) NSArray *scales;
@property (nonatomic, copy) GridScaleItemSelectedBlock gridScaleItemSelectedBlock;

@end

NS_ASSUME_NONNULL_END
