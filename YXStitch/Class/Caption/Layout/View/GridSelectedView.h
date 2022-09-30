//
//  GridView.h
//  YXStitch
//
//  Created by mac_m11 on 2022/9/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^GridSelectedItemBlock)(NSInteger index);

@interface GridSelectedView : UIView

@property (nonatomic, strong) NSArray *grids;
@property (nonatomic, copy) GridSelectedItemBlock gridSelectedItemBlock;

@end

NS_ASSUME_NONNULL_END
