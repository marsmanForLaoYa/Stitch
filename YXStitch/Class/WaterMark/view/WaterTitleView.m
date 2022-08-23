//
//  WaterTitleView.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/17.
//

#import "WaterTitleView.h"

@interface WaterTitleView ()<UITextViewDelegate>

@end

@implementation WaterTitleView
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.9;
        [self setupViews];
        [self setupLayout];
        
    }
    return self;
}

- (void)setupViews{
    _titleTV = [UITextView new];
    _titleTV.backgroundColor = [UIColor blackColor];
    _titleTV.text = GVUserDe.waterTitle.length > 0? GVUserDe.waterTitle:@"@拼图";
    _titleTV.delegate = self;
//    if (GVUserDe.waterTitleColor.length > 0){
//        _titleTV.textColor = HexColor(GVUserDe.waterTitleColor);
//    }else{
//        
//    }
//    if (GVUserDe.waterTitleFontSize > 8){
//        _titleTV.font = [UIFont systemFontOfSize:GVUserDe.waterTitleFontSize];
//    }else{
//        
//    }
    _titleTV.font = [UIFont systemFontOfSize:16];
    _titleTV.textColor = [UIColor whiteColor];
    [self addSubview:_titleTV];
    [self addBtn];
}
-(void)setupLayout{
    [_titleTV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(SCREEN_WIDTH - 32));
        make.left.equalTo(@16);
        make.top.equalTo(@86);
        make.height.equalTo(@200);
    }];
}
 
-(void)addBtn{
    NSArray *arr = @[@"取消",@"保存 "];
    for (NSInteger i = 0 ; i < arr.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.tag = i;
        [btn setTitle:arr[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = Font18;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@34);
            make.width.equalTo(@60);
            make.height.equalTo(@40);
            if (i == 0){
                make.left.equalTo(@16);
            }else{
                make.right.equalTo(self.mas_right).offset(-16);
            }
        }];
    }
}

-(void)btnClick:(UIButton *)btn{
    if (btn.tag == 1) {
        if(_titleTV.text.length > 0){
            GVUserDe.waterTitle = _titleTV.text;
            [_titleTV resignFirstResponder];
            self.btnClick(btn.tag);
        }else{
            [SVProgressHUD showInfoWithStatus:@"水印文字不能为空"];
        }
    }else{
        self.btnClick(btn.tag);
    }
    
}


//限制字数100字
-(void)textViewDidChange:(UITextView *)textView {
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
   //如果在变化中是高亮部分在变，就不要计算字符了
    if (selectedRange && pos) {
        return;
    }
    if (textView.text.length > 10) {
        textView.text = [textView.text substringToIndex:10];
        [SVProgressHUD showInfoWithStatus:@"水印文字长度不能超过10个"];
    }
}

@end
