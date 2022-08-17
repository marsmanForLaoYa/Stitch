//
//  MoveCollectionViewCell.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/9.
//

#import "MoveCollectionViewCell.h"

@interface MoveCollectionViewCell()<UIGestureRecognizerDelegate>
@property(nonatomic,strong) UILabel *nameLab;
@property(nonatomic,strong) UIImageView *iconIMG;
@end

@implementation MoveCollectionViewCell
@synthesize p_MoveCollectionViewCellDelegate = m_MoveCollectionViewCellDelegate;
@synthesize nameLab;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addGestureCell];
        self.backgroundColor = [UIColor whiteColor];
        [self addLab];
    }
    return self;
}

//为cell添加手势
-(void)addGestureCell
{
    UILongPressGestureRecognizer * longPress =[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(GesturePress:)];
    longPress.delegate = self;
    [self addGestureRecognizer:longPress];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] <9)
    {
        UIPanGestureRecognizer * panGes =[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(GesturePress:)];
        panGes.delegate = self;
        [self addGestureRecognizer:panGes];
    }
}
//为cell添加lab
-(void)addLab{
    _iconIMG = [UIImageView new];
    [self addSubview:_iconIMG];
    nameLab = [UILabel new];
    nameLab.textAlignment = NSTextAlignmentCenter;
    nameLab.font = [UIFont boldSystemFontOfSize:16];
    [self addSubview:nameLab];
}

-(void)setCellName:(NSString *)cellName{
    _cellName = cellName;
    _iconIMG.image = [UIImage imageNamed:cellName];
    if ([cellName isEqualToString:@"更多功能"]){
        nameLab.textColor =  [UIColor colorWithHexString:@"#999999"];
    }else{
        nameLab.textColor = [UIColor blackColor];
    }
    [_iconIMG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        if ([cellName isEqualToString:@"截长屏"]){
            make.width.equalTo(@44);
            make.height.equalTo(@44);
        }else if ([cellName isEqualToString:@"网页滚动截图"]){
            make.width.equalTo(@32);
            make.height.equalTo(@44);
        }else if ([cellName isEqualToString:@"拼图"]){
            make.width.equalTo(@44);
            make.height.equalTo(@44);
        }else if ([cellName isEqualToString:@"水印"]){
            make.width.equalTo(@44);
            make.height.equalTo(@44);
        }else if ([cellName isEqualToString:@"设置"]){
            make.height.equalTo(@38);
            make.width.equalTo(@44);
        }else{
            //更多功能
            make.width.equalTo(@44);
            make.height.equalTo(@44);
        }
        make.top.equalTo(@32);
    }];
    [nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self);
        make.centerX.equalTo(_iconIMG);
        make.top.equalTo(_iconIMG.mas_bottom).offset(24);
    }];
    nameLab.text = cellName;
}

- (void)GesturePress:(UIGestureRecognizer *)gestureRecognizer{
    
    if (m_MoveCollectionViewCellDelegate && [m_MoveCollectionViewCellDelegate respondsToSelector:@selector(GesturePressDelegate:)]) {
        [m_MoveCollectionViewCellDelegate GesturePressDelegate:gestureRecognizer];
    }
}

@end

