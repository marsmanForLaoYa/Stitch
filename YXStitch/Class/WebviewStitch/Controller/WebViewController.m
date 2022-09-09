//
//  WebViewController.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/9.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>
#import "SaveViewController.h"
#import "WKWebView+LVShot.h"
#import "CaptionViewController.h"

@interface WebViewController ()
<WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>
@property (nonatomic, strong)WKWebView *WKwebView;
@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic, strong)NSArray *components;
@property (nonatomic, strong)NSMutableDictionary *dataDic;
@property (nonatomic, assign)BOOL isCanClick;
@property (nonatomic, strong)UIButton *fowardBtn; //前进btn
@property (nonatomic, strong)UIButton *backBtn; //后退btn
@property (nonatomic, strong)UIButton *editBtn; //后退btn

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"预览";
    [self setupViews];
    [self setupNavItems];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.isCanClick = NO;
    
}

-(void)setupViews{
    self.WKwebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 50)];
    self.WKwebView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.WKwebView.backgroundColor = [UIColor clearColor];
    self.WKwebView.navigationDelegate = self;
    self.WKwebView.UIDelegate = self;
    
    [self.view addSubview:self.WKwebView];
    self.WKwebView.allowsBackForwardNavigationGestures = YES;
    [self.WKwebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_urlStr]]];
    
    UIView *bottomView = [UIView new];
    bottomView.backgroundColor = [UIColor colorWithHexString:@"#fefefe"];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.bottom.left.equalTo(self.view);
        make.height.equalTo(@50);
    }];
    
    _backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_backBtn setBackgroundImage:[UIImage imageNamed:@"网页后退"] forState:UIControlStateNormal];
    _backBtn.tag = 1;
    [_backBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_backBtn];
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@12);
        make.height.equalTo(@21);
        make.centerY.equalTo(bottomView);
        make.left.equalTo(@27);
    }];

    _fowardBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_fowardBtn setBackgroundImage:[UIImage imageNamed:@"网页前进"] forState:UIControlStateNormal];
    _fowardBtn.tag = 2;
    [_fowardBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_fowardBtn];
    [_fowardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.centerY.equalTo(_backBtn);
        make.left.equalTo(_backBtn.mas_right).offset(134);
    }];

    _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_editBtn setTitle:@"网页编辑：关" forState:UIControlStateNormal];
    _editBtn.backgroundColor = [UIColor colorWithHexString:@"#fefefe"];
    [_editBtn setTitleColor:HexColor(@"#999999") forState:UIControlStateNormal];
    _editBtn.titleLabel.font = Font15Bold;
    _editBtn.selected = NO;
    _editBtn.tag = 3;
    [_editBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_editBtn];
    [_editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_backBtn);
        make.right.equalTo(bottomView.mas_right).offset(-22);
    }];   
}

-(void)setupNavItems{
    UIButton *cutBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [cutBtn setBackgroundImage:[UIImage imageNamed:@"网页剪切"] forState:UIControlStateNormal];
    cutBtn.tag = 1;
    [cutBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *cutItem = [[UIBarButtonItem alloc]initWithCustomView:cutBtn];
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [saveBtn setBackgroundImage:[UIImage imageNamed:@"网页保存"] forState:UIControlStateNormal];
    saveBtn.tag = 2;
    [saveBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc]initWithCustomView:saveBtn];
    
    //空白占位item
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = 15;
    
    self.navigationItem.rightBarButtonItems = @[saveItem,spaceItem,cutItem];
}

