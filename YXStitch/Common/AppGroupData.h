//
//  AppGroupData.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/8.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <ReplayKit/ReplayKit.h>
#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

static NSString * _Nonnull kUserDefaultFrame = @"KEY_BXL_DEFAULT_FRAME"; // 接收屏幕共享(屏幕流)监听的Key
static NSString * _Nonnull kUserDefaultState = @"KEY_BXL_DEFAULT_STATE"; // 接收屏幕共享(开始/结束 状态)监听的Key

static NSString * _Nonnull kPropFormat = @"format";
static NSString * _Nonnull kPropWidth = @"width";
static NSString * _Nonnull kPropHeight = @"height";
static NSString * _Nonnull kPropStrideY = @"strideY";
static NSString * _Nonnull kPropStrideU = @"strideU";
static NSString * _Nonnull kPropStrideV = @"strideV";
static NSString * _Nonnull kPropDataLength = @"dataLength";
static NSString * _Nonnull kPropData = @"data";
static NSString * _Nonnull kPropRotation = @"rotation";

@interface AppGroupData : NSObject
+ (NSDictionary *_Nonnull)packetWithSampleBuffer:(CMSampleBufferRef _Nullable )sampleBuffer;
@end

NS_ASSUME_NONNULL_END
