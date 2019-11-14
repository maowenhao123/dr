//
//  DRShoppingViewController.m
//  dr
//
//  Created by apple on 17/1/14.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShoppingCarViewController.h"
#import "DRShopDetailViewController.h"
#import "DRGoodDetailViewController.h"
#import "DRPaySuccessViewController.h"
#import "DRSubmitOrderViewController.h"
#import "DRLoginViewController.h"
#import "DRShoppingCarBottomView.h"
#import "DRShoppingCarNoDataTableViewCell.h"
#import "DRShoppingCarShopTableViewCell.h"
#import "DRShoppingCarTableViewCell.h"
#import "DRShoppingCarRecommendTableViewCell.h"
#import "DRShoppingCarCache.h"

@interface DRShoppingCarViewController ()<UITableViewDelegate, UITableViewDataSource, ShoppingCarShopTableViewCellDelegate, ShoppingCarTableViewCellDelegate, ShoppingCarBottomViewDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) MJRefreshGifHeader *headerView;
@property (nonatomic, weak) MJRefreshBackGifFooter *footerView;
@property (nonatomic, weak) DRShoppingCarBottomView * shoppingBottomView;
@property (nonatomic, assign) int pageIndex;//页数
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *goodArray;
@property (nonatomic, assign) BOOL isEdit;//是否是编辑状态

@end

@implementation DRShoppingCarViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"购物车";
    self.pageIndex = 1;
    [self setupChilds];
    [self getGoodData];
    
    //接收去购物车的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upData) name:@"upSataShoppingCar" object:nil];
}

- (void)getGoodData
{
    NSDictionary *bodyDic = @{
                               @"pageIndex": @(self.pageIndex),
                               @"pageSize": DRPageSize,
                               };
    NSDictionary *headDic = @{
                              @"cmd":@"B07",
                              };
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            NSArray * dataArray = [DRGoodModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            for (DRGoodModel * goodModel in dataArray) {
                NSInteger index = [dataArray indexOfObject:goodModel];
                goodModel.specifications = [DRGoodSpecificationModel mj_objectArrayWithKeyValuesArray:json[@"list"][index][@"specifications"]];
            }
            if (dataArray.count == 0) {
                [self.footerView endRefreshingWithNoMoreData];
            }else
            {
                [self.footerView endRefreshing];
            }
            [self.goodArray addObjectsFromArray:dataArray];
            [self.tableView reloadData];
        }else
        {
            ShowErrorView
            [self.footerView endRefreshing];
        }
        [self.headerView endRefreshing];
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        [self.headerView endRefreshing];
        [self.footerView endRefreshing];
    }];
}

- (void)upData
{
    self.dataArray = [NSMutableArray arrayWithArray:[DRShoppingCarCache getShoppingCarGoods]];
    self.navigationItem.rightBarButtonItem.title = @"编辑";
    self.isEdit = NO;
    [self.shoppingBottomView updataWithData:self.dataArray isEdit:self.isEdit];
    [self.tableView reloadData];
    [self upDataAllSelectedButtonStatus];
}