#pragma mark -- btn触发事件
-(void)rightBtnClick:(UIButton *)btn{
    //先裁剪图片
    MJWeakSelf
    [SVProgressHUD showWithStatus:@"生成图片中..."];
    self.view.userInteractionEnabled = NO;
    if (btn.tag == 1){
        //裁剪
        __block NSMutableArray *tmpArr = [NSMutableArray array];
        [_WKwebView DDGContentScreenShot:^(UIImage *screenShotImage) {
            [SVProgressHUD dismiss];
            self.view.userInteractionEnabled = YES;
            CaptionViewController *vc = [CaptionViewController new];
            [tmpArr addObject:screenShotImage];
            vc.dataArr = tmpArr;
            vc.type = 2;
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }else{
        //保存
        
        
        [_WKwebView DDGContentScreenShot:^(UIImage *screenShotImage) {
            weakSelf.view.userInteractionEnabled = YES;
            [SVProgressHUD dismiss];
            [weakSelf showScreenShot:screenShotImage];
        }];
        
    }
}

-(void)showScreenShot:(UIImage*)image{
    SaveViewController *vc = [SaveViewController new];
    vc.screenshotIMG = image;
    vc.urlStr = _urlStr;
    vc.type = 1;
    [self.navigationController pushViewController:vc animated:YES];
}


-(void)btnClick:(UIButton *)btn{
    if (btn.tag == 1){
        //后退
        if ([_WKwebView canGoBack]){
            [_WKwebView goBack];
        }else{
            [SVProgressHUD showInfoWithStatus:@"已无法后退"];
        }
    }else if (btn.tag == 2){
        //前进
        if ([_WKwebView canGoForward]){
            [_WKwebView goForward];
        }else{
            [SVProgressHUD showInfoWithStatus:@"已无法前进"];
        }
    }else{
        //编辑
        _editBtn.selected = !_editBtn.selected;
        if (_editBtn.selected){
            [_editBtn setTitle: @"网页编辑：开" forState:UIControlStateNormal];
            [_editBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.view makeToast:@"可长按元素手动删除网页中广告等元素" duration:1 position:CSToastPositionCenter];
            
        }else{
            [_editBtn setTitle:@"网页编辑：关" forState:UIControlStateNormal];
            [_editBtn setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        }
    }
}

#pragma mark --WKWebViewDelegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    [SVProgressHUD showWithStatus:@"网页加载中..."];
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{

    
    ///阻止wkwebview的原生长按弹出
    NSString *js1 = @"document.documentElement.style.webkitUserSelect='none';";
    [self.WKwebView evaluateJavaScript:js1 completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        NSLog(@"response: %@ error: %@", response, error);
        NSLog(@"call js alert by native");
    }];
    NSString *js2 = @"document.documentElement.style.webkitTouchCallout='none';";
    [self.WKwebView evaluateJavaScript:js2 completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        NSLog(@"response: %@ error: %@", response, error);
        NSLog(@"call js alert by native");
    }];
    
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [SVProgressHUD dismiss];
    [self immitjs];
}

//在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    WKNavigationActionPolicy actionPolicy = WKNavigationActionPolicyAllow;
    decisionHandler(actionPolicy);
    
    ///如果是跳转新的界面, 就走这个判断
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }
}

- (void)immitjs{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[self.WKwebView configuration].userContentController addScriptMessageHandler:self name:@"TheData"];
    });
    
    [self injectionJS];
    
}


#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"TheData"]) {
        // NSDictionary, and NSNull类型
        //        NSLog(@"~~~~~~~~~~~%@", message.body);
        if (_editBtn.selected){
            [self jszhixing:message.body];
        }
       
    }
}

///js执行代码
- (void)jszhixing:(NSString *)str{
    //    NSLog(@"requestString == %@", str);
    _components = nil;
    _components = [str componentsSeparatedByString:@":"];
    if ([_components count] > 1 && [(NSString *)[_components objectAtIndex:0]
                                   isEqualToString:@"thewebview"]) {
        if([(NSString *)[_components objectAtIndex:1] isEqualToString:@"touch"])
        {
            if ([(NSString *)[_components objectAtIndex:2] isEqualToString:@"start"])
            {
                ///定时器, 判断手势是否长按
                _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(handle) userInfo:nil repeats:NO];
                NSLog(@"start");
            }else if ([(NSString *)[_components objectAtIndex:2] isEqualToString:@"move"]){
                //NSLog(@"这是在滑动");
                if (_timer != nil) {
                    [_timer invalidate];
                    _timer = nil;
                }
                NSLog(@"move");
            }else if ([(NSString*)[_components objectAtIndex:2]isEqualToString:@"cancel"]) {
                if (self.isCanClick == YES) {
                    self.isCanClick = NO;
                    self.WKwebView.scrollView.scrollEnabled = YES;
                }
                if (_timer != nil) {
                    [_timer invalidate];
                    _timer = nil;
                }
                NSLog(@"cancel");
            }else if ([(NSString*)[_components objectAtIndex:2]isEqualToString:@"end"]) {
                if (self.isCanClick == YES) {
                    self.isCanClick = NO;
                    self.WKwebView.scrollView.scrollEnabled = YES;
                }
                if (_timer != nil) {
                    [_timer invalidate];
                    _timer = nil;
                }
                NSLog(@"end");
            }
            
        }
    }
}

