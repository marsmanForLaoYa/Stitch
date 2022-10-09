//
//  GridEditView.h
//  YXStitch
//
//  Created by mac_m11 on 2022/10/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GridEditView : UIView

@property (nonatomic, copy) void(^btnClick)(NSInteger tag);

@end

NS_ASSUME_NONNULL_END
