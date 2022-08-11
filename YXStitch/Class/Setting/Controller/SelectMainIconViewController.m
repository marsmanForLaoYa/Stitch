//
//  SelectMainIconViewController.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/10.
//

#import "SelectMainIconViewController.h"

@interface SelectMainIconViewController ()
@property (nonatomic ,strong)UIView *contentView;
@property (nonatomic ,strong)UIImageView *darkIMG;
@property (nonatomic ,strong)UIImageView *lightIMG;
@end

@implementation SelectMainIconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"主屏幕图标";
    [self setupViews];
}
-(void)setupViews{
    _contentView = [[UIView alloc]init];
    _contentView.backgroundColor = HexColor(BKGrayColor);
    [self.view addSubview:_contentView];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(self.view);
        make.height.equalTo(@(SCREEN_HEIGHT - Nav_H));
        make.top.equalTo(@(Nav_H));
    }];
    
    NSArray *arr = @[@"darkIcon",@"lightIcon"];
    CGFloat iconWidth = (CGFloat)(SCREEN_WIDTH - 45 ) / 2;
    for (NSInteger i = 0; i < arr.count ; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
        btn.backgroundColor = [UIColor clearColor];
        [btn addTarget:self action:@selector(changeIcon:) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(iconWidth));
            make.height.equalTo(@(iconWidth + 30));
            make.top.equalTo(@20);
            make.left.equalTo(@(15 + i * (iconWidth + 15)));
        }];
        
        UIImageView *icon = [UIImageView new];
        icon.image = IMG(arr[i]);
        [btn addSubview:icon];
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@(iconWidth));
            make.left.top.equalTo(btn);
        }];
        
        UIImageView *selectIMG = [UIImageView new];
        selectIMG.image = IMG(@"unSelect");
        if (i == 0){
            _darkIMG = selectIMG;
        }else{
            _lightIMG = selectIMG;
        }
        [btn addSubview:selectIMG];
        [selectIMG mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@15);
            make.centerX.equalTo(btn);
            make.top.equalTo(icon.mas_bottom).offset(15);
        }];
    }
    
}

-(void)changeIcon:(UIButton *)btn{
    if (btn.tag == 0){
        _darkIMG.image = [UIImage imageNamed:@"select"];
        _lightIMG.image = [UIImage imageNamed:@"unSelect"];
    }else{
        _darkIMG.image = [UIImage imageNamed:@"unSelect"];
        _lightIMG.image = [UIImage imageNamed:@"select"];
    }
    
    
}


@end
