//
//  GridView.m
//  YXStitch
//
//  Created by mac_m11 on 2022/9/24.
//

#import "GridSelectedView.h"
#import "GridCell.h"
#import "UnlockFuncView.h"
#import "CheckProView.h"
#import "BuyViewController.h"
#define kMinimumLineSpacing  20
#define kMinimumInteritemSpacing  20
#define kCollectionViewItemWidth  (self.height - 30)
@interface GridSelectedView ()<UICollectionViewDataSource, UICollectionViewDelegate, UnlockFuncViewDelegate, CheckProViewDelegate>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSIndexPath *selectedIndexPath;
@property(nonatomic ,strong) UnlockFuncView *funcView;
@property(nonatomic ,strong) CheckProView *checkProView;
@property (nonatomic ,strong)UIView *bgView;

@end

@implementation GridSelectedView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame: frame]){
        [self initlalizeSubviews];
    }
    return self;
}

- (void)initlalizeSubviews {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 16;
//    layout.itemSize = CGSizeMake(self.height, self.height);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
//    self.collectionView.contentInset = UIEdgeInsetsMake(0, 15, 0, 20);
    
    [self addSubview:self.collectionView];

    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 15;
    self.layer.borderColor = RGB(135, 135, 135).CGColor;
    self.layer.borderWidth = 0.5;
}

- (void)setGrids:(NSArray *)grids
{
    _grids = grids;
    [self.collectionView reloadData];
    //设置默认选中第一个
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
}

- (UIViewController *)viewController {
    // 遍历响应者链。返回第一个找到视图控制器
    UIResponder *responder = self;
    while ((responder = [responder nextResponder])){
        if ([responder isKindOfClass: [UIViewController class]]){
            return (UIViewController *)responder;
        }
    }
    // 如果没有找到则返回nil
    return nil;
}

-(void)btnClickWithTag:(NSInteger)tag{
    if (tag == 1) {
        [_funcView removeFromSuperview];
        UIViewController *vc = [self viewController];
        [vc.navigationController pushViewController:[BuyViewController new] animated:YES];
    }else{
        MJWeakSelf
        if (_bgView == nil){
            _bgView = [Tools addBGViewWithFrame:[UIApplication sharedApplication].keyWindow.frame];
            [[UIApplication sharedApplication].keyWindow addSubview:_bgView];
        }else{
            _bgView.hidden = NO;
        }
        if (_checkProView == nil){
            _checkProView = [[CheckProView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 550)];
            _checkProView.delegate = self;
            [[UIApplication sharedApplication].keyWindow addSubview:_checkProView];
        }
        _checkProView.hidden = NO;
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:_checkProView];
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.checkProView.frame = CGRectMake(0, SCREEN_HEIGHT - weakSelf.checkProView.height, SCREEN_WIDTH , weakSelf.checkProView.height);
        }];
    }
}

-(void)cancelClickWithTag:(NSInteger)tag{
    MJWeakSelf
    if (tag == 1){
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.checkProView.frame = CGRectMake(0, SCREEN_HEIGHT + 100, SCREEN_WIDTH , weakSelf.checkProView.height);
            weakSelf.bgView.hidden = YES;
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.checkProView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 550);
        } completion:^(BOOL finished) {
            weakSelf.bgView.hidden = YES;
            weakSelf.checkProView.hidden = YES;
        }];
        [_funcView removeFromSuperview];
        UIViewController *vc = [self viewController];
        [vc.navigationController pushViewController:[BuyViewController new] animated:YES];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.grids.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = [NSString stringWithFormat:@"Cell%ld%ld", (long)indexPath.section, (long)indexPath.item];
    [self.collectionView registerClass:[GridCell class] forCellWithReuseIdentifier:reuseIdentifier];
    GridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSDictionary *dict = self.grids[indexPath.item];
    NSString *imageNormal = dict[@"image-normal"];
    NSString *imageSelected = dict[@"image-selected"];
    
    cell.imgNormal = imageNormal;
    cell.imageSelected = imageSelected;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.item > 0) {
        
        if(![User checkIsVipMember]) {
            //设置默认选中第一个
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
            
            
            //非会员弹出提示
            _funcView = [[UnlockFuncView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            _funcView.delegate = self;
            _funcView.type = 5;
            [[UIApplication sharedApplication].keyWindow addSubview:_funcView];
            

            return;
        }
    }
    if(self.selectedIndexPath!= nil && [indexPath isEqual:self.selectedIndexPath]) {
        return;
    }
    self.selectedIndexPath = indexPath;
    
    if(_gridSelectedItemBlock)
    {
        _gridSelectedItemBlock(indexPath.item);
    }
}

//对于水平滚动网格，此值表示连续列之间的最小间距。(行间距)
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    if(self.grids.count < 3)
    {
        return (self.width - kCollectionViewItemWidth * self.grids.count) / (self.grids.count + 1);
    }
    else
    {
        return kMinimumLineSpacing;
    }
}

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kCollectionViewItemWidth, kCollectionViewItemWidth);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if(self.grids.count < 3)
    {
        //设置collectionView
        return UIEdgeInsetsMake(kMinimumLineSpacing / 2, (self.width - kCollectionViewItemWidth * self.grids.count) / (self.grids.count + 1), kMinimumLineSpacing / 2, kMinimumInteritemSpacing / 2);
    }
    else
    {
        //设置collectionView
        return UIEdgeInsetsMake(kMinimumLineSpacing / 2, kMinimumInteritemSpacing / 2 + 15, kMinimumLineSpacing / 2, kMinimumInteritemSpacing / 2);
    }
}

@end