- (void)injectionJS{
    
    NSString *js = @"document.ontouchstart=function(event){\
    x=event.targetTouches[0].clientX;\
    y=event.targetTouches[0].clientY;\
    window.webkit.messageHandlers.TheData.postMessage('thewebview:touch:start:\'+x+\':\'+y);\
    };\
    document.ontouchmove=function(event){\
    x=event.targetTouches[0].clientX;\
    y=event.targetTouches[0].clientY;\
    window.webkit.messageHandlers.TheData.postMessage('thewebview:touch:move:\'+x+\':\'+y);\
    };\
    document.ontouchcancel=function(event){\
    window.webkit.messageHandlers.TheData.postMessage('thewebview:touch:cancel');\
    ;};\
    document.ontouchend=function(event){\
    window.webkit.messageHandlers.TheData.postMessage('thewebview:touch:end');\
    };";
    [self.WKwebView evaluateJavaScript:js completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        
    }];
}

- (void)CloseHTMLTouch{
    
    NSString *js = @"document.ontouchstart=function(event){\
    x=event.targetTouches[0].clientX;\
    y=event.targetTouches[0].clientY;\
    window.webkit.messageHandlers.TheData.postMessage('thewebview:touch:start:\'+x+\':\'+y);\
    };\
    document.ontouchmove=function(event){\
    x=event.targetTouches[0].clientX;\
    y=event.targetTouches[0].clientY;\
    window.webkit.messageHandlers.TheData.postMessage('thewebview:touch:move:\'+x+\':\'+y);\
    };\
    document.ontouchcancel=function(event){\
    window.webkit.messageHandlers.TheData.postMessage('thewebview:touch:cancel');\
    ;};\
    document.ontouchend=function(event){\
    event.preventDefault();\
    window.webkit.messageHandlers.TheData.postMessage('thewebview:touch:end');\
    };";
    [self.WKwebView evaluateJavaScript:js completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        
    }];
}


