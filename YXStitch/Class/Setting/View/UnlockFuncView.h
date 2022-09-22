//
//  UnlockFuncView.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/11.
//

#import "BaseView.h"

NS_ASSUME_NONNULL_BEGIN
@protocol UnlockFuncViewDelegate <NSObject>
@optional
- (void)btnClickWithTag:(NSInteger)tag;
@end
@interface UnlockFuncView : BaseView
@property (nonatomic, assign) id<UnlockFuncViewDelegate> delegate;
@property (nonatomic, assign) NSInteger type;//1=一键删除原图 2=自定义水印设置 =3 图片数量限制 =4带壳截图
@end

NS_ASSUME_NONNULL_END
