//
//  GridScaleView.m
//  YXStitch
//
//  Created by mac_m11 on 2022/10/8.
//

#import "GridScaleView.h"
#import "GridCell.h"

#define kMinimumLineSpacing  20
#define kMinimumInteritemSpacing  20
#define kCollectionViewItemWidth  (self.height - 25)
@interface GridScaleView ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic, strong) UICollectionView *collectionView;

@end
@implementation GridScaleView

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
    self.layer.cornerRadius = 5;
    self.layer.borderColor = RGB(135, 135, 135).CGColor;
    self.layer.borderWidth = 0.5;
}

- (void)setScales:(NSArray *)scales
{
    _scales = scales;
    [self.collectionView reloadData];
    //设置默认选中第一个
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.scales.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = [NSString stringWithFormat:@"Cell%ld%ld", (long)indexPath.section, (long)indexPath.item];
    [self.collectionView registerClass:[GridCell class] forCellWithReuseIdentifier:reuseIdentifier];
    GridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSDictionary *dict = self.scales[indexPath.item];
    NSString *imageNormal = dict[@"image-normal"];
    NSString *imageSelected = dict[@"image-selected"];
    
    cell.imgNormal = imageNormal;
    cell.imageSelected = imageSelected;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = self.scales[indexPath.item];
    NSInteger scaleWidth = [dict[@"scaleWidth"] integerValue];
    NSInteger scaleHeight = [dict[@"scaleHeight"] integerValue];
    if(_gridScaleItemSelectedBlock)
    {
        _gridScaleItemSelectedBlock(scaleWidth, scaleHeight);
    }
}

//对于水平滚动网格，此值表示连续列之间的最小间距。(行间距)
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return kMinimumLineSpacing;
}

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kCollectionViewItemWidth, kCollectionViewItemWidth);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //设置collectionView
    return UIEdgeInsetsMake(kMinimumLineSpacing / 2, kMinimumInteritemSpacing / 2 + 15, kMinimumLineSpacing / 2, kMinimumInteritemSpacing / 2);
}
@end
