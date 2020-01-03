//
//  DRHomePageViewController.m
//  dr
//
//  Created by apple on 17/1/14.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRHomePageViewController.h"
#import "DRLoginViewController.h"
#import "DRConversationListController.h"
#import "DRGoodDetailViewController.h"
#import "DRHomePageSerachViewController.h"
#import "DRHomeTitleCollectionReusableView.h"
#import "DRHomePageBannerCollectionViewCell.h"
#import "DRHomePageSortCollectionViewCell.h"
#import "DRHomePageNewCollectionViewCell.h"
#import "DRHomePageAllShopCollectionViewCell.h"
#import "DRRecommendGoodCollectionViewCell.h"

NSString * const HomeHeaderId = @"HomeHeaderId";
NSString * const BannerCellId = @"BannerCellId";
NSString * const SortCellId = @"SortCellId";
NSString * const NewCellId = @"NewCellId";
NSString * const AllShopCellId = @"AllShopCellId";
NSString * const RecommendGoodCellId = @"RecommendGoodCellId";

@interface DRHomePageViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate>

@property (nonatomic, weak) UIView *barView;
@property (nonatomic, weak) UIImageView * messageImageView;
@property (nonatomic, weak) UISearchBar * searchBar;
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic,weak) DRHomePageAllShopCollectionViewCell * shopCell;
@property (nonatomic, strong) NSArray * sortDataArray;
@property (nonatomic, strong) NSMutableArray * goodRecommendDataArray;
@property (nonatomic, weak) MJRefreshGifHeader *headerView;
@property (nonatomic, weak) MJRefreshBackGifFooter *footerView;
@property (nonatomic, assign) int pageIndex;//页数
@property (nonatomic,weak) UIButton * backTopBtn;
@property (nonatomic,weak) UILabel * bageLabel;//未读消息数

@end

@implementation DRHomePageViewController

#pragma mark - 控制器的生命周期
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.searchBar && self.searchBar.isFirstResponder) {
        [self.searchBar resignFirstResponder];
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self scrollViewDidScroll:self.collectionView];
    if (self.searchBar && self.searchBar.isFirstResponder) {
        [self.searchBar resignFirstResponder];
    }
    [self setupUnreadMessageCount];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupChilds];
    self.pageIndex = 1;
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self getData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData) name:@"addGoodSuccess" object:nil];
    //有新消息时的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupUnreadMessageCount) name:@"haveNewMessageNote" object:nil];
    //未读消息数改变时的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupUnreadMessageCount) name:@"setupUnreadMessageCount" object:nil];
}

- (void)getData
{
    //banner刷新
    DRHomePageBannerCollectionViewCell * bannerCell = (DRHomePageBannerCollectionViewCell * )[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    [bannerCell getData];
    
    //分类刷新
    [self getSortData];
    
    //精品刷新
    DRHomePageNewCollectionViewCell * newCell = (DRHomePageNewCollectionViewCell * )[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:2]];
    [newCell getData];
    
    //店铺刷新
    [self.shopCell getShopData];
    
    [self getGoodRecommendData];
}

