//
//  GridView.m
//  YXStitch
//
//  Created by mac_m11 on 2022/9/24.
//

#import "GridSelectedView.h"
#import "GridCell.h"

#define kMinimumLineSpacing  20
#define kMinimumInteritemSpacing  20
#define kCollectionViewItemWidth  (self.height - 30)
@interface GridSelectedView ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSIndexPath *selectedIndexPath;

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
