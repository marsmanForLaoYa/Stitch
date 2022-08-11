//
//  HomeViewController.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/8.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeViewController : UIViewController
@property (nonatomic ,copy)void(^btnClick)(NSMutableArray *arr);
@property (nonatomic ,strong)NSMutableArray *textArr;
@end

NS_ASSUME_NONNULL_END
