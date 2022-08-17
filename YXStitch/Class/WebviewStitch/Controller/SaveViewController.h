//
//  SaveViewController.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SaveViewController : UIViewController
@property (nonatomic ,strong)UIImage *screenshotIMG;
@property (nonatomic ,strong)NSString *urlStr;
@property (nonatomic ,assign)NSInteger type;//1=网页截图保存 2=拼图保存
@end

NS_ASSUME_NONNULL_END
