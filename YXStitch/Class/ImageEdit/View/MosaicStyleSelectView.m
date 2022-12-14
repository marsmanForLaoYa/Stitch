//
//  mosaic MosaicStyleSelectView.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/9/23.
//

#import "MosaicStyleSelectView.h"

@interface MosaicStyleSelectView ()
@property (nonatomic ,assign)UIButton *styleBtn;
@end

@implementation MosaicStyleSelectView
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = HexColor(@"#1A1A1A");
        [self setupViews];
    }
    return self;
}

-(void)setupViews{
    NSArray *shapeArr = @[@"样式_01_selected",@"样式_02_unSelected",@"样式_03_unSelected"];
    NSArray *styleArr = @[@"马赛克样式_03",@"马赛克样式_02",@"马赛克样式_01"];
    [self addBtnViewWithType:1 andData:shapeArr];
    [self addBtnViewWithType:2 andData:styleArr];
    
}

-(void)addBtnViewWithType:(NSInteger)type andData:(NSArray *)arr{
    for (NSInteger i = 0 ; i < arr.count ; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = type * 100 + i;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundImage:IMG(arr[i]) forState:UIControlStateNormal];
        [self addSubview:btn];
        if (type == 2){
            btn.layer.cornerRadius = 13;
            btn.layer.masksToBounds = YES;
            if (i == 2){
                _styleBtn = btn;
                btn.layer.borderWidth = 2;
                btn.layer.borderColor = [UIColor redColor].CGColor;
            }
        }
        if (i == 0 && type == 1){
            _selectBtn = btn;
        }
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            if (type == 1){
                make.left.equalTo(@(i * 40 + 30));
            }else{
                make.right.equalTo(self.mas_right).offset(-(i * 40 + 30));
            }
            make.width.height.equalTo(@(27));
            make.top.equalTo(@20);
        }];
        
    }
}

-(void)btnClick:(UIButton *)btn{
    if (btn.tag >= 200){
        if (_styleBtn != btn){
            _styleBtn.layer.borderWidth = 0;
            _styleBtn.layer.borderColor = [UIColor clearColor].CGColor;
            btn.layer.borderWidth = 2;
            btn.layer.borderColor = [UIColor redColor].CGColor;
            _styleBtn = btn;
            self.styleBtnClick(btn.tag);
        }
        
    }else{
        if (_selectBtn != btn){
            switch (btn.tag) {
                case 100:
                    [btn setImage:IMG(@"样式_01_selected") forState:UIControlStateNormal];
                    break;
                case 101:
                    [btn setImage:IMG(@"样式_02_selected") forState:UIControlStateNormal];
                    break;
                case 102:
                    [btn setImage:IMG(@"样式_03_selected") forState:UIControlStateNormal];
                    break;
                default:
                    break;
            }
            switch (_selectBtn.tag) {
                case 100:
                    [_selectBtn setImage:IMG(@"样式_01_unSelected") forState:UIControlStateNormal];
                    break;
                case 101:
                    [_selectBtn setImage:IMG(@"样式_02_unSelected") forState:UIControlStateNormal];
                    break;
                case 102:
                    [_selectBtn setImage:IMG(@"样式_03_unSelected") forState:UIControlStateNormal];
                    break;
                default:
                    break;
            }
            _selectBtn = btn;
            self.shapeBtnClick(btn.tag);
        }
    }
}

@end