- (void)setupChilds
{
    self.dataArray = [NSMutableArray arrayWithArray:[DRShoppingCarCache getShoppingCarGoods]];
    //编辑按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editDidClick:)];
    
    //tableview
    CGFloat bottomViewH = 40;
    if (iPhoneXR || iPhoneXSMax) {
        bottomViewH = 45;
    }

    CGFloat tableViewH = screenHeight - statusBarH - navBarH - tabBarH - bottomViewH;
    if (self.navigationController.viewControllers.count > 1) {
        tableViewH = screenHeight - statusBarH - navBarH - bottomViewH - [DRTool getSafeAreaBottom];
    }
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, tableViewH)];
    self.tableView = tableView;
    tableView.backgroundColor = DRBackgroundColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    [self.view addSubview:tableView];
    
    //初始化头部刷新控件
    MJRefreshGifHeader *headerView = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshViewBeginRefreshing)];
    self.headerView = headerView;
    [DRTool setRefreshHeaderData:headerView];
    tableView.mj_header = headerView;
    
    //初始化底部刷新控件
    MJRefreshBackGifFooter *footerView = [MJRefreshBackGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshViewBeginRefreshing)];
    self.footerView = footerView;
    [DRTool setRefreshFooterData:footerView];
    tableView.mj_footer = footerView;
    
    //ShoppingBottomView
    DRShoppingCarBottomView * shoppingCarBottomView = [[DRShoppingCarBottomView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(tableView.frame), screenWidth, bottomViewH)];
    self.shoppingBottomView = shoppingCarBottomView;
    shoppingCarBottomView.delegate = self;
    [self.view addSubview:shoppingCarBottomView];
    [self.shoppingBottomView updataWithData:self.dataArray isEdit:self.isEdit];
    
    [self upDataAllSelectedButtonStatus];
}

- (void)editDidClick:(UIBarButtonItem *)barButtonItem
{
    if ([barButtonItem.title isEqualToString:@"编辑"]) {
        self.navigationItem.rightBarButtonItem.title = @"完成";
        self.isEdit = YES;
    }else
    {
        self.navigationItem.rightBarButtonItem.title = @"编辑";
        self.isEdit = NO;
    }
    [self.shoppingBottomView updataWithData:self.dataArray isEdit:self.isEdit];
    [self.tableView reloadData];
}

#pragma mark - 刷新
- (void)headerRefreshViewBeginRefreshing
{
    self.pageIndex = 1;
    [self.goodArray removeAllObjects];
    [self getGoodData];
}
- (void)footerRefreshViewBeginRefreshing
{
    self.pageIndex++;
    [self getGoodData];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.dataArray.count == 0) {
        return 2;
    }
    return self.dataArray.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataArray.count == 0 && section == 0) {
        return 1;
    }
    if (section < self.dataArray.count) {
        DRShoppingCarShopModel * carShopModel = self.dataArray[section];
        return carShopModel.goodArr.count + 1;
    }else
    {
        if (self.goodArray.count % 2 == 0) {
            return self.goodArray.count / 2;
        }else
        {
            return 1 + self.goodArray.count / 2;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataArray.count == 0 && indexPath.section == 0) {
        DRShoppingCarNoDataTableViewCell * cell = [DRShoppingCarNoDataTableViewCell cellWithTableView:tableView];
        return cell;
    }
    if (indexPath.section < self.dataArray.count) {
        if (indexPath.row == 0) {
            DRShoppingCarShopTableViewCell * cell = [DRShoppingCarShopTableViewCell cellWithTableView:tableView];
            DRShoppingCarShopModel * carShopModel = self.dataArray[indexPath.section];
            cell.model = carShopModel;
            cell.delegate = self;
            return cell;
        }else
        {
            DRShoppingCarTableViewCell * cell = [DRShoppingCarTableViewCell cellWithTableView:tableView];
            DRShoppingCarShopModel * carShopModel = self.dataArray[indexPath.section];
            DRShoppingCarGoodModel * carGoodModel = carShopModel.goodArr[indexPath.row - 1];
            cell.model = carGoodModel;
            cell.delegate = self;
            cell.tag = indexPath.section * 1000 + indexPath.row;
            return cell;
        }
    }else
    {
        DRShoppingCarRecommendTableViewCell * cell = [DRShoppingCarRecommendTableViewCell cellWithTableView:tableView];
        cell.leftModel = self.goodArray[indexPath.row * 2];
        if (1 + indexPath.row * 2 < self.goodArray.count) {
            cell.rightModel = self.goodArray[1 + indexPath.row * 2];
        }else
        {
            cell.rightModel = nil;
        }
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ((section == self.dataArray.count && section != 0) || (self.dataArray.count == 0 && section == 1)) {
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 50)];
        titleLabel.backgroundColor = DRBackgroundColor;
        titleLabel.text = @"- 猜你喜欢 -";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:DRGetFontSize(35)];
        return titleLabel;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataArray.count == 0 && indexPath.section == 0) {
        return 300;
    }
    if (indexPath.section < self.dataArray.count) {
        if (indexPath.row == 0) {
            return 49;
        }
        return 100;
    }
    CGFloat goodItemViewW = (screenWidth - 3 * DRMargin) / 2;
    return goodItemViewW + 75 + DRMargin;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ((section == self.dataArray.count && section != 0) || (self.dataArray.count == 0 && section == 1)) {
        return 50;
    }
    return 0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 || indexPath.section == self.dataArray.count) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //删除数据
        DRShoppingCarShopModel * carShopModel = self.dataArray[indexPath.section];
        DRShoppingCarGoodModel * carGoodModel = carShopModel.goodArr[indexPath.row - 1];
        [DRShoppingCarCache deleteGoodInShoppingCarWithCarGoodModel:carGoodModel];
        
        //刷新数据
        self.dataArray = [NSMutableArray arrayWithArray:[DRShoppingCarCache getShoppingCarGoods]];

        if (carShopModel.goodArr.count == 1) {
             [self.tableView reloadData];
        }else
        {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        [self upDataAllSelectedButtonStatus];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < self.dataArray.count) {
        if (self.dataArray.count == 0 && indexPath.section == 0) {
            return;
        }
        if (indexPath.row == 0) {
            DRShoppingCarShopModel * carShopModel = self.dataArray[indexPath.section];
            
            DRShopDetailViewController * shopVC = [[DRShopDetailViewController alloc] init];
            shopVC.shopId = carShopModel.shopModel.id;
            [self.navigationController pushViewController:shopVC animated:YES];
        }else
        {
            DRShoppingCarShopModel * carShopModel = self.dataArray[indexPath.section];
            DRShoppingCarGoodModel * carGoodModel = carShopModel.goodArr[indexPath.row - 1];
            
            DRGoodDetailViewController * goodVC = [[DRGoodDetailViewController alloc] init];
            goodVC.goodId = carGoodModel.goodModel.id;
            [self.navigationController pushViewController:goodVC animated:YES];
        }
    }
}

