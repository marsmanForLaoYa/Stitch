//
//  GuiderVisitorView.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/9/1.
//

#import "BaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface GuiderVisitorView : BaseView
@property (nonatomic ,copy)void(^btnClick)(void);
@property (nonatomic, strong)UIPageControl *pageC;  //页码
@end

NS_ASSUME_NONNULL_END
