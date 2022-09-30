//
//  ImageEditViewController.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/9/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageEditViewController : UIViewController
@property (nonatomic ,strong)NSString *titleStr;
@property (nonatomic ,strong)UIImage *screenshotIMG;
@property (nonatomic ,assign)NSInteger type;
@property (nonatomic ,assign)BOOL isVer;//是竖拼还是横拼
@property (nonatomic ,strong)NSMutableArray *imgArr; //图片数组
@end

NS_ASSUME_NONNULL_END
