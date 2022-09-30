//
//  imageShellSelectView.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/9/29.
//

#import "imageShellSelectView.h"
#import "ShellTableViewCell.h"

@interface imageShellSelectView ()<UITableViewDelegate ,UITableViewDataSource>
@property (nonatomic ,strong)UITableView *tableView;
@property (nonatomic ,strong)UIView *colorView;
@property (nonatomic ,strong)NSArray *iphoneArr;
@property (nonatomic ,assign)NSInteger selectIndex;
@property (nonatomic ,strong)UIColor *defaultColor;
@end

@implementation imageShellSelectView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = HexColor(@"#1A1A1A");
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        _selectIndex = 1000;
        _iphoneArr = @[@"无套壳",@"iPad Pro",@"iPad",@"iPhone14Pro Max",@"iPhone14Pro",@"iPhone14Plus",@"iPhone14",@"iPhone13Pro Max",@"iPhone13Pro",@"iPhone13",@"iPhone13 Mini",@"iPhone12Pro Max",@"iPhone12Pro",@"iPhone12",@"iPhone12 Mini",@"iPhone11Pro Max",@"iPhone11Pro",@"iPhoneXR/11",@"iPhone8Plus",@"iPhone8"];
        [self setupViews];
    }
    return self;
}

-(void)layoutSubviews{
    
}
-(void)setupViews{
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 230, 325) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = HexColor(@"#1A1A1A");
    _tableView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_tableView];
//    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.equalTo(@230);
//        make.height.equalTo(@325);
//        make.left.top.equalTo(self);
//    }];
    [self.tableView registerClass:[ShellTableViewCell class] forCellReuseIdentifier:@"ShellTableViewCell"];
    UIImageView *line = [UIImageView new];
    line.backgroundColor = HexColor(@"#666666");
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@1);
        make.height.top.equalTo(self);
        make.left.equalTo(_tableView.mas_right);
    }];
    
    _colorView = [UIView new];
    [self addSubview:_colorView];
    //这判断机型显示颜色
    [_colorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(line.mas_right);
        make.top.height.equalTo(self);
        make.width.equalTo(@120);
    }];
    //[self layouColorViewType:1];
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _iphoneArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ShellTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ShellTableViewCell" forIndexPath:indexPath];
    [cell configModelWithTag:indexPath.row AndStr:_iphoneArr[indexPath.row]];
    return cell;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_selectIndex != indexPath.row){
        [self layouColorViewType:indexPath.row];
        _selectIndex = indexPath.row;
        self.selectClick(_iphoneArr[indexPath.row], _defaultColor);
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 36;
}

-(void)layouColorViewType:(NSInteger )type{
    if(type == 0){
        
    }else{
        NSArray *colorArr;
        if (type == 1 ){
            colorArr = @[@"#68696D",@"#E2E3E4"];
        }else if (type == 2 ){
            colorArr = @[@"#68696D",@"#E2E3E4",@"#FAE7CF"];
        }else if (type == 3 || type == 4){
            
        }else if (type == 5 || type == 6){
            
        }else if (type == 7 || type == 8){
            colorArr = @[@"#FFFFFF",@"#B7AFE6",@"#023B63",@"#D8EFD5",@"#54524F",@"#25212B"];
            
        }else if (type == 9 || type == 10){
            colorArr = @[@"#394C38",@"#FADDD7",@"#276787",@"#FFFFFF",@"#232A31",@"#BF0013"];
            
        }else if (type == 11 || type == 12){
            colorArr = @[@"#E3E4DF",@"#2D4E5C",@"#FCEBD3",@"#52514D"];
        }else if (type == 13 || type == 14){
            colorArr = @[@"#F6F2EF",@"#B7AFE6",@"#023B63",@"#D8EFD5",@"#D93030",@"#25212B"];
        }else if (type == 15 || type == 16){
            colorArr = @[@"#EBEBE3",@"#4E5851",@"#535150",@"#FAD7BD"];
        }else if (type == 17){
            colorArr = @[@"#F9F6EF",@"#D1CDDA",@"#FFE681",@"#AEE1CD",@"#1F2020",@"#BA0C2E"];
        }else if (type == 18){
            colorArr = @[@"#E2E3E4",@"#F7E8DD",@"#272729"];
        }else{
            colorArr = @[@"#E2E3E4",@"#F7E8DD",@"#272729"];
        }
        
        [_colorView removeAllSubviews];
        for (NSInteger i = 0; i < colorArr.count; i++) {
            UIButton *colorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            colorBtn.tag = i;
            colorBtn.frame = CGRectMake(28 + (i % 2) * 50, (i / 2 * 50) + 28 , 28, 28);
            colorBtn.layer.cornerRadius = 28 / 2;
            colorBtn.layer.masksToBounds = YES;
            
            if (i == 0){
                _selectColorBtn = colorBtn;
                if ([colorArr[i] isEqualToString:@"#FFFFFF"]){
                    colorBtn.layer.borderColor = [UIColor redColor].CGColor;
                }else{
                    colorBtn.layer.borderColor = [UIColor whiteColor].CGColor;
                }
                colorBtn.layer.borderWidth = 2;
                _defaultColor = HexColor(colorArr[i]);
            }
            colorBtn.backgroundColor = HexColor(colorArr[i]);
            
            [colorBtn addTarget:self action:@selector(colorSelected:) forControlEvents:UIControlEventTouchUpInside];
            [_colorView addSubview:colorBtn];
        }
    }
}

-(void)colorSelected:(UIButton *)btn{
    if (btn != _selectColorBtn){
        _selectColorBtn.layer.borderWidth = 0;
        _selectColorBtn.layer.borderColor = [UIColor clearColor].CGColor;
        btn.layer.borderWidth = 4;
        if ([btn.backgroundColor isEqual:[UIColor whiteColor]]){
            btn.layer.borderColor = [UIColor redColor].CGColor;
        }else{
            btn.layer.borderColor = [UIColor whiteColor].CGColor;
        }
        _selectColorBtn = btn;
        self.selectClick(_iphoneArr[_selectIndex], btn.backgroundColor);
    }
}


@end
