//
//  SettingCell.m
//  XWNWS
//
//  Created by mac_m11 on 2022/9/8.
//

#import "RecommendCell.h"
#import "RewardTextField.h"
@interface RecommendCell ()

@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel *titleLabel;
//title右侧的label
@property (nonatomic, strong) UILabel *detailLabel;
//title下方的label
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UIImageView *goForwardImgView;
@property (nonatomic, strong) UIImageView *iconImgView;
@property (nonatomic, strong) UILabel *userLabel;
//复制button
@property (nonatomic, strong) UIButton *copBtn;
//邀请码
@property (nonatomic, strong) UILabel *inviteCodeLabel;

//领取奖励button
@property (nonatomic, strong) UIButton *getRewardsBtn;

@property (nonatomic, strong) UIImageView *guideImgView;
//邀请码
@property (nonatomic, strong) RewardTextField *textField;

@end

@implementation RecommendCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"title";
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.textColor = RGB(0, 0, 0);
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:titleLabel];
    _titleLabel = titleLabel;
    
    UILabel *detailLabel = [[UILabel alloc] init];
    detailLabel.font = [UIFont systemFontOfSize:13];
    detailLabel.textColor = RGB(51, 51, 51);
    detailLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:detailLabel];
    _detailLabel = detailLabel;
    
    UIImageView *goForwardImgView = [[UIImageView alloc] init];
    goForwardImgView.image = [UIImage imageNamed:@"wx_go"];
    [self.contentView addSubview:goForwardImgView];
    _goForwardImgView = goForwardImgView;
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = RGB(233, 233, 233);
    [self.contentView addSubview:lineView];
    _lineView = lineView;
    
    UILabel *userLabel = [[UILabel alloc] init];
    userLabel.text = @"title";
    userLabel.font = [UIFont systemFontOfSize:15];
    userLabel.textColor = RGB(0, 0, 0);
    userLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:userLabel];
    _userLabel = userLabel;
    
    UILabel *subTitleLabel = [[UILabel alloc] init];
    subTitleLabel.font = [UIFont systemFontOfSize:12];
    subTitleLabel.textColor = RGB(0, 0, 0);
    subTitleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:subTitleLabel];
    _subTitleLabel = subTitleLabel;
    
    UIImageView *iconImgView = [[UIImageView alloc] init];
    iconImgView.image = [UIImage imageNamed:@"xw_login"];
    [self.contentView addSubview:iconImgView];
    _iconImgView = iconImgView;
    
    UIButton *copBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [copBtn setTitle:@"复制邀请码" forState:UIControlStateNormal];
    [copBtn addTarget:self action:@selector(copyInviteCode) forControlEvents:UIControlEventTouchUpInside];
    copBtn.backgroundColor = [UIColor whiteColor];
    copBtn.layer.masksToBounds = YES;
    copBtn.layer.borderWidth = 1;
    copBtn.layer.borderColor = RGB(37, 111, 217).CGColor;
    copBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [copBtn setTitleColor:RGB(37, 111, 217) forState:UIControlStateNormal];
    [self.contentView addSubview:copBtn];
    _copBtn = copBtn;
    
    UILabel *inviteCodeLabel = [[UILabel alloc] init];
    inviteCodeLabel.font = [UIFont systemFontOfSize:15];
    inviteCodeLabel.textColor = RGB(51, 51, 51);
    inviteCodeLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:inviteCodeLabel];
    _inviteCodeLabel = inviteCodeLabel;
    
    UIButton *getRewardsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [getRewardsBtn setTitle:@"领取奖励" forState:UIControlStateNormal];
    getRewardsBtn.backgroundColor = RGB(37, 111, 217);
//    [getRewardsBtn setBackgroundImage:[UIImage imageNamed:@"xw_get_rewards"] forState:UIControlStateNormal];
    [getRewardsBtn addTarget:self action:@selector(getRewardsAction) forControlEvents:UIControlEventTouchUpInside];
    getRewardsBtn.layer.masksToBounds = YES;
    getRewardsBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [getRewardsBtn setTitleColor:RGB(255, 255, 255) forState:UIControlStateNormal];
    [self.contentView addSubview:getRewardsBtn];
    _getRewardsBtn = getRewardsBtn;
    
    RewardTextField *textField = [[RewardTextField alloc] init];
    textField.returnKeyType = UIReturnKeyDone;
