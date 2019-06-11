//
//  DRHomePageAllShopCollectionViewCell.m
//  dr
//
//  Created by 毛文豪 on 2018/1/8.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRHomePageAllShopCollectionViewCell.h"
#import "DRHomePageShopCollectionViewCell.h"

NSString * const HomePageShopCellId = @"HomePageShopCellId";

@interface DRHomePageAllShopCollectionViewCell ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic,weak) UIPageControl *pageControl;
@property (nonatomic, strong) NSArray *shopDataArray;

@end

@implementation DRHomePageAllShopCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self getShopData];
        [self setupChildViews];
    }
    return self;
}

- (void)getShopData
{
    NSDictionary *bodyDic = @{
                              @"pageIndex":@1,
                              @"pageSize":@5,
                              @"type":@(1)//type 1 推荐店铺
                              };
    
    NSDictionary *headDic = @{
                              @"cmd":@"U26",
                              };
    
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@", json);
        if (SUCCESS) {
            self.shopDataArray = [DRShopModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            for (DRShopModel * shopModel in self.shopDataArray) {
                NSInteger index = [self.shopDataArray indexOfObject:shopModel];
                [self getGoodDataWithShopId:shopModel.id index:index];
            }
            self.pageControl.numberOfPages = self.shopDataArray.count;
            [self.collectionView reloadData];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
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

- (void)setupChildViews
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.minimumInteritemSpacing = 0.0;//列间距
    layout.minimumLineSpacing = 0.0;//行间距
    
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height - 25) collectionViewLayout:layout];
    self.collectionView = collectionView;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.pagingEnabled = YES;
    
    //注册
    [collectionView registerClass:[DRHomePageShopCollectionViewCell class] forCellWithReuseIdentifier:HomePageShopCellId];
    [self addSubview:collectionView];
    
    UIPageControl * pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.height - 25 - 5, self.width, 28)];
    self.pageControl = pageControl;
    pageControl.currentPage = 0;
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = DRDefaultColor;
    [self addSubview:pageControl];
}

//pagecontroll的委托方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page = scrollView.contentOffset.x / scrollView.frame.size.width;
    self.pageControl.currentPage = page;
}

#pragma mark - UICollectionViewDelegateFlowLayout
//配置item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.width, self.height - 25);
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
    DRHomePageShopCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:HomePageShopCellId forIndexPath:indexPath];
    cell.model = self.shopDataArray[indexPath.row];
    return cell;
}

#pragma mark - 初始化
- (NSArray *)shopDataArray
{
    if (!_shopDataArray) {
        _shopDataArray = [NSArray array];
    }
    return _shopDataArray;
}

@end
