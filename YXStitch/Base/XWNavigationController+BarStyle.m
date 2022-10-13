//
//  XWNavigationController+BarStyle.m
//  XWNWS
//
//  Created by mac_m11 on 2022/9/9.
//

#import "XWNavigationController+BarStyle.h"

@implementation XWNavigationController (BarStyle)

- (void) removeBarShadow
{
    if (@available(iOS 15.0, *))
    {
        UINavigationBarAppearance *navigationBarAppearance = [[UINavigationBarAppearance alloc]init];
        [navigationBarAppearance configureWithOpaqueBackground];
        navigationBarAppearance.backgroundColor = UIColor.whiteColor;
        navigationBarAppearance.backgroundEffect = nil;
        navigationBarAppearance.shadowColor = nil;
        self.navigationBar.scrollEdgeAppearance = nil;
        self.navigationBar.standardAppearance = navigationBarAppearance;
    }
    else
    {
        [self.navigationBar setShadowImage:[UIImage new]];
    }
    //导航栏透明
    self.navigationBar.translucent = YES;
}

- (void) setNavgationBarTintColor:(UIColor * __nullable)color
{
    if (color == nil) {
        self.navigationBar.tintColor = [UIColor blackColor];
    } else {
        self.navigationBar.tintColor = color;
    }
}

- (void) removeNavBarShadowImage
{
    [self setBackgroundImageWithImage:[[UIImage alloc] init]];
    //去掉透明后导航栏下边的黑边
    [self removeBarShadow];
}

- (void) addNavBarShadowImageWithColor:(UIColor *)color
{
    [self setBackgroundImageWithImage:[self imageWithColor:color]];
    //导航栏不透明
    self.navigationBar.translucent = YES;
}

- (void)setBackgroundImageWithImage:(UIImage *)image {
    if (@available(iOS 15.0, *))
    {
        UINavigationBarAppearance *navigationBarAppearance = [[UINavigationBarAppearance alloc]init];
        [navigationBarAppearance configureWithOpaqueBackground];
        [navigationBarAppearance setBackgroundImage:image];

        self.navigationBar.scrollEdgeAppearance = navigationBarAppearance;
        self.navigationBar.standardAppearance = navigationBarAppearance;
    }
    else
    {
        [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
}

- (void) addNavBarTitleTextAttributes:(NSDictionary *)attributes barShadowHidden:(BOOL)barShadowHidden shadowColor:(UIColor *)shadowColor
{
    if (@available(iOS 15.0, *))
    {
        UINavigationBarAppearance *navigationBarAppearance = [[UINavigationBarAppearance alloc]init];

        [navigationBarAppearance configureWithOpaqueBackground];
        navigationBarAppearance.titleTextAttributes = attributes;
        // 隐藏分割线
        if(barShadowHidden) {
            navigationBarAppearance.backgroundEffect = nil;
            navigationBarAppearance.shadowColor = nil;
        }
        else
        {
            navigationBarAppearance.shadowImage =[[UIImage alloc] init];
            navigationBarAppearance.shadowColor= shadowColor;
        }

        if (self.navigationBar.scrollEdgeAppearance) {
            [navigationBarAppearance setBackgroundImage:self.navigationBar.scrollEdgeAppearance.backgroundImage];
            self.navigationBar.scrollEdgeAppearance = navigationBarAppearance;
            self.navigationBar.standardAppearance = navigationBarAppearance;
        }
        else
        {
            navigationBarAppearance.backgroundColor = UIColor.whiteColor;
            self.navigationBar.scrollEdgeAppearance = nil;
            self.navigationBar.standardAppearance = navigationBarAppearance;
        }
    }
    else
    {
        [self.navigationBar setTitleTextAttributes:attributes];
        // 隐藏分割线
        if(barShadowHidden) {
            // 隐藏分割线
            [self.navigationBar setShadowImage:[self shadowImage]];
        }
    }
}

static UIImage *navigationBarShadowImage;

- (UIImage *) shadowImage
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGFloat locations[] = { 0.0, 1.0 };
        
        CGColorRef startColor = RGB(26, 32, 39).CGColor;
        CGColorRef endColor = RGB(26, 32, 39).CGColor;
        
        NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor];
        
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
        
        CGRect rect = CGRectMake(0.0f, 0.0f, kScreenWidth, 10.0f);
        
        
        //具体方向可根据需求修改
        CGPoint startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGPoint endPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
        
        UIGraphicsBeginImageContext(rect.size); //在这个范围内开启一段上下文
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();//从这段上下文中获取Image属性,,,结束
        UIGraphicsEndImageContext();
        
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorSpace);
        
        navigationBarShadowImage = image;
    });
    
    
    return navigationBarShadowImage;
}

@end
