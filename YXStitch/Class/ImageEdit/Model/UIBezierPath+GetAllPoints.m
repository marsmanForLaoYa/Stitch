//
//  UIBezierPath+GetAllPoints.m
//  HYEfficientWhiteBoard
//
//  Created by xiaobin Tang on 2021/5/31.
//  Copyright © 2021 xiaobin Tang. All rights reserved.
//

#import "UIBezierPath+GetAllPoints.h"

#define VALUE(_INDEX_) [NSValue valueWithCGPoint:points[_INDEX_]]

@implementation UIBezierPath (GetAllPoints)

void getPointsFromBezier(void *info,const CGPathElement *element){
    NSMutableArray *bezierPoints = (__bridge NSMutableArray *)info;
    CGPathElementType type = element->type;
    CGPoint *points = element->points;
    
    if (type != kCGPathElementCloseSubpath) {
        [bezierPoints addObject:VALUE(0)];
        if ((type != kCGPathElementAddLineToPoint) && (type != kCGPathElementMoveToPoint)) {
            [bezierPoints addObject:VALUE(1)];
        }
    }
    
    if (type == kCGPathElementAddCurveToPoint) {
        [bezierPoints addObject:VALUE(2)];
    }
    
}
 
- (NSMutableArray *)points{
    NSMutableArray *points = [NSMutableArray array];
    CGPathApply(self.CGPath, (__bridge void *)points, getPointsFromBezier);
    return points;
    
}

@end
