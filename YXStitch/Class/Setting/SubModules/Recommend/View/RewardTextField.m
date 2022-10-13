//
//  RewardTextField.m
//  XWNWS
//
//  Created by mac_m11 on 2022/9/13.
//

#import "RewardTextField.h"

@implementation RewardTextField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void) initialize
{
    
    [self addObservers];
}


- (void) addObservers
{
    [self addTarget:self action:@selector(textFieldDidChangeText:) forControlEvents:UIControlEventEditingChanged];
    
}

- (void) textFieldDidChangeText:(UITextField *)textField
{
    if (textField != self || self.maxLength == 0)
    {
        return;
    }
    
    NSString *destText = self.text;
    
    //去掉首空格
    while ([destText hasPrefix:@" "] ) {
        destText = [destText substringFromIndex:1];
    }

    //如果有连续两个空格则合并成一个空格
    NSRange doubleSpaceRange = [destText rangeOfString:@"  " options:NSBackwardsSearch];
    while (doubleSpaceRange.length == 2) {
        destText = [destText stringByReplacingCharactersInRange:doubleSpaceRange withString:@" "];
        doubleSpaceRange = [destText rangeOfString:@"  " options:NSBackwardsSearch];
    }
    
    NSUInteger maxLength = self.maxLength;
    
    if (self.clearEmoji)
    {
        destText = [self clearEmojiForString:destText];
//        self.text = destText;
    }
    
    // 对中文的特殊处理，shouldChangeCharactersInRangeWithReplacementString 并不响应中文输入法的选择事件
    // 如拼音输入时，拼音字母处于选中状态，此时不判断是否超长
    UITextRange *range = textField.selectedTextRange;
    UITextRange *selectedRange = [textField markedTextRange];
    if (!selectedRange || !selectedRange.start)
    {
        if (destText.length > maxLength)
        {
            //Emoji占2个字符，如果是超出了半个Emoji，用15位置来截取会出现Emoji截为2半
            //超出最大长度的那个字符序列(Emoji算一个字符序列)的range
            NSRange range = [destText rangeOfComposedCharacterSequenceAtIndex:maxLength];
            self.text = [destText substringToIndex:range.location];
        }
        else
        {
            self.text = destText;
        }
    }
    self.selectedTextRange = range;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (NSString *)clearEmojiForString:(NSString *)str
{
    // 符号表：https://blog.csdn.net/hherima/article/details/9045765
    __block NSString *resultStr = str;
    [resultStr enumerateSubstringsInRange:NSMakeRange(0, [resultStr length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        if (substring.length>1) {
            resultStr = [resultStr stringByReplacingCharactersInRange:substringRange withString:@""];
            *stop=YES;
        }
    }];
    
    resultStr = [resultStr stringByReplacingRegex:@"[^\\u0100-\\u02AF\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\u0300-\\u06FF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFFF\\u0080-\\u00FF\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive withString:@""];
    return resultStr;
}

-(CGRect)textRectForBounds:(CGRect)bounds {
    int leftMargin = 10;
    int rightMargin = 5;
    CGRect inset = CGRectMake(bounds.origin.x + leftMargin, bounds.origin.y, bounds.size.width - leftMargin - rightMargin, bounds.size.height);
    return inset;
}

-(CGRect)editingRectForBounds:(CGRect)bounds {
    int leftMargin = 10;
    int rightMargin = 5;
    CGRect inset = CGRectMake(bounds.origin.x + leftMargin, bounds.origin.y, bounds.size.width - leftMargin - rightMargin, bounds.size.height);
    return inset;
}

@end
