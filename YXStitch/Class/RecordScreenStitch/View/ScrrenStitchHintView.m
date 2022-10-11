//
//  ScrrenStitchHintView.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/15.
//

#import "ScrrenStitchHintView.h"

typedef void(^SZImageMergeBlock)(SZImageGenerator *generator,NSError *error);


@interface ScrrenStitchHintView ()
@property (nonatomic, strong)dispatch_queue_t queue;
@property (nonatomic, strong)SZImageGenerator *generator;
@property (nonatomic, assign)NSInteger count ;

@property (nonatomic, assign) BOOL scrollEnable;
@end
@implementation ScrrenStitchHintView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 12;
        self.layer.maskedCorners = YES;
        _count = 1;
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if (_count == 1){
        [self setupViews];
        [self setupLayout];
        _count ++;
    }
   
}

-(void)setupViews{
    //
    MJWeakSelf
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelBtn addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@40);
        make.top.equalTo(@20);
        make.left.equalTo(@5);
    }];
    
    UIImageView *cancelIMG = [UIImageView new];
    cancelIMG.image = IMG(@"取消");
    [cancelBtn addSubview:cancelIMG];
    [cancelIMG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@15);
        make.centerX.top.equalTo(cancelBtn);
    }];
    
    if (_type == 1){
        UIImageView *icon = [UIImageView new];
        icon.image = [UIImage imageNamed:@"无长图提示"];
        [self addSubview:icon];
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.width.equalTo(@117);
            make.height.equalTo(@110);
            make.top.equalTo(@91);
        }];
        
        UILabel *titleLab = [UILabel new];
        titleLab.text = @"最近没有长截图生成 ";
        titleLab.textColor = [UIColor blackColor];
        titleLab.font = Font16;
        titleLab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLab];
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(icon.mas_bottom).offset(38);
        }];
        
        
        UILabel *tipLab = [UILabel new];
        tipLab.text = @"当你连续截屏，App会自动识别、\n 拼接图片，生成长截图放在这里。";
        tipLab.numberOfLines = 0;
        tipLab.textColor = HexColor(@"#666666");
        tipLab.font = Font14;
        tipLab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:tipLab];
        [tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(titleLab.mas_bottom).offset(15);
        }];
    }else{
        UIImageView *markIMG = [UIImageView new];
        markIMG.image = IMG(@"惊叹号");
        [self addSubview:markIMG];
        [markIMG mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@27);
            make.centerX.equalTo(self);
            make.centerY.equalTo(cancelBtn);
        }];
        
        _queue = dispatch_queue_create("com.chenshaozhe.image.queue", 0);
        [self mergeImages:_arr
               completion:^(SZImageGenerator *generator, NSError *error) {
            generator.error = error;
            if ([self.delegate respondsToSelector:@selector(showResult:)]) {
                [self.delegate showResult:generator];
            }

        }];
    }
 
    _bottomView = [UIView new];
    _bottomView.backgroundColor = HexColor(@"#EEEEEE");
    
    [self addSubview:_bottomView];
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.bottom.equalTo(self);
        if ([Tools isIPhoneNotchScreen]) {
            make.height.equalTo(@60);
        }else{
            make.height.equalTo(@48);
        }  
    }];
    
    NSArray *textArr = @[@"裁切",@"拼接",@"字幕"];
    NSArray *iconArr = @[@"截长屏icon",@"拼接icon",@"字幕icon"];
    
    for (NSInteger i = 0; i < iconArr.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.tag = i;
        [btn addTarget:self action:@selector(functionClick:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@60);
            make.height.top.equalTo(_bottomView);
            make.left.equalTo(@(30 + i * 90));
        }];
        
        UIImageView *funcIcon = [UIImageView new];
        funcIcon.image = IMG(iconArr[i]);
        [btn addSubview:funcIcon];
        [funcIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@22);
            make.centerX.equalTo(btn);
            make.top.equalTo(@4);
        }];
        
        UILabel *iconLab = [UILabel new];
        iconLab.text = textArr[i];
        iconLab.textAlignment = NSTextAlignmentCenter;
        iconLab.font = Font13;
        iconLab.textColor = [UIColor blackColor];
        [_bottomView addSubview:iconLab];
        [iconLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(funcIcon.mas_bottom).offset(4);
            make.centerX.equalTo(btn);
        }];
    }
    
    UIButton *exportBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    exportBtn.layer.cornerRadius = 10;
    exportBtn.layer.masksToBounds = YES;
    [exportBtn addTarget:self action:@selector(exportClick) forControlEvents:UIControlEventTouchUpInside];
    [exportBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [exportBtn setTitle:@"导出" forState:UIControlStateNormal];
    [exportBtn setBackgroundColor:HexColor(@"#0C59F5")];
    [self addSubview:exportBtn];
    [exportBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_bottomView);
        make.width.equalTo(@75);
        make.height.equalTo(@30);
        make.right.equalTo(_bottomView.mas_right).offset(-15);
    }];
    if (_type == 1) {
        //无长图禁止交互
        _bottomView.userInteractionEnabled = NO;
        exportBtn.userInteractionEnabled = NO;
    }
}

-(void)cancelClick{
    [self.delegate stitchBtnClickWithTag:4];
}

-(void)exportClick{
    [self.delegate stitchBtnClickWithTag:5];
}

-(void)functionClick:(UIButton *)btn{
    [self.delegate stitchBtnClickWithTag:btn.tag];
//    if (btn.tag == 0) {
//        //长屏
//    }else if (btn.tag == 1){
//        //拼接
//    }else{
//        //字幕
//    }
}

-(void)setupLayout{
    
}

#pragma mark - 合并图片
- (void)mergeImages:(NSArray *)assets
         completion:(SZImageMergeBlock)completion{
    MJWeakSelf
        dispatch_async(_queue, ^{
            CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
            SZImageGenerator *generator = [self imageGeneratorBy:assets];
            if (!generator) {
                return ;
            }
            NSError *error = [generator error];
            CFAbsoluteTime nextTime = CFAbsoluteTimeGetCurrent() - time;
            NSLog(@"合并时间%@",@(nextTime));
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (completion) {
                    generator.stiching = NO;
                    completion(generator,error);
                    weakSelf.generator = generator;
                    
                }
            });
        });
}

/*
 * @description assets数组生成获取图片，并开始合并
 */
- (SZImageGenerator *)imageGeneratorBy:(NSArray *)assets{
    NSMutableArray *images = [NSMutableArray array];
    for (PHAsset *asset in assets) {
      [Tools getImageWithAsset:asset withBlock:^(UIImage * _Nonnull image) {
          [images addObject:image];
      }];
    }
    if (!images.count) {
        return nil;
    }
    /*
     这里是合成代码，合成图片
     SZImageGenerator 包含合成信息，数据
     */
    SZImageGenerator *generator = [[SZImageGenerator alloc] init];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;
    CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
    for (UIImage *image in images){
        [generator feedImage:image];
    }
    
    CFAbsoluteTime next = CFAbsoluteTimeGetCurrent() - time;
    NSLog(@"总共消耗的时间：%@",@(next));
    return generator;
}
@end