- (void)getSortData
{
    NSDictionary *bodyDic = @{
                              };
    
    NSDictionary *headDic = @{
                              @"cmd":@"P03",
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            self.sortDataArray = [DRHomePageSortStatus mj_objectArrayWithKeyValuesArray:json[@"list"]];
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

- (void)getGoodRecommendData
{
    NSDictionary *bodyDic = @{
                              @"pageIndex":@(self.pageIndex),
                              @"pageSize":@30,
                              };
    
    NSDictionary *headDic = @{
                              @"cmd":@"B07",
                              };
    
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            if ([self.headerView isRefreshing]) {
                [self.goodRecommendDataArray removeAllObjects];
            }
            NSArray * goodRecommendDataArray = [DRGoodModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            [self.goodRecommendDataArray addObjectsFromArray:goodRecommendDataArray];
            
            [self.collectionView reloadData];
            if (goodRecommendDataArray.count == 0) {
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
#pragma mark - 布局子视图
- (void)setupChilds
{
    //layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    //collectionView
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - tabBarH) collectionViewLayout:layout];
    self.collectionView = collectionView;
    collectionView.backgroundColor = DRBackgroundColor;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.contentInset = UIEdgeInsetsMake(0, 0, 40, 0);
    //注册
    [collectionView registerClass:[DRHomePageBannerCollectionViewCell class] forCellWithReuseIdentifier:BannerCellId];
    [collectionView registerClass:[DRHomePageSortCollectionViewCell class] forCellWithReuseIdentifier:SortCellId];
    [collectionView registerClass:[DRHomePageNewCollectionViewCell class] forCellWithReuseIdentifier:NewCellId];
    [collectionView registerClass:[DRHomePageAllShopCollectionViewCell class] forCellWithReuseIdentifier:AllShopCellId];
    [collectionView registerClass:[DRRecommendGoodCollectionViewCell class] forCellWithReuseIdentifier:RecommendGoodCellId];
    [collectionView registerClass:[DRHomeTitleCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HomeHeaderId];
    [self.view addSubview:collectionView];
    
    //初始化头部刷新控件
    MJRefreshGifHeader *headerRefreshView = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshViewBeginRefreshing)];
    self.headerView = headerRefreshView;
    [DRTool setRefreshHeaderData:headerRefreshView];
    collectionView.mj_header = headerRefreshView;
    
    //初始化底部刷新控件
    MJRefreshBackGifFooter *footerView = [MJRefreshBackGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshViewBeginRefreshing)];
    self.footerView = footerView;
    [DRTool setRefreshFooterData:footerView];
    collectionView.mj_footer = footerView;
    
    //barView
    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, statusBarH + navBarH)];
    self.barView = barView;
    barView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    [self.view addSubview:barView];
    
    //bar
    //消息
    CGFloat barImageViewWH = 20;
    UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    messageButton.frame = CGRectMake(screenWidth - DRMargin - barImageViewWH - DRMargin, statusBarH, barImageViewWH + 2 * DRMargin, navBarH);
    [messageButton addTarget:self action:@selector(messageDidClick) forControlEvents:UIControlEventTouchUpInside];
    [barView addSubview:messageButton];
    
    UIImageView * messageImageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth - DRMargin - barImageViewWH, statusBarH + (navBarH - barImageViewWH) / 2, barImageViewWH, barImageViewWH)];
    self.messageImageView = messageImageView;
    messageImageView.image = [UIImage imageNamed:@"white_message_bar"];
    [barView addSubview:messageImageView];
    
    //未读消息数
    CGFloat bageLabelWH = 15;
    UILabel * bageLabel = [[UILabel alloc] initWithFrame:CGRectMake(messageImageView.width - bageLabelWH / 2 - 1.5,  - bageLabelWH / 2 + 1.5, bageLabelWH, bageLabelWH)];
    self.bageLabel = bageLabel;
    bageLabel.backgroundColor = DRRedTextColor;
    bageLabel.textColor = [UIColor whiteColor];
    bageLabel.font = [UIFont systemFontOfSize:DRGetFontSize(22)];
    bageLabel.textAlignment = NSTextAlignmentCenter;
    bageLabel.layer.masksToBounds = YES;
    bageLabel.layer.cornerRadius = bageLabelWH / 2;
    bageLabel.adjustsFontSizeToFitWidth = YES;
    bageLabel.hidden = YES;
    [messageImageView addSubview:bageLabel];
    
    //search
    UISearchBar * searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(DRMargin, statusBarH + (44 - 30) / 2, screenWidth - messageImageView.width - DRMargin * 2 - 8, 30)];
    self.searchBar = searchBar;
    searchBar.layer.masksToBounds = YES;
    searchBar.layer.cornerRadius = searchBar.height / 2;
    searchBar.layer.borderColor = [UIColor whiteColor].CGColor;
    searchBar.layer.borderWidth = 8;
    searchBar.delegate = self;
    searchBar.placeholder = @"多肉、店铺";
    UITextField * searchTextField = nil;
    if (iOS13) {
        searchTextField = (UITextField *)[DRTool findViewWithClassName:@"UITextField" inView:_searchBar];
    }else
    {
        searchTextField = [_searchBar valueForKey:@"_searchField"];
    }
    searchTextField.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    searchTextField.layer.cornerRadius = searchTextField.height / 2;
    searchTextField.layer.masksToBounds = YES;
    [barView addSubview:searchBar];
    
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
    self.pageIndex = 1;
    [self getData];
}

- (void)footerRefreshViewBeginRefreshing
{
    self.pageIndex++;
    [self getGoodRecommendData];
}

