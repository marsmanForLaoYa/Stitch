//
//  WaterTitleView.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/17.
//

#import "BaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface WaterTitleView : BaseView
@property (nonatomic ,strong)UITextView *titleTV;
@property (nonatomic ,assign)NSInteger type;
@property (nonatomic ,copy)void(^btnClick)(NSInteger tag);
@end

NS_ASSUME_NONNULL_END
