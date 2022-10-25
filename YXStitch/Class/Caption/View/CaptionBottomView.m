//
//  CaptionBottomView.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/19.
//

#import "CaptionBottomView.h"

@interface CaptionBottomView ()
@property (nonatomic ,assign)NSInteger selectIndex;
@property (nonatomic ,assign)BOOL isAdd;
@end

@implementation CaptionBottomView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = HexColor(@"#1A1A1A");
        _selectIndex = MAXINTERP;
        _isAdd = YES;
    }
    return self;
}

-(void)layoutSubviews{
    if (_isAdd){
        [self setupViews];
        [self setupLayout];
        _isAdd = NO;
    }
}

-(void)setupViews{
    NSArray *iconArr;
    NSArray *textArr;
    if (_type == 5){
        iconArr = @[@"字幕裁切未选中",@"字幕切割未选中",@"字幕编辑未选中"];
        textArr = @[@"裁切",@"切割",@"编辑"];
    }else{
        if(_type == 1){
            iconArr = @[@"字幕调整选中" ,@"字幕裁切未选中",@"字幕切割未选中",@"字幕编辑未选中"];
            textArr = @[@"调整",@"裁切",@"切割",@"编辑"];
        }else if(_type == 2){
            iconArr = @[@"横拼" ,@"字幕裁切未选中",@"字幕切割未选中",@"字幕编辑未选中"];
            textArr = @[@"横拼",@"裁切",@"切割",@"编辑"];
        }else{
            iconArr = @[@"擦除滚动条" ,@"字幕裁切未选中",@"字幕切割未选中",@"字幕编辑未选中"];
            textArr = @[@"擦除滚动条",@"裁切",@"切割",@"编辑"];
        }
    }
    
    CGFloat btnWidth = SCREEN_WIDTH / iconArr.count;
    for (NSInteger i = 0; i < iconArr.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (_type == 5){
            btn.tag = i + 2;
        }else{
            btn.tag = i + 1;
        }
        [btn setBackgroundColor:[UIColor clearColor]];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(btnWidth));
            make.height.top.equalTo(self);
            make.left.equalTo(@( i * btnWidth));
        }];
        if (_type == 1 && i == 0){
            btn.selected = YES;
        }else{
            btn.selected = NO;
        }  
        UIImageView *icon = [UIImageView new];
        icon.image = IMG(iconArr[i]);
        icon.tag = btn.tag * 100;
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
        if ((_type == 2 && i == 0) || (_type == 3 && i == 0) || (_type == 4 && i == 0) ){
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
    UIImageView *selectIMG = [UIImageView new];
    UIImageView *beforeIMG = [UIImageView new];
    if (btn.tag == _selectIndex){
        selectIMG = (UIImageView *)[self viewWithTag:btn.tag * 100];
        if (btn.tag == 1){
            if (btn.selected){
                if(_type == 1){
                    selectIMG.image = IMG(@"字幕调整未选中");
                }else if (_type == 2){
                    _typeLab.text = @"竖拼";
                    selectIMG.image = IMG(@"横拼");
                }else{
                    _typeLab.text = @"擦除滚动条";
                    selectIMG.image = IMG(@"擦除滚动条");
                }
            }else{
                if(_type == 1){
                    selectIMG.image = IMG(@"字幕调整选中");
                }else if (_type == 2){
                    _typeLab.text = @"横拼";
                    selectIMG.image = IMG(@"横拼");
                }else{
                    _typeLab.text = @"恢复滚动条";
                    selectIMG.image = IMG(@"恢复滚动条");
                }
                
            }
        }else if (btn.tag == 2){
            if ([_preLab.text isEqualToString: @"裁切"]){
                selectIMG.image = IMG(@"预览选中");
                _preLab.text = @"预览";
            }else{
                selectIMG.image = IMG(@"字幕裁切选中");
                _preLab.text = @"裁切";
            }
        }else{
            if (btn.selected){
                selectIMG.image = IMG(@"字幕切割未选中");
            }else{
                selectIMG.image = IMG(@"字幕切割选中");
            }
        }
        btn.selected = !btn.selected;
    }else{
        selectIMG = (UIImageView *)[self viewWithTag:btn.tag * 100];
        beforeIMG = (UIImageView *)[self viewWithTag:_selectIndex * 100];
        
        if (_selectIndex == 1){
            if(_type == 1){
                beforeIMG.image = IMG(@"字幕调整未选中");
            }else if (_type == 2){
                _typeLab.text = @"竖拼";
                beforeIMG.image = IMG(@"横拼");
            }else{
                _typeLab.text = @"擦除滚动条";
                beforeIMG.image = IMG(@"擦除滚动条");
            }
        }else if (_selectIndex == 2){
            beforeIMG.image = IMG(@"字幕裁切未选中");
        }else if (_selectIndex == 3){
            beforeIMG.image = IMG(@"字幕切割未选中");
        }
        btn.selected = YES;
        if (btn.tag == 1){
            if(_type == 1){
                selectIMG.image = IMG(@"字幕调整未选中");
                btn.selected = NO;
            }else if (_type == 2){
                selectIMG.image = IMG(@"横拼");
                if ([_typeLab.text isEqualToString:@"竖拼"]){
                    _typeLab.text = @"横拼";
                }else{
                    _typeLab.text = @"竖拼";
                }
            }else if (_type == 3 || _type == 4){
                if ([_typeLab.text isEqualToString:@"擦除滚动条"]){
                    _typeLab.text = @"恢复滚动条";
                    selectIMG.image = IMG(@"恢复滚动条");
                }else{
                    _typeLab.text = @"擦除滚动条";
                    selectIMG.image = IMG(@"擦除滚动条");
                }
            }
        }else if (btn.tag == 2){
            selectIMG.image = IMG(@"预览选中");
            _preLab.text = @"预览";
        }else if (btn.tag == 3){
            selectIMG.image = IMG(@"字幕切割选中");
        }else{
            
        }
        
    }
    _selectIndex = btn.tag;
    self.btnClick(btn.tag);
}

@end
