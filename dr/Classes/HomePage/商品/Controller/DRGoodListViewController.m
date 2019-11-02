//
//  DRGoodListViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/5/8.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRGoodListViewController.h"
#import "CoreLocation/CoreLocation.h"
#import "DRHomePageSerachViewController.h"
#import "DRCityListViewController.h"
#import "DRGoodDetailViewController.h"
#import "DRRecommendGoodCollectionViewCell.h"
#import "DRGoodScreeningView.h"
#import "YZSortButton.h"
#import "UICollectionView+DRNoData.h"
#import "UIButton+DR.h"

NSString * const collectionCellId = @"GoodCollectionViewCellId";

@interface DRGoodListViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, GoodScreeningViewDelegate, CLLocationManagerDelegate, DRCityListViewControllerDelegate>

@property (strong, nonatomic) CLLocationManager* locationManager;
@property (nonatomic, weak) UIButton *cityButton;
@property (nonatomic, assign) int pageIndex;//页数
@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) MJRefreshGifHeader *headerView;
@property (nonatomic, weak) MJRefreshBackGifFooter *footerView;
@property (nonatomic, strong) NSMutableArray *sortButtons;
@property (nonatomic, weak) UIView *backView;
@property (nonatomic, weak) DRGoodScreeningView * screeningView;
@property (nonatomic,weak) UIButton * backTopBtn;
@property (nonatomic, copy) NSString *address;

@end

@implementation DRGoodListViewController

#pragma mark - 控制器的生命周期
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pageIndex = 1;
    self.title = @"多肉";
    [self setupChilds];
    waitingView;
    [self getSearchData];
    [self getData];
}

#pragma mark - 请求数据
- (void)getSearchData
{
    if (DRStringIsEmpty(self.categoryId)) {
        return;
    }
    NSDictionary *bodyDic = @{
                               @"id":self.categoryId,
                               };
    NSDictionary *headDic = @{
                              @"cmd":@"L05",
                              };
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            if ([json[@"status"] intValue] == 1) {
                [self setLocation];
            }
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        
    }];
}

- (void)getData
{
    NSDictionary *bodyDic_ = @{
                              @"pageIndex":@(self.pageIndex),
                              @"pageSize":DRPageSize,
                              };
    NSMutableDictionary * bodyDic = [NSMutableDictionary dictionaryWithDictionary:bodyDic_];
    if (!DRStringIsEmpty(self.shopId)) {
        [bodyDic setObject:self.shopId forKey:@"storeId"];
    }
    if (!DRStringIsEmpty(self.categoryId)) {
        [bodyDic setObject:self.categoryId forKey:@"categoryId"];
    }
    if (!DRStringIsEmpty(self.subjectId)) {
        [bodyDic setObject:self.subjectId forKey:@"subjectId"];
    }
    if (!DRStringIsEmpty(self.sellType)) {
        [bodyDic setObject:self.sellType forKey:@"sellType"];
    }
    if (!DRStringIsEmpty(self.type)) {
        [bodyDic setObject:self.type forKey:@"type"];
    }
    if (!DRArrayIsEmpty(self.sorts)) {
        [bodyDic setObject:self.sorts forKey:@"sorts"];
    }
    if (!DRStringIsEmpty(self.isGroup)) {
        [bodyDic setObject:self.isGroup forKey:@"isGroup"];
    }
    if (!DRStringIsEmpty(self.address)) {
        [bodyDic setObject:self.address forKey:@"address"];
    }
    if (!DRStringIsEmpty(self.likeName)) {
        [bodyDic setObject:self.likeName forKey:@"likeName"];
    }
    if (!DRStringIsEmpty(self.minPrice)) {
        int minPrice = [self.minPrice doubleValue] * 100;
        [bodyDic setObject:@(minPrice) forKey:@"greater"];
    }
    if (!DRStringIsEmpty(self.maxPrice)) {
        int maxPrice = [self.maxPrice doubleValue] * 100;
        [bodyDic setObject:@(maxPrice) forKey:@"less"];
    }
    
    NSDictionary *headDic = @{
                              @"cmd":@"B07",
                              };
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            NSArray * newDataArray = [DRGoodModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            for (DRGoodModel * goodModel in newDataArray) {
                NSInteger index = [newDataArray indexOfObject:goodModel];
                goodModel.specifications = [DRGoodSpecificationModel mj_objectArrayWithKeyValuesArray:json[@"list"][index][@"specifications"]];
            }
            [self.dataArray addObjectsFromArray:newDataArray];
            self.backTopBtn.hidden = YES;
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
        [MBProgressHUD hideHUDForView:self.view];
        //结束刷新
        [self.headerView endRefreshing];
        [self.footerView endRefreshing];
    }];
}

