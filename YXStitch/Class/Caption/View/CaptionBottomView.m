//
//  CaptionBottomView.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/19.
//

#import "CaptionBottomView.h"

@interface CaptionBottomView ()
@property (nonatomic ,assign)NSInteger selectIndex;

@end

@implementation CaptionBottomView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = HexColor(@"#1A1A1A");
        _selectIndex = 1;
       
        
    }
    return self;
}

-(void)layoutSubviews{
    [self setupViews];
    [self setupLayout];
}

-(void)setupViews{
    NSArray *iconArr;
    NSArray *textArr;
    if(_type == 1){
        iconArr = @[@"字幕调整未选中" ,@"字幕裁切未选中",@"字幕切割未选中",@"字幕编辑未选中"];
        textArr = @[@"调整",@"裁切",@"切割",@"编辑"];
    }else if(_type == 2){
        iconArr = @[@"字幕调整未选中" ,@"字幕裁切未选中",@"字幕切割未选中",@"字幕编辑未选中"];
        textArr = @[@"横拼",@"裁切",@"切割",@"编辑"];
    }else{
        iconArr = @[@"字幕调整未选中" ,@"字幕裁切未选中",@"字幕切割未选中",@"字幕编辑未选中"];
        textArr = @[@"擦除滚动条",@"裁切",@"切割",@"编辑"];
    }
    CGFloat btnWidth = SCREEN_WIDTH / iconArr.count;
    for (NSInteger i = 0; i < iconArr.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.tag = i + 1;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(btnWidth));
            make.height.top.equalTo(self);
            make.left.equalTo(@( i * btnWidth));
        }];
        
        UIImageView *icon = [UIImageView new];
        icon.image = IMG(iconArr[i]);
        icon.tag = (i + 1) * 100;
        [btn addSubview:icon];
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@22);
            make.centerX.equalTo(btn);
            make.top.equalTo(@22);
        }];
        
        UILabel *textLab = [UILabel new];
        textLab.textAlignment = NSTextAlignmentCenter;
        textLab.text = textArr[i];
        textLab.font = Font13;
        textLab.textColor = [UIColor whiteColor];
        [btn addSubview:textLab];
        [textLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.left.equalTo(btn);
            make.top.equalTo(icon.mas_bottom).offset(4);
        }];
        if ((_type == 2 && i == 0) || (_type == 3 && i == 0)){
            _typeLab = textLab;
        }
        if (i == 1){
            _preLab = textLab;
        }
        
    }
}
-(void)setupLayout{
    
}

-(void)btnClick:(UIButton *)btn{
//    if (btn.tag != _selectIndex){
//
//    }
    UIImageView *findIMG = (UIImageView *)[self viewWithTag:btn.tag * 100];
    UIImageView *beforeIMG = (UIImageView *)[self viewWithTag:_selectIndex * 100];
    switch (_selectIndex) {
        case 1:
            beforeIMG.image = [UIImage imageNamed:@"字幕调整未选中"];
            break;
        case 2:
            beforeIMG.image = [UIImage imageNamed:@"字幕裁切未选中"];
            break;
        case 3:
            beforeIMG.image = [UIImage imageNamed:@"字幕切割未选中"];
            break;
        case 4:
           // beforeIMG.image = [UIImage imageNamed:@"未选中水印右"];
            break;
        default:
            break;
    }
    switch (btn.tag) {
        case 1:
            findIMG.image = [UIImage imageNamed:@"选中无水印"];
            if (_type == 2){
                if ([_typeLab.text isEqualToString:@"竖拼"]){
                    _typeLab.text = @"横拼";
                }else{
                    _typeLab.text = @"竖拼";
                }
            }
            if (_type == 3){
                if ([_typeLab.text isEqualToString:@"擦除滚动条"]){
                    _typeLab.text = @"恢复滚动条";
                }else{
                    _typeLab.text = @"擦除滚动条";
                }
            }
            
            break;
        case 2:
            findIMG.image = [UIImage imageNamed:@"字幕裁切选中"];
//            if (_type == 2){
//
//            }
            if ([_preLab.text isEqualToString:@"预览"]){
                _preLab.text = @"裁切";
            }else{
                _preLab.text = @"预览";
            }
            break;
        case 3:
            findIMG.image = [UIImage imageNamed:@"选中水印居中"];
            break;
        case 4:
            //findIMG.image = [UIImage imageNamed:@"选中水印右"];
            break;
        default:
            break;
    }
    
    _selectIndex = btn.tag;
    self.btnClick(btn.tag);
}

@end
