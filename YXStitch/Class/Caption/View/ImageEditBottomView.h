//
//  ImageEditBottomView.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/9/20.
//

#import "BaseView.h"
#import "ImageEditBottomView.h"
NS_ASSUME_NONNULL_BEGIN

@interface ImageEditBottomView : BaseView
@property (nonatomic ,strong)UIButton *backBtn;
@property (nonatomic ,strong)UIButton *deleteBtn;
@property (nonatomic ,strong)UIButton *selectBtn;
@property (nonatomic ,copy)void(^btnClick)(NSInteger tag);
@end

NS_ASSUME_NONNULL_END
