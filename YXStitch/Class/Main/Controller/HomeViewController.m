//
//  HomeViewController.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/8.
//

#import "HomeViewController.h"
#import "HomeSettingViewController.h"
#import "MoveCollectionViewCell.h"
#import "EnterURLViewController.h"
#import "SettingViewController.h"

@interface HomeViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,MoveCollectionViewCellDelegate>

@property (nonatomic ,strong)UIView *iconView;
@property (nonatomic ,strong) UICollectionView *MJColloctionView;
@property (nonatomic ,strong)NSMutableArray *iconArr;
//iOS9 及之后弃用以下属性
@property (nonatomic ,strong) UIView * shotView;
@property (nonatomic ,strong) NSIndexPath * indexPath;
@property (nonatomic ,strong) NSIndexPath * nextIndexPath;
@property (nonatomic ,weak) MoveCollectionViewCell * originalCell;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"首页";
    _iconArr = [NSMutableArray arrayWithObjects:@"截长屏",@"网页滚动截图",@"拼图",@"水印",@"设置",@"更多功能",nil];
    [self setupViews];
    [self setupLayout];
    [self setupNavItems];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noty:) name:@"homeChange" object:nil];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];   
}

- (void)noty:(NSNotification *)noty {
    NSDictionary *dict = noty.userInfo;
    _iconArr = dict[@"iconArr"];
    [_MJColloctionView reloadData];
}

#pragma mark - UI
-(void)setupViews{
//    _iconView = [[UIView alloc]init];
//    _iconView.backgroundColor = HexColor(BKGrayColor);
//    [self.view addSubview:_iconView];
//    [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.left.equalTo(self.view);
//        make.height.equalTo(@(SCREEN_HEIGHT - Nav_H));
//        make.top.equalTo(@(Nav_H));
//    }];
    
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat sizeWidth = (CGFloat) 168 / 375  * SCREEN_WIDTH;
    CGFloat sizeHeight = (CGFloat) 160 / 667  * SCREEN_HEIGHT;
    layout.itemSize = CGSizeMake(sizeWidth, sizeHeight);
    _MJColloctionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, Nav_H,SCREEN_WIDTH,SCREEN_HEIGHT - Nav_H) collectionViewLayout:layout];
    [_MJColloctionView registerClass:[MoveCollectionViewCell class] forCellWithReuseIdentifier:@"MoveCollectionViewCell"];
    _MJColloctionView.dataSource = self;
    _MJColloctionView.delegate = self;
    _MJColloctionView.backgroundColor = HexColor(BKGrayColor);
    [self.view addSubview:_MJColloctionView];
    

    
}
-(void)setupLayout{
    
}

-(void)setupNavItems{
    UIButton *letfBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [letfBtn setBackgroundImage:[UIImage imageNamed:@"水滴"] forState:UIControlStateNormal];
    [letfBtn addTarget:self action:@selector(letfBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:letfBtn];
    self.navigationItem.leftBarButtonItem = item;
}
        
#pragma mark -- CollectionDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _iconArr.count;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(20, 10, 10, 10);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MoveCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MoveCollectionViewCell" forIndexPath:indexPath];
    
    cell.p_MoveCollectionViewCellDelegate = self;
    cell.cellName = [_iconArr objectAtIndex:indexPath.row];
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //得到的cell
    MoveCollectionViewCell * cell = (MoveCollectionViewCell *)[self collectionView:collectionView cellForItemAtIndexPath:indexPath];
    NSString *cellName = cell.cellName;
    //跳转
    UIViewController *vc;
    if ([cellName isEqualToString:@"截长屏"]){
        
    }else if ([cellName isEqualToString:@"网页滚动截图"]){
        vc = [EnterURLViewController new];
    }else if ([cellName isEqualToString:@"拼图"]){
        
    }else if ([cellName isEqualToString:@"水印"]){
        
    }else if ([cellName isEqualToString:@"设置"]){
        vc = [SettingViewController new];
    }else{
        //更多功能
        vc = [HomeSettingViewController new];
    }
    [self.navigationController pushViewController:vc animated:YES];
}


