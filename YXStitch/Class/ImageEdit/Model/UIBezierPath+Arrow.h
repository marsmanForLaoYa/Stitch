//
//  mosaic UIBezierPath+Arrow.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/9/23.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ENUM_BUTTON_CHOICE) {
    LINE = 1001,
    ARROW,
    RECTANGLE,
    FILLRECTANGLE,
    MOSAICOVAL,
    MOSAICRECTANGLE,
    MOSAIC,
    WORD,
    CLEAR,
    UNDO,
    CANCEL,
    DELETELAYER,
    FINISH
};

@interface UIBezierPath (Arrow)

@property(nonatomic, assign)NSInteger pathType;
@property (nonatomic, strong) UIColor *color;

@property (nonatomic ,strong)NSArray *allPoints;//该画笔的所有路径点
@property (nonatomic ,assign)CGRect boundRect; //该画笔形成的矩形框
@property (nonatomic ,assign)NSInteger pathLineWidth;// 线的宽度
@property (nonatomic ,strong)NSString *colorStr;// 线的颜色
@property (nonatomic ,strong)UIColor *pathColor;

+ (instancetype)pathWitchColor:(UIColor *)color lineWidth:(CGFloat)lineWidth;

+ (UIBezierPath *)arrow:(CGPoint)start toEnd:(CGPoint)end tailWidth:(CGFloat)tailWidth headWidth:(CGFloat)headWidth headLength:(CGFloat)headLength;

@end
