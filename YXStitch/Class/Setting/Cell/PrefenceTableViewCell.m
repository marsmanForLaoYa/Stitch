//
//  PrefenceTableViewCell.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/11.
//

#import "PrefenceTableViewCell.h"

@implementation PrefenceTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        self.accessoryType = UITableViewCellAccessoryNone;
        [self setupLayout];
    }
    return self;
}
- (void)setupLayout {
    _setingLabel = [UILabel new];
    _setingLabel.font = Font15;
    _setingLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:_setingLabel];
    [_setingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.centerY.equalTo(self);
    }];
    
    _funcswitch = [UISwitch new];
    _funcswitch.transform = CGAffineTransformMakeScale(0.8, 0.8);
    _funcswitch.tag = self.tag;
    _funcswitch.onTintColor = HexColor(@"#166BFF");
    _funcswitch.tintColor = HexColor(@"#999999");
    
    
    [_funcswitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:_funcswitch];
    [_funcswitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-15);
    }];
//    [self addSubview:[Tools getLineWithFrame:CGRectMake(16, 39, SCREEN_WIDTH-16, 1)]];
}

- (void)configModel:(NSString *)str andTag:(NSInteger)tag{
    self.accessibilityIdentifier =
    _setingLabel.text = str;
    _funcswitch.tag = tag;
    if (tag == 1){
        //判断是否是会员 不是显示弹窗
        if(GVUserDe.isMember){
            _funcswitch.userInteractionEnabled = YES;
        }else{
            _funcswitch.userInteractionEnabled = NO;
        }
    }
}

-(void)switchAction:(UISwitch *)sw{
    if (sw.tag == 0){
        GVUserDe.isSaveIMGAlbum = _funcswitch.on;
    }else if(sw.tag == 1){
        if (_funcswitch.on){
            [self.delegate autoDeleteWith:_funcswitch.on];
        }else{
            
        }
        GVUserDe.isAutoDeleteOriginIMG = _funcswitch.on;
    }else if(sw.tag == 2){
        GVUserDe.isAutoCheckRecentlyIMG = _funcswitch.on;
    }else {
        GVUserDe.isAutoHiddenScrollStrip = _funcswitch.on;
    }
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
