//
//  PaintPath.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/9/21.
//

#import "PaintPath.h"

@implementation PaintPath
+ (instancetype)paintPathWithLineWidth:(CGFloat)width
                            startPoint:(CGPoint)startP{
    PaintPath * path = [[self alloc] init];
    path.lineWidth = width;
    path.lineCapStyle = kCALineCapButt;
    path.lineJoinStyle = kCALineCapButt;
    [path moveToPoint:startP];
    return path;
}

@end
