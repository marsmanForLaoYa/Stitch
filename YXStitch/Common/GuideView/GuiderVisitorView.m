//
//  GuiderVisitorView.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/9/1.
//

#import "GuiderVisitorView.h"

@interface GuiderVisitorView ()<UIScrollViewDelegate>
@property (nonatomic, strong)UIScrollView *scrollView;
@property (nonatomic, strong)NSMutableArray *arr;  //放图片的数组
@property (nonatomic, strong)UIImageView *pageImage;  //图片

@property (nonatomic, strong)UILabel *titleLab;
@property (nonatomic, strong)UILabel *tipLab;
@property (nonatomic, strong)UIButton *endBtn;
@end
@implementation GuiderVisitorView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 12;
        self.layer.maskedCorners = YES;
        NSString *imgstr;
        if (GVUserDe.logoType == 1){
            imgstr = @"滚动导览3-1";
        }else{
            imgstr = @"滚动导览3-2";
        }
        _arr = [NSMutableArray arrayWithObjects:@"滚动导览1",@"滚动导览2",imgstr,@"滚动导览4", nil];
        [self setupViews];
        [self setupLayout];
    }
    return self;
}

-(void)setupViews{
    UIButton *grayBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [grayBtn setBackgroundColor:[UIColor clearColor]];
    
    [grayBtn addTarget:self action:@selector(endClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:grayBtn];
    [grayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@36);
        make.height.equalTo(@25);
        make.centerX.top.equalTo(self);
    }];
    
    UIImageView *grayImg = [UIImageView new];
    grayImg.backgroundColor = HexColor(@"#D9D9D9");
    grayImg.layer.cornerRadius = 3;
    grayImg.layer.maskedCorners = YES;
    [grayBtn addSubview:grayImg];
    [grayImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(grayBtn);
        make.height.equalTo(@5);
        make.top.equalTo(@15);
    }];
    
    _titleLab = [UILabel new];
    _titleLab.text = @"准备滚动截图";
    _titleLab.font = FontBold(20);
    [self addSubview:_titleLab];
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@41);
        make.top.equalTo(@54);
    }];
    CGFloat scWidth = SCREEN_WIDTH - 62 ;
    _tipLab = [UILabel new];
    _tipLab.text = @"添加录屏到控制中心";
    _tipLab.font = Font14;
    _tipLab.numberOfLines = 0;
    _tipLab.textColor = HexColor(@"#333333");
    [self addSubview:_tipLab];
    [_tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLab);
        make.top.equalTo(_titleLab.mas_bottom).offset(11);
        make.height.equalTo(@50);
        make.width.equalTo(@(scWidth));
    }];
    _scrollView = [UIScrollView new];
    _scrollView.delegate = self;
    [self addSubview:_scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@146);
        make.left.equalTo(@31);
        make.height.equalTo(@314);
        make.width.equalTo(@(scWidth));
    }];
    //设置滚动量
    _scrollView.contentSize = CGSizeMake(scWidth * self.arr.count, 0);
    //设置偏移量
    _scrollView.contentOffset = CGPointMake(0, 0);
    //设置按页滚动
    _scrollView.pagingEnabled = YES;
    //设置是否显示水平滑动条
    _scrollView.showsHorizontalScrollIndicator = NO;
    //设置是否边界反弹
    _scrollView.bounces = NO;
    //把scrollView添加到tableView的表头的视图上
    
    for (NSInteger i = 0; i < _arr.count ; i ++) {
        UIImageView *IMG = [UIImageView new];
        IMG.image = IMG(_arr[i]);
        [_scrollView addSubview:IMG];
        [IMG mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(_scrollView);
            make.left.equalTo(@(i * scWidth));
        }];
    }
    self.scrollView.delegate = self;
    //设置页面
    self.pageC = [[UIPageControl alloc]initWithFrame:CGRectMake(-200, 565 - 60 , 100, 40)];
    self.pageC.backgroundColor = [UIColor clearColor];
    //把页码添加到头视图上
    [self addSubview:self.pageC];
    //设置页码数
    self.pageC.numberOfPages = self.arr.count;
    //设置选中页码的颜色
    self.pageC.currentPageIndicatorTintColor = [UIColor blackColor];
    //设置未选中的页码颜色
    self.pageC.pageIndicatorTintColor = [UIColor grayColor];
    //设置当前选中页
    self.pageC.currentPage = 0;
    
    _pageImage = [UIImageView new];
    _pageImage.image = IMG(@"01");
    [self addSubview:_pageImage];
    [_pageImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@32);
        make.height.equalTo(@29);
        make.centerY.equalTo(_pageC);
        make.right.equalTo(_scrollView);
    }];
    
    _endBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_endBtn setBackgroundImage:IMG(@"退出导览") forState:UIControlStateNormal];
    _endBtn.hidden = YES;
    [_endBtn addTarget:self action:@selector(endClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_endBtn];
    [_endBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@73);
        make.height.equalTo(@30);
        make.right.equalTo(_scrollView);
        make.centerY.equalTo(_pageC);
    }];
    
}
-(void)endClick{
    self.btnClick();
}


//减速停止时触发
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //滚动换页码
    int index = scrollView.contentOffset.x/scrollView.frame.size.width;
    self.pageC.currentPage = index;
    NSLog(@"index==%d",index);
    if (index == 0){
        _titleLab.text = @"准备滚动截图";
        _tipLab.text = @"添加录屏到控制中心";
        _pageImage.hidden = NO;
        _pageImage.image = IMG(@"01");
        _endBtn.hidden = YES;
    }else if (index == 1){
        _titleLab.text = @"开始滚动截图";
        _tipLab.text = @"打开『控制中心』，长按『录制屏幕图标』";
        _pageImage.hidden = NO;
        _pageImage.image = IMG(@"02");
        _endBtn.hidden = YES;
    }else if (index == 2){
        _titleLab.text = @"开始滚动截图";
        _tipLab.text = @"勾选『快捷拼图』，点击『开始直播』， 等待状态栏出现 录屏标志后开始滚动屏幕";
        _pageImage.hidden = NO;
        _pageImage.image = IMG(@"03");
        _endBtn.hidden = YES;
    }else if (index == 3){
        _titleLab.text = @"结束滚动截图";
        _tipLab.text = @"停止滚动后等待2秒或摇一摇手机将会自动停止录制，点击『前往应用程序』查看结果";
        _pageImage.hidden = YES;
        _endBtn.hidden = NO;
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    scrollView.bounces = NO;
}

-(void)setupLayout{
    
}

@end
