//
//  CaptionViewController.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CaptionViewController : UIViewController
@property (nonatomic ,strong)NSMutableArray *dataArr;
@property (nonatomic ,assign)NSInteger type;//type == 1字幕 type = 2拼接

@end

NS_ASSUME_NONNULL_END
