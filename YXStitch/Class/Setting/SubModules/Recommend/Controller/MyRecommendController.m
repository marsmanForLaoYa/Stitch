//
//  MyRecommendController.m
//  XWNWS
//
//  Created by mac_m11 on 2022/9/9.
//

#import "MyRecommendController.h"
#import "RecommendTableView.h"
@interface MyRecommendController ()<RecommendTableViewDelegate>

@property (nonatomic, strong) RecommendTableView *tableView;
@property (nonatomic, strong) NSArray <NSArray <RecommendModel *>*>*dataSources;

@end

@implementation MyRecommendController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的推荐";
    self.view.backgroundColor = HexColor(@"#f4f4f4");
    
    [self setTableView];
    [self getDataSources];
}

- (void)setTableView {
    RecommendTableView *tableView = [[RecommendTableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    tableView.delegate = self;
    [self.view addSubview:tableView];
    _tableView = tableView;
    //获取数据源
    [self getDataSources];
    self.tableView.dataSources = self.dataSources;
}

- (void)getDataSources {
    RecommendModel *shareModel = [[RecommendModel alloc] initWithTitle:@"分享我的推荐链接" detail:nil userName:nil subTitle:nil cellType:CellTypeShowDetail isLineHidden:YES];

    
    NSArray *firstArr = [NSArray arrayWithObjects:shareModel, nil];
    
    RecommendModel *inviteModel = [[RecommendModel alloc] initWithTitle:@"我的邀请码" detail:[User current].invitation_code userName:nil subTitle:nil cellType:CellTypeButton isLineHidden:NO];
    RecommendModel *recommedModel = [[RecommendModel alloc] initWithTitle:@"我的推荐" detail:[NSString stringWithFormat:@"%ld", [User current].totalInvites] userName:nil subTitle:nil cellType:CellTypeShowDetail isLineHidden:YES];

    NSArray *secondArr = [NSArray arrayWithObjects:inviteModel, recommedModel, nil];
    
    RecommendModel *rewardModel = [[RecommendModel alloc] initWithTitle:@"填写邀请码" detail:nil userName:nil subTitle:nil cellType:CellTypeTextFeild isLineHidden:YES];
    NSArray *thirdArr = [NSArray arrayWithObjects:rewardModel, nil];
    
    RecommendModel *guideModel = [[RecommendModel alloc] initWithTitle:nil detail:nil userName:nil subTitle:nil cellType:CellTypeImageView isLineHidden:YES];
    NSArray *fourthArr = [NSArray arrayWithObjects:guideModel, nil];
    
    self.dataSources = [NSArray arrayWithObjects:firstArr, secondArr, thirdArr, fourthArr, nil];
}

#pragma mark - SettingTableViewDelegate
- (UIView *)xw_tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    UILabel *label;
    if (section == 1) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, kScreenWidth, 60)];
    }
    else
    {
       label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, kScreenWidth, 30)];
    }
    
    label.numberOfLines = 0;
    label.textColor = RGB(18, 18, 18);
    label.font = [UIFont systemFontOfSize:12];
    if (section == 1)
    {
        label.text = @"每推荐一个朋友，你可以得到7天的无广告体验，最多35天。\
        \n为了让你获得奖励，用户必须通过你的推荐链接安装应用程序，\
        \n并至少打开该APP一次。";
    }
    label.adjustsFontSizeToFitWidth = YES;
    [view addSubview:label];
    return view;
}

- (CGFloat)xw_tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 70;
    }
    else
    {
        return 30;
    }
}

- (void)xw_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {

            if (![User current].isLogin) {
//                [self showToastWithMsg:@"未登录"];
                return;
            }
            [self handleShare];
        }
    }
}

-(void)handleShare {

    // 必须要提供url 才会显示分享标签否则只显示图片
    NSArray *activityItems = nil;
    if ([User current].shareDescription && [User current].shareUrl) {

        activityItems = @[[User current].shareDescription, [UIImage imageNamed:@"share_icon"], [NSURL URLWithString:[User current].shareUrl]];
    }

    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    //忽略的app
    activityVC.excludedActivityTypes = [self excludetypes];
    activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {

    };
    [self presentViewController:activityVC animated:YES completion:nil];
}

-(NSArray *)excludetypes{
    
    NSMutableArray *excludeTypesM =  [NSMutableArray arrayWithArray:@[UIActivityTypePostToFacebook]];
    
    if (@available(iOS 11.0, *)) {
        [excludeTypesM addObject:UIActivityTypeMarkupAsPDF];
    }
    
    return excludeTypesM;
}

- (CGFloat)xw_tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 3) {
        return 120;
    }
    else
    {
        return 55 * NORMAL_SCALE;
    }
}

@end
