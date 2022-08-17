//
//  Color.h
//  SkyMeeting
//
//  Created by xiaobin Tang on 2020/4/14.
//  Copyright © 2020 xiaobin Tang. All rights reserved.
//

#ifndef Color_h
#define Color_h

#pragma mark - 定义
#define  FontBlue   @"#2E9DFF"
#define  FontGrary   @"#FEFEFE"
#define  FontDarkGrary   @"#333333"
#define  Base_bg_white_color   @"#FFFFFF"
#define  BKGrayColor  @"#F4F4F4"
#define  BlueFont  @"609BFC"
#define  BlueBK  @"DEEBF5"

#define GLOABLE_COLOR RGB(33, 46, 66)
#define GLOABLE_SELECT_COLOR RGB_A(33, 46, 66, 0.5)
#define GLOABLE_TEXT_COLR RGB(218, 250, 255)//DAFAFF
#define GLOABLE_TEXT_SELECT_COLOR RGB_A(218, 250, 255, 0.5)
//色值
#define RGB(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGB_A(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#pragma mark- 转换

#define HexColor(str) [UIColor colorWithHexString:str]

//rgb颜色转换（16进制->10进制）
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//获取RGB颜色
#define ColorA(str1,str2,str3,str4) [UIColor colorWithRed:str1/255.0 green:str2/255.0 blue:str3/255.0 alpha:str4]
#define Color(str1,str2,str3) ColorA(str1,str2,str3,1.0f)




#pragma mark- 随机颜色

#define random(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]
#define randomColor random(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

#endif /* Color_h */
