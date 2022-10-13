//
//  SettingModel.h
//  XWNWS
//
//  Created by mac_m11 on 2022/9/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CellType) {
    CellTypeGoForward,
    CellTypeGoLogin,
    CellTypeShowDetail,
    CellTypeButton,
    CellTypeTextFeild,
    CellTypeImageView,
};

@interface RecommendModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *subTitle;
@property (nonatomic, assign) CellType cellType;
//订阅的产品类型
@property (nonatomic, copy) NSString *subcriseProduct;

@property (nonatomic, assign) BOOL isLineHidden;

- (instancetype)initWithTitle:(nullable NSString *)title
                       detail:(nullable NSString *)detail
                     userName:(nullable NSString *)userName
                     subTitle:(nullable NSString *)subTitle
                     cellType:(CellType)cellType
                 isLineHidden:(BOOL)isLineHidden;

+ (instancetype)setWithTitle:(nullable NSString *)title
                      detail:(nullable NSString *)detail
                    userName:(nullable NSString *)userName
                    subTitle:(nullable NSString *)subTitle
                    cellType:(CellType)cellType
                isLineHidden:(BOOL)isLineHidden;
@end

NS_ASSUME_NONNULL_END