- (void)messageDidClick
{
    if(!UserId || !Token)
    {
        DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
        [self presentViewController:loginVC animated:YES completion:nil];
        return;
    }

    DRConversationListController * conversationListVC = [[DRConversationListController alloc] init];
    [self.navigationController pushViewController:conversationListVC animated:YES];
}
// 统计未读消息数
-(void)setupUnreadMessageCount
{
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
    }

    if (unreadCount > 0) {
        self.bageLabel.hidden = NO;
        self.bageLabel.text = [NSString stringWithFormat:@"%i",(int)unreadCount];
    }else{
        self.bageLabel.hidden = YES;
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
//配置item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return CGSizeMake(screenWidth, screenWidth * 176 / 375);
    }else if (indexPath.section == 1)
    {
        CGFloat cellH = (self.sortDataArray.count + 4) / 5 * 80;
        if (cellH == 0) {
            cellH = 1;
        }
        return CGSizeMake(screenWidth, cellH);
    }else if (indexPath.section == 2)
    {
        return CGSizeMake(screenWidth, 180);
    }else if (indexPath.section == 3)
    {
        CGFloat padding = 5;
        CGFloat smallImageViewWH = (screenWidth -  4 * padding) / 3;
        return CGSizeMake(screenWidth, 53 + padding * 2 + smallImageViewWH * 2 + 25);
    }else if (indexPath.section == 4)
    {
        CGFloat width = (screenWidth - 5) / 2;
        return CGSizeMake(width, width + 75);
    }
    return CGSizeZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    if (section == 4) {
        return 5;
    }
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    if (section == 4) {
        return 5;
    }
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == 0 || section == 1) {
        return CGSizeZero;
    }
    return CGSizeMake(screenWidth, 9 + 40);
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 5;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0 || section == 1 || section == 2 || section == 3) {
        return 1;
    }else if (section == 4)
    {
        return self.goodRecommendDataArray.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        DRHomePageBannerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:BannerCellId forIndexPath:indexPath];
        return cell;
    }else if (indexPath.section == 1)
    {
        DRHomePageSortCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SortCellId forIndexPath:indexPath];
        cell.dataArray = self.sortDataArray;
        [cell setData];
        return cell;
    }else if (indexPath.section == 2)
    {
        DRHomePageNewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NewCellId forIndexPath:indexPath];
        return cell;
    }else if (indexPath.section == 3)
    {
        DRHomePageAllShopCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:AllShopCellId forIndexPath:indexPath];
        self.shopCell = cell;
        return cell;
    }else if (indexPath.section == 4)
    {
        DRRecommendGoodCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:RecommendGoodCellId forIndexPath:indexPath];
        cell.model = self.goodRecommendDataArray[indexPath.row];
        return cell;
    }
    return nil;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 1) {
        return nil;
    }
    
    if (kind == UICollectionElementKindSectionHeader) {
        DRHomeTitleCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:HomeHeaderId forIndexPath:indexPath];
        NSArray * titles = @[@"—— 精品推荐 ——", @"—— 发现好店 ——", @"—— 为您推荐 ——"];
        headerView.title = titles[indexPath.section - 2];
        headerView.index = indexPath.section - 2;
        return headerView;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.backTopBtn.hidden = YES;
    if (indexPath.section == 4) {
        if (indexPath.row > 30) {
            self.backTopBtn.hidden = NO;
        }
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 4) {
        DRGoodDetailViewController * goodVC = [[DRGoodDetailViewController alloc] init];
        DRGoodModel * model = self.goodRecommendDataArray[indexPath.row];
        goodVC.goodId = model.id;
        [self.navigationController pushViewController:goodVC animated:YES];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
    if (scrollView == self.collectionView) {
        CGFloat offsetY = scrollView.contentOffset.y;
        CGFloat scale = offsetY / 120;
        scale = scale > 1 ? 1 : scale;
        //设置bar背景色
        self.barView.backgroundColor = [UIColor colorWithWhite:1 alpha:scale * 0.94];
        //设置输入框背景色
        UITextField * searchTextField = nil;
        if (iOS13) {
            searchTextField = (UITextField *)[DRTool findViewWithClassName:@"UITextField" inView:_searchBar];
        }else
        {
            searchTextField = [_searchBar valueForKey:@"_searchField"];
        }
        CGFloat tfColor = 255 - (255 - 223) * scale;
        searchTextField.backgroundColor = DRColor(tfColor, tfColor, tfColor, 1);
        self.searchBar.layer.borderColor = DRColor(tfColor, tfColor, tfColor, 1).CGColor;
        if (offsetY <= 120) {
            self.messageImageView.image = [UIImage imageNamed:@"white_message_bar"];
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        }else
        {
            self.messageImageView.image = [UIImage imageNamed:@"black_message_bar"];
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        }
    }
}
#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    DRHomePageSerachViewController * searchVC = [[DRHomePageSerachViewController alloc] init];
    [self.navigationController pushViewController:searchVC animated:YES];
}
#pragma mark - 初始化
- (NSArray *)sortDataArray
{
    if (!_sortDataArray) {
        _sortDataArray = [NSArray array];
    }
    return _sortDataArray;
}

- (NSMutableArray *)goodRecommendDataArray
{
    if (!_goodRecommendDataArray) {
        _goodRecommendDataArray = [NSMutableArray array];
    }
    return _goodRecommendDataArray;
}

@end
