//
//  DRGoodSearchView.m
//  dr
//
//  Created by 毛文豪 on 2017/5/25.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRGoodSearchView.h"
#import "DRGoodDetailViewController.h"
#import "DRRecommendGoodCollectionViewCell.h"

@interface DRGoodSearchView ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) int pageIndex;//页数
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) MJRefreshGifHeader *headerView;
@property (nonatomic, weak) MJRefreshBackGifFooter *footerView;
@property (nonatomic,copy) NSString *keyWord;

@end

NSString * const goodSearchCollectionCellId = @"goodSearchCollectionCellId";

@implementation DRGoodSearchView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.pageIndex = 1;
        [self setupChildViews];
    }
    return self;
}
- (void)searchGoodWithKeyword:(NSString *)keyWord
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
                              @"cmd":@"B07",
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            NSArray * newDataArray = [DRGoodModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            for (DRGoodModel * goodModel in newDataArray) {
                NSInteger index = [newDataArray indexOfObject:goodModel];
                goodModel.specifications = [DRGoodSpecificationModel mj_objectArrayWithKeyValuesArray:json[@"list"][index][@"specifications"]];
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
- (void)setupChildViews
{
    //商品列表
    //layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.minimumInteritemSpacing = 5;//列间距
    layout.minimumLineSpacing = 5;//行间距
    
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH) collectionViewLayout:layout];
    self.collectionView = collectionView;
    collectionView.backgroundColor = DRBackgroundColor;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.showsHorizontalScrollIndicator = NO;
    //注册
    [collectionView registerClass:[DRRecommendGoodCollectionViewCell class] forCellWithReuseIdentifier:goodSearchCollectionCellId];
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
    [self searchGoodWithKeyword:self.keyWord];
}
- (void)footerRefreshViewBeginRefreshing
{
    self.pageIndex++;
    [self searchGoodWithKeyword:self.keyWord];
}
#pragma mark - UICollectionViewDelegateFlowLayout
//配置item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = (screenWidth - 5) / 2;
    return CGSizeMake(width, width + 75);
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
    DRRecommendGoodCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:goodSearchCollectionCellId forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DRGoodModel * model = self.dataArray[indexPath.row];
    if (_delegate && [_delegate respondsToSelector:@selector(goodSearchView:goodDidClickWithGoodModel:)]) {
        [_delegate goodSearchView:self goodDidClickWithGoodModel:model];
    }
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
