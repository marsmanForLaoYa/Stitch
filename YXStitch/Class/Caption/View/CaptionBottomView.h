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
@property (nonatomic ,assign)NSInteger type;
@property (nonatomic ,strong)UILabel *typeLab;
@property (nonatomic ,strong)UILabel *preLab;
@end

NS_ASSUME_NONNULL_END
