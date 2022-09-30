//
//  ShellTableViewCell.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/9/29.
//

#import "ShellTableViewCell.h"

@implementation ShellTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        [self setupLayout];
    }
    return self;
}

- (void)setupLayout {
    _phoneLabel = [UILabel new];
    _phoneLabel.font = Font13;
    _phoneLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:_phoneLabel];
    [_phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@26);
        make.centerY.equalTo(self);
    }];
}

- (void)configModelWithTag:(NSInteger)tag AndStr:(NSString *)str{
    _phoneLabel.text = str;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
