//
//  UrlInvalidHintView.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/9.
//

#import "UrlInvalidHintView.h"

@implementation UrlInvalidHintView
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 16;
        self.layer.masksToBounds = YES;
        [self setupViews];
    }
    return self;
}
- (void)setupViews {
    UIImageView *icon = [UIImageView new];
    icon.image = [UIImage imageNamed:@"无长图提示"];
    [self addSubview:icon];
}


@end
