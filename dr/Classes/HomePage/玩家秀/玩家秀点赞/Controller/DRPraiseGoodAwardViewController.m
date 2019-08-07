//
//  DRPraiseGoodAwardViewController.m
//  dr
//
//  Created by 毛文豪 on 2018/12/19.
//  Copyright © 2018 JG. All rights reserved.
//

#import "DRPraiseGoodAwardViewController.h"
#import "DRPraiseGoodAwardCollectionViewCell.h"
#import "UICollectionView+DRNoData.h"

NSString * const GoodAwardCollectionCellId = @"PraiseGoodAwardCollectionViewCellId";

@interface DRPraiseGoodAwardViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) MJRefreshGifHeader *headerView;

@end

@implementation DRPraiseGoodAwardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"领多肉";
    [self setupChilds];
    waitingView
    [self getData];
}

#pragma mark - 请求数据
- (void)getData
{
    NSDictionary *bodyDic = @{
                              @"type":self.type
                              };
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"G04",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        [self.headerView endRefreshing];
        if (SUCCESS) {
            NSArray *dataArr = [DRPraiseGoodAwardModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            [self.dataArray addObjectsFromArray:dataArr];
            [self.collectionView reloadData];//刷新数据
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        [MBProgressHUD hideHUDForView:self.view];
        [self.headerView endRefreshing];
    }];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    //商品列表
    //layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(5, 0, 0, 0);
    layout.minimumInteritemSpacing = 10;//列间距
    layout.minimumLineSpacing = 10;//行间距
    
    //collectionView
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, 0, screenWidth - 20, screenHeight - statusBarH - navBarH) collectionViewLayout:layout];
    self.collectionView = collectionView;
    collectionView.backgroundColor = DRBackgroundColor;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    //注册
    [collectionView registerClass:[DRPraiseGoodAwardCollectionViewCell class] forCellWithReuseIdentifier:GoodAwardCollectionCellId];
    [self.view addSubview:collectionView];
    
    //初始化头部刷新控件
    MJRefreshGifHeader *headerView = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshViewBeginRefreshing)];
    self.headerView = headerView;
    [DRTool setRefreshHeaderData:headerView];
    collectionView.mj_header = headerView;
}

#pragma mark - 刷新
- (void)headerRefreshViewBeginRefreshing
{
    [self.dataArray removeAllObjects];
    [self getData];
}

#pragma mark - UICollectionViewDelegateFlowLayout
//配置item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = (screenWidth - 30) / 2;
    return CGSizeMake(width, width + 45);
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    [collectionView showNoDataWithTitle:@"" description:@"没有相关商品" rowCount:self.dataArray.count];
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DRPraiseGoodAwardCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GoodAwardCollectionCellId forIndexPath:indexPath];
    cell.goodAwardModel = self.dataArray[indexPath.item];
    cell.activityId = self.activityId;
    cell.type = self.type;
    return cell;
}

#pragma mark - 初始化
- (NSMutableArray *)dataArray
{
    if(_dataArray == nil)
    {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
