//
//  DRShopListViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/10/9.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShopListViewController.h"
#import "DRHomePageShopCollectionViewCell.h"

NSString * const ShopListCellId = @"ShopListCellId";

@interface DRShopListViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) MJRefreshGifHeader *headerView;
@property (nonatomic,strong) NSMutableArray *shopDataArray;
@property (nonatomic,weak) UIButton * backTopBtn;

@end

@implementation DRShopListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!DRStringIsEmpty(self.likeName)) {
        self.title = @"店铺搜索";
    }else//type 1 推荐店铺
    {
        self.title = @"发现好店";
    }
    [self setupChilds];
    [self getShopData];
}

- (void)getShopData
{
    NSDictionary *bodyDic_ = @{
                              @"pageIndex":@(1),
                              @"pageSize":@1000,
                              };
    NSMutableDictionary * bodyDic = [NSMutableDictionary dictionaryWithDictionary:bodyDic_];
    if (!DRStringIsEmpty(self.likeName)) {
        [bodyDic setObject:self.likeName forKey:@"likeName"];
    }else//type 1 推荐店铺
    {
        [bodyDic setObject:@(1) forKey:@"type"];
    }
    NSDictionary *headDic = @{
                              @"cmd":@"U26",
                              };
    
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            if ([self.headerView isRefreshing]) {
                [self.shopDataArray removeAllObjects];
            }
            NSArray * shopDataArray = [DRShopModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            //转化description
            for (DRShopModel * shopModel in shopDataArray) {
                NSInteger index = [shopDataArray indexOfObject:shopModel];
                [self getGoodDataWithShopId:shopModel.id index:index];
            }
            [self.shopDataArray addObjectsFromArray:shopDataArray];
            
            [self.collectionView reloadData];
        }else
        {
            ShowErrorView
      }
        //结束刷新
        [self.headerView endRefreshing];
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        //结束刷新
        [self.headerView endRefreshing];
    }];
}

- (void)getGoodDataWithShopId:(NSString *)shopId  index:(NSInteger)index
{
    if (!shopId) {
        return;
    }
    NSDictionary *bodyDic = @{
                              @"pageIndex":@(1),
                              @"pageSize":@(3),
                              @"storeId":shopId,
                              };
    
    NSDictionary *headDic = @{
                              @"cmd":@"B07",
                              };
    
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            DRShopModel * shopModel = self.shopDataArray[index];
            shopModel.recommendGoods = [DRGoodModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            [UIView performWithoutAnimation:^{
                NSIndexPath * indexPath = [NSIndexPath indexPathForItem:index inSection:0];
                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
#pragma mark - 布局视图
- (void)setupChilds
{
    //layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    //collectionView
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH) collectionViewLayout:layout];
    self.collectionView = collectionView;
    collectionView.backgroundColor = DRBackgroundColor;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    //注册
    [collectionView registerClass:[DRHomePageShopCollectionViewCell class] forCellWithReuseIdentifier:ShopListCellId];
    [self.view addSubview:collectionView];
    
    //初始化头部刷新控件
    MJRefreshGifHeader *headerRefreshView = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshViewBeginRefreshing)];
    self.headerView = headerRefreshView;
    [DRTool setRefreshHeaderData:headerRefreshView];
    collectionView.mj_header = headerRefreshView;
    
    //回到顶部按钮
    UIButton * backTopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backTopBtn = backTopBtn;
    CGFloat backTopBtnW = 40;
    CGFloat backTopBtnH = 40;
    CGFloat backTopBtnX = screenWidth - backTopBtnW - 20;
    CGFloat backTopBtnY = screenHeight - statusBarH - navBarH - backTopBtnH - 20;
    backTopBtn.frame = CGRectMake(backTopBtnX, backTopBtnY, backTopBtnW, backTopBtnH);
    [backTopBtn setBackgroundImage:[UIImage imageNamed:@"go_top"] forState:UIControlStateNormal];
    [backTopBtn addTarget:self action:@selector(backTopBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    backTopBtn.hidden = YES;
    [self.view addSubview:backTopBtn];
}
- (void)backTopBtnDidClick
{
    [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x, 0) animated:YES];
}
- (void)headerRefreshViewBeginRefreshing
{
    [self getShopData];
}
#pragma mark - UICollectionViewDelegateFlowLayout
//配置item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat padding = 5;
    CGFloat smallImageViewWH = (screenWidth -  4 * padding) / 3;
    return CGSizeMake(screenWidth, 53 + padding * 2 + smallImageViewWH * 2);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.shopDataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DRHomePageShopCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ShopListCellId forIndexPath:indexPath];
    cell.model = self.shopDataArray[indexPath.row];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.backTopBtn.hidden = YES;
    if (indexPath.row > 10) {
        self.backTopBtn.hidden = NO;
    }
}
#pragma mark - 初始化
- (NSMutableArray *)shopDataArray
{
    if (!_shopDataArray) {
        _shopDataArray = [NSMutableArray array];
    }
    return _shopDataArray;
}
@end
