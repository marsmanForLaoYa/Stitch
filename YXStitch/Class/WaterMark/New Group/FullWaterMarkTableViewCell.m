//
//  FullWaterMarkTableViewCell.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/17.
//

#import "FullWaterMarkTableViewCell.h"

@implementation FullWaterMarkTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.waterTextLabel];
    }
    return self;
}

- (UILabel *)waterTextLabel{
    if(!_waterTextLabel){
        _waterTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_HEIGHT * 3, 100)];
        _waterTextLabel.alpha = 0.5;
        _waterTextLabel.backgroundColor = [UIColor clearColor];
    }
    return _waterTextLabel;
}

-(void)configModel:(NSString *)str andSize:(NSInteger)Size andColor:(NSString *)color{
    _waterTextLabel.text = str;
    _waterTextLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:Size];
    _waterTextLabel.textColor = HexColor(color);
}

@end
