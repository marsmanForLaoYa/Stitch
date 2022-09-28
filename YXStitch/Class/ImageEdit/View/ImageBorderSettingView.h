//
//  ImageBorderSettingView.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/9/27.
//

#import "BaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ImageBorderSettingView : BaseView
@property (nonatomic ,strong)UIButton *selectBtn;
@property (nonatomic ,copy)void(^btnClick)(NSInteger tag);
@end

NS_ASSUME_NONNULL_END
