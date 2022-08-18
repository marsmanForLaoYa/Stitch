//
//  ColorPlateView.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/17.
//

#import "BaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ColorPlateView : BaseView
@property (nonatomic ,copy)void(^btnClick)(NSInteger tag);
@property (nonatomic ,strong)UILabel *colorLab;
@end

NS_ASSUME_NONNULL_END
