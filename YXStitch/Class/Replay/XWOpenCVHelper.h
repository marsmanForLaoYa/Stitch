//
//  MMOpenCVHelper.h
//  screenDemo
//
//  Created by mac_m11 on 2022/10/11.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#include "opencv2/core.hpp"
#include "opencv2/imgproc.hpp"
#include "opencv2/imgcodecs.hpp"
#include "opencv2/highgui.hpp"
#include <iostream>
#include <vector>



NS_ASSUME_NONNULL_BEGIN

@interface XWOpenCVHelper : NSObject

/// 平均值哈希算法
/// - Parameters:
///   - matSrc1: <#matSrc1 description#>
///   - matSrc2: <#matSrc2 description#>
int aHash(cv::Mat matSrc1, cv::Mat matSrc2);
//
/// image类型转换
/// - Parameter image: <#image description#>
+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
