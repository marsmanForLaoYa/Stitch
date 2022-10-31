//
//  SaveViewController.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/9.
//

#import "SaveViewController.h"
#import <ShareSDK/ShareSDK.h>
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
    
    CGFloat imageFakewidth = 0.0;
    CGFloat imageFakeHeight= 0.0;
    CGFloat scrollWidth= 0.0;
    CGFloat scrollHeight= 0.0;
    UIScrollView *imgScrollView = [UIScrollView new];
    imgScrollView.showsVerticalScrollIndicator = NO;
    imgScrollView.showsHorizontalScrollIndicator = NO;
    NSLog(@"size==%@",@(_screenshotIMG.size));
    [_detailView addSubview:imgScrollView];
    if(_isVer){
        [imgScrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(20));
            make.centerX.equalTo(self.view);
            make.height.equalTo(@((CGFloat)360 / 667 * SCREEN_HEIGHT));
            make.width.equalTo(@(260));
        }];
        [imgScrollView setContentSize:CGSizeMake(0, _screenshotIMG.size.height)];
    }else{
        [imgScrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(SCREEN_WIDTH));
            make.top.equalTo(@(20));
            make.height.equalTo(@(300));
        }];
        [imgScrollView setContentSize:CGSizeMake(_screenshotIMG.size.width, 0)];
    }
    UIImageView *storeImage = [UIImageView new];
    storeImage.image = _screenshotIMG;
    [imgScrollView addSubview:storeImage];
    [storeImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(imgScrollView);
    }]; 
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [saveBtn setBackgroundColor:[UIColor blackColor]];
    [saveBtn setTintColor:[UIColor whiteColor]];
    if (_type == 2){
        [saveBtn setTitle:@"再拼一张" forState:UIControlStateNormal];
    }else{
        [saveBtn setTitle:@"再截图一张" forState:UIControlStateNormal];
    }
    
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
    
    NSArray *shareArr = @[@"复制",@"微信",@"朋友圈",@"微博"];
    for (NSInteger i = 0; i < shareArr.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.tag = i;
        [btn addTarget:self action:@selector(shareClick:) forControlEvents:UIControlEventTouchUpInside];
        [_detailView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(30 + i * 90));
            make.width.equalTo(@60);
            make.bottom.equalTo(saveBtn.mas_top).offset(-65);
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
    MJWeakSelf
    if (btn.tag == 1){
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    }else{
        if (_identify.length > 0){
            //删除原图
            PHFetchResult *collectonResuts = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:[PHFetchOptions new]] ;
            [collectonResuts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                PHAssetCollection *assetCollection = obj;
                if ([assetCollection.localizedTitle isEqualToString:@"最近项目"]){
                    PHFetchResult *assetResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:[PHFetchOptions new]];
                    [assetResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                            //获取相册的最后一张照片
                            if (idx == [assetResult count] - 1) {
                                [PHAssetChangeRequest deleteAssets:@[obj]];
                                weakSelf.identify = @"";
                                [SVProgressHUD showSuccessWithStatus:@"删除成功"];
                                NSLog(@"——删除图片成功——");
                            }

                        } completionHandler:^(BOOL success, NSError *error) {
                            NSLog(@"删除图片Error: %@", error);
                        }];
                    }];
                }
                
            }];
        }else{
            [SVProgressHUD showInfoWithStatus:@"原图已删除"];
        }
    }
   
}

-(void)shareClick:(UIButton *)btn{
    SSDKPlatformType shareType;
    if (btn.tag != 0){
        switch (btn.tag) {
            case 1:
                //微信
                shareType = SSDKPlatformSubTypeWechatSession;
                break;
            case 2:
                shareType = SSDKPlatformSubTypeWechatTimeline;
                //朋友圈
                break;
            default:
                //微博
                shareType = SSDKPlatformTypeSinaWeibo;
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

-(void)shareImageToPlatformType:(SSDKPlatformType)shareType{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params SSDKSetupShareParamsByText:nil
                                images:_screenshotIMG
                                   url:nil
                                 title:nil
                                  type:SSDKContentTypeAuto];
    //调用分享接口分享
    [ShareSDK  share:shareType
        parameters:params
        onStateChanged:^(SSDKResponseState state, NSDictionary *userData,
        SSDKContentEntity *contentEntity, NSError *error) {
        switch (state) {
            case SSDKResponseStateSuccess:
                     NSLog(@"成功");//成功
                     break;
            case SSDKResponseStateFail:
               {
                      NSLog(@"--%@",error.description);
                      //失败
                      break;
                }
            case SSDKResponseStateCancel:
                      //取消
                      break;

            default:
                break;
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
