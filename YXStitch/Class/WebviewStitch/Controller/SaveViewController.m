//
//  SaveViewController.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/9.
//

#import "SaveViewController.h"
#import <UMShare/UMShare.h>
@interface SaveViewController ()
@property (nonatomic ,strong)UIView *detailView;
@end

@implementation SaveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"保存分享";
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupViews];
    [self setupNavItems];
}
-(void)setupViews{
    _detailView = [[UIView alloc]init];
    _detailView.backgroundColor = HexColor(BKGrayColor);
    [self.view addSubview:_detailView];
    [_detailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(self.view);
        make.height.equalTo(@(SCREEN_HEIGHT - Nav_H));
        make.top.equalTo(@(Nav_H));
    }];
    
    CGFloat imageFakewidth = (CGFloat) SCREEN_WIDTH / 2;
    CGFloat imageFakeHeight = (CGFloat)_screenshotIMG.size.height *imageFakewidth / _screenshotIMG.size.width;
    CGFloat scrollWidth = (CGFloat)225 / 375 * SCREEN_WIDTH;

    UIScrollView *imgScrollView = [UIScrollView new];
    imgScrollView.contentSize = CGSizeMake(imageFakewidth, imageFakeHeight);
    [_detailView addSubview:imgScrollView];
    [imgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@20);
        make.centerX.equalTo(self.view);
        make.width.equalTo(@(scrollWidth));
        make.height.equalTo(@((CGFloat)360 / 667 * SCREEN_HEIGHT));
    }];
    UIImageView *storeImage = [UIImageView new];
    storeImage.image = _screenshotIMG;
    [imgScrollView addSubview:storeImage];
    [storeImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.width.equalTo(imgScrollView);
        make.height.equalTo(@(imageFakeHeight));
    }];
    
    NSArray *shareArr = @[@"复制",@"微信",@"朋友圈",@"微博"];
    for (NSInteger i = 0; i < shareArr.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.tag = i;
        [btn addTarget:self action:@selector(shareClick:) forControlEvents:UIControlEventTouchUpInside];
        [_detailView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(30 + i * 90));
            make.width.equalTo(@60);
            make.top.equalTo(imgScrollView.mas_bottom).offset(20);
            make.height.equalTo(@80);
        }];
        UIImageView *iconIMG = [UIImageView new];
        iconIMG.image = [UIImage imageNamed:shareArr[i]];
        [btn addSubview:iconIMG];
        [iconIMG mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@44);
            make.top.centerX.equalTo(btn);
        }];
        UILabel *iconText = [UILabel new];
        iconText.text = shareArr[i];
        iconText.textAlignment = NSTextAlignmentCenter;
        [btn addSubview:iconText];
        [iconText mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.width.equalTo(btn);
            make.top.equalTo(iconIMG.mas_bottom).offset(6);
        }];
    }
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [saveBtn setBackgroundColor:[UIColor blackColor]];
    [saveBtn setTintColor:[UIColor whiteColor]];
    [saveBtn setTitle:@"再截图一张" forState:UIControlStateNormal];
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    saveBtn.layer.masksToBounds = YES;
    saveBtn.layer.cornerRadius = 5;
    saveBtn.tag = 1;
    [saveBtn addTarget:self action:@selector(oneMore:) forControlEvents:UIControlEventTouchUpInside];
    [_detailView addSubview:saveBtn];
    [saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.type == 1){
            make.bottom.equalTo(self.view).offset(-50);
        }else{
            make.bottom.equalTo(self.view).offset(-40);
        }
        
        make.height.equalTo(@40);
        make.left.equalTo(@58);
        make.width.equalTo(@(SCREEN_WIDTH - 58 * 2));
    }];
    if (self.type != 1){
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [deleteBtn setBackgroundColor:HexColor(@"#DDDDDD")];
        [deleteBtn setTintColor:[UIColor blackColor]];
        [deleteBtn setTitle:@"删除原图" forState:UIControlStateNormal];
        deleteBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        deleteBtn.layer.masksToBounds = YES;
        deleteBtn.layer.cornerRadius = 5;
        deleteBtn.tag = 2;
        [deleteBtn addTarget:self action:@selector(oneMore:) forControlEvents:UIControlEventTouchUpInside];
        [_detailView addSubview:deleteBtn];
        [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.centerX.equalTo(saveBtn);
            make.bottom.equalTo(saveBtn.mas_top).offset(-15);
        }];
    }
}

-(void)setupNavItems{
    UIButton *shareBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 22, 4)];
    [shareBtn setBackgroundImage:IMG(@"苹果分享") forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc]initWithCustomView:shareBtn];
    self.navigationItem.rightBarButtonItem = shareItem;
}

#pragma mark -- btn触发事件
-(void)oneMore:(UIButton *)btn{
    if (btn.tag == 1){
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    }else{
        //删除原图
        
    }
   
}

-(void)shareClick:(UIButton *)btn{
    UMSocialPlatformType shareType;
    if (btn.tag != 0){
        switch (btn.tag) {
            case 1:
                //微信
                shareType = UMSocialPlatformType_WechatSession;
                break;
            case 2:
                shareType = UMSocialPlatformType_WechatTimeLine;
                //朋友圈
                break;
            case 3:
                //微博
                shareType = UMSocialPlatformType_Sina;
                break;
            default:
                shareType = UMSocialPlatformType_Predefine_Begin;
                break;
        }
        [self shareImageToPlatformType:shareType];
    }else{
        //复制
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.image = _screenshotIMG;
        [SVProgressHUD showSuccessWithStatus:@"截图已复制"];
    }
    
    
}

- (void)shareImageToPlatformType:(UMSocialPlatformType)platformType{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    //创建图片内容对象
    UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
    //如果有缩略图，则设置缩略图
    shareObject.thumbImage = [UIImage imageNamed:@"darkIcon"];
    [shareObject setShareImage:_screenshotIMG];

    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
   // messageObject.text = @"分享文本";
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            NSLog(@"************Share fail with error %@*********",error);
        }else{
            NSLog(@"response data is %@",data);
        }
    }];
}

-(void)rightBtnClick{
    //分享的标题
    [SVProgressHUD showWithStatus:@"生成分享图中..."];
    NSString *textToShare = @"网页截图分享";
    //分享的图片
    UIImage *imageToShare = _screenshotIMG;
    //分享的url
//    NSURL *urlToShare = [NSURL URLWithString:nil];

    NSArray *activityItems = @[textToShare,imageToShare];
        
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];

    activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll];
        
    [self presentViewController:activityVC animated:YES completion:nil];
    [SVProgressHUD dismiss];
        
    //分享之后的回调
    activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        if (completed) {
            NSLog(@"completed");
            //分享 成功
        } else  {
            NSLog(@"cancled");
            //分享 取消
        }
    };
}





@end
