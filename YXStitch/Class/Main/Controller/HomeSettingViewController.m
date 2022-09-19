//
//  SettingViewController.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/9.
//

#import "HomeSettingViewController.h"
#import "HomeViewController.h"

@interface HomeSettingViewController ()
@property (nonatomic ,strong)UIView *iconView;
@property (nonatomic ,strong)NSMutableArray *selectArr;

@end

@implementation HomeSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"设置";
    _selectArr = [NSMutableArray array];
    [self setupViews];
    [self setupLayout];
    [self setupNavItems];
}

#pragma mark - UI
-(void)setupViews{
    _iconView = [[UIView alloc]init];
    _iconView.backgroundColor = HexColor(BKGrayColor);
    [self.view addSubview:_iconView];
    [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(self.view);
        make.height.equalTo(@(SCREEN_HEIGHT - Nav_H));
        make.top.equalTo(@(Nav_H));
    }];
    NSMutableArray *iconArr = [NSMutableArray arrayWithObjects:@"截长屏",@"网页滚动截图",@"拼图",@"水印",@"设置",nil];
    CGFloat btnWidth = (CGFloat) 168 / 375  * SCREEN_WIDTH;
    CGFloat btnHeight = (CGFloat) 160 / 667  * SCREEN_HEIGHT;
   // CGFloat btnHeight = (CGFloat) 160 ;
    for (NSInteger i = 0; i < iconArr.count; i ++) {
        UIButton *iconBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        iconBtn.tag = i ;
        [iconBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [iconBtn setBackgroundColor:[UIColor whiteColor]];
        iconBtn.layer.masksToBounds = YES;
        iconBtn.layer.cornerRadius = 10;
        [_iconView addSubview:iconBtn];
        [iconBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(16 + (i % 2) * (btnWidth  + 10)));
            make.top.equalTo(@(30 + (i / 2) * (btnHeight + 10)));
            make.width.equalTo(@(btnWidth));
            make.height.equalTo(@(btnHeight));
        }];
        UIImageView *iconIMG = [UIImageView new];
        iconIMG.image = [UIImage imageNamed:iconArr[i]];
        [iconBtn addSubview:iconIMG];
        NSString *textStr = iconArr[i];
        
        UIImageView *selectIMG = [UIImageView new];
        selectIMG.image = [UIImage imageNamed:@"unSelect"];
        [iconBtn addSubview:selectIMG];
        selectIMG.tag = (i + 1) * 100;
        [iconBtn addSubview:selectIMG];
        [selectIMG mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@15);
            make.right.equalTo(@-12);
            make.top.equalTo(@12);
        }];
        
        
        
        [iconIMG mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(iconBtn);
            make.height.equalTo(@45);
            if ([textStr isEqualToString:@"截长屏"]){
                make.width.equalTo(@45);
            }else if ([textStr isEqualToString:@"网页滚动截图"]){
                make.width.equalTo(@32);
            }else if ([textStr isEqualToString:@"拼图"]){
                make.width.equalTo(@44);
            }else if ([textStr isEqualToString:@"水印"]){
                make.width.equalTo(@44);
            }else if ([textStr isEqualToString:@"设置"]){
                make.height.equalTo(@39);
                make.width.equalTo(@44);
            }else{
                //更多功能
                make.width.equalTo(@44);
            }
            make.top.equalTo(@32);
        }];
        
        UILabel *textLab = [UILabel new];
        textLab.textColor = [UIColor blackColor];
        textLab.text = iconArr[i];
        textLab.textAlignment = NSTextAlignmentCenter;
        textLab.font = [UIFont boldSystemFontOfSize:16];
        [iconBtn addSubview:textLab];
        [textLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(iconBtn);
            make.centerX.equalTo(iconIMG);
            make.top.equalTo(iconIMG.mas_bottom).offset(24);
        }];
    }
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [saveBtn setBackgroundColor:[UIColor blackColor]];
    [saveBtn setTintColor:[UIColor whiteColor]];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    saveBtn.layer.masksToBounds = YES;
    saveBtn.layer.cornerRadius = 5;
    [saveBtn addTarget:self action:@selector(saveClick) forControlEvents:UIControlEventTouchUpInside];
    [_iconView addSubview:saveBtn];
    [saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-23);
        make.height.equalTo(@40);
        make.left.equalTo(@58);
        make.width.equalTo(@(SCREEN_WIDTH - 58 * 2));
    }];
    
}
-(void)setupLayout{
    
}

-(void)setupNavItems{
    
//    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//    [rightBtn setTitle:@"功能" forState:UIControlStateNormal];
//    [rightBtn setTintColor:[UIColor blackColor]];
//    [rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
//    self.navigationItem.rightBarButtonItem = rightItem;
}


#pragma mark -- btn触发事件
-(void)rightBtnClick:(UIButton *)btn{
    
}

-(void)btnClick:(UIButton *)btn{
    if ([_selectArr containsObject:btn]){
        NSInteger index = [_selectArr indexOfObject:btn];
        [_selectArr removeObjectAtIndex:index];
        UIImageView *findIMG = (UIImageView *)[self.view viewWithTag:(btn.tag + 1) * 100];
        findIMG.image = [UIImage imageNamed:@"unSelect"];
    }else{
        [_selectArr addObject:btn];
        UIImageView *findIMG = (UIImageView *)[self.view viewWithTag:(btn.tag + 1) * 100];
        findIMG.image = [UIImage imageNamed:@"select"];
    }
    
}

-(void)saveClick{
    if (_selectArr.count > 0){
        NSMutableArray *tempArr = [NSMutableArray array];
        for (UIButton *btn in _selectArr) {
            switch (btn.tag) {
                case 0:
                    [tempArr addObject: @"截长屏"];
                    break;
                case 1:
                    [tempArr addObject: @"网页滚动截图"];
                    break;
                case 2:
                    [tempArr addObject: @"拼图"];
                    break;
                case 3:
                    [tempArr addObject: @"水印"];
                    break;
                case 4:
                    [tempArr addObject: @"设置"];
                    break;
                default:
                    break;
            }
        }
        [tempArr addObject:@"更多功能"];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:tempArr forKey:@"iconArr"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"homeChange" object:nil userInfo:dict];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [SVProgressHUD showInfoWithStatus:@"请至少选择一个功能保存！"];
    }
    
}


@end
