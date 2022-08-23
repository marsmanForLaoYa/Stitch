//
//  CaptionBottomView.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/19.
//

#import "BaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CaptionBottomView : BaseView
@property (nonatomic ,copy)void(^btnClick)(NSInteger tag);
@end

NS_ASSUME_NONNULL_END
