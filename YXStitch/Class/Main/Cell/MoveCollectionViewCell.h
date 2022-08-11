//
//  MoveCollectionViewCell.h
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@protocol MoveCollectionViewCellDelegate <NSObject>
- (void)GesturePressDelegate:(UIGestureRecognizer *)gestureRecognizer;
@end

@interface MoveCollectionViewCell : UICollectionViewCell
{
    __weak id<MoveCollectionViewCellDelegate>m_MoveCollectionViewCellDelegate;
}
@property (nonatomic, weak) id<MoveCollectionViewCellDelegate> p_MoveCollectionViewCellDelegate;
@property (nonatomic, strong) NSString* cellName;
@end

NS_ASSUME_NONNULL_END
