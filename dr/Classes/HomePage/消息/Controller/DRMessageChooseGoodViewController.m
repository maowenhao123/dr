//
//  DRMessageChooseGoodViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/12/19.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRMessageChooseGoodViewController.h"
#import "DRMessageChooseGoodTableViewCell.h"
#import "UITableView+DRNoData.h"
#import "DRShoppingCarShopModel.h"
#import "DROrderModel.h"
#import "DRShoppingCarCache.h"

@interface DRMessageChooseGoodViewController ()<UITableViewDataSource, UITableViewDelegate, MessageChooseGoodTableViewCellDelegate>

@property (nonatomic,weak) UILabel *numberLabel;
@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, assign) int pageIndex1;
@property (nonatomic, assign) int pageIndex2;
@property (nonatomic, assign) int pageIndex4;
@property (nonatomic, assign) int currentPageIndex;//当前的页数
@property (nonatomic, strong) NSMutableArray *headerViews;
@property (nonatomic, strong) NSMutableArray *footerViews;

@end

@implementation DRMessageChooseGoodViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"选择宝贝";
    self.view.backgroundColor = [UIColor whiteColor];
    self.currentPageIndex = 1;
    self.pageIndex1 = 1;
    self.pageIndex2 = 1;
    self.pageIndex4 = 1;
    [self setupChilds];
}
#pragma mark - 请求数据
- (void)getAttentionGoodData
{
    NSDictionary *bodyDic = @{
                              @"pageIndex":@(self.currentPageIndex),
                              @"pageSize":DRPageSize,
                              @"type":@"1",
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U24",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        MJRefreshGifHeader *headerView = self.headerViews[self.currentIndex];
        MJRefreshBackGifFooter *footerView = self.footerViews[self.currentIndex];
        UITableView *tableView = self.views[self.currentIndex];
        if (SUCCESS) {
            NSMutableArray * dataArray = self.dataArray[self.currentIndex];
            NSArray * newAttentionArray = [NSMutableArray array];
            newAttentionArray = json[@"list"];
            [dataArray addObjectsFromArray:[self setAttentionGoodDataByArray:newAttentionArray]];
            [tableView reloadData];
            //结束刷新
            if ([headerView isRefreshing]) {
                [headerView endRefreshing];
            }
            if ([footerView isRefreshing]) {
                if (newAttentionArray.count == 0) {
                    [footerView endRefreshingWithNoMoreData];
                }else
                {
                    [footerView endRefreshing];
                }
            }
        }else
        {
            ShowErrorView
            //结束刷新
            if ([headerView isRefreshing]) {
                [headerView endRefreshing];
            }
            if ([footerView isRefreshing]) {
                [footerView endRefreshing];
            }
            
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        MJRefreshGifHeader *headerView = self.headerViews[self.currentIndex];
        MJRefreshBackGifFooter *footerView = self.footerViews[self.currentIndex];
        //结束刷新
        if ([headerView isRefreshing]) {
            [headerView endRefreshing];
        }
        if ([footerView isRefreshing]) {
            [footerView endRefreshing];
        }
    }];
}

- (NSArray *)setAttentionGoodDataByArray:(NSArray *)array
{
    NSMutableArray * dataArray = [NSMutableArray array];
    for (NSDictionary * dic in array) {
        DRGoodModel * goodModel = [DRGoodModel mj_objectWithKeyValues:dic[@"goods"]];
        DRMessageChooseGoodModel * messageChooseGoodModel = [[DRMessageChooseGoodModel alloc] init];
        messageChooseGoodModel.selected = NO;
        messageChooseGoodModel.goodModel = goodModel;
        messageChooseGoodModel.type = 1;
        [dataArray addObject:messageChooseGoodModel];
    }
    return dataArray;
}