-(void)GesturePressDelegate:(UIGestureRecognizer *)gestureRecognizer
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >9) {
        switch (gestureRecognizer.state) {
            case UIGestureRecognizerStateBegan:{
                //判断手势落点位置是否在路径上
                NSIndexPath *indexPath = [_MJColloctionView indexPathForItemAtPoint:[gestureRecognizer locationInView:self.MJColloctionView]];
                if (indexPath == nil) {
                    break;
                }
                //在路径上则开始移动该路径上的cell
                [_MJColloctionView beginInteractiveMovementForItemAtIndexPath:indexPath];
            }
                break;
            case UIGestureRecognizerStateChanged:
                //移动过程当中随时更新cell位置
                [_MJColloctionView updateInteractiveMovementTargetPosition:[gestureRecognizer locationInView:self.MJColloctionView]];
                break;
            case UIGestureRecognizerStateEnded:
                //移动结束后关闭cell移动
                [_MJColloctionView endInteractiveMovement];
                break;
            default:
                [_MJColloctionView cancelInteractiveMovement];
                break;
        }

    }else
    {
        MoveCollectionViewCell* cell = (MoveCollectionViewCell*)gestureRecognizer.view;
        static CGPoint startPoint;
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            _shotView = [cell snapshotViewAfterScreenUpdates:NO];
            _shotView.center = cell.center;
            
            NSLog(@"%@",cell.description);
            NSLog(@"%@",_shotView.description);
            [_MJColloctionView addSubview:_shotView];
            _indexPath = [_MJColloctionView indexPathForCell:cell];
            _originalCell = cell;
            _originalCell.hidden = YES;
            startPoint = [gestureRecognizer locationInView:_MJColloctionView];
        }else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
        {
            //获取移动量
            CGFloat tranX = [gestureRecognizer locationOfTouch:0 inView:_MJColloctionView].x - startPoint.x;
            CGFloat tranY = [gestureRecognizer locationOfTouch:0 inView:_MJColloctionView].y - startPoint.y;
            
            //进行移动
            _shotView.center = CGPointApplyAffineTransform(_shotView.center, CGAffineTransformMakeTranslation(tranX, tranY));
            //更新初始位置
            startPoint = [gestureRecognizer locationOfTouch:0 inView:_MJColloctionView];
            for (UICollectionViewCell *cellVisible in [_MJColloctionView visibleCells])
            {
                //移动的截图与目标cell的center直线距离
                CGFloat space = sqrtf(pow(_shotView.center.x - cellVisible.center.x, 2) + powf(_shotView.center.y - cellVisible.center.y, 2));
                //判断是否替换位置，通过直接距离与重合程度
                if (space <= _shotView.frame.size.width/2&&(fabs(_shotView.center.y-cellVisible.center.y) <= _shotView.bounds.size.height/2)) {
                    _nextIndexPath = [_MJColloctionView indexPathForCell:cellVisible];
                    if (_nextIndexPath.item > _indexPath.item)
                    {
                        for(NSInteger i = _indexPath.item; i <_nextIndexPath.item;i++)
                        {
                            //移动数据源位置
                            [_iconArr exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                        }
                    }else
                    {
                        for(NSInteger i = _indexPath.item; i <_nextIndexPath.item;i--)
                        {
                            //移动数据源位置
                            [_iconArr exchangeObjectAtIndex:i withObjectAtIndex:i-1];
                        }
                    }
                    //移动视图cell位置
                    [_MJColloctionView moveItemAtIndexPath:_indexPath toIndexPath:_nextIndexPath];
                    //更新移动视图的数据
                    _indexPath = _nextIndexPath;
                    break;
                }
            }
        }else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
        {
            [_shotView removeFromSuperview];
            [_originalCell setHidden:NO];
        }

    }
}

-(BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath {
    id objc = [_iconArr objectAtIndex:sourceIndexPath.item];
    [_iconArr removeObject:objc];
    [_iconArr insertObject:objc atIndex:destinationIndexPath.item];
}


#pragma mark -- btn触发事件
-(void)letfBtnClick:(UIButton *)btn{
    //滚动截图指引
}


@end
