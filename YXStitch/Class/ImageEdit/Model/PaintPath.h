//
//  PaintPath.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/9/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PaintPath : UIBezierPath
@property (nonatomic ,strong)NSArray *allPoints;//该画笔的所有路径点
@property (nonatomic ,assign)CGRect boundRect; //该画笔形成的矩形框
@property (nonatomic ,assign)NSInteger pathLineWidth;// 线的宽度
@property (nonatomic ,strong)NSString *colorStr;// 线的颜色
@property (nonatomic ,strong)UIColor *pathColor;


@property (nonatomic ,assign)UIBezierPath *path;

+ (instancetype)paintPathWithLineWidth:(CGFloat)width
                            startPoint:(CGPoint)startP;
@end

NS_ASSUME_NONNULL_END
