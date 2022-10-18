//
//  surroundSelectPathView.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/10/17.
//

#import "surroundSelectPathView.h"
@interface surroundSelectPathView ()
@property (nonatomic ,strong)UIPanGestureRecognizer *panGesture;
@end

@implementation surroundSelectPathView
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupViews];
        self.layer.borderWidth = 1;
        self.layer.borderColor = HexColor(@"#276787").CGColor;
    }
    return self;
}


-(void)setupViews{
    for (NSInteger i = 0; i < 4 ; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.tag = i;
        [btn setBackgroundColor:HexColor(@"#276787")];
        btn.layer.cornerRadius = 6;
        btn.layer.masksToBounds = YES;
        btn.layer.borderColor = [UIColor whiteColor].CGColor;
        btn.layer.borderWidth = 1;
        [self addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@12);
            if (i == 0){
                make.centerX.equalTo(self.mas_left);
                make.top.equalTo(self.mas_top).offset(-4);
            }else if (i == 1){
                make.bottom.equalTo(self.mas_bottom).offset(4);
                make.centerX.equalTo(self.mas_left);
            }else if (i == 2){
                make.centerX.equalTo(self.mas_right);
                make.bottom.equalTo(self.mas_bottom).offset(4);
            }else{
                make.centerX.equalTo(self.mas_right);
                make.top.equalTo(self.mas_top).offset(-4);
            }
        }];
        [btn addTarget:self action:@selector(pathMove:) forControlEvents:UIControlEventTouchUpInside];
        
    }
}

-(void)pathMove:(UIButton *)btn{
    NSLog(@"btn.tag===%ld",btn.tag);
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(btnPanGesture:)];
    [btn addGestureRecognizer:_panGesture];
}

-(void)btnPanGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self];
    //NSLog(@"point.x===%lf point.y===%lf",point.x,point.y);
    
}

@end
