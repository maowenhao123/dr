//
//  DRShipmentDetailViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/4/6.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShipmentDetailViewController.h"
#import "DRChatViewController.h"
#import "DRGoodDetailViewController.h"
#import "DRShipmentConfirmViewController.h"
#import "DRShipmentGrouponConfirmViewController.h"
#import "DRSellerLogisticsViewController.h"
#import "DRShipmentGoodTableViewCell.h"
#import "DRShipmentAddressTableViewCell.h"
#import "DRShipmentUserInfoTableViewCell.h"
#import "DRShipmentGrouponAddressTableViewCell.h"
#import "DRShipmentLogisticsAddressTableViewCell.h"
#import "DRShipmentGrouponLogisticsAddressTableViewCell.h"
#import "DRChangeGrouponNumberView.h"
#import "DRDateTool.h"
#import "DRIMTool.h"

@interface DRShipmentDetailViewController ()<UITableViewDataSource, UITableViewDelegate, ShipmentLogisticsAddressTableViewCellDelegate,ShipmentGrouponLogisticsAddressTableViewCellDelegate, ChangeGrouponNumberViewDelegate>

@property (nonatomic,weak) UILabel * statusLabel;
@property (nonatomic,weak) UILabel * orderNumberLabel;
@property (nonatomic,weak) UILabel * orderTimeLabel;
@property (nonatomic,weak) UILabel * freightLabel;
@property (nonatomic,weak) UILabel * priceCountLabel;
@property (nonatomic,weak) UILabel * totalMoneyLabel;
@property (nonatomic,weak) UITableView *tableView;
@property (nonatomic, weak) MJRefreshGifHeader *header;
@property (nonatomic, strong) NSMutableArray *buttonArray;
@property (nonatomic,strong) DRShipmentModel *shipmentModel;

@end

@implementation DRShipmentDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"发货清单";
    [self setupChilds];
    [self getData];
}