#pragma mark - 协议
- (void)upDataShopTableViewCell:(DRShoppingCarShopTableViewCell *)cell isSelected:(BOOL)isSelected
{
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    DRShoppingCarShopModel * carShopModel = self.dataArray[indexPath.section];
    carShopModel.selected = isSelected;
    for (DRShoppingCarGoodModel * carGoodModel in carShopModel.goodArr) {
        carGoodModel.selected = carShopModel.selected;
    }
    NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:indexPath.section];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    [self.shoppingBottomView updataWithData:self.dataArray isEdit:self.isEdit];
    [self upDataAllSelectedButtonStatus];
}

- (void)upDataGoodTableViewCell:(DRShoppingCarTableViewCell *)cell isSelected:(BOOL)isSelected currentNumber:(NSString *)number
{
    self.dataArray = [NSMutableArray arrayWithArray:[DRShoppingCarCache getShoppingCarGoods]];
    
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath == nil) {
        indexPath = [NSIndexPath indexPathForRow:cell.tag % 1000 inSection:cell.tag / 1000];
    }
    
    DRShoppingCarShopModel * carShopModel = self.dataArray[indexPath.section];
    DRShoppingCarGoodModel * carGoodModel = carShopModel.goodArr[indexPath.row - 1];
    carGoodModel.selected = isSelected;
    carGoodModel.count = [number intValue];
    BOOL allSelected = YES;
    for (DRShoppingCarGoodModel * carGoodModel in carShopModel.goodArr) {
        if (!carGoodModel.isSelected) {
            allSelected = NO;
            break;
        }
    }
    carShopModel.selected = allSelected;
    
    //刷新数据
    NSMutableArray * indexPaths = [NSMutableArray array];
    [indexPaths addObject:indexPath];
    [indexPaths addObject:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.shoppingBottomView updataWithData:self.dataArray isEdit:self.isEdit];
    [self upDataAllSelectedButtonStatus];
}

