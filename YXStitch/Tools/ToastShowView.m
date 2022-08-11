//
//  ToastShowView.m
//  SkyMeeting
//
//  Created by xiaobin Tang on 2020/4/14.
//  Copyright © 2020 xiaobin Tang. All rights reserved.
//

#import "ToastShowView.h"

@interface ToastShowView ()

@property (nonatomic, strong)UIView *viewBg;

@property(nonatomic ,strong)ToastShowView *thisView ;

@end

@implementation ToastShowView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor=[UIColor cyanColor];
//        [self ];
    }
    return self;
}

- (void)showToastWindow{

    [self animateIn];

}

- (void)hideToastWindow{

    
    [self animateOut];

}



#pragma mark - BG Action
-(void)animateIn
{
    self.viewBg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    //背景
    [self creatBackgroundView];
    [self addSubview:self.viewBg];
    
    self.userInteractionEnabled = YES;
    self.viewBg.userInteractionEnabled = YES;
    
    self.viewBg.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.0 animations:^{
        self.viewBg.transform = CGAffineTransformMakeScale(1, 1);
        [self makeToastActivity:CSToastPositionCenter];
    }];
    
}

-(void)animateOut
{
    [UIView animateWithDuration:0.0 animations:^{
        self.viewBg.transform = CGAffineTransformMakeScale(0.01, 0.01);
        self.viewBg.alpha = 0.2;
        self.alpha = 0.2;
    } completion:^(BOOL finished) {
        [self hideToastActivity];
        [self removeFromSuperview];
    }];
    
}
-(void)creatBackgroundView
{
    self.frame = [[UIScreen mainScreen] bounds];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    self.opaque = NO;
    
    //这里自定义的View 达到的效果和UIAlterView一样是在Window上添加，UIWindow的优先级最高，Window包含了所有视图，在这之上添加视图，可以保证添加在最上面
    UIWindow *appWindow = [[UIApplication sharedApplication] keyWindow];
    [appWindow addSubview:self];
    
    [UIView animateWithDuration:0.0 animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }];
    
}

@end