- (void)setLocation
{
    //定位
    UIButton *cityButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cityButton = cityButton;
    cityButton.frame = CGRectMake(0, 0, 120, 44);
    [cityButton setTitle:@"定位中..." forState:UIControlStateNormal];
    cityButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(34)];
    [cityButton setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
    [cityButton setImage:[UIImage imageNamed:@"city_ location_icon"] forState:UIControlStateNormal];
    [cityButton addTarget:self action:@selector(cityButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = cityButton;
    
    if ([CLLocationManager locationServicesEnabled]) {//判断定位操作是否被允许
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;//遵循代理
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        [self.locationManager requestWhenInUseAuthorization];//使用程序其间允许访问位置数据
        [self.locationManager startUpdatingLocation];//开始定位
    }
}

#pragma mark - 布局视图
- (void)setupChilds
{
    UIBarButtonItem * screeningBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"筛选" style:UIBarButtonItemStylePlain target:self action:@selector(screeningDidClick)];
    UIBarButtonItem * searchBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"black_search_bar"] style:UIBarButtonItemStylePlain target:self action:@selector(searchBarDidClick)];
    self.navigationItem.rightBarButtonItems = @[screeningBarButtonItem, searchBarButtonItem];
 
    //排序
    UIView * sortView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 40)];
    sortView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:sortView];

    NSArray * sortTitles = @[@"上新", @"销量", @"价格"];
    NSArray * sortTitleViewWs = @[@0.35,@0.3,@0.35];
    UIView * lastSortButton;
    for (int i = 0; i < sortTitles.count; i++) {
        YZSortButton * sortButton = [[YZSortButton alloc] initWithShowImage:i == 2];
        sortButton.tag = i;
        sortButton.frame = CGRectMake(CGRectGetMaxX(lastSortButton.frame), 0, [sortTitleViewWs[i] floatValue] * screenWidth, sortView.height);
        sortButton.text = sortTitles[i];
        [sortButton addTarget:self action:@selector(sortButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [sortView addSubview:sortButton];
        [self.sortButtons addObject:sortButton];
        lastSortButton = sortButton;
    }
    
    //商品列表
    //layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.minimumInteritemSpacing = 5;//列间距
    layout.minimumLineSpacing = 5;//行间距
    
    //collectionView
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, sortView.height + 5, screenWidth, screenHeight - statusBarH - navBarH - sortView.height - 5) collectionViewLayout:layout];
    self.collectionView = collectionView;
    collectionView.backgroundColor = DRBackgroundColor;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.showsHorizontalScrollIndicator = NO;
    //注册
    [collectionView registerClass:[DRRecommendGoodCollectionViewCell class] forCellWithReuseIdentifier:collectionCellId];
    [self.view addSubview:collectionView];
    
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
    
    //筛选
    UIView *backView = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
    self.backView = backView;
    backView.hidden = YES;
    backView.backgroundColor = DRColor(0, 0, 0, 0);
    [self.navigationController.view addSubview:backView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenBackView)];
    tap.delegate = self;
    [backView addGestureRecognizer:tap];
    
    CGFloat screeningViewW = 293;
    DRGoodScreeningView * screeningView = [[DRGoodScreeningView alloc] initWithFrame:CGRectMake(screenWidth, 0, screeningViewW, self.backView.height)];
    self.screeningView = screeningView;
    screeningView.categoryId = self.categoryId;
    screeningView.sellType = self.sellType;
    self.isGroup = self.isGroup;
    screeningView.minPrice = self.minPrice;
    screeningView.maxPrice = self.maxPrice;
    screeningView.delegate = self;
    [self.backView addSubview:screeningView];
    
    //回到顶部按钮
    UIButton * backTopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backTopBtn = backTopBtn;
    CGFloat backTopBtnW = 40;
    CGFloat backTopBtnH = 40;
    CGFloat backTopBtnX = screenWidth - backTopBtnW - 20;
    CGFloat backTopBtnY = screenHeight - statusBarH - navBarH - [DRTool getSafeAreaBottom] - backTopBtnH - 20;
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

//筛选
- (void)screeningDidClick
{
    //动画
    self.backView.hidden = NO;
    [UIView animateWithDuration:DRAnimateDuration animations:^{
        self.backView.backgroundColor = DRColor(0, 0, 0, 0.4);
        self.screeningView.x = screenWidth - self.screeningView.width;
    }];
}

- (void)goodScreeningView:(DRGoodScreeningView *)goodScreeningView confirmButtonDidClick:(UIButton *)button
{
    [self hiddenBackView];
    self.categoryId = goodScreeningView.categoryId;
    self.sellType = goodScreeningView.sellType;
    self.isGroup = goodScreeningView.isGroup;
    self.minPrice = goodScreeningView.minPrice;
    self.maxPrice = goodScreeningView.maxPrice;
    [self.collectionView.mj_header beginRefreshing];
}

- (void)hiddenBackView
{
    [UIView animateWithDuration:DRAnimateDuration animations:^{
        self.backView.backgroundColor = DRColor(0, 0, 0, 0);
        self.screeningView.x = screenWidth;
    } completion:^(BOOL finished) {
        self.backView.hidden = YES;
    }];
}

