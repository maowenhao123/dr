//
//  DRShopSearchView.m
//  dr
//
//  Created by 毛文豪 on 2017/5/25.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShopSearchView.h"
#import "DRHomePageShopCollectionViewCell.h"

NSString * const ShopSearchCellId = @"ShopSearchCellId";

@interface DRShopSearchView ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, assign) int pageIndex;//页数
@property (nonatomic, weak) MJRefreshGifHeader *headerView;
@property (nonatomic, weak) MJRefreshBackGifFooter *footerView;
@property (nonatomic,copy) NSString *keyWord;

@end

@implementation DRShopSearchView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.pageIndex = 1;
        [self setupChildViews];
    }
    return self;
}
- (void)searchShopWithKeyword:(NSString *)keyWord
{    
    self.keyWord = keyWord;
    NSDictionary *bodyDic_ = @{
                               @"pageIndex":@(self.pageIndex),
                               @"pageSize":DRPageSize,
                               };
    NSMutableDictionary * bodyDic = [NSMutableDictionary dictionaryWithDictionary:bodyDic_];
    if (!DRStringIsEmpty(keyWord)) {
        [bodyDic setObject:keyWord forKey:@"likeName"];
    }
    
    NSDictionary *headDic = @{
                              @"cmd":@"U26",
                              };
    
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            NSArray * newDataArray = [DRShopModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            for (DRShopModel * shopModel in newDataArray) {
                NSInteger index = [newDataArray indexOfObject:shopModel];
                [self getGoodDataWithShopId:shopModel.id index:index];
            }
            [self.dataArray addObjectsFromArray:newDataArray];
            [self.collectionView reloadData];
            if (newDataArray.count == 0) {
                [self.footerView endRefreshingWithNoMoreData];
            }else
            {
                [self.footerView endRefreshing];
            }
        }else
        {
            ShowErrorView
            [self.footerView endRefreshing];
        }
        //结束刷新
        [self.headerView endRefreshing];
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        //结束刷新
        [self.headerView endRefreshing];
        [self.footerView endRefreshing];
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
            DRShopModel * shopModel = self.dataArray[index];
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
- (void)setupChildViews
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
    [collectionView registerClass:[DRHomePageShopCollectionViewCell class] forCellWithReuseIdentifier:ShopSearchCellId];
    [self addSubview:collectionView];
    
    //初始化头部刷新控件
    MJRefreshGifHeader *headerView = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshViewBeginRefreshing)];
    self.headerView = headerView;
    [DRTool setRefreshHeaderData:headerView];
    collectionView.mj_header = headerView;
    
    //初始化底部刷新控件
    MJRefreshBackGifFooter *footerView = [MJRefreshBackGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshViewBeginRefreshing)];
    self.footerView = footerView;
    [DRTool setRefreshFooterData:footerView];
    collectionView.mj_footer = footerView;
}
- (void)headerRefreshViewBeginRefreshing
{
    self.pageIndex = 1;
    [self.dataArray removeAllObjects];
    [self searchShopWithKeyword:self.keyWord];
}
- (void)footerRefreshViewBeginRefreshing
{
    self.pageIndex++;
    [self searchShopWithKeyword:self.keyWord];
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
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DRHomePageShopCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ShopSearchCellId forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];
    return cell;
}
#pragma mark - 初始化
- (NSArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
