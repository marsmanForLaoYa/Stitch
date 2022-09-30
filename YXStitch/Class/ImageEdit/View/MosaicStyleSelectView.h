//
//  mosaic MosaicStyleSelectView.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/9/23.
//

#import "BaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MosaicStyleSelectView : BaseView
@property (nonatomic ,strong)UIButton *selectBtn;
@property (nonatomic ,copy)void(^shapeBtnClick)(NSInteger tag);
@property (nonatomic ,copy)void(^styleBtnClick)(NSInteger tag);
@end

NS_ASSUME_NONNULL_END
