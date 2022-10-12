//
//  AdvertisFreeController.m
//  XWNWS
//
//  Created by mac_m11 on 2022/9/9.
//

#import "AdvertisFreeController.h"
#import "RecommendTableView.h"
#import "MyRecommendController.h"

@interface AdvertisFreeController ()<RecommendTableViewDelegate>

@property (nonatomic, strong) RecommendTableView *tableView;
@property (nonatomic, strong) NSArray <NSArray <RecommendModel *>*>*dataSources;
@property (nonatomic, strong) RecommendModel *noAdModel;
@property (nonatomic, strong) RecommendModel *recommedModel;
@property (nonatomic, strong) RecommendModel *myRecommedModel;
@property (nonatomic, strong) RecommendModel *subMonthModel;
@property (nonatomic, strong) RecommendModel *subQuarterlyModel;
@property (nonatomic, strong) RecommendModel *subYearModel;
@property (nonatomic, strong) RecommendModel *loginModel;

@end

@implementation AdvertisFreeController
- (void)dealloc
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"分享得超级会员";
    self.view.backgroundColor = HexColor(@"#f4f4f4");
    [self setTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getDataSources];
    //为了在每次进入时，刷新推荐数和剩余天数否则不用要（邀请了一个用户，被邀请的用户下载app之后，会刷新推荐数和剩余天数）
    [self loadUserInformation];
}

- (void)setTableView {
    RecommendTableView *tableView = [[RecommendTableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    tableView.delegate = self;
    [self.view addSubview:tableView];
    _tableView = tableView;
}

- (void)getDataSources {
    self.noAdModel = [[RecommendModel alloc] initWithTitle:@"无广告" detail:@"" userName:nil subTitle:nil cellType:CellTypeShowDetail isLineHidden:YES];

    NSArray *firstArr = [NSArray arrayWithObjects:self.noAdModel, nil];
    
    self.recommedModel = [[RecommendModel alloc] initWithTitle:@"推荐一个朋友，得到免费7天" detail:nil userName:nil subTitle:nil cellType:CellTypeGoForward isLineHidden:NO];

    self.myRecommedModel = [[RecommendModel alloc] initWithTitle:@"我的推荐" detail:@"0" userName:nil subTitle:nil cellType:CellTypeShowDetail isLineHidden:YES];
    NSArray *secondArr = [NSArray arrayWithObjects:self.recommedModel, self.myRecommedModel, nil];
    
    self.subMonthModel = [[RecommendModel alloc] initWithTitle:@"按月订阅" detail:@"￥38" userName:nil subTitle:nil cellType:CellTypeShowDetail isLineHidden:NO];
    self.subMonthModel.subcriseProduct = @"com.hjllq.apple.month38";

    self.subQuarterlyModel = [[RecommendModel alloc] initWithTitle:@"按季订阅" detail:@"￥68" userName:nil subTitle:nil cellType:CellTypeShowDetail isLineHidden:NO];
    self.subQuarterlyModel.subcriseProduct = @"com.hjllq.apple.quarterly68";

    self.subYearModel = [[RecommendModel alloc] initWithTitle:@"按年订阅" detail:@"￥168" userName:nil subTitle:nil cellType:CellTypeShowDetail isLineHidden:YES];
    self.subYearModel.subcriseProduct = @"com.hjllq.apple.year168";

    NSArray *thirdArr = [NSArray arrayWithObjects:self.subMonthModel, self.subQuarterlyModel, self.subYearModel, nil];
    
    NSString *subTitle = [NSString stringWithFormat:@"%@: %@", @"设备id", [User current].userId];
    self.loginModel = [[RecommendModel alloc] initWithTitle:nil detail:nil userName:@"游客" subTitle:subTitle cellType:CellTypeGoLogin isLineHidden:YES];
    
    NSArray *fourthArr = [NSArray arrayWithObjects:self.loginModel, nil];
    
    if ([User current].isVipMember) {

        self.noAdModel.detail = [NSString stringWithFormat:@"剩%ld天", [self getResDay]];
        self.myRecommedModel.detail = [NSString stringWithFormat:@"%ld", [User current].totalInvites];
        self.dataSources = [NSArray arrayWithObjects:firstArr, secondArr, fourthArr, nil];
    }
    else
    {
        self.dataSources = [NSArray arrayWithObjects:firstArr, secondArr, thirdArr, fourthArr, nil];
    }
    
    self.tableView.dataSources = self.dataSources;
}

- (void)loadUserInformation {
    [[XWNetTool sharedInstance] queryUserInformationShowAdAlert:NO callback:^(User * _Nonnull user, NSString * _Nonnull errorMsg, NSInteger code) {
        if (!errorMsg) {
            
            self.noAdModel.detail = [NSString stringWithFormat:@"剩%ld天", [self getResDay]];
            self.myRecommedModel.detail = [NSString stringWithFormat:@"%ld", user.totalInvites];
        }
        self.tableView.dataSources = self.dataSources;
    }];
}

- (NSInteger)getResDay {
    NSInteger resDay = 0;
    NSTimeInterval nowTimeStamp = [[NSDate date] timeIntervalSince1970];
    NSInteger betweenTimeStamp = [User current].vipExpireTimeStamp - nowTimeStamp;
    if (betweenTimeStamp > 0) {
        
        resDay = ceil(betweenTimeStamp * 1.0 / (24 * 3600));
        
    }
    return resDay;
}

#pragma mark - SettingTableViewDelegate
- (UIView *)xw_tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, kScreenWidth, 30)];
    label.textColor = RGB(18, 18, 18);
    label.font = [UIFont systemFontOfSize:12];
    if (section == 1)
    {
        label.text = @"免费移除广告";
    }
    else if(section == 2)
    {
        label.text = @"每推荐一个朋友，你可以得到7天的无广告体验，最多35天";
    }
    [view addSubview:label];
    return view;
}

- (CGFloat)xw_tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1 || section == 2) {
        return 45;
    }
    else
    {
        return 30;
    }
}

- (void)xw_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RecommendModel *setModel = self.dataSources[indexPath.section][indexPath.row];
    
    if (indexPath.section == 0) {
        
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0) {
            MyRecommendController *reVC = [[MyRecommendController alloc] init];
            [self.navigationController pushViewController:reVC animated:YES];
        }
    }
    else if (indexPath.section == 2)
    {
        if (![User current].isVipMember)
        {
//            [self showLoading];
            [[IAPSubscribeTool sharedInstance] buy:setModel.subcriseProduct finishedBlock:^(NSString * _Nullable errorMsg, NSURL * _Nullable appStoreReceiptURL, BOOL isTest, BOOL isAutoRenewal) {
                if (errorMsg) {
//                    [self showToastWithMsg:errorMsg];
                }
                else
                {
                    @weakify(self);
                    [[XWNetTool sharedInstance] uploadSubscribeReceiptToServiceWithUrl:appStoreReceiptURL isTest:isTest needAutoCheck:YES callback:^(NSString * _Nullable errorMsg) {
                        @strongify(self);
                        [self getDataSources];
                        [self loadUserInformation];
                    }];
//                    [self dimiss];
                }
            }];
        }
    }
}

- (CGFloat)xw_tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([User current].isVipMember)
    {
        if (indexPath.section == 2) {
            return 70 * NORMAL_SCALE;
        }
    }
    else
    {
        if (indexPath.section == 3) {
            return 70 * NORMAL_SCALE;
        }
    }
    return 55 * NORMAL_SCALE;
}

@end
