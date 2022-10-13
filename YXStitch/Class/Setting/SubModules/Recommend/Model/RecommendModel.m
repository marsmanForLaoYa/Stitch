//
//  SettingModel.m
//  XWNWS
//
//  Created by mac_m11 on 2022/9/8.
//

#import "RecommendModel.h"

@implementation RecommendModel

- (instancetype)initWithTitle:(nullable NSString *)title
                       detail:(nullable NSString *)detail
                     userName:(nullable NSString *)userName
                     subTitle:(nullable NSString *)subTitle
                     cellType:(CellType)cellType
                 isLineHidden:(BOOL)isLineHidden
{
    if (self = [super init]) {
        _title = title;
        _subTitle = subTitle;
        _detail = detail;
        _userName = userName;
        _cellType = cellType;
        _isLineHidden = isLineHidden;
    }
    return self;
}

+ (instancetype)setWithTitle:(nullable NSString *)title
                      detail:(nullable NSString *)detail
                    userName:(nullable NSString *)userName
                    subTitle:(nullable NSString *)subTitle
                    cellType:(CellType)cellType
                isLineHidden:(BOOL)isLineHidden
{
    RecommendModel *settingModel = [[RecommendModel alloc]init];
    settingModel.title = title;
    settingModel.subTitle = subTitle;
    settingModel.detail = detail;
    settingModel.userName = userName;
    settingModel.cellType = cellType;
    settingModel.isLineHidden = isLineHidden;
    return settingModel;
}

@end
