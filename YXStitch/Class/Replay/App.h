//
//  App.h
//  YXStitch
//
//  Created by mac_m11 on 2022/10/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface App : NSObject

+ (instancetype)sharedInstance;
@property (nonatomic ,strong)NSURL *videoURL;
@end

NS_ASSUME_NONNULL_END
