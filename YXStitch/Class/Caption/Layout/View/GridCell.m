//
//  GridCell.m
//  YXStitch
//
//  Created by mac_m11 on 2022/9/24.
//

#import "GridCell.h"
@interface GridCell ()

@property(nonatomic, strong) UIImageView *iconImgView;

@end
@implementation GridCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.iconImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.iconImgView.contentMode = UIViewContentModeScaleAspectFit;
        self.iconImgView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.iconImgView];
    }
    return self;
}

- (void)setImageSelected:(NSString *)imageSelected
{
    _imageSelected = imageSelected;
    if (self.selected) {//选中
        self.iconImgView.image = [UIImage imageNamed:self.imageSelected];
    }else {//未选中
        self.iconImgView.image = [UIImage imageNamed:self.imgNormal];
    }
}

- (void)setSelected:(BOOL)selected
{
    if (selected) {//选中
        self.iconImgView.image = [UIImage imageNamed:self.imageSelected];
    }else {//未选中
        self.iconImgView.image = [UIImage imageNamed:self.imgNormal];
    }
    [super setSelected:selected];
}

@end