//    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.maxLength = 20;
//    [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.contentView addSubview:textField];
    _textField = textField;
    
    UIImageView *guideImgView = [[UIImageView alloc] init];
    guideImgView.contentMode = UIViewContentModeScaleToFill;
    guideImgView.image = [UIImage imageNamed:@"xw_invite_guide"];
    guideImgView.layer.shadowOpacity = 0.1;
    guideImgView.layer.shadowRadius = 10;
    guideImgView.layer.shadowOffset = CGSizeMake(0, 0);
    guideImgView.layer.shadowColor = RGB(0, 0, 0).CGColor;
    [self.contentView addSubview:guideImgView];
    _guideImgView = guideImgView;
    
    [self setlayoutSubviews];
}

- (void)setlayoutSubviews
{
    CGFloat marginLeft = 30;
    CGFloat marginRight = -30;
    CGFloat height = 26 * NORMAL_SCALE;
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(marginLeft);
        make.centerY.equalTo(self.contentView);
        make.height.mas_equalTo(30);
    }];
    
    [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(marginRight);
        make.centerY.equalTo(self.contentView);
        make.height.mas_equalTo(30);
    }];
    
    [_goForwardImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(marginRight);
        make.centerY.equalTo(self.contentView);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(12);
    }];
    
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(marginLeft);
        make.right.equalTo(self.contentView).offset(marginRight);
        make.height.mas_equalTo(1);
        make.bottom.equalTo(self.contentView.mas_bottom);
    }];
    
    [_iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(marginLeft);
        make.centerY.equalTo(self.contentView);
        make.width.height.mas_equalTo(50);
    }];
    
    [_userLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImgView.mas_right).offset(10);
        make.top.equalTo(self.iconImgView).offset(5);
        make.height.mas_equalTo(25);
    }];
    
    [_subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.userLabel);
        make.bottom.equalTo(self.iconImgView.mas_bottom);
        make.height.mas_equalTo(25);
    }];
    [_copBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(marginRight);
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(height);
    }];
    [_inviteCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_copBtn.mas_left).offset(-5);
        make.centerY.equalTo(self.contentView);
        make.height.mas_equalTo(height);
    }];
    [_getRewardsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(marginRight);
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(height);
    }];
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_getRewardsBtn.mas_left).offset(0);
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(110);
        make.height.mas_equalTo(height - 1);
    }];
    [_guideImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
        make.bottom.top.equalTo(self.contentView);
    }];
    
    [self.contentView layoutIfNeeded];
    self.copBtn.layer.cornerRadius = self.copBtn.height / 2;

    [self.textField.layer addSublayer:[self getCornerWithRoundedRect:self.textField.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft isStroke:YES]];
    if (@available(iOS 11.0, *)) {
        self.getRewardsBtn.layer.cornerRadius = self.getRewardsBtn.height / 2;
        self.getRewardsBtn.layer.maskedCorners = kCALayerMaxXMaxYCorner | kCALayerMaxXMinYCorner;
    } else {
        // Fallback on earlier versions
        self.getRewardsBtn.layer.mask = [self getCornerWithRoundedRect:self.getRewardsBtn.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight isStroke:NO] ;
    }
}

- (void)setSettingModel:(RecommendModel *)settingModel
{
    _settingModel = settingModel;
    
    self.lineView.hidden = settingModel.isLineHidden;
    self.titleLabel.text = settingModel.title;
    self.detailLabel.text = settingModel.detail;
    self.subTitleLabel.text = settingModel.subTitle;
    self.userLabel.text = settingModel.userName;
    self.inviteCodeLabel.text = settingModel.detail;
    
//    根据不同celltype处理
    [self handleWithCellType:settingModel.cellType];
}

#pragma mark - Action
- (void)getRewardsAction
{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD dismissWithDelay:1.0];
    if (![User current].isLogin) {
        [SVProgressHUD showInfoWithStatus:@"未登录"];
        return;
    }
    if (self.textField.text.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"邀请码不能为空"];
        return;
    }
    [[XWNetTool sharedInstance] uploadInvataionCodelWithCode:self.textField.text callback:^(NSString * _Nonnull errorMsg, NSInteger code) {
            
        if (errorMsg) {
           
            [SVProgressHUD showInfoWithStatus:errorMsg];
        }
        else
        {
            [SVProgressHUD showInfoWithStatus:@"成功"];
            //重新获取用户信息（获取用户vip状态）
            [[XWNetTool sharedInstance] queryUserInformationShowAdAlert:NO callback:nil];
        }
    }];
}

