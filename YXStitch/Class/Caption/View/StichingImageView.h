//
//  StichingImageView.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface StichingImageView : UIView

@property (nonatomic, copy) void(^touchBegan)(StichingImageView *stichingImageView);
@property (nonatomic, copy) void(^touchEnd)(StichingImageView *stichingImageView);
@property (nonatomic, copy) void(^touchMove)(StichingImageView *stichingImageView, CGFloat offsetY);

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign, getter=isEditing) BOOL editing;

@end

NS_ASSUME_NONNULL_END
