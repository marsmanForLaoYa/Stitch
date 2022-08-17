//
//  URLSchemesViewController.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/11.
//

#import "URLSchemesViewController.h"
#import "UrlSchemeTableView.h"

@interface URLSchemesViewController ()<UrlSchemeTableViewDelegate>
@property (nonatomic ,strong)UrlSchemeTableView *tabletView;
@end

@implementation URLSchemesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"URL Schemes";
    [self setupViews];
}
-(void)setupViews{
    _tabletView = [UrlSchemeTableView new];
    _tabletView.delegate = self;
    [self.view addSubview:_tabletView];
    [_tabletView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(Nav_H));
        make.left.width.equalTo(self.view);
        make.height.equalTo(@(SCREEN_HEIGHT - Nav_H));

    }];
}

#pragma mark -- viewDelegate
-(void)urlSchemeClickWithTag:(NSInteger)tag{
    
}

@end