//- (void)textFieldDidChange:(UITextField *)textField {
//    NSLog(@"%@", textField.text);
//}

#pragma mark - Method
- (CAShapeLayer *)getCornerWithRoundedRect:(CGRect)rect byRoundingCorners:(UIRectCorner)corners isStroke:(BOOL)isStroke
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:CGSizeMake(rect.size.height / 2, rect.size.height / 2)];
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.lineWidth = 0.5;
    shapeLayer.frame = rect;
    shapeLayer.path = bezierPath.CGPath;
    if (isStroke) {
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        shapeLayer.strokeColor = RGB(51, 51, 51).CGColor;
    }
    return shapeLayer;
}

- (void)handleWithCellType:(CellType)cellType
{
    switch (cellType) {
        case CellTypeGoForward:
        {
            self.titleLabel.hidden = NO;
            self.detailLabel.hidden = YES;
            self.goForwardImgView.hidden = NO;
            self.iconImgView.hidden = YES;
            self.userLabel.hidden = YES;
            self.subTitleLabel.hidden = YES;
            self.copBtn.hidden = YES;
            self.inviteCodeLabel.hidden = YES;
            self.getRewardsBtn.hidden = YES;
            self.textField.hidden = YES;
            self.guideImgView.hidden = YES;
        }
            
            break;
        case CellTypeGoLogin:
        {
            self.titleLabel.hidden = YES;
            self.detailLabel.hidden = YES;
            self.goForwardImgView.hidden = YES;
            self.iconImgView.hidden = NO;
            self.userLabel.hidden = NO;
            self.subTitleLabel.hidden = NO;
            self.copBtn.hidden = YES;
            self.inviteCodeLabel.hidden = YES;
            self.getRewardsBtn.hidden = YES;
            self.textField.hidden = YES;
            self.guideImgView.hidden = YES;
        }
            
            break;
        case CellTypeShowDetail:
        {
            self.titleLabel.hidden = NO;
            self.detailLabel.hidden = NO;
            self.goForwardImgView.hidden = YES;
            self.iconImgView.hidden = YES;
            self.userLabel.hidden = YES;
            self.subTitleLabel.hidden = YES;
            self.copBtn.hidden = YES;
            self.inviteCodeLabel.hidden = YES;
            self.getRewardsBtn.hidden = YES;
            self.textField.hidden = YES;
            self.guideImgView.hidden = YES;
        }
            break;
        case CellTypeButton:
        {
            self.titleLabel.hidden = NO;
            self.detailLabel.hidden = YES;
            self.goForwardImgView.hidden = YES;
            self.iconImgView.hidden = YES;
            self.userLabel.hidden = YES;
            self.subTitleLabel.hidden = YES;
            self.copBtn.hidden = NO;
            self.inviteCodeLabel.hidden = NO;
            self.getRewardsBtn.hidden = YES;
            self.textField.hidden = YES;
            self.guideImgView.hidden = YES;
        }
            
            break;
        case CellTypeTextFeild:
        {
            self.titleLabel.hidden = NO;
            self.detailLabel.hidden = YES;
            self.goForwardImgView.hidden = YES;
            self.iconImgView.hidden = YES;
            self.userLabel.hidden = YES;
            self.subTitleLabel.hidden = YES;
            self.copBtn.hidden = YES;
            self.inviteCodeLabel.hidden = YES;
            self.getRewardsBtn.hidden = NO;
            self.textField.hidden = NO;
            self.guideImgView.hidden = YES;
        }
            
            break;
        case CellTypeImageView:
        {
            self.titleLabel.hidden = YES;
            self.detailLabel.hidden = YES;
            self.goForwardImgView.hidden = YES;
            self.iconImgView.hidden = YES;
            self.userLabel.hidden = YES;
            self.subTitleLabel.hidden = YES;
            self.copBtn.hidden = YES;
            self.inviteCodeLabel.hidden = YES;
            self.getRewardsBtn.hidden = YES;
            self.textField.hidden = YES;
            self.guideImgView.hidden = NO;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Action
- (void)copyInviteCode
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [User current].shareDescription;

    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD showInfoWithStatus:@"已复制，快去粘贴吧"];
    [SVProgressHUD dismissWithDelay:1.0];
}

@end
