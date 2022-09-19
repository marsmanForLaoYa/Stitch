//
//  FullWaterMarkView.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/17.
//

#import "FullWaterMarkView.h"
#import "FullWaterMarkTableViewCell.h"

@interface FullWaterMarkView()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)NSMutableArray *dataSource;

@end

@implementation FullWaterMarkView

+(FullWaterMarkView*)addWaterMarkView:(NSString*)waterMarkText andSize:(NSInteger)size andColor:(nonnull NSString *)color{
    FullWaterMarkView *watermarkView =  [[FullWaterMarkView alloc] initWithFrame:CGRectMake(- SCREEN_HEIGHT,-SCREEN_HEIGHT, SCREEN_HEIGHT * 3, SCREEN_HEIGHT * 3) waterMarkText:waterMarkText andSize:size andColor:color];
    watermarkView.transform = CGAffineTransformMakeRotation(-M_PI * 0.25);
    return watermarkView;
}

- (instancetype)initWithFrame:(CGRect)frame waterMarkText:(NSString*)waterMarkText andSize:(NSInteger)size andColor:(nonnull NSString *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.waterMarkText = waterMarkText;
        self.waterMarkTextSize = size;
        self.waterMarkTextColor = color;
        [self setUI];
    }
    return self;
}
-(void)setUI{
    [self addSubview:self.tableView];
    [self.tableView registerClass:[FullWaterMarkTableViewCell class] forCellReuseIdentifier:@"cellWaterMark"];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}
#pragma mark ==========tableView代理方法==========
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    static NSString *CellIdentifier = @"cellWaterMark";
//    FullWaterMarkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[FullWaterMarkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
    FullWaterMarkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellWaterMark"];
   // cell.waterTextLabel.text = self.dataSource[indexPath.row];
//    cell.waterTextLabel.textColor = HexColor(self.waterMarkTextColor);
//    cell.waterTextLabel.font = [UIFont systemFontOfSize:self.waterMarkTextSize];
    [cell configModel:self.dataSource[indexPath.row] andSize:self.waterMarkTextSize andColor:self.waterMarkTextColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}
-  (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
- (UITableView *)tableView{
    if(!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width,self.frame.size.height) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.userInteractionEnabled = NO;
        return _tableView;
    }
    return _tableView;
}
- (NSMutableArray *)dataSource{
    if(!_dataSource){
        _dataSource = [[NSMutableArray alloc]init];
        for (int i = 0; i < SCREEN_HEIGHT * 3 / 100; i++) {
            NSString *str = @"";
            for (int j = 0; j < 50; j++) {
                str = [NSString stringWithFormat:@"%@        %@",str,self.waterMarkText];
            }
            if (i%2 == 0) {
                [_dataSource addObject:str];
            }else{
                [_dataSource addObject:[NSString stringWithFormat:@"%@%@",@"        ",str]];
            }
        }
    }
    return _dataSource;
}

@end
