//
//  StitchingButton.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface StitchingButton : UIButton

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign, getter=isEditing) BOOL editing;

@end

NS_ASSUME_NONNULL_END
