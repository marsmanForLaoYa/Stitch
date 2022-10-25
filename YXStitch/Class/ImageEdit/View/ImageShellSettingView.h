//
//  ImageShellSettingView.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/9/27.
//

#import "BaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ImageShellSettingView : BaseView
@property (nonatomic ,strong)UIButton *selectBtn;
@property (nonatomic ,strong)UIButton *phoneTypeBtn;
@property (nonatomic ,assign)BOOL isVer;
@property (nonatomic ,copy)void(^btnClick)(NSInteger tag ,BOOL isSelected);
@property (nonatomic ,strong)UILabel *phoneTypeLab;
@property (nonatomic ,strong)UIImageView *phoneBKIMG;

@end

NS_ASSUME_NONNULL_END
