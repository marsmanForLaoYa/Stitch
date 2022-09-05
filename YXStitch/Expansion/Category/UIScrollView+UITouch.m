//
//  UIScrollView+UITouch.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/23.
//

#import "UIScrollView+UITouch.h"

@implementation UIScrollView (UITouch)

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event{
    [super touchesBegan:touches withEvent:event];
    if ( !self.dragging )
    {
        [[self nextResponder] touchesBegan:touches withEvent:event];
    }
}
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event{
    [super touchesMoved:touches withEvent:event];
    if ( !self.dragging )
    {
        [[self nextResponder] touchesMoved:touches withEvent:event];
    }
}
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event{
    [super touchesEnded:touches withEvent:event];
    if ( !self.dragging )
    {
        [[self nextResponder] touchesEnded:touches withEvent:event];
    }
}
@end