#pragma mark - 请求数据
- (void)getData
{
    if (DRStringIsEmpty(self.orderId)) {
        return;
    }
    NSDictionary *bodyDic = @{
                              @"id":self.orderId
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"S21",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            DRShipmentModel *shipmentModel = [DRShipmentModel mj_objectWithKeyValues:json[@"detail"]];
            shipmentModel.deliveryList = [DRDeliveryAddressModel mj_objectArrayWithKeyValuesArray:json[@"detail"][@"deliveryList"]];
            shipmentModel.order.detail = [DROrderItemDetailModel mj_objectArrayWithKeyValuesArray: json[@"detail"][@"order"][@"detail"]];
            shipmentModel.groupItemDetailList = [DRShipmentGroupon mj_objectArrayWithKeyValuesArray: json[@"detail"][@"groupItemDetailList"]];
            for (DRDeliveryAddressModel * model in shipmentModel.deliveryList) {
                model.mailType = shipmentModel.mailType;
                model.freight = shipmentModel.freight;
                model.remarks = shipmentModel.order.remarks;
                model.status = shipmentModel.status;
            }
            shipmentModel.orderType = self.orderType;
            if (self.isWaitPending && [shipmentModel.status intValue] == 0) {
                shipmentModel.status = @(5);
            }
            self.shipmentModel = shipmentModel;
        }else
        {
            ShowErrorView
        }
        if ([self.header isRefreshing]) {
            [self.header endRefreshing];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        [MBProgressHUD hideHUDForView:self.view];
        if ([self.header isRefreshing]) {
            [self.header endRefreshing];
        }
    }];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH - 49 - [DRTool getSafeAreaBottom]) style:UITableViewStyleGrouped];
    self.tableView = tableView;
    tableView.backgroundColor = DRBackgroundColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    [self.view addSubview:tableView];
    
    //初始化头部刷新控件
    MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshViewBeginRefreshing)];
    self.header = header;
    [DRTool setRefreshHeaderData:header];
    tableView.mj_header = header;
    
    //headerView
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 67)];
    headerView.backgroundColor = DRDefaultColor;
    
    UILabel * statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 0, screenWidth - 2 * DRMargin, headerView.height)];
    self.statusLabel = statusLabel;
    statusLabel.textColor = [UIColor whiteColor];
    statusLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [headerView addSubview:statusLabel];

    tableView.tableHeaderView = headerView;
    
    //headerView
    UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 9 + 60 + 9 + 80)];
    footerView.backgroundColor = [UIColor whiteColor];
    
    NSArray * footerTitles = @[@"商品总额", @"运费", @"小记"];
    for (int i = 0; i < 7; i++) {
        if (i == 0 || i == 3) {
            UIView * lineView = [[UIView alloc] init];
            if (i == 0) {
                lineView.frame = CGRectMake(0, 0, screenWidth, 9);
            }else if (i == 3)
            {
                lineView.frame = CGRectMake(0, 9 + 60, screenWidth, 9);
            }
            lineView.backgroundColor = DRBackgroundColor;
            [footerView addSubview:lineView];
        }else
        {
            UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 9 + 10, screenWidth - 2 * DRMargin, 20)];
            if (i > 0 && i < 3) {
                label.frame = CGRectMake(DRMargin, 9 + 10 + 20 * (i - 1), screenWidth - 2 * DRMargin, 20);
            }else if (i > 3 && i < 7)
            {
                UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 9 + 60 + 9 + 10 + 20 * (i - 4), 150, 20)];
                titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
                titleLabel.textColor = DRBlackTextColor;
                titleLabel.text = footerTitles[i - 4];
                [footerView addSubview:titleLabel];
                
                label.frame = CGRectMake(screenWidth - DRMargin - 150, 9 + 60 + 9 + 10 + 20 * (i - 4), 150, 20);
                label.textAlignment = NSTextAlignmentRight;
            }
            if (i == 1) {
                self.orderNumberLabel = label;
            }else if (i == 2)
            {
                self.orderTimeLabel = label;
            }else if (i == 4)
            {
                self.priceCountLabel = label;
            }else if (i == 5)
            {
                self.freightLabel = label;
            }else if (i == 6)
            {
                self.totalMoneyLabel = label;
            }
            label.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
            label.textColor = DRBlackTextColor;
            [footerView addSubview:label];
        }
    }

    tableView.tableFooterView = footerView;
    
    //底部视图
    CGFloat bottomViewH = 49 + [DRTool getSafeAreaBottom];;
    CGFloat bottomViewY = screenHeight - statusBarH - navBarH - bottomViewH;
    UIView * bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, bottomViewY, screenWidth, bottomViewH)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    //阴影
    bottomView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    bottomView.layer.shadowOffset = CGSizeMake(0, -0.2);
    bottomView.layer.shadowOpacity = 0.5;
    
    CGFloat buttonW = 90;
    CGFloat buttonH = 31;
    CGFloat buttonY = (49 - buttonH) / 2;
    for (int i = 0; i < 3; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(screenWidth - (buttonW + DRMargin) * (i + 1), buttonY, buttonW, buttonH);
        button.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = button.height / 2;
        button.layer.borderWidth = 1;
        [button addTarget:self action:@selector(bottomButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:button];
        [self.buttonArray addObject:button];
    }
}

- (void)bottomButtonDidClick:(UIButton *)button
{
    if ([button.currentTitle isEqualToString:@"联系买家"]) {
        [self chatWithBuyer];
    }else if ([button.currentTitle isEqualToString:@"发货"])
    {
        if ([_shipmentModel.orderType intValue] == 2) {//团购
            DRShipmentGrouponConfirmViewController * shipmentConfirmVC = [[DRShipmentGrouponConfirmViewController alloc] init];
            shipmentConfirmVC.deliveryList = self.shipmentModel.deliveryList;
            shipmentConfirmVC.orderId = self.orderId;
            [self.navigationController pushViewController:shipmentConfirmVC animated:YES];
        }else
        {
            DRShipmentConfirmViewController * shipmentConfirmVC = [[DRShipmentConfirmViewController alloc] init];
            shipmentConfirmVC.orderId = self.orderId;
            [self.navigationController pushViewController:shipmentConfirmVC animated:YES];
        }
    }else if ([button.currentTitle isEqualToString:@"无货"])
    {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"点击“无货”，会造成不必要的订单流失，建议您联系买家调换同等价位商品。" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * alertAction1 = [UIAlertAction actionWithTitle:@"好，去联系买家" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self chatWithBuyer];
        }];
        UIAlertAction * alertAction2 = [UIAlertAction actionWithTitle:@"继续无货撤单操作" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSDictionary *bodyDic = @{
                                      @"orderId":self.orderId,
                                      };
            NSDictionary *headDic = @{
                                      @"digest":[DRTool getDigestByBodyDic:bodyDic],
                                      @"cmd":@"S53",
                                      @"userId":UserId,
                                      };
            [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
                DRLog(@"%@",json);
                if (SUCCESS) {
                    [self headerRefreshViewBeginRefreshing];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NoGoodsNote" object:nil];
                }else
                {
                    ShowErrorView
                }
            } failure:^(NSError *error) {
                DRLog(@"error:%@",error);
            }];
        }];
        [alertController addAction:alertAction1];
        [alertController addAction:alertAction2];
        [self presentViewController:alertController animated:YES completion:nil];
    }else if ([button.currentTitle isEqualToString:@"修改成团数"])
    {
        DRChangeGrouponNumberView * changeGrouponNumberView = [[DRChangeGrouponNumberView alloc] initWithFrame:self.tabBarController.view.bounds];
        changeGrouponNumberView.delegate = self;
        [self.tabBarController.view addSubview:changeGrouponNumberView];
    }
}

