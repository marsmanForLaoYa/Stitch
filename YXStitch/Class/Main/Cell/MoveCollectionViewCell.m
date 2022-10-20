//
//  MoveCollectionViewCell.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/9.
//

#import "MoveCollectionViewCell.h"

@interface MoveCollectionViewCell()<UIGestureRecognizerDelegate>

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
    if ([cellName isEqualToString:@"更多功能"] || [cellName isEqualToString:@"截长屏"] || [cellName isEqualToString:@"网页滚动截图"]|| [cellName isEqualToString:@"拼图"]|| [cellName isEqualToString:@"水印"]|| [cellName isEqualToString:@"设置"]){
        _iconIMG.image = [UIImage imageNamed:cellName];
        nameLab.text = cellName;
    }else{
        [_iconIMG sd_setImageWithURL:[NSURL URLWithString:cellName]];
    }
    
    if ([cellName isEqualToString:@"更多功能"]){
        nameLab.textColor =  [UIColor colorWithHexString:@"#999999"];
    }else{
        nameLab.textColor = [UIColor blackColor];
    }
    [_iconIMG mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        if ([cellName isEqualToString:@"截长屏"]){
            make.width.equalTo(@45);
            make.height.equalTo(@44);
        }else if ([cellName isEqualToString:@"网页滚动截图"]){
            make.width.equalTo(@31);
            make.height.equalTo(@44);
        }else if ([cellName isEqualToString:@"拼图"]){
            make.width.equalTo(@44);
            make.height.equalTo(@44);
        }else if ([cellName isEqualToString:@"水印"]){
            make.width.equalTo(@44);
            make.height.equalTo(@44);
        }else if ([cellName isEqualToString:@"设置"]){
            make.height.equalTo(@39);
            make.width.equalTo(@44);
        }else if ([cellName isEqualToString:@"更多功能"]){
            //更多功能
            make.width.equalTo(@44);
            make.height.equalTo(@44);
        }else{
            make.width.equalTo(@44);
            make.height.equalTo(@44);
        }
        make.top.equalTo(@34);
    }];
    [nameLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self);
        make.centerX.equalTo(_iconIMG);
        make.top.equalTo(_iconIMG.mas_bottom).offset(24);
    }];
    
}

- (void)GesturePress:(UIGestureRecognizer *)gestureRecognizer{
    
    if (m_MoveCollectionViewCellDelegate && [m_MoveCollectionViewCellDelegate respondsToSelector:@selector(GesturePressDelegate:)]) {
        [m_MoveCollectionViewCellDelegate GesturePressDelegate:gestureRecognizer];
    }
}

@end

