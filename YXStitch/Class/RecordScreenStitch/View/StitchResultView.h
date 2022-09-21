//
//  StitchResultView.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/15.
//

#import "BaseView.h"
#import "SZImageGenerator.h"
#import "SZScrollView.h"

NS_ASSUME_NONNULL_BEGIN
@interface StitchResultView : BaseView
@property (nonatomic,strong)  SZScrollView    *scrollView;
@property (nonatomic,copy)  dispatch_block_t completion;
@property (nonatomic, strong)SZImageGenerator *generator;
@property (nonatomic,strong)NSMutableArray *dataImageViews;

//- (id)initWithFrame:(CGRect)frame andGenerator :(SZImageGenerator *)generator;

- (instancetype)initWithImage:(UIImage *)image;
- (instancetype)initWithGenerator:(SZImageGenerator *)generator;
@end

NS_ASSUME_NONNULL_END
