//
//  ImageEditBottomView.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/9/21.
//

#import "BaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ImageEditBottomView : BaseView
@property (nonatomic ,copy)void(^btnClick)(NSInteger tag);
@end

NS_ASSUME_NONNULL_END