//搜索
- (void)searchBarDidClick
{
    NSArray * viewControllers = self.navigationController.viewControllers;
    for (id viewController in viewControllers)
    {
        if ([viewController isKindOfClass:[DRHomePageSerachViewController class]])
        {
            [self.navigationController popToViewController:viewController animated:YES];
            return;
        }
    }
    DRHomePageSerachViewController * searchVC = [[DRHomePageSerachViewController alloc] init];
    [self.navigationController pushViewController:searchVC animated:YES];
}

- (void)cityButtonDidClick
{
    DRCityListViewController * cityListVC = [[DRCityListViewController alloc] init];
    cityListVC.currentCityName = self.address;
    cityListVC.delegate = self;
    [self.navigationController pushViewController:cityListVC animated:YES];
}

- (void)cityListViewControllerChooseAddress:(NSString *)address
{
    self.address = address;
    [self.cityButton setTitle:self.address forState:UIControlStateNormal];
    [self getData];
}

- (void)sortButtonDidClick:(YZSortButton *)button
{
    //先清空其他的
    for (int i = 0; i < self.sortButtons.count; i++) {
        if (i != button.tag) {
            YZSortButton * sortButton = self.sortButtons[i];
            sortButton.sortMode = SortModeNormal;
        }
    }
    
    if (button.tag == 2) {
        if (button.sortMode == SortModeNormal || button.sortMode == SortModeDescending) {
            button.sortMode = SortModeAscending;
        }else
        {
            button.sortMode = SortModeDescending;
        }
    }else
    {
        button.sortMode = SortModeDescending;
    }
    
    NSString * name = @"";
    if (button.tag == 0) {
        name = @"create_time";
    }else if (button.tag == 1)
    {
        name = @"sell_count";
    }else if (button.tag == 2)
    {
        name = @"price";
    }
    NSString * type = @"";
    if (button.sortMode == SortModeDescending) {
        type = @"desc";
    }else if (button.sortMode == SortModeAscending)
    {
        type = @"asc";
    }
    NSDictionary * sortDic = @{
                               @"name":name,
                               @"type":type,
                               };
    self.sorts = @[sortDic];
    [self.collectionView.mj_header beginRefreshing];
}

#pragma mark - 刷新
- (void)headerRefreshViewBeginRefreshing
{
    self.pageIndex = 1;
    [self.dataArray removeAllObjects];
    [self getData];
}
- (void)footerRefreshViewBeginRefreshing
{
    self.pageIndex++;
    [self getData];
}

#pragma mark - 定位
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    //当前所在城市的坐标值
    CLLocation *currLocation = [locations lastObject];
    //根据经纬度反向地理编译出地址信息
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:currLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error && placemarks.count > 0) {
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"定位功能" message:@"按位置给您推荐附近商品"  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * alertAction1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                self.navigationItem.titleView = nil;
                self.title = @"多肉";
            }];
            UIAlertAction * alertAction2 = [UIAlertAction actionWithTitle:@"按位置推荐" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                CLPlacemark * placemark = placemarks.firstObject;
                NSDictionary *address = [placemark addressDictionary];
                self.address = [NSString stringWithFormat:@"%@", address[@"City"]];
                [self.cityButton setTitle:self.address forState:UIControlStateNormal];
                [self.dataArray removeAllObjects];
                [self getData];
            }];
            [alertController addAction:alertAction1];
            [alertController addAction:alertAction2];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    self.address = @"";
    [self.cityButton setTitle:@"定位失败" forState:UIControlStateNormal];
    [MBProgressHUD showError:@"定位失败"];
    [self.locationManager stopUpdatingLocation];
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
   [collectionView showNoDataWithTitle:@"" description:@"没有相关商品" rowCount:self.dataArray.count];
    return self.dataArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DRRecommendGoodCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellId forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DRGoodModel * model = self.dataArray[indexPath.row];
    DRGoodDetailViewController * goodDetailVC = [[DRGoodDetailViewController alloc] init];
    goodDetailVC.goodId = model.id;
    [self.navigationController pushViewController:goodDetailVC animated:YES];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[UICollectionView class]]) {//collectionView的偏移量
        CGFloat contentOffsetY = scrollView.contentOffset.y;
        CGFloat padding = 10;
        if (contentOffsetY >= 2 * ((screenWidth - padding * 3) / 2 + 70 + padding)) {//大于4条数据才显示
            self.backTopBtn.hidden = NO;
        }else
        {
            self.backTopBtn.hidden = YES;
        }
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

- (NSArray *)sorts
{
    if (!_sorts) {
        _sorts = [NSArray array];
    }
    return _sorts;
}

- (NSMutableArray *)sortButtons
{
    if (!_sortButtons) {
        _sortButtons = [NSMutableArray array];
    }
    return _sortButtons;
}
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        CGPoint pos = [touch locationInView:self.screeningView.superview];
        if (CGRectContainsPoint(self.screeningView.frame, pos)) {
            return NO;
        }
    }
    return YES;
}

@end
