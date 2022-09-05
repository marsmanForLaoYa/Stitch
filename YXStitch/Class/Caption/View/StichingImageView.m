//
//  StichingImageView.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/24.
//

#import "StichingImageView.h"

@interface StichingImageView ()
@property (nonatomic, assign) CGPoint touchBeganPoint;
@property (nonatomic, assign) CGFloat offsetY;
//@property (nonatomic, strong) CALayer *coverLayer;
@end

@implementation StichingImageView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
        [self configViews];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
    
    }
    return self;
}

- (void)configViews{
    self.imageView.frame = self.bounds;
    [self addSubview:self.imageView];
}

- (void)setImage:(UIImage *)image{
    _image = image;
    _imageView.image = image;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
   // self.coverLayer.backgroundColor = randomColor.CGColor;
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.superview];
    _touchBeganPoint = point;
    if (self.touchBegan) {
        self.touchBegan(self);
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //self.coverLayer.backgroundColor = [UIColor clearColor].CGColor;
    if (self.touchEnd) {
        self.touchEnd(self);
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_editing) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.superview];
    CGFloat offsetY = point.y - _touchBeganPoint.y;
    if (self.touchMove) {
        self.touchMove(self, offsetY);
    }
    _touchBeganPoint = point;
     NSLog(@"我移动了%@",@(offsetY));
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //self.coverLayer.backgroundColor = [UIColor clearColor].CGColor;
    if (self.touchEnd) {
        self.touchEnd(self);
    }
}


- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (void)setEditing:(BOOL)editing {
    _editing = editing;
}
@end
