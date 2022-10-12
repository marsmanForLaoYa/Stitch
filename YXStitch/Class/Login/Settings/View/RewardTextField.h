//
//  RewardTextField.h
//  XWNWS
//
//  Created by mac_m11 on 2022/9/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RewardTextField : UITextField

@property(nonatomic, assign) NSUInteger maxLength;
@property(nonatomic, assign) BOOL clearEmoji;

@end

NS_ASSUME_NONNULL_END
