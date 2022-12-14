//
//  CaptionViewController.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/19.
//

#import <UIKit/UIKit.h>
#import "SZImageGenerator.h"
NS_ASSUME_NONNULL_BEGIN

@interface CaptionViewController : UIViewController
@property (nonatomic ,strong)NSMutableArray *dataArr;
@property (nonatomic ,strong)NSMutableArray *editImgArr;
@property (nonatomic ,assign)NSInteger type;//type == 1字幕 type = 2拼接 type=4 长截图拼接 type=5 单图裁切
@property (nonatomic ,strong)SZImageGenerator *gengrator;

@end

NS_ASSUME_NONNULL_END