- (void)getOrderGoodData
{
    NSDictionary *bodyDic = @{
                               @"pageIndex":@(self.currentPageIndex),
                               @"pageSize":DRPageSize,
                               };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"S11",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        MJRefreshGifHeader *headerView = self.headerViews[self.currentIndex];
        MJRefreshBackGifFooter *footerView = self.footerViews[self.currentIndex];
        UITableView *tableView = self.views[self.currentIndex];
        if (SUCCESS) {
            NSMutableArray * dataArray = self.dataArray[self.currentIndex];
            NSArray * newDataArray = [DROrderModel  mj_objectArrayWithKeyValuesArray:json[@"list"]];
            NSArray *orders = json[@"list"];
            for (DROrderModel * orderModel in newDataArray) {
                NSInteger index = [newDataArray indexOfObject:orderModel];
                NSArray *storeOrders_ = [DRStoreOrderModel  mj_objectArrayWithKeyValuesArray:orders[index][@"storeOrders"]];
                orderModel.storeOrders = storeOrders_;
                
                NSArray *detail = orders[index][@"storeOrders"];
                for (DRStoreOrderModel * storeOrder in orderModel.storeOrders) {
                    NSInteger index_ = [orderModel.storeOrders indexOfObject:storeOrder];
                    NSArray *detail_ = [DROrderItemDetailModel  mj_objectArrayWithKeyValuesArray:detail[index_][@"detail"]];
                    storeOrder.detail = detail_;
                }
            }
            
            [dataArray addObjectsFromArray:[self setOrderGoodDataByArray:newDataArray]];
            [tableView reloadData];
            if (newDataArray.count == 0) {//没有新的数据
                [footerView endRefreshingWithNoMoreData];
            }else
            {
                [footerView endRefreshing];
            }
        }else
        {
            ShowErrorView
            if ([footerView isRefreshing]) {
                [footerView endRefreshing];
            }
        }
        //结束刷新
        if ([headerView isRefreshing]) {
            [headerView endRefreshing];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        [MBProgressHUD hideHUDForView:self.view];
        MJRefreshGifHeader *headerView = self.headerViews[self.currentIndex];
        MJRefreshBackGifFooter *footerView = self.footerViews[self.currentIndex];
        //结束刷新
        if ([headerView isRefreshing]) {
            [headerView endRefreshing];
        }
        if ([footerView isRefreshing]) {
            [footerView endRefreshing];
        }
    }];
}

- (NSArray *)setOrderGoodDataByArray:(NSArray *)array
{
    NSMutableArray * dataArray = [NSMutableArray array];
    for (DROrderModel * orderModel in array) {
        if ([orderModel.orderType intValue] == 1) {//普通商品
            for (DRStoreOrderModel * storeOrder in orderModel.storeOrders) {
                for (DROrderItemDetailModel * orderItemDetailModel in storeOrder.detail) {
                    DRMessageChooseGoodModel * messageChooseGoodModel = [[DRMessageChooseGoodModel alloc] init];
                    messageChooseGoodModel.selected = NO;
                    messageChooseGoodModel.goodModel = orderItemDetailModel.goods;
                    messageChooseGoodModel.type = 1;
                    messageChooseGoodModel.goodModel.price = orderItemDetailModel.priceCount;
                    [dataArray addObject:messageChooseGoodModel];
                }
            }
        }else//团购商品
        {
            DRMessageChooseGoodModel * messageChooseGoodModel = [[DRMessageChooseGoodModel alloc] init];
            messageChooseGoodModel.selected = NO;
            messageChooseGoodModel.group = orderModel.group;
            messageChooseGoodModel.type = 2;
            [dataArray addObject:messageChooseGoodModel];
        }
    }
    return dataArray;
}

- (void)getShoppingCarGoodData
{
    NSMutableArray * shopDataArray = [[NSMutableArray arrayWithArray:[DRShoppingCarCache getShoppingCarGoods]] mutableCopy];
    NSMutableArray * goodDataArray = [NSMutableArray array];
    for (DRShoppingCarShopModel * carShopModel in shopDataArray) {
        for (DRShoppingCarGoodModel * carGoodModel in carShopModel.goodArr) {
            DRMessageChooseGoodModel * messageChooseGoodModel = [[DRMessageChooseGoodModel alloc] init];
            messageChooseGoodModel.selected = NO;
            messageChooseGoodModel.goodModel = carGoodModel.goodModel;
            messageChooseGoodModel.type = 1;
            [goodDataArray addObject:messageChooseGoodModel];
        }
    }
    self.dataArray[2] = [goodDataArray mutableCopy];
    UITableView * tableView = self.views[2];
    [tableView reloadData];
}

