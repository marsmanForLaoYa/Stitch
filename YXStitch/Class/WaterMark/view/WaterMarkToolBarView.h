//
//  WaterMarkToolBarView.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/16.
//

#import "BaseView.h"
#import "WaterColorSelectView.h"
NS_ASSUME_NONNULL_BEGIN

@protocol WaterMarkToolBarViewDelegate <NSObject>
@optional
- (void)changeWaterFontSize:(NSInteger)size;
- (void)changeWaterFontColor:(NSString *)color;
- (void)changeWaterText:(NSString *)text;
- (void)hintUser;
@end

@interface WaterMarkToolBarView : UIView
@property (nonatomic, assign) id<WaterMarkToolBarViewDelegate> delegate;
@property (nonatomic ,strong)WaterColorSelectView *colorSelectView;
@property (nonatomic ,assign)NSInteger selectIndex;
@property (nonatomic ,copy)void(^btnClick)(NSInteger tag);
@property (nonatomic ,assign)NSInteger type;
@property (nonatomic ,strong)UIButton *titleBtn;
@end

NS_ASSUME_NONNULL_END
