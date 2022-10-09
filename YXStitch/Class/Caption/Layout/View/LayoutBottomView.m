//
//  LayoutBottomView.m
//  YXStitch
//
//  Created by mac_m11 on 2022/9/24.
//

#import "LayoutBottomView.h"
@class ButtonView;

static NSInteger BottomItemBaseTag = 1100;

@interface LayoutBottomView ()

@end
@implementation LayoutBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame: frame])
    {
        [self initlalizeSubviews];
    }
    return self;
}

- (void)initlalizeSubviews {
    
    NSArray *imagesNormal = @[@"bottom_layout_normal", @"bottom_canvas_normal", @"bottom_border_normal"];
    NSArray *imagesSelected = @[@"bottom_layout_selected", @"bottom_canvas_selected", @"bottom_border_selected"];
    NSArray *titles = @[@"布局", @"画布", @"边框"];
    CGFloat ButtonWidth = 60;
    CGFloat padding = (SCREEN_WIDTH - ButtonWidth * 3) / (titles.count + 1);
    CGFloat left = padding;
    for (int i = 0; i < titles.count; i++) {
//        ButtonView *btnView = [[ButtonView alloc] initWithImagName:imagesNormal[i] title:titles[i]];
        ButtonView *btnView = [[ButtonView alloc] initWithNormalImagName:imagesNormal[i] selectedImagName:imagesSelected[i] title:titles[i]];
        [btnView.button addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        btnView.button.tag = BottomItemBaseTag + i;
        [self addSubview:btnView];
        btnView.frame = CGRectMake(left, 0, ButtonWidth, self.height);
        left += padding + ButtonWidth;
    }
}

UIButton *lastSelectedBtn;
- (void)btnAction:(UIButton *)btn {
    
    if(![btn isEqual:lastSelectedBtn]) {
        lastSelectedBtn.selected = NO;
    }
    btn.selected = !btn.selected;
    lastSelectedBtn = btn;

    if(self.layoutBottomBlock)
    {
        self.layoutBottomBlock(btn.tag - BottomItemBaseTag);
    }
}

@end

@implementation ButtonView

- (instancetype)initWithNormalImagName:(NSString *)normalImageName selectedImagName:(NSString *)selectedImagName title:(NSString *)title
{
    if(self = [super init])
    {
        [self initlizeSubviewsWithNormalImagName:normalImageName selectedImagName:selectedImagName title:title];
    }
    return self;
}

- (void)initlizeSubviewsWithNormalImagName:(NSString *)normalImageName selectedImagName:(NSString *)selectedImagName title:(NSString *)title {
    
    UIButton *button = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:normalImageName] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:selectedImagName] forState:UIControlStateSelected];
        btn.backgroundColor = [UIColor clearColor];
        btn;
    });
    [self addSubview:button];
    _button = button;
    
    UILabel *titleLabel = ({
        UILabel *name = [[UILabel alloc] init];
        name.textColor = RGB(255, 255, 255);
        name.textAlignment = NSTextAlignmentCenter;
        name.font = Font15;
        name.text = title;
        name;
    });
    [self addSubview:titleLabel];
    _titleLabel = titleLabel;
}

- (void)layoutSubviews
{
    CGFloat left = 10;
    self.button.left = left;
    self.button.top = 0;
    self.button.width = self.width - left * 2;
    self.button.height = self.width - left * 2;
    
    self.titleLabel.top = self.button.bottom - 5;
    self.titleLabel.left = 0;
    self.titleLabel.width = self.width;
    self.titleLabel.height = self.height - self.width;
}

@end