- (void)chatWithBuyer
{
    if (DRStringIsEmpty(self.shipmentModel.user.id)) {
        [MBProgressHUD showError:@"未获取到买家信息"];
        return;
    }
    
    DRChatViewController *chatVC = [[DRChatViewController alloc] initWithConversationChatter:self.shipmentModel.user.id conversationType:EMConversationTypeChat];
    chatVC.title = self.shipmentModel.user.nickName;
    NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@", baseUrl, self.shipmentModel.user.headImg];
    [DRIMTool saveUserProfileWithUsername:self.shipmentModel.user.id forNickName:self.shipmentModel.user.nickName avatarURLPath:imageUrlStr];
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (void)changeGrouponNumberView:(DRChangeGrouponNumberView *)changeGrouponNumberView number:(int)number
{
    NSDictionary *bodyDic = @{
                              @"orderId":self.orderId,
                              @"count":@(number),
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"S60",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            [self headerRefreshViewBeginRefreshing];
            
            BOOL enoughNumber = NO;
            if (number <= [self.shipmentModel.payCount intValue]) {
                enoughNumber = YES;
            }
            if (!enoughNumber) {
                return;
            }
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"团购订单已成单，去发货？" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * alertAction1 = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                NSDictionary * objectDic = @{
                                             @"enoughNumber":@(enoughNumber),
                                             @"goSendGood":@(NO)
                                             };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeGrouponNumberNote" object:objectDic];
                [self.navigationController popViewControllerAnimated:YES];
            }];
            UIAlertAction * alertAction2 = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSDictionary * objectDic = @{
                                             @"enoughNumber":@(enoughNumber),
                                             @"goSendGood":@(YES)
                                             };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeGrouponNumberNote" object:objectDic];
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [alertController addAction:alertAction1];
            [alertController addAction:alertAction2];
            [self presentViewController:alertController animated:YES completion:nil];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

//刷新
- (void)headerRefreshViewBeginRefreshing
{
    //请求数据
    [self getData];
}

//设置数据
- (void)setShipmentModel:(DRShipmentModel *)shipmentModel
{
    _shipmentModel = shipmentModel;
    
    //设置数据
    int statusInt = [_shipmentModel.status intValue];
    if (statusInt == 30) {
        self.statusLabel.text = @"已完成";
    }else if (statusInt == 0) {
        self.statusLabel.text = @"待付款";
    }else if (statusInt == 5) {
        self.statusLabel.text = @"待成团";
    }else if (statusInt == 10) {
        self.statusLabel.text = @"待发货";
    }else if (statusInt == 20) {
        self.statusLabel.text = @"已发货";
    }else if (statusInt == -1) {
        self.statusLabel.text = @"已取消";
    }else if (statusInt == -5) {
        self.statusLabel.text = @"拼单失败撤单";
    }else if (statusInt == -6) {
        self.statusLabel.text = @"无货撤单";
    }
    
    NSArray * buttonTitles = @[@"联系买家"];
    if (statusInt == 10) {//待发货
        buttonTitles = @[@"无货", @"联系买家", @"发货"];
    }else if (statusInt == 5)//待成团
    {
        buttonTitles = @[@"修改成团数"];
    }
    for (int i = 0; i < 3; i++) {
        UIButton * button = self.buttonArray[i];
        button.hidden = YES;
        if (i < buttonTitles.count) {
            button.hidden = NO;
            [button setTitle:buttonTitles[i] forState:UIControlStateNormal];
            [self setButtonByTitle:buttonTitles[i] button:button];
        }
    }
    
    self.orderNumberLabel.attributedText = [self getAttributedStringByString:[NSString stringWithFormat:@"订单编号：%@", _shipmentModel.orderId]];
    if ([_shipmentModel.status intValue] == 20) {//已发货
        self.orderTimeLabel.attributedText = [self getAttributedStringByString:[NSString stringWithFormat:@"发货时间：%@", [DRDateTool getTimeByTimestamp:_shipmentModel.orderTime format:@"yyyy-MM-dd HH:mm:ss"]]];
    }else
    {
        if ([_shipmentModel.orderType intValue] == 2) {//团购
            self.orderTimeLabel.attributedText = [self getAttributedStringByString:[NSString stringWithFormat:@"完成时间：%@", [DRDateTool getTimeByTimestamp:_shipmentModel.orderTime format:@"yyyy-MM-dd HH:mm:ss"]]];
        }else
        {
            self.orderTimeLabel.attributedText = [self getAttributedStringByString:[NSString stringWithFormat:@"下单时间：%@", [DRDateTool getTimeByTimestamp:_shipmentModel.orderTime format:@"yyyy-MM-dd HH:mm:ss"]]];
        }
    }
    self.priceCountLabel.text = [NSString stringWithFormat:@"%@元", [DRTool formatFloat:[_shipmentModel.priceCount doubleValue] / 100]];
    self.freightLabel.text = [NSString stringWithFormat:@"%@元", [DRTool formatFloat:[_shipmentModel.freight doubleValue] / 100]];
    self.totalMoneyLabel.text = [NSString stringWithFormat:@"%@元", [DRTool formatFloat:[_shipmentModel.freight doubleValue] / 100 + [_shipmentModel.priceCount doubleValue] / 100]];

    //frame
    [self.tableView reloadData];
}

- (void)setButtonByTitle:(NSString *)title button:(UIButton *)button
{
    if ([title isEqualToString:@"发货"]) {
        [button setTitleColor:DRDefaultColor forState:UIControlStateNormal];
        button.layer.borderColor = DRDefaultColor.CGColor;
    }else
    {
        [button setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
        button.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
}

- (NSAttributedString *)getAttributedStringByString:(NSString *)string
{
    NSMutableAttributedString * attStr = [[NSMutableAttributedString alloc] initWithString:string];
    [attStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(0, 5)];
    return attStr;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int statusInt = [self.shipmentModel.status intValue];
    if (statusInt == 0 || statusInt == 5) {//待付款 待成团
        if ([self.shipmentModel.orderType intValue] == 2) {//团购
            if (section == 0) {
                return self.shipmentModel.order.detail.count;
            }else
            {
                return self.shipmentModel.groupItemDetailList.count;
            }
        }else
        {
            if (section == 0) {
                return 1;
            }else
            {
                return self.shipmentModel.order.detail.count;
            }
        }
    }else if (statusInt == 10) {//待发货
        if ([self.shipmentModel.orderType intValue] == 2) {//团购
            if (section == 0) {
                return self.shipmentModel.order.detail.count;
            }else
            {
                return self.shipmentModel.deliveryList.count;
            }
        }else
        {
            if (section == 0) {
                return self.shipmentModel.deliveryList.count;
            }else
            {
                return self.shipmentModel.order.detail.count;
            }
        }
    }else if (statusInt == 20 || statusInt == 30) {//已发货 已收货
        if ([self.shipmentModel.orderType intValue] == 2) {//团购
            if (section == 0) {
                return self.shipmentModel.order.detail.count;
            }else
            {
                return self.shipmentModel.deliveryList.count;
            }
        }else
        {
            if (section == 0) {
                return self.shipmentModel.deliveryList.count;
            }else
            {
                return self.shipmentModel.order.detail.count;
            }
        }
    }else if (statusInt == -1 || statusInt == -5 || statusInt == -6) {//失败
        if ([self.shipmentModel.orderType intValue] == 2) {//团购
            if (section == 0) {
                return self.shipmentModel.order.detail.count;
            }else
            {
                return self.shipmentModel.deliveryList.count;
            }
        }else
        {
            if (section == 0) {
                return self.shipmentModel.deliveryList.count;
            }else
            {
                return self.shipmentModel.order.detail.count;
            }
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int statusInt = [self.shipmentModel.status intValue];
    if (statusInt == 0 || statusInt == 5) {
        if ([self.shipmentModel.orderType intValue] == 2) {//团购
            if (indexPath.section == 0) {
                DRShipmentGoodTableViewCell *cell = [DRShipmentGoodTableViewCell cellWithTableView:tableView];
                DROrderItemDetailModel * detail = self.shipmentModel.order.detail[indexPath.row];
                cell.successCount = self.shipmentModel.successCount;
                cell.payCount = self.shipmentModel.payCount;
                cell.orderType = self.shipmentModel.orderType;
                cell.orderItemDetailModel = detail;
                return cell;
            }else
            {
                DRShipmentUserInfoTableViewCell *cell = [DRShipmentUserInfoTableViewCell cellWithTableView:tableView];
                DRShipmentGroupon *shipmentGroupon = self.shipmentModel.groupItemDetailList[indexPath.row];
                if (shipmentGroupon == self.shipmentModel.groupItemDetailList.lastObject && statusInt == 5) {
                    cell.promptView.hidden = NO;
                }else
                {
                    cell.promptView.hidden = YES;
                }
                cell.shipmentGroupon = shipmentGroupon;
                return cell;
            }
        }else
        {
            if (indexPath.section == 0) {
                DRShipmentUserInfoTableViewCell *cell = [DRShipmentUserInfoTableViewCell cellWithTableView:tableView];
                DRShipmentGroupon * shipmentGroupon = [[DRShipmentGroupon alloc] init];
                shipmentGroupon.user = self.shipmentModel.user;
                shipmentGroupon.status = self.shipmentModel.status;
                cell.shipmentGroupon = shipmentGroupon;
                cell.promptView.hidden = YES;
                return cell;
            }else
            {
                DRShipmentGoodTableViewCell *cell = [DRShipmentGoodTableViewCell cellWithTableView:tableView];
                DROrderItemDetailModel * detail = self.shipmentModel.order.detail[indexPath.row];
                cell.orderType = self.shipmentModel.orderType;
                cell.orderItemDetailModel = detail;
                return cell;
            }
        }
    }else if (statusInt == 10) {//待发货
        if ([self.shipmentModel.orderType intValue] == 2) {//团购
            if (indexPath.section == 0) {
                DRShipmentGoodTableViewCell *cell = [DRShipmentGoodTableViewCell cellWithTableView:tableView];
                DROrderItemDetailModel * detail = self.shipmentModel.order.detail[indexPath.row];
                cell.successCount = self.shipmentModel.successCount;
                cell.payCount = self.shipmentModel.payCount;
                cell.orderType = self.shipmentModel.orderType;
                cell.orderItemDetailModel = detail;
                return cell;
            }else
            {
                DRShipmentGrouponAddressTableViewCell *cell = [DRShipmentGrouponAddressTableViewCell cellWithTableView:tableView];
                DRDeliveryAddressModel * deliveryModel = self.shipmentModel.deliveryList[indexPath.row];
                cell.deliveryModel = deliveryModel;
                cell.numberButton.hidden = NO;
                return cell;
            }
        }else
        {
            if (indexPath.section == 0) {
                DRShipmentAddressTableViewCell *cell = [DRShipmentAddressTableViewCell cellWithTableView:tableView];
                DRDeliveryAddressModel * deliveryModel = self.shipmentModel.deliveryList[indexPath.row];
                cell.deliveryModel = deliveryModel;
                cell.numberButton.hidden = NO;
                return cell;
            }else
            {
                DRShipmentGoodTableViewCell *cell = [DRShipmentGoodTableViewCell cellWithTableView:tableView];
                DROrderItemDetailModel * detail = self.shipmentModel.order.detail[indexPath.row];
                cell.orderType = self.shipmentModel.orderType;
                cell.orderItemDetailModel = detail;
                return cell;
            }
        }
    }else if (statusInt == 20 || statusInt == 30) {//已发货
        if ([self.shipmentModel.orderType intValue] == 2) {//团购
            if (indexPath.section == 0) {
                DRShipmentGoodTableViewCell *cell = [DRShipmentGoodTableViewCell cellWithTableView:tableView];
                DROrderItemDetailModel * detail = self.shipmentModel.order.detail[indexPath.row];
                cell.successCount = self.shipmentModel.successCount;
                cell.payCount = self.shipmentModel.payCount;
                cell.orderType = self.shipmentModel.orderType;
                cell.orderItemDetailModel = detail;
                return cell;
            }else
            {
                DRShipmentGrouponLogisticsAddressTableViewCell *cell = [DRShipmentGrouponLogisticsAddressTableViewCell cellWithTableView:tableView];
                cell.delegate = self;
                DRDeliveryAddressModel * deliveryModel = self.shipmentModel.deliveryList[indexPath.row];
                cell.deliveryModel = deliveryModel;
                return cell;
            }
        }else
        {
            if (indexPath.section == 0) {
                DRShipmentLogisticsAddressTableViewCell *cell = [DRShipmentLogisticsAddressTableViewCell cellWithTableView:tableView];
                cell.delegate = self;
                DRDeliveryAddressModel * deliveryModel = self.shipmentModel.deliveryList[indexPath.row];
                cell.deliveryModel = deliveryModel;
                return cell;
            }else
            {
                DRShipmentGoodTableViewCell *cell = [DRShipmentGoodTableViewCell cellWithTableView:tableView];
                DROrderItemDetailModel * detail = self.shipmentModel.order.detail[indexPath.row];
                cell.orderType = self.shipmentModel.orderType;
                cell.orderItemDetailModel = detail;
                return cell;
            }
        }
    }else if (statusInt == -1 || statusInt == -5 || statusInt == -6) {//失败
        if ([self.shipmentModel.orderType intValue] == 2) {//团购
            if (indexPath.section == 0) {
                DRShipmentGoodTableViewCell *cell = [DRShipmentGoodTableViewCell cellWithTableView:tableView];
                DROrderItemDetailModel * detail = self.shipmentModel.order.detail[indexPath.row];
                cell.successCount = self.shipmentModel.successCount;
                cell.payCount = self.shipmentModel.payCount;
                cell.orderType = self.shipmentModel.orderType;
                cell.orderItemDetailModel = detail;
                return cell;
            }else
            {
                DRShipmentGrouponAddressTableViewCell *cell = [DRShipmentGrouponAddressTableViewCell cellWithTableView:tableView];
                DRDeliveryAddressModel * deliveryModel = self.shipmentModel.deliveryList[indexPath.row];
                cell.deliveryModel = deliveryModel;
                cell.numberButton.hidden = YES;
                return cell;
            }
        }else
        {
            if (indexPath.section == 0) {
                DRShipmentAddressTableViewCell *cell = [DRShipmentAddressTableViewCell cellWithTableView:tableView];
                DRDeliveryAddressModel * deliveryModel = self.shipmentModel.deliveryList[indexPath.row];
                cell.deliveryModel = deliveryModel;
                cell.numberButton.hidden = YES;
                return cell;
            }else
            {
                DRShipmentGoodTableViewCell *cell = [DRShipmentGoodTableViewCell cellWithTableView:tableView];
                DROrderItemDetailModel * detail = self.shipmentModel.order.detail[indexPath.row];
                cell.orderType = self.shipmentModel.orderType;
                cell.orderItemDetailModel = detail;
                return cell;
            }
        }
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    int statusInt = [_shipmentModel.status intValue];
    if (statusInt == -1 || statusInt == 30) {
        return nil;
    }
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 9)];
    lineView.backgroundColor = DRBackgroundColor;
    return lineView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int statusInt = [self.shipmentModel.status intValue];
    if (statusInt == 0 || statusInt == 5) {//待付款
        if ([self.shipmentModel.orderType intValue] == 2) {//团购
            if (indexPath.section == 0) {
                return 100;
            }else
            {
                DRShipmentGroupon *shipmentGroupon = self.shipmentModel.groupItemDetailList[indexPath.row];
                if (shipmentGroupon == self.shipmentModel.groupItemDetailList.lastObject && statusInt == 5) {
                    return 80;
                }else
                {
                    return 50;
                }
            }
        }else
        {
            if (indexPath.section == 0) {
                return 50;
            }else
            {
                return 100;
            }
        }
    }else if (statusInt == 10) {//待发货
        if ([self.shipmentModel.orderType intValue] == 2) {//团购
            if (indexPath.section == 0) {
                return 100;
            }else
            {
                DRDeliveryAddressModel * deliveryModel = self.shipmentModel.deliveryList[indexPath.row];
                return deliveryModel.cellH;
            }
        }else
        {
            if (indexPath.section == 0) {
                DRDeliveryAddressModel * deliveryModel = self.shipmentModel.deliveryList[indexPath.row];
                return deliveryModel.cellH;
            }else
            {
                return 100;
            }
        }
    }else if (statusInt == 20 || statusInt == 30) {//已发货
        if ([self.shipmentModel.orderType intValue] == 2) {//团购
            if (indexPath.section == 0) {
                return 100;
            }else
            {
                DRDeliveryAddressModel * deliveryModel = self.shipmentModel.deliveryList[indexPath.row];
                return deliveryModel.cellH;
            }
        }else
        {
            if (indexPath.section == 0) {
                DRDeliveryAddressModel * deliveryModel = self.shipmentModel.deliveryList[indexPath.row];
                return deliveryModel.cellH;
            }else
            {
                return 100;
            }
        }
    }else if (statusInt == -1 || statusInt == -5 || statusInt == -6) {//失败
        if ([self.shipmentModel.orderType intValue] == 2) {//团购
            if (indexPath.section == 0) {
                return 100;
            }else
            {
                DRDeliveryAddressModel * deliveryModel = self.shipmentModel.deliveryList[indexPath.row];
                return deliveryModel.cellH;
            }
        }else
        {
            if (indexPath.section == 0) {
                DRDeliveryAddressModel * deliveryModel = self.shipmentModel.deliveryList[indexPath.row];
                return deliveryModel.cellH;
            }else
            {
                return 100;
            }
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 9;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[DRShipmentGoodTableViewCell class]]) {
        DRGoodDetailViewController * goodVC = [[DRGoodDetailViewController alloc] init];
        DROrderItemDetailModel * detail = self.shipmentModel.order.detail[indexPath.row];
        goodVC.goodId = detail.goods.id;
        [self.navigationController pushViewController:goodVC animated:YES];
    }else
    {
        int statusInt = [self.shipmentModel.status intValue];
        if (statusInt == 5) {
            if ([self.shipmentModel.orderType intValue] == 2) {//团购
                if (indexPath.section == 1) {
                    DRShipmentGroupon *shipmentGroupon = self.shipmentModel.groupItemDetailList[indexPath.row];
                    NSString * nickName;
                    if (DRStringIsEmpty(shipmentGroupon.user.nickName)) {
                        nickName = shipmentGroupon.user.loginName;
                    }else
                    {
                        nickName = shipmentGroupon.user.nickName;
                    }
                    DRChatViewController *chatVC = [[DRChatViewController alloc] initWithConversationChatter:shipmentGroupon.user.id conversationType:EMConversationTypeChat];
                    chatVC.title = nickName;
                    NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@", baseUrl, shipmentGroupon.user.headImg];
                    [DRIMTool saveUserProfileWithUsername:shipmentGroupon.user.id forNickName:nickName avatarURLPath:imageUrlStr];
                    [self.navigationController pushViewController:chatVC animated:YES];
                }
            }
        }
    }
}

- (void)shipmentLogisticsAddressTableViewCell:(DRShipmentLogisticsAddressTableViewCell *)cell logisticsButtonDidClick:(UIButton *)button
{
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    
    DRSellerLogisticsViewController * sellerLogisticsVC = [[DRSellerLogisticsViewController alloc] init];
    sellerLogisticsVC.isSeller = YES;
    sellerLogisticsVC.orderId = self.shipmentModel.orderId;
    NSArray * deliveryListArray = self.shipmentModel.deliveryList;
    DRDeliveryAddressModel *deliveryList = deliveryListArray[indexPath.row];
    sellerLogisticsVC.groupId = deliveryList.groupId;
    [self.navigationController pushViewController:sellerLogisticsVC animated:YES];
}

- (void)shipmentGrouponLogisticsAddressTableViewCell:(DRShipmentGrouponLogisticsAddressTableViewCell *)cell logisticsButtonDidClick:(UIButton *)button
{
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    
    DRSellerLogisticsViewController * sellerLogisticsVC = [[DRSellerLogisticsViewController alloc] init];
    sellerLogisticsVC.isSeller = YES;
    sellerLogisticsVC.orderId = self.shipmentModel.orderId;
    NSArray * deliveryListArray = self.shipmentModel.deliveryList;
    DRDeliveryAddressModel *deliveryList = deliveryListArray[indexPath.row];
    sellerLogisticsVC.groupId = deliveryList.groupId;
    [self.navigationController pushViewController:sellerLogisticsVC animated:YES];
}

#pragma mark - 初始化
- (NSMutableArray *)buttonArray
{
    if (!_buttonArray) {
        _buttonArray = [NSMutableArray array];
    }
    return _buttonArray;
}

@end
