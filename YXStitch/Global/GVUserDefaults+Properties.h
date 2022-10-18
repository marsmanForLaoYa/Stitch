//
//  GVUserDefaults+Properties.h
//  SkyMeeting
//
//  Created by xiaobin Tang on 2020/4/16.
//  Copyright © 2020 xiaobin Tang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GVUserDefaults/GVUserDefaults.h>

NS_ASSUME_NONNULL_BEGIN

@interface GVUserDefaults (Properties)
#pragma mark--记录全局保存信息
@property (nonatomic ,assign)NSInteger logoType;//logo类型，1=2drakIcon，2=lightIcon
@property (nonatomic ,assign)NSInteger waterPosition;//水印位置 //1=无水印 2=左 3=居中 4=右 5=全屏  默认居中
@property (nonatomic ,strong)NSString *waterTitle;//水印文字
@property (nonatomic ,assign)NSInteger waterTitleFontSize;//水印文字大小
@property (nonatomic ,strong)NSString *waterTitleColor;//水印文字颜色
@property (nonatomic ,strong)NSDictionary *screenVideoDic;//录屏地址

@property (nonatomic ,assign)NSInteger deleteIMGType;//删除原图类型 1=所有图片 2=只删原图

@property (nonatomic ,assign)BOOL isMember;//是否是会员
@property (nonatomic ,assign)BOOL isAutoSaveIMGAlbum;//是否保存到拼图相册
@property (nonatomic ,assign)BOOL isAutoDeleteOriginIMG;//是否删除原图
@property (nonatomic ,assign)BOOL isAutoCheckRecentlyIMG;//是否检测最新长截图
@property (nonatomic ,assign)BOOL isAutoHiddenScrollStrip;//是否自动隐藏滚动条
@property (nonatomic ,assign)BOOL isHaveScreenData;//有录屏数据
@property (nonatomic ,assign)BOOL isScorllScreen;

@property (nonatomic ,strong)NSMutableArray *homeIconArr;//主页icon
@property (nonatomic ,strong)NSMutableArray *selectColorArr;//选中的6个颜色




@end

NS_ASSUME_NONNULL_END
