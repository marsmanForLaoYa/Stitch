//
//  CustomScrollView.m
//  YJMosaiDemo
//
//  Created by xwan-iossdk on 2022/9/26.
//  Copyright © 2022 zhangshuyue. All rights reserved.
//

#import "CustomScrollView.h"

@implementation CustomScrollView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
       // [self setupViews];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if(!self.dragging){
        [[self nextResponder] touchesBegan:touches withEvent:event];
        
    }
    [super touchesBegan:touches withEvent:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if(!self.dragging){
        [[self nextResponder] touchesEnded:touches withEvent:event];
    }
    [super touchesEnded:touches withEvent:event];
}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if(!self.dragging){
        [[self nextResponder] touchesMoved:touches withEvent:event];
    }
    [super touchesMoved:touches withEvent:event];
}

@end
