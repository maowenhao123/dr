//
//  DRGoodSortViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/11/30.
//  Copyright © 2017年 JG. All rights reserved.
//

#define leftScale 0.2346
#define padding 5

#import "DRGoodSortViewController.h"
#import "DRLoginViewController.h"
#import "DRGoodListViewController.h"
#import "DRSortTableViewCell.h"
#import "DRSortTitleCollectionReusableView.h"
#import "DRSortGoodCollectionViewCell.h"
#import "ULBCollectionViewFlowLayout.h"

@interface DRGoodSortViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, ULBCollectionViewDelegateFlowLayout>
{
    BOOL _isScrollDown;//滚动方向
}
@property (nonatomic, weak) UITableView * tableView;//左边分类视图
@property (nonatomic, weak) UICollectionView * collectionView;//右边显示视图
@property (nonatomic, strong) id json;
@property (nonatomic, strong) NSMutableArray * sortArray;//分类
@property (nonatomic, strong) NSArray * sortGoodArray;//商品分类
@property (nonatomic, assign) NSInteger selectedIndex;

@end

NSString * const SortGoodCellId = @"SortGoodCellId";
NSString * const SortGoodHeaderId = @"SortGoodHeaderId";

@implementation DRGoodSortViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"分类";
    self.view.backgroundColor = DRBackgroundColor;
    [self setupChilds];
    [self getData];
}
- (void)getData
{
    waitingView;
    NSDictionary *bodyDic = @{
                              };
    
    NSDictionary *headDic = @{
                              @"cmd":@"B02",
                              };
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            self.json = json;
            [self setSortDataArray];
            [self setSortGoodDataArray];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        DRLog(@"error:%@",error);
    }];
}
- (void)setSortDataArray
{
    NSArray * dataArray = self.json[@"list"];
    for (int i = 0; i < dataArray.count; i++) {
        DRSortModel * model = [[DRSortModel alloc] init];
        NSDictionary * dataDic = dataArray[i];
        model.name = dataDic[@"name"];
        model.id = dataDic[@"id"];
        model.logo = dataDic[@"logo"];
        [self.sortArray addObject:model];
    }
    self.selectedIndex = 0;
    [self.tableView reloadData];
}
- (void)setSortGoodDataArray
{
    NSArray * dataArray = self.json[@"list"];
    NSMutableArray * sortGoodArray = [NSMutableArray array];
    for (NSDictionary * dataDic in dataArray) {
        NSArray * dataArr = dataDic[@"child"];
        [sortGoodArray addObject:dataArr];
    }
    self.sortGoodArray = [NSArray arrayWithArray:sortGoodArray];
    [self.collectionView reloadData];
}
- (void)setupChilds
{
    //tableView
    CGFloat viewH = screenHeight - statusBarH - navBarH - tabBarH;
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth * leftScale, viewH) style:UITableViewStylePlain];
    self.tableView = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    [self.view addSubview:tableView];
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 1)];
    line.backgroundColor = DRWhiteLineColor;
    [tableView addSubview:line];
    
    //collectionView
    ULBCollectionViewFlowLayout * layout = [[ULBCollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 8, 0, 8);
    layout.minimumInteritemSpacing = 0;//列间距
    layout.minimumLineSpacing = 0;//行间距
    
    UICollectionView * collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(screenWidth * leftScale + padding * 2, 0, screenWidth * (1 - leftScale) - 2 * padding, viewH) collectionViewLayout:layout];
    self.collectionView = collectionView;
    collectionView.backgroundColor = DRBackgroundColor;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.contentInset = UIEdgeInsetsMake(0, 0, padding * 2, 0);
    collectionView.showsVerticalScrollIndicator = NO;
    //注册
    [collectionView registerClass:[DRSortGoodCollectionViewCell class] forCellWithReuseIdentifier:SortGoodCellId];
    [collectionView registerClass:[DRSortTitleCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:SortGoodHeaderId];
    [self.view addSubview:collectionView];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sortArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRSortTableViewCell * cell = [DRSortTableViewCell cellWithTableView:tableView];
    cell.model = self.sortArray[indexPath.row];
    cell.haveSelected = indexPath.row == self.selectedIndex;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectRowAtIndexPath:indexPath.row];
    
    //滚动collectionView
    CGRect headerRect = [self frameForHeaderForSection:indexPath.row];
    CGPoint topOfHeader = CGPointMake(0, headerRect.origin.y - self.collectionView.contentInset.top);
    [self.collectionView setContentOffset:topOfHeader animated:YES];
}

- (void)selectRowAtIndexPath:(NSInteger)index
{
    if (index < self.sortArray.count) {
        self.selectedIndex = index;
        [self.tableView reloadData];
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
}

- (CGRect)frameForHeaderForSection:(NSInteger)section
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    UICollectionViewLayoutAttributes *attributes = [self.collectionView.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
    return attributes.frame;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (UIColor *)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout colorForSectionAtIndex:(NSInteger)section
{
    return [UIColor whiteColor];
}

//配置item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat itemW = (collectionView.width - 2 * padding - 2 * 8) / 3;
    CGFloat itemH = itemW + 33;
    return CGSizeMake(itemW, itemH);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(collectionView.width, 9 + 33);
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.sortGoodArray.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray * dataArr = self.sortGoodArray[section];
    return dataArr.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DRSortGoodCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SortGoodCellId forIndexPath:indexPath];
    NSArray * dataArr = self.sortGoodArray[indexPath.section];
    NSDictionary * dic = dataArr[indexPath.item];
    cell.dic = dic;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader)
    {
        DRSortTitleCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:SortGoodHeaderId forIndexPath:indexPath];
        //分类
        if (self.sortArray.count > 0) {
            DRSortModel * model = self.sortArray[indexPath.section];
            headerView.title = model.name;
        }else
        {
            headerView.title = @"分类";
        }
        DRSortModel * model = self.sortArray[indexPath.section];
        headerView.categoryId = model.id;
        return headerView;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DRGoodListViewController * goodListVC = [[DRGoodListViewController alloc] init];
    DRSortModel * model = self.sortArray[indexPath.section];
    NSArray * dataArr = self.sortGoodArray[indexPath.section];
    NSDictionary * dataDic = dataArr[indexPath.row];
    goodListVC.categoryId = model.id;
    goodListVC.subjectId = dataDic[@"id"];
    [self.navigationController pushViewController:goodListVC animated:YES];
} 
// CollectionView分区标题即将展示
- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    if (!_isScrollDown && (collectionView.dragging || collectionView.decelerating)) {
        [self selectRowAtIndexPath:indexPath.section];
    }
}
// CollectionView分区标题展示结束
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(nonnull UICollectionReusableView *)view forElementOfKind:(nonnull NSString *)elementKind atIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (_isScrollDown && (collectionView.dragging || collectionView.decelerating)) {
        [self selectRowAtIndexPath:indexPath.section + 1];
    }
}

#pragma mark - UIScrollView Delegate
// 标记一下CollectionView的滚动方向，是向上还是向下
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    static double lastOffsetY = 0;
    if (self.collectionView == scrollView) {
        _isScrollDown = lastOffsetY < scrollView.contentOffset.y;
        lastOffsetY = scrollView.contentOffset.y;
    }
}

#pragma mark - 初始化
- (NSMutableArray *)sortArray
{
    if (!_sortArray) {
        _sortArray = [NSMutableArray array];
    }
    return _sortArray;
}
- (NSArray *)sortGoodArray
{
    if (!_sortGoodArray) {
        _sortGoodArray = [NSArray array];
    }
    return _sortGoodArray;
}

@end