- (void)handle{
    MJWeakSelf
    self.isCanClick = YES;
    self.WKwebView.scrollView.scrollEnabled = NO;
    ///阻止一次触摸传递
    [self CloseHTMLTouch];
    
//    NSLog(@"self.WKwebView.isUserInteractionEnabled == %zd", self.WKwebView.isUserInteractionEnabled);
    [_timer invalidate];
    _timer = nil;
    if (_components.count == 3) {
        return;
    }
    
    NSLog(@"---------------------------------------");
    
    float ptX = [[_components objectAtIndex:3]floatValue];
    float ptY = [[_components objectAtIndex:4]floatValue];
    NSLog(@"touch point (%f, %f)", ptX, ptY);
    _dataDic = nil;
    _dataDic = [NSMutableDictionary dictionary];
    //第一个js看,是不是广告
    [self.WKwebView evaluateJavaScript:[NSString stringWithFormat:@"document.elementFromPoint(%f, %f).className", ptX, ptY] completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        NSString * className = response;
        if (className != nil && className.length > 0) {
            NSLog(@"className %@", className);
            [weakSelf.dataDic setValue:className forKey:@"className"];
        }
        //第三个和第四个js看看是不是图片, 要保存
        [weakSelf.WKwebView evaluateJavaScript:[NSString stringWithFormat:@"document.elementFromPoint(%f, %f).tagName", ptX, ptY] completionHandler:^(id _Nullable response, NSError * _Nullable error) {
            NSString * tagName = response;
            NSLog(@"tagName %@", tagName);
            if ([tagName isEqualToString:@"IMG"]) {
                [weakSelf.WKwebView evaluateJavaScript:[NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", ptX, ptY] completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                    NSString * imgURL = response;
                    if (imgURL != nil && imgURL.length > 0) {
                        NSLog(@"imgURL %@", imgURL);
                        [weakSelf.dataDic setValue:imgURL forKey:@"imgURL"];
                    }
                    
                    [weakSelf alertX:ptX Y:ptY];
                }];
            }else{
                if ([tagName isEqualToString:@"DIV"]){
                    ///是DIV, 直接取a
                    [weakSelf.WKwebView evaluateJavaScript:[NSString stringWithFormat:@"document.elementFromPoint(%f, %f).getElementsByTagName(\"a\")[0].href", ptX, ptY] completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                        NSString * href = response;
                        if (href != nil && href.length > 0) {
                            NSLog(@"href %@", href);
                            [weakSelf.dataDic setValue:href forKey:@"href"];
                        }
                        [weakSelf alertX:ptX Y:ptY];
                    }];
                }else{
                    [weakSelf.WKwebView evaluateJavaScript:[NSString stringWithFormat:@"document.elementFromPoint(%f, %f).parentNode.tagName", ptX, ptY] completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                        if ([response isEqualToString:@"A"]) {
                            [weakSelf.WKwebView evaluateJavaScript:[NSString stringWithFormat:@"document.elementFromPoint(%f, %f).parentNode.href", ptX, ptY] completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                                NSString * href = response;
                                if (href != nil && href.length > 0) {
                                    NSLog(@"href %@", href);
                                    [weakSelf.dataDic setValue:href forKey:@"href"];
                                }
                                [weakSelf alertX:ptX Y:ptY];
                            }];
                        }else{
                            [weakSelf.WKwebView evaluateJavaScript:[NSString stringWithFormat:@"document.elementFromPoint(%f, %f).parentNode.parentNode.tagName", ptX, ptY] completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                                if ([response isEqualToString:@"A"]) {
                                    [weakSelf.WKwebView evaluateJavaScript:[NSString stringWithFormat:@"document.elementFromPoint(%f, %f).parentNode.parentNode.href", ptX, ptY] completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                                        NSString * href = response;
                                        if (href != nil && href.length > 0) {
                                            NSLog(@"href %@", href);
                                            [weakSelf.dataDic setValue:href forKey:@"href"];
                                        }
                                        [weakSelf alertX:ptX Y:ptY];
                                    }];
                                }else{
                                    [weakSelf.WKwebView evaluateJavaScript:[NSString stringWithFormat:@"document.elementFromPoint(%f, %f).parentNode.parentNode.parentNode.tagName", ptX, ptY] completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                                        if ([response isEqualToString:@"A"]) {
                                            [weakSelf.WKwebView evaluateJavaScript:[NSString stringWithFormat:@"document.elementFromPoint(%f, %f).parentNode.parentNode.parentNode.href", ptX, ptY] completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                                                NSString * href = response;
                                                if (href != nil && href.length > 0) {
                                                    NSLog(@"href %@", href);
                                                    [weakSelf.dataDic setValue:href forKey:@"href"];
                                                }
                                                [weakSelf alertX:ptX Y:ptY];
                                            }];
                                        }else{
                                            [weakSelf alertX:ptX Y:ptY];
                                        }
                                    }];
                                }
                            }];
                        }
                    }];
                    
                }
            }
        }];
    }];
}

- (void)alertX:(CGFloat)x Y:(CGFloat)y{
    MJWeakSelf
    NSString *str = [_dataDic objectForKey:@"href"] != nil ? [_dataDic objectForKey:@"href"] : [_dataDic objectForKey:@"imgURL"] != nil ? [_dataDic objectForKey:@"imgURL"] : nil;
    
    UIAlertController *alC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf injectionJS];
    }]];
    [alC addAction:[UIAlertAction actionWithTitle:@"删除该元素" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf injectionJS];
        [weakSelf.WKwebView evaluateJavaScript:[NSString stringWithFormat:@"document.elementFromPoint(%f, %f).style.display = 'none'", x, y] completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        }];
    }]];
    if ([_dataDic objectForKey:@"imgURL"]) {
        [alC addAction:[UIAlertAction actionWithTitle:@"下载图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSData *data = [NSData dataWithContentsOfURL:[NSURL  URLWithString:[weakSelf.dataDic objectForKey:@"imgURL"]]];
            UIImage *image = [UIImage imageWithData:data]; // 取得图片
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
            [weakSelf injectionJS];
        }]];
    }
    if ([_dataDic objectForKey:@"href"]) {
        
        [alC addAction:[UIAlertAction actionWithTitle:@"复制链接" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//            pasteboard.string = [weakSelf.dataDic objectForKey:@"href"];
            [weakSelf injectionJS];
        }]];
    }
    
    [self presentViewController:alC animated:YES completion:nil];
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo{
    
    NSString *msg = nil ;
    
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    NSLog(@"%@", msg);
}


@end