- (void)getMyShopGoodData
{
    DRMyShopModel * shopModel = [DRUserDefaultTool myShopModel];
    NSDictionary *bodyDic = @{
                              @"pageIndex":@(self.currentPageIndex),
                              @"pageSize":DRPageSize,
                              @"storeId":shopModel.id,
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"B07",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        MJRefreshGifHeader *headerView = self.headerViews[self.currentIndex - 1];
        MJRefreshBackGifFooter *footerView = self.footerViews[self.currentIndex - 1];
        UITableView *tableView = self.views[self.currentIndex];
        if (SUCCESS) {
            NSMutableArray * dataArray = self.dataArray[self.currentIndex];
            NSArray * newGoodArray = [NSMutableArray array];
            newGoodArray = json[@"list"];
            [dataArray addObjectsFromArray:[self setMyShopGoodDataByArray:newGoodArray]];
            [tableView reloadData];
            //结束刷新
            if ([headerView isRefreshing]) {
                [headerView endRefreshing];
            }
            if ([footerView isRefreshing]) {
                if (newGoodArray.count == 0) {
                    [footerView endRefreshingWithNoMoreData];
                }else
                {
                    [footerView endRefreshing];
                }
            }
        }else
        {
            ShowErrorView
            //结束刷新
            if ([headerView isRefreshing]) {
                [headerView endRefreshing];
            }
            if ([footerView isRefreshing]) {
                [footerView endRefreshing];
            }
            
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        MJRefreshGifHeader *headerView = self.headerViews[self.currentIndex - 1];
        MJRefreshBackGifFooter *footerView = self.footerViews[self.currentIndex - 1];
        //结束刷新
        if ([headerView isRefreshing]) {
            [headerView endRefreshing];
        }
        if ([footerView isRefreshing]) {
            [footerView endRefreshing];
        }
    }];
}

- (NSArray *)setMyShopGoodDataByArray:(NSArray *)array
{
    NSMutableArray * dataArray = [NSMutableArray array];
    for (NSDictionary * dic in array) {
        DRGoodModel * goodModel = [DRGoodModel mj_objectWithKeyValues:dic];
        DRMessageChooseGoodModel * messageChooseGoodModel = [[DRMessageChooseGoodModel alloc] init];
        messageChooseGoodModel.selected = NO;
        messageChooseGoodModel.goodModel = goodModel;
        messageChooseGoodModel.type = 1;
        [dataArray addObject:messageChooseGoodModel];
    }
    return dataArray;
}

