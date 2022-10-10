//
//  StitchingButton.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/27.
//

#import "StitchingButton.h"

@interface StitchingButton ()
@property (nonatomic, assign) CGPoint touchBeganPoint;
@property (nonatomic, assign) CGFloat offsetY;
//@property (nonatomic, strong) CALayer *coverLayer;
@end

@implementation StitchingButton

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
//        self = [UIButton buttonWithType:UIButtonTypeSystem];
    }
    return self;
}

- (void)configViews{
    self.imgView.frame = self.bounds;
    [self addSubview:self.imgView];
}

- (void)setImage:(UIImage *)image{
    _image = image;
    _imgView.image = image;
    _imgView.userInteractionEnabled = YES;
}

- (UIImageView *)imgView{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
    }
    return _imgView;
}

- (void)setEditing:(BOOL)editing {
    _editing = editing;
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event{
    [[self nextResponder] touchesBegan:touches withEvent:event];
    [super touchesBegan:touches withEvent:event];
}
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event{
    [[self nextResponder] touchesMoved:touches withEvent:event];
    [super touchesMoved:touches withEvent:event];
}
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event{
    [[self nextResponder] touchesEnded:touches withEvent:event];
    [super touchesEnded:touches withEvent:event];
}

@end
