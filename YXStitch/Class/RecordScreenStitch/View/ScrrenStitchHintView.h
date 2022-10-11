//
//  ScrrenStitchHintView.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/15.
//

#import "BaseView.h"
#import "SZImageMergeInfo.h"
#import "SZImageGenerator.h"
#import <Photos/Photos.h>
#import "StitchResultView.h"
NS_ASSUME_NONNULL_BEGIN

@protocol ScrrenStitchHintViewDelegate <NSObject>
@optional
- (void)stitchBtnClickWithTag:(NSInteger)tag;
- (void)showResult:(SZImageGenerator *)result;
@end

@interface ScrrenStitchHintView : BaseView
@property (nonatomic, assign) id<ScrrenStitchHintViewDelegate> delegate;
@property (nonatomic ,assign)NSInteger type; //type= 1无长图 type=2有长图
@property (nonatomic ,strong)UIView *bottomView;
@property (nonatomic ,strong)NSMutableArray *arr;

@end

NS_ASSUME_NONNULL_END