#pragma mark - 布局视图
- (void)setupChilds
{
    //添加btnTitle
    DRUser *user = [DRUserDefaultTool user];
    if ([user.type intValue] == 0) {//未开店
        self.btnTitles = @[@"我关注的", @"我购买的", @"购物车"];
    }else
    {
        self.btnTitles = @[@"我关注的", @"我购买的", @"购物车",@"我的商品"];
    }
    self.maxViewCount = 5;
    //添加tableview
    CGFloat bottomViewH = 40;
    if (@available(iOS 11.0, *)) {
        bottomViewH = 45;
    }
    CGFloat scrollViewH = screenHeight - statusBarH - navBarH - topBtnH - bottomViewH - [DRTool getSafeAreaBottom];
    for(int i = 0;i < self.btnTitles.count;i++)
    {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(screenWidth * i, 0, screenWidth, scrollViewH) style:UITableViewStylePlain];
        tableView.tag = i;
        tableView.backgroundColor = DRBackgroundColor;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
        UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 9)];
        headerView.backgroundColor = DRBackgroundColor;
        tableView.tableHeaderView = headerView;
        [self.views addObject:tableView];
        
        if (i != 2) {
            //初始化头部刷新控件
            MJRefreshGifHeader *headerView = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshViewBeginRefreshing)];
            [DRTool setRefreshHeaderData:headerView];
            [self.headerViews addObject:headerView];
            tableView.mj_header = headerView;
            
            //初始化底部刷新控件
            MJRefreshBackGifFooter *footerView = [MJRefreshBackGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshViewBeginRefreshing)];
            [DRTool setRefreshFooterData:footerView];
            [self.footerViews addObject:footerView];
            tableView.mj_footer = footerView;
        }
    }
    //完成配置
    [super configurationComplete];
    [super topBtnClick:self.topBtns[self.currentIndex]];

    //BottomView
    UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scrollView.frame), screenWidth, bottomViewH)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    //上分割线
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    line1.backgroundColor = DRWhiteLineColor;
    [bottomView addSubview:line1];
    
    //数量
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 0, screenWidth - 90 - 2 * DRMargin, bottomView.height)];
    self.numberLabel = numberLabel;
    numberLabel.textColor = DRBlackTextColor;
    numberLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    [bottomView addSubview:numberLabel];
    [self setNumber];
    
    //确认按钮
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.frame = CGRectMake(screenWidth - 90, 0, 90, bottomView.height);
    confirmButton.backgroundColor = DRDefaultColor;
    [confirmButton setTitle:@"确认" forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [confirmButton addTarget:self action:@selector(confirmButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:confirmButton];
}

#pragma mark - 刷新
- (void)headerRefreshViewBeginRefreshing
{
    if(self.currentIndex == 0)
    {
        self.pageIndex1 = 1;
    }else if(self.currentIndex == 1)
    {
        self.pageIndex2 = 1;
    }else if(self.currentIndex == 3)
    {
        self.pageIndex4 = 1;
    }
    self.currentPageIndex = 1;
    NSMutableArray * dataArray = self.dataArray[self.currentIndex];
    [dataArray removeAllObjects];
    
    if (self.currentIndex == 0) {
        [self getAttentionGoodData];
    }else if (self.currentIndex == 1)
    {
        [self getOrderGoodData];
    }else if (self.currentIndex == 3)
    {
        [self getMyShopGoodData];
    }
}
- (void)footerRefreshViewBeginRefreshing
{
    if(self.currentIndex == 0)
    {
        self.pageIndex1 += 1;
        self.currentPageIndex = self.pageIndex1;
    }else if(self.currentIndex == 1)
    {
        self.pageIndex2 += 1;
        self.currentPageIndex = self.pageIndex2;
    }else if(self.currentIndex == 3)
    {
        self.pageIndex4 += 1;
        self.currentPageIndex = self.pageIndex4;
    }
    
    if (self.currentIndex == 0) {
        [self getAttentionGoodData];
    }else if (self.currentIndex == 1)
    {
        [self getOrderGoodData];
    }else if (self.currentIndex == 3)
    {
        [self getMyShopGoodData];
    }
}

#pragma mark - 更改数量
- (void)setNumber
{
    NSInteger number = 0;
    for (NSArray * dataArray in self.dataArray) {
        for (DRMessageChooseGoodModel * messageChooseGoodModel in dataArray) {
            if (messageChooseGoodModel.selected) {
                number++;
            }
        }
    }
    NSString * numberStr = [NSString stringWithFormat:@"%ld", number];
    NSMutableAttributedString * numberAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"已选择%@件商品", numberStr]];
    [numberAttStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, numberAttStr.length)];
    [numberAttStr addAttribute:NSForegroundColorAttributeName value:DRDefaultColor range:[numberAttStr.string rangeOfString:numberStr]];
    self.numberLabel.attributedText = numberAttStr;
}

- (void)changeCurrentIndex:(int)currentIndex
{
    NSMutableArray * dataArray = self.dataArray[self.currentIndex];
    //没有数据时加载数据
    if(dataArray.count == 0)
    {
        if (self.currentIndex == 0) {
            [self getAttentionGoodData];
        }else if (self.currentIndex == 1)
        {
            [self getOrderGoodData];
        }else if (self.currentIndex == 2)
        {
            [self getShoppingCarGoodData];
        }else if (self.currentIndex == 3)
        {
            [self getMyShopGoodData];
        }
    }
}

