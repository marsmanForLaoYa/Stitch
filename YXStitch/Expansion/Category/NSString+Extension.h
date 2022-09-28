//
//  NSString+Extension.h
//  A01-QQ聊天
//
//  Created by apple on 15/3/17.
//  Copyright (c) 2015年 heima. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (Extension)

- (CGSize)sizeOfMaxSize:(CGSize)maxSize font:(UIFont *)font;
+ (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font constraintSize:(CGSize)constraintSize;

@end
