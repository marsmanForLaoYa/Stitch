//
//  WaterColorSelectView.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/17.
//

#import "BaseView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol WaterColorSelectViewDelegate <NSObject>
@optional
- (void)changeWaterFontSize:(NSInteger)size;
- (void)changeWaterFontColor:(NSString *)color;
@end


@interface WaterColorSelectView : BaseView
@property (nonatomic, assign) id<WaterColorSelectViewDelegate> delegate;
@property (nonatomic ,strong)NSMutableArray *colorArray;
@property (nonatomic, strong)UISlider *paintSlider;
@property (nonatomic ,copy)void(^moreColorClick)(void);
@end

NS_ASSUME_NONNULL_END