- (void)upDataAllSelectedButtonStatus
{
    BOOL isAllSelected = YES;
    for (DRShoppingCarShopModel * carShopModel in self.dataArray) {
        if (!carShopModel.isSelected) {
            isAllSelected = NO;
        }
        for (DRShoppingCarGoodModel * carGoodModel in carShopModel.goodArr) {
            if (!carGoodModel.isSelected) {
                isAllSelected = NO;
            }
        }
    }
    isAllSelected = self.dataArray.count > 0 ? isAllSelected : NO;
    self.shoppingBottomView.allSelectedButton.selected = isAllSelected;
}

- (void)bottomView:(DRShoppingCarBottomView *)bottomView confirmButtonDidClick:(UIButton *)button
{
//    DRPaySuccessViewController * submitOrderVC1 = [[DRPaySuccessViewController alloc] init];
//    submitOrderVC1.orderId = @"191106134300010049";
//    [self.navigationController pushViewController:submitOrderVC1 animated:YES];
//    return;
//    
    if((!UserId || !Token))//未登录
    {
        DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
        [self presentViewController:loginVC animated:YES completion:nil];
        return;
    }

    NSMutableArray * dataArray = [NSMutableArray array];
    for (DRShoppingCarShopModel * carShopModel in self.dataArray) {
        BOOL haveSelectedGood = NO;
        for (DRShoppingCarGoodModel * carGoodModel in carShopModel.goodArr) {
            if (carGoodModel.selected) {
                haveSelectedGood = YES;
            }
        }
        if (haveSelectedGood) {
            DRShoppingCarShopModel * carShopModel_ = [[DRShoppingCarShopModel alloc] init];
            carShopModel_.shopModel = carShopModel.shopModel;
            for (DRShoppingCarGoodModel * carGoodModel in carShopModel.goodArr) {
                if (carGoodModel.selected) {
                    [carShopModel_.goodDic setValue:carGoodModel forKey:carGoodModel.carGoodId];
                    [carShopModel_.goodArr addObject:carGoodModel];
                }
            }
            [dataArray addObject:carShopModel_];
        }
    }
    if (dataArray.count == 0) {
        [MBProgressHUD showError:@"您还未选择商品"];
        return;
    }
    DRSubmitOrderViewController * submitOrderVC = [[DRSubmitOrderViewController alloc] init];
    submitOrderVC.dataArray = dataArray;
    [self.navigationController pushViewController:submitOrderVC animated:YES];
}

- (void)bottomView:(DRShoppingCarBottomView *)bottomView deleteButtonDidClick:(UIButton *)button
{
    for (DRShoppingCarShopModel * carShopModel in self.dataArray) {
        for (DRShoppingCarGoodModel * carGoodModel in carShopModel.goodArr) {
            if (carGoodModel.selected) {
                [DRShoppingCarCache deleteGoodInShoppingCarWithCarGoodModel:carGoodModel];
            }
        }
    }
    [self upData];
    [self upDataAllSelectedButtonStatus];
}

- (void)bottomView:(DRShoppingCarBottomView *)bottomView allSelectedButtonDidClick:(UIButton *)button
{
    BOOL isSelected = button.selected;
    for (DRShoppingCarShopModel * carShopModel in self.dataArray) {
        carShopModel.selected = isSelected;
        for (DRShoppingCarGoodModel * carGoodModel in carShopModel.goodArr) {
            carGoodModel.selected = isSelected;
        }
    }
    [self.tableView reloadData];
    
    [self.shoppingBottomView updataWithData:self.dataArray isEdit:self.isEdit];
}
#pragma mark - 初始化
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray *)goodArray
{
    if (!_goodArray) {
        _goodArray = [NSMutableArray array];
    }
    return _goodArray;
}


@end
