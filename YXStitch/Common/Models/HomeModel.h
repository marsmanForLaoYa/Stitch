//
//  HomeModel.h
//  XWNWS
//
//  Created by mac_m11 on 2022/8/16.
//

#import "XWModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeModel : XWModel

@property (nonatomic, copy) NSString *image;
@property (nonatomic, assign) NSInteger sort;
@property (nonatomic, copy) NSString *url;

@end

NS_ASSUME_NONNULL_END
