//
//  SettingTableViewCell.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/10.
//

#import "SettingTableViewCell.h"

@interface SettingTableViewCell ()
@property (nonatomic, strong) UILabel *setingLabel;
@end

@implementation SettingTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self setupLayout];
    }
    return self;
}

- (void)setupLayout {
    _setingLabel = [UILabel new];
    _setingLabel.font = Font15;
    _setingLabel.textColor = [UIColor blackColor];
    [self addSubview:_setingLabel];
    [_setingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.centerY.equalTo(self);
    }];
    
    [self addSubview:[Tools getLineWithFrame:CGRectMake(16, 39, SCREEN_WIDTH-16, 1)]];
}

- (void)configModel:(NSString *)str{
    self.accessibilityIdentifier = 
    _setingLabel.text = str;
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
