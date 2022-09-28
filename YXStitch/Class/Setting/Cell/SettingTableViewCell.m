//
//  SettingTableViewCell.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/10.
//

#import "SettingTableViewCell.h"

@interface SettingTableViewCell ()

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
}

- (void)configModel:(NSString *)str andTag:(NSInteger)tag andType:(NSInteger)type{
   // self.accessibilityIdentifier =
    self.tag = tag;
    if (tag != 6){
        _setingLabel.text = str;
        [self addSubview:[Tools getLineWithFrame:CGRectMake(16, 43, SCREEN_WIDTH-16, 1)]];
        if (tag == 2 && type == 1){
            UIImageView *icon = [UIImageView new];
            if (GVUserDe.logoType == 1){
                icon.image = IMG(@"darkIcon");
            }else{
                icon.image = IMG(@"lightIcon");
            }
            [self addSubview:icon];
            [icon mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.height.equalTo(@24);
                make.centerY.equalTo(self);
                make.right.equalTo(self.mas_right).offset(-32);
            }];
        }
        if (tag == 1 && type == 1){
            UILabel *posizionLab = [UILabel new];
            posizionLab.font = Font13;
            switch (GVUserDe.waterPosition) {
                case 1:
                    posizionLab.text = @"无";
                    break;
                case 2:
                    posizionLab.text = @"左边";
                    break;
                case 3:
                    posizionLab.text = @"居中";
                    break;
                case 4:
                    posizionLab.text = @"右边";
                    break;
                case 5:
                    posizionLab.text = @"全屏";
                    break;
                    
                default:
                    break;
            }
            
            posizionLab.textColor = HexColor(@"#999999");
            [self addSubview:posizionLab];
            [posizionLab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self);
                make.right.equalTo(self.mas_right).offset(-32);
            }];
        }
    }else{
        self.accessoryType = UITableViewCellAccessoryNone;
        UIImageView *icon = [UIImageView new];
        icon.image = IMG(@"darkIcon");
        [self addSubview:icon];
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@20);
            make.centerY.equalTo(self);
            make.width.height.equalTo(@40);
        }];
        
        UILabel *nameLab = [UILabel new];
        nameLab.text = @"游客xxx";
        nameLab.textColor = [UIColor blackColor];
        nameLab.font = Font14;
        [self addSubview:nameLab];
        [nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(icon.mas_right).offset(11);
            make.top.equalTo(@10);
            make.width.equalTo(@(SCREEN_WIDTH - 100));
            make.height.equalTo(@16);
        }];
        
        UILabel *idLab = [UILabel new];
        idLab.textColor = [UIColor blackColor];
        idLab.font = Font12;
        idLab.text = @"设备id：xxxxx";
        [self addSubview:idLab];
        [idLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.equalTo(nameLab);
            make.top.equalTo(nameLab.mas_bottom).offset(8);
        }];
        
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
