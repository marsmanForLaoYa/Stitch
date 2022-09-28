//
//  NSString+Extension.m
//  A01-QQ聊天
//
//  Created by apple on 15/3/17.
//  Copyright (c) 2015年 heima. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)
//计算文本的size
- (CGSize)sizeOfMaxSize:(CGSize)maxSize font:(UIFont *)font{
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
}

+ (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font constraintSize:(CGSize)constraintSize
{
    CGSize stringSize = CGSizeZero;
    
    NSDictionary *attributes = @{NSFontAttributeName:font};
    NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
    CGRect stringRect = [string boundingRectWithSize:constraintSize options:options attributes:attributes context:NULL];
    stringSize = stringRect.size;
    
    return stringSize;
}

@end
