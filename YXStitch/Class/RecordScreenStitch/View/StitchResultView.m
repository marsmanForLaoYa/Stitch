//
//  StitchResultView.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/15.
//

#import "StitchResultView.h"
#import "UIImage+Logo.h"
#import "SZStichingImageView.h"
#import "SZEditorView.h"


#define MIN_HEIGHT 50
#define EDITOR_BAR_HEIGHT 0

@interface StitchResultView ()

@property (nonatomic,strong)  UIImage *image;
@property (nonatomic,assign)  CGFloat totoalHeight;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSMutableArray *editViews;
@property (nonatomic, assign) BOOL isLoadView;
@property (nonatomic, assign) BOOL scrollEnable;
@end

@implementation StitchResultView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
//        _generator = generator;
        _isLoadView = NO;
        
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image{
    if (self = [super init])
{
        _image = image;
        _imageView = [[UIImageView alloc] initWithImage:image];
        _imageView.frame = CGRectMake(0, 0, self.width, image.size.height * (self.width/image.size.width));
        
    }
    return self;
}

- (instancetype)initWithGenerator:(SZImageGenerator *)generator{
    if (self = [super init]) {
        _generator = generator;
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if (!_isLoadView){
        [self setupViews];
        _isLoadView = !_isLoadView;
    }  
}


-(void)setupViews{
    CAGradientLayer *layer = [CAGradientLayer setGradualChangingColor:self colors:@[RGB(33, 46, 66),RGB_A(59, 75, 110, 0.8)]];
    [self.layer addSublayer:layer];

    _scrollView = [[SZScrollView alloc] initWithFrame:self.bounds];
    [_scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    _scrollView.contentSize = self.bounds.size;
    _scrollView.userInteractionEnabled = YES;
    [self addSubview:_scrollView];
    if (_imageView) {
        [self.scrollView addSubview:_imageView];
        self.scrollView.contentSize = _imageView.size;
        return;
    }
    [self configImageViews];
}

- (void)configImageViews{
    if (!_generator.infos.count) {
        return;
    }
    [self.editViews removeAllObjects];
    self.scrollEnable = YES;
    __block NSInteger editTouchIndex = 0;
    @WeakObj(self);
    for (NSInteger i = 0; i <= _generator.infos.count + 1; i ++) {
        SZEditorView *editorView = [SZEditorView new];
        editorView.editorIcon.hidden = YES;
        editorView.touchBegan = ^(SZEditorView *editorView) {
            @StrongObj(self);
            self.scrollEnable = !editorView.editorIcon.isSelected;
            self.scrollView.scrollEnabled = self.scrollEnable;
            for (SZEditorView *editor in self.editViews) {
                editor.editing = NO;
            }
            editorView.editing = YES;
            editTouchIndex = i;
        };
        [self.editViews addObject:editorView];
    }
    
   // [self.guideViews addObject:self.editViews[1]];
    //????????????????????????
    self.scrollView.editors = self.editViews;
    @weakify(self);
    SZImageMergeInfo *firstInfo = _generator.infos.firstObject;
    CGFloat firstImagescale = self.width / firstInfo.firstImage.size.width;
    SZStichingImageView *lastImageView = [[SZStichingImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, firstInfo.firstImage.size.height * firstImagescale)];
    lastImageView.image = firstInfo.firstImage;
    lastImageView.touchMove = ^(SZStichingImageView *stichingImageView, CGFloat offsetY) {
        @strongify(self)
        //?????????????????????????????????????????????????????????????????????????????????????????????????????????
        if (editTouchIndex == 0) {
           [self firstImageScrollUp:stichingImageView offsetY:offsetY];
        }else if(editTouchIndex == 1) {
            [self topImageScrollDown:stichingImageView offsetY:offsetY];
        }
    };
    
    lastImageView.touchEnd = ^(SZStichingImageView *stichingImageView) {
        @strongify(self);
        if (editTouchIndex == 0) {
            [UIView animateWithDuration:0.5 animations:^{
                @strongify(self);
                stichingImageView.height = stichingImageView.height - stichingImageView.imageView.top;
                stichingImageView.imageView.top = 0;
                [self bottomFollow:stichingImageView  isFirstImage:YES];
                [self updateEditorBarPosition];
                [self updateScrollViewContentSize];
                SZEditorView *lastEditorView = [self.editViews lastObject];
                lastEditorView.bottom = self.scrollView.contentSize.height;
            }];
        }else if(editTouchIndex == 1) {
            [UIView animateWithDuration:0.5 animations:^{
                @strongify(self);
                stichingImageView.imageView.top = 0;
                stichingImageView.top = 0;
                [self bottomFollow:stichingImageView isFirstImage:YES];
                [self updateEditorBarPosition];
                [self updateScrollViewContentSize];
                SZEditorView *lastEditorView = [self.editViews lastObject];
                lastEditorView.bottom = self.scrollView.contentSize.height;
            }];
        }
    };
    
    //??????????????????
    SZEditorView *firstEditorView = self.editViews.firstObject;
    firstEditorView.firstImageView = nil;
    firstEditorView.lastImageView = lastImageView;
    firstEditorView.top = lastImageView.top ;
    firstEditorView.left = 0;
    firstEditorView.width = lastImageView.width;
    firstEditorView.height = EDITOR_BAR_HEIGHT;
    [self.scrollView addSubview:lastImageView];
    [self.scrollView addSubview:firstEditorView];
    [self.imageViews addObject:lastImageView];
    
    NSInteger index = 0;
    for (SZImageMergeInfo *info in _generator.infos) {
        CGFloat scale = self.width / info.secondImage.size.width;
        CGFloat secondImageH = info.secondImage.size.height * scale;
        SZStichingImageView *imageView = [[SZStichingImageView alloc] initWithFrame:CGRectMake(0, lastImageView.bottom, self.width, secondImageH)];
        imageView.image = info.secondImage;
         [self.scrollView addSubview:imageView];
        if (!info.error) {
            lastImageView.height = lastImageView.height - (info.firstOffset) * scale;
            imageView.top = lastImageView.bottom;
            imageView.height = (info.secondOffset) * scale;
            imageView.imageView.top = - secondImageH + (info.secondOffset) * scale;
        }
        SZEditorView *ediView = self.editViews[index + 1];
        ediView.firstImageView = [self.imageViews lastObject];
        ediView.lastImageView = imageView;
        ediView.left = 0;
        ediView.width = imageView.width;
        ediView.height = EDITOR_BAR_HEIGHT;
        ediView.bottom = lastImageView.bottom;
        [self.scrollView addSubview:ediView];
        lastImageView = imageView;
        [self.imageViews addObject:imageView];
        @weakify(self);
        imageView.touchEnd = ^(SZStichingImageView *stichingImageView) {
            @strongify(self);
            BOOL isLastIndex = editTouchIndex == self.editViews.count - 1;
            SZEditorView *editorView = self.editViews[editTouchIndex];
            editorView.hidden = NO;
            //?????????????????????????????????self.scrollView.contentSize????????????????????????
            if (isLastIndex) {
//                [UIView animateWithDuration:0.5 animations:^{
                    [self updateScrollViewContentSize];
                    //?????????????????????????????????scrollView??????contentSize??????
                    SZEditorView *lastEditorView = [self.editViews lastObject];
                    lastEditorView.bottom = self.scrollView.contentSize.height;
//                }];
            } else {
                [self updateScrollViewContentSize];
                //?????????????????????????????????scrollView??????contentSize??????
                SZEditorView *lastEditorView = [self.editViews lastObject];
                lastEditorView.bottom = self.scrollView.contentSize.height;
                NSLog(@"?????????%@",@(self.scrollView.contentSize.height));
            }
        };
        
        imageView.touchMove = ^(SZStichingImageView *stichingImageView, CGFloat offsetY) {
            @strongify(self);
            NSInteger canMoveIndex = [self.imageViews indexOfObject:stichingImageView];
            BOOL isAbove = canMoveIndex >= editTouchIndex;
            BOOL isLastIndex = editTouchIndex == self.editViews.count - 1;
            SZEditorView *editorView = self.editViews[editTouchIndex];
            editorView.hidden = YES;
            //???????????????????????????editview
             SZEditorView *ediView_ = self.editViews[editTouchIndex];
            //????????????????????????????????????
            if (ediView_.firstImageView == stichingImageView && !isLastIndex) {
                [self topImageScrollDown:stichingImageView offsetY:offsetY];
                
                [self updateEditorBarPosition];
            }
            //???????????????????????????????????????
            else if (ediView_.lastImageView == stichingImageView  && !isLastIndex) {
                [self belowImageScrollUp:stichingImageView offsetY:offsetY];
                
                [self updateEditorBarPosition];
            }
            //?????????????????????????????????????????????
            else if (isAbove && !isLastIndex) {
                SZStichingImageView *aboveStichingImageView = ediView_.lastImageView;
                [self belowImageScrollUp:aboveStichingImageView offsetY:offsetY];
                
                [self updateEditorBarPosition];
            }
            //?????????????????????????????????????????????
            else if (!isAbove && !isLastIndex) {
                  SZStichingImageView *underStichingImageView = ediView_.firstImageView;
                 [self topImageScrollDown:underStichingImageView offsetY:offsetY];
                
                [self updateEditorBarPosition];
            }
            else if (isLastIndex) {
                [self belowImageScrollUp:stichingImageView offsetY:offsetY];
            }
 
        };
        index ++;
    }
    _totoalHeight = lastImageView.bottom;
    for (UIView *childView in self.scrollView.subviews.reverseObjectEnumerator) {
        [self.scrollView bringSubviewToFront:childView];
    }
    for (SZEditorView *editorView in self.editViews) {
        [self.scrollView bringSubviewToFront:editorView];
    }
    
    self.scrollView.contentSize = CGSizeMake(self.width, _totoalHeight);
    
    //?????????????????????
    SZEditorView *lastEditorView = self.editViews.lastObject;
    lastEditorView.firstImageView = nil;
    lastEditorView.lastImageView = lastImageView;
    lastEditorView.left = 0;
    lastEditorView.width = lastImageView.width;
    lastEditorView.height = EDITOR_BAR_HEIGHT;
    lastEditorView.bottom = self.scrollView.contentSize.height;
    [self.scrollView addSubview:lastEditorView];
}


/*
 * ??????????????????????????????
 */
- (void)topImageScrollDown:(SZStichingImageView *)stichingImageView offsetY:(CGFloat)offsetY {
    stichingImageView.height = stichingImageView.height - offsetY;
    if ((stichingImageView.height >= stichingImageView.imageView.bottom) ||
        (stichingImageView.height <= MIN_HEIGHT)) {
        stichingImageView.height = stichingImageView.imageView.bottom;
        return;
    }
    stichingImageView.top = stichingImageView.top + offsetY;
    
    //????????????
    [self topFollow:stichingImageView offsetY:offsetY isLastImage:NO];
}

/*
 * ??????????????????????????????
 */
- (void)belowImageScrollUp:(SZStichingImageView *)stichingImageView offsetY:(CGFloat)offsetY {
    stichingImageView.height = stichingImageView.height + offsetY;
    stichingImageView.imageView.top = stichingImageView.imageView.top  + offsetY;
    if (stichingImageView.imageView.top >= 0.0 || (stichingImageView.height <= MIN_HEIGHT)) {
        stichingImageView.height = stichingImageView.height - offsetY;
        stichingImageView.imageView.top = stichingImageView.imageView.top - offsetY;
        return;
    }
   
    //????????????
    [self bottomFollow:stichingImageView isFirstImage:NO];
}

/*
 * ?????????????????????
 */
- (void)firstImageScrollUp:(SZStichingImageView *)stichingImageView offsetY:(CGFloat)offsetY {
    stichingImageView.imageView.top = stichingImageView.imageView.top  + offsetY;
    if ((stichingImageView.height <= MIN_HEIGHT) ||
        stichingImageView.height >= stichingImageView.imageView.bottom) {
        stichingImageView.imageView.top = stichingImageView.imageView.top - offsetY;
        stichingImageView.top = 0;
        return;
    }
   
}

/*
 * ????????????
 * stichingImageView ????????????????????????
 * isFirstImage ??????????????????????????????????????????????????????????????????????????????
 */
- (void)bottomFollow:(SZStichingImageView *)stichingImageView isFirstImage:(BOOL) isFirstImage{
    SZStichingImageView *lastStichimageView = stichingImageView;
    NSInteger inlineIndex = [self.imageViews indexOfObject:stichingImageView];
    if ((inlineIndex + 1) < self.imageViews.count) {
        for (NSInteger i = inlineIndex + 1; i < self.imageViews.count; i ++) {
            SZStichingImageView *imageView = self.imageViews[i];
            if (i == (inlineIndex + 1) && !isFirstImage) {
                if (imageView.isEditing) {
                    break;
                }
            }
            imageView.top = lastStichimageView.bottom;
            lastStichimageView = imageView;
        }
    }
}

/*
 * ????????????
 * stichingImageView ????????????????????????
 */
- (void)topFollow:(SZStichingImageView *)stichingImageView offsetY:(CGFloat) offsetY isLastImage:(BOOL) isLastImage{
    SZStichingImageView *lastStichimageView = stichingImageView;
    NSInteger inlineIndex = [self.imageViews indexOfObject:stichingImageView];
    if ((inlineIndex - 1) >= 0) {
        for (NSInteger i =  inlineIndex - 1 ; i >= 0; i --) {
            SZStichingImageView *imageView = self.imageViews[i];
            if (i == (inlineIndex - 1) && !isLastImage) {
                if (imageView.isEditing) {
                    break;
                }
            }
            imageView.top = imageView.top + offsetY;
            lastStichimageView = imageView;
        }
    }
}

/*
 * ???????????????????????????
 */
- (void)updateEditorBarPosition {
    NSInteger i = 0;
    SZEditorView *firstEditorView = [self.editViews firstObject];
    firstEditorView.top = 0;
    
    for (SZStichingImageView *imageView in self.imageViews) {
        if (i + 1 >= self.imageViews.count) {
            break;
        }
        SZEditorView *editorView = self.editViews[i + 1];
        editorView.bottom = imageView.bottom;
        i ++;
    }
}

- (void)updateScrollViewContentSize {
    CGFloat totalHeight = 0;
    for (SZStichingImageView *imageView in self.imageViews) {
        totalHeight += imageView.height;
    }
    self.scrollView.contentSize = CGSizeMake(self.width, totalHeight);
}

- (NSMutableArray *)editViews {
    if (!_editViews) {
        _editViews = [NSMutableArray array];
    }
    return _editViews;
}
- (NSMutableArray *)imageViews {
    if (!_imageViews) {
        _imageViews = [NSMutableArray array];
    }
    return _imageViews;
}





@end
