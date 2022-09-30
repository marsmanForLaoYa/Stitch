//
//  ImageEditBottomView.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/9/20.
//

#import "BaseView.h"
#import "ImageEditMarkView.h"
NS_ASSUME_NONNULL_BEGIN

@interface ImageEditMarkView : BaseView
@property (nonatomic ,strong)UIButton *backBtn;
@property (nonatomic ,strong)UIButton *deleteBtn;
@property (nonatomic ,strong)UIButton *selectBtn;
@property (nonatomic ,assign)BOOL isVer;
@property (nonatomic ,copy)void(^btnClick)(NSInteger tag);
@end

NS_ASSUME_NONNULL_END
