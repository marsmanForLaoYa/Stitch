//
//  imageShellSelectView.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/9/29.
//

#import "BaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface imageShellSelectView : BaseView
@property (nonatomic ,copy)void(^selectClick)(NSString *str ,UIColor *color,NSInteger tag);
@property (nonatomic ,strong)UIButton *selectColorBtn;
@end

NS_ASSUME_NONNULL_END