- (void)confirmButtonDidClick
{
    NSMutableArray * goodArray = [NSMutableArray array];
    for (NSArray * dataArray in self.dataArray) {
        UITableView * tableView = self.views[[self.dataArray indexOfObject:dataArray]];
        for (DRMessageChooseGoodModel * messageChooseGoodModel in dataArray) {
            NSInteger index = [dataArray indexOfObject:messageChooseGoodModel];
            DRMessageChooseGoodTableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            if (messageChooseGoodModel.selected) {
                NSMutableDictionary * goodInfo = [NSMutableDictionary dictionary];
                // 商品名称
                if (messageChooseGoodModel.type == 2) {//团购
                    if (!DRStringIsEmpty(messageChooseGoodModel.group.goods.name)) {
                        [goodInfo setObject:messageChooseGoodModel.group.goods.name forKey:@"name"];
                    }
                }else
                {
                    if (!DRStringIsEmpty(messageChooseGoodModel.goodModel.name)) {
                        [goodInfo setObject:messageChooseGoodModel.goodModel.name forKey:@"name"];
                    }
                }
                
                //商品描述
                if (messageChooseGoodModel.type == 2) {//团购
                    if (!DRStringIsEmpty(messageChooseGoodModel.group.goods.description_)) {
                        [goodInfo setObject:messageChooseGoodModel.group.goods.description_ forKey:@"description"];
                    }
                }else
                {
                    if (!DRStringIsEmpty(messageChooseGoodModel.goodModel.description_)) {
                        [goodInfo setObject:messageChooseGoodModel.goodModel.description_ forKey:@"description"];
                    }
                }
                
                // 商品价格
                if (!DRStringIsEmpty(cell.goodPriceLabel.text)) {
                    [goodInfo setObject:cell.goodPriceLabel.text forKey:@"price"];
                }
                
                // 推广图片
                if (messageChooseGoodModel.type == 2) {//团购
                    if (!DRStringIsEmpty(messageChooseGoodModel.group.goods.spreadPics)) {
                        [goodInfo setObject:messageChooseGoodModel.group.goods.spreadPics forKey:@"spreadPics"];
                    }
                }else
                {
                    if (!DRStringIsEmpty(messageChooseGoodModel.goodModel.spreadPics)) {
                        [goodInfo setObject:messageChooseGoodModel.goodModel.spreadPics forKey:@"spreadPics"];
                    }
                }
                
                if (messageChooseGoodModel.type == 2) {//团购
                    [goodInfo setObject:@"2" forKey:@"sellType"];
                    if (!DRStringIsEmpty(messageChooseGoodModel.group.id)) {
                        [goodInfo setObject:messageChooseGoodModel.group.id forKey:@"grouponId"];
                    }
                }else
                {
                    [goodInfo setObject:@"1" forKey:@"sellType"];
                    if (!DRStringIsEmpty(messageChooseGoodModel.goodModel.id)) {
                        [goodInfo setObject:messageChooseGoodModel.goodModel.id forKey:@"goodsId"];
                    }
                }
                [goodArray addObject:goodInfo];
            }
        }
    }
    if (_delegate && [_delegate respondsToSelector:@selector(chooseGoodWithArray:)]) {
        [self.navigationController popViewControllerAnimated:YES];
        [_delegate chooseGoodWithArray:goodArray];
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * dataArray = self.dataArray[self.currentIndex];
    [tableView showNoDataWithTitle:@"" description:@"暂无数据" rowCount:dataArray.count];
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRMessageChooseGoodTableViewCell * cell = [DRMessageChooseGoodTableViewCell cellWithTableView:tableView];
    NSArray * dataArray = self.dataArray[self.currentIndex];
    cell.model = dataArray[indexPath.row];
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

#pragma mark - 协议
- (void)upDataGoodTableViewCell:(DRMessageChooseGoodTableViewCell *)cell isSelected:(BOOL)isSelected
{
    UITableView * tableView = self.views[self.currentIndex];
    NSIndexPath * indexPath = [tableView indexPathForCell:cell];
    NSArray * dataArray = self.dataArray[self.currentIndex];
    DRMessageChooseGoodModel * messageChooseGoodModel = dataArray[indexPath.row];
    messageChooseGoodModel.selected = isSelected;
    [self setNumber];
    
    //刷新数据
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - 初始化
- (NSMutableArray *)headerViews
{
    if(_headerViews == nil)
    {
        _headerViews = [NSMutableArray array];
    }
    return _headerViews;
}
- (NSMutableArray *)footerViews
{
    if(_footerViews == nil)
    {
        _footerViews = [NSMutableArray array];
    }
    return _footerViews;
}
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
        for (int i = 0; i < 4; i++) {
            NSMutableArray * array = [NSMutableArray array];
            [_dataArray addObject:array];
        }
    }
    return _dataArray;
}

@end
