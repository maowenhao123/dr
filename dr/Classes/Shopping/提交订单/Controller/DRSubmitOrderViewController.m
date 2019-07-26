//
//  DRSubmitOrderViewController.m
//  dr
//
//  Created by 毛文豪 on 2018/3/27.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRSubmitOrderViewController.h"
#import "DRLoginViewController.h"
#import "DRManageAddressViewController.h"
#import "DRChooseRedPacketViewController.h"
#import "DRPayViewController.h"
#import "DRSubmitOrderAddressView.h"
#import "DRChooseRedPacketView.h"
#import "DRSubmitOrderGoodHeaderView.h"
#import "DRSubmitOrderGoodFooterView.h"
#import "DRSubmitOrderGoodTableViewCell.h"
#import "DRShoppingCarShopModel.h"

@interface DRSubmitOrderViewController ()<UITableViewDelegate, UITableViewDataSource, ManageAddressViewControllerDelegate, ChooseRedPacketViewControllerDelegate>

@property (nonatomic, weak) UITableView * tableView;
@property (nonatomic, weak) DRSubmitOrderAddressView * addressView;
@property (nonatomic, weak) DRChooseRedPacketView * redPacketView;
@property (nonatomic,weak) UILabel *moneyLabel;
@property (nonatomic,strong) NSArray * storeOrderList;
@property (nonatomic,strong) DRAddressModel *addressModel;
@property (nonatomic,assign) NSInteger couponNumber;
@property (nonatomic,copy) NSString *couponUserId;
@property (nonatomic,assign) double orderPrice;

@end

@implementation DRSubmitOrderViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"订单支付";
    [self setupChilds];
    [self getAddressData];
    [self getGoodData];
}

#pragma mark - 请求数据
- (void)getGoodData
{
    NSDictionary * bodyDic;
    NSString * cmd;
    if (self.grouponType == 0) {
        cmd = @"S09";
        NSMutableArray * items = [NSMutableArray array];
        for (DRShoppingCarShopModel * carShopModel in self.dataArray) {
            for (DRShoppingCarGoodModel * carGoodModel in carShopModel.goodArr) {
                NSDictionary * item = @{
                                        @"purchaseCount":[NSNumber numberWithInt:carGoodModel.count],
                                        @"goodsId":carGoodModel.goodModel.id,
                                        };
                [items addObject:item];
            }
        }
        
        NSDictionary * order = @{
                                 @"items":items,
                                 };
        
       bodyDic = @{
                   @"order":order,
                   };
    }else
    {
        cmd = @"S33";
        DRShoppingCarShopModel * carShopModel = self.dataArray.firstObject;
        DRShoppingCarGoodModel * carGoodModel = carShopModel.goodArr.firstObject;
        bodyDic = @{
                    @"purchaseCount":[NSNumber numberWithInt:carGoodModel.count],
                    @"goodsId":carGoodModel.goodModel.id,
                    };
    }
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":cmd,
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            NSArray * storeOrderList = [NSArray array];
            if (self.grouponType == 0) {
                storeOrderList = [DRStoreOrderModel mj_objectArrayWithKeyValuesArray:json[@"storeOrderList"]];
                for (DRStoreOrderModel * storeOrderModel in storeOrderList) {
                    NSInteger index = [storeOrderList indexOfObject:storeOrderModel];
                    NSArray *detail = [DROrderItemDetailModel  mj_objectArrayWithKeyValuesArray:json[@"storeOrderList"][index][@"detail"]];
                    storeOrderModel.detail = detail;
                }
            }else
            {
                DRStoreOrderModel * storeOrderModel = [DRStoreOrderModel mj_objectWithKeyValues:json[@"storeOrder"]];
                NSArray *detail = [DROrderItemDetailModel  mj_objectArrayWithKeyValuesArray:json[@"storeOrder"][@"detail"]];
                storeOrderModel.detail = detail;
                storeOrderList = @[storeOrderModel];
            }
            self.storeOrderList = storeOrderList;
            [self.tableView reloadData];
            double totalPrice = 0;
            for (DRStoreOrderModel * storeOrderModel in self.storeOrderList) {
                double ruleMoney = [storeOrderModel.ruleMoney doubleValue] / 100;
                double priceCount = [storeOrderModel.priceCount doubleValue] / 100;
                double freightMoney = [storeOrderModel.freight doubleValue] / 100;
                totalPrice += priceCount;
                if (ruleMoney > priceCount && freightMoney > 0) {//不包邮
                    totalPrice += freightMoney;
                }
            }
            self.orderPrice = totalPrice;
            NSString * moneyStr = [NSString stringWithFormat:@"应付：¥%@", [DRTool formatFloat:self.orderPrice]];
            [self setMoneyByMoneyStr:moneyStr];
            [self getRedPacketData];
        }else
        {
            ShowErrorView
        }
        
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        [MBProgressHUD hideHUDForView:self.view];
    }];
}

- (void)getAddressData
{
    if (!Token || !UserId) {
        return;
    }
    
    NSDictionary *bodyDic = @{
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U08",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            NSArray * addresss = [DRAddressModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            DRAddressModel *addressModel = addresss.firstObject;
            for (DRAddressModel *addressModel_ in addresss) {
                if ([addressModel_.defaultv intValue] == 1) {
                    addressModel = addressModel_;
                    break;
                }
            }
            
            self.addressModel = addressModel;
            [self setAddressData];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

- (void)getRedPacketData
{
    NSDictionary *bodyDic = @{
                              @"pageIndex":@(1),
                              @"pageSize":@"100000",
                              @"status":@(1),
                              @"orderPrice":@(self.orderPrice * 100),
                              };
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"C02",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            NSArray *redPacketList = [DRRedPacketModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            NSMutableArray * usableRedPacketList = [NSMutableArray array];
            for (DRRedPacketModel * redPacketModel in redPacketList) {
                if ([redPacketModel.coupon.minAmount doubleValue] <= self.orderPrice * 100) {
                    [usableRedPacketList addObject:redPacketModel];
                }
            }
            self.couponNumber = usableRedPacketList.count;
            if (self.couponNumber == 0) {
                self.tableView.tableFooterView = [UIView new];
            }else
            {
                self.redPacketView.couponNumber = self.couponNumber;
                self.tableView.tableFooterView = self.redPacketView;
            }
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH - 45) style:UITableViewStyleGrouped];
    self.tableView = tableView;
    tableView.backgroundColor = DRBackgroundColor;
    tableView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    [self.view addSubview:tableView];
    
    DRSubmitOrderAddressView *addressView = [[DRSubmitOrderAddressView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 91)];
    self.addressView = addressView;
    [addressView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseAddress)]];
    tableView.tableHeaderView = addressView;
    
    DRChooseRedPacketView *redPacketView = [[DRChooseRedPacketView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 9 + DRCellH)];
    self.redPacketView = redPacketView;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseRedPacketViewDidTap)];
    [redPacketView addGestureRecognizer:tap];
    tableView.tableFooterView = redPacketView;
    
    //底部视图
    CGFloat bottomViewH = 45;
    CGFloat bottomViewY = screenHeight - statusBarH - navBarH - bottomViewH - [DRTool getSafeAreaBottom];
    UIView * bottomView = [[UIView alloc] init];
    bottomView.frame = CGRectMake(0, bottomViewY, screenWidth, bottomViewH);
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    //上分割线
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    line.backgroundColor = DRWhiteLineColor;
    [bottomView addSubview:line];
    
    CGFloat confirmButtonW = 100;
    //金额
    UILabel *moneyLabel = [[UILabel alloc] init];
    self.moneyLabel = moneyLabel;
    [bottomView addSubview:moneyLabel];
    
    //提交订单
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.frame = CGRectMake(screenWidth - confirmButtonW, 0, confirmButtonW, bottomView.height);
    confirmButton.backgroundColor = DRDefaultColor;
    [confirmButton setTitle:@"提交订单" forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [confirmButton addTarget:self action:@selector(confirmButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:confirmButton];
}

- (void)setMoneyByMoneyStr:(NSString *)moneyStr
{
    NSMutableAttributedString * moneyAttStr = [[NSMutableAttributedString alloc] initWithString:moneyStr];
    [moneyAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(28)] range:NSMakeRange(0, moneyStr.length)];
    [moneyAttStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, 3)];
    [moneyAttStr addAttribute:NSForegroundColorAttributeName value:DRRedTextColor range:NSMakeRange(3, moneyStr.length - 3)];
    self.moneyLabel.attributedText = moneyAttStr;
    CGSize moneyLabelSize = [self.moneyLabel.attributedText boundingRectWithSize:CGSizeMake(screenWidth, screenHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    self.moneyLabel.frame = CGRectMake(screenWidth - 100 - 10 - moneyLabelSize.width, 0, moneyLabelSize.width, 45);
}

#pragma mark - 地址
- (void)chooseAddress
{
    DRManageAddressViewController * addressVC = [[DRManageAddressViewController alloc] init];
    addressVC.delegate = self;
    [self.navigationController pushViewController:addressVC animated:YES];
}

- (void)manageAddressViewControllerSelectedAddressModel:(DRAddressModel *)addressModel
{
    if (addressModel) {
        self.addressModel = addressModel;
        [self setAddressData];
    }
}

- (void)setAddressData
{
    if (self.addressModel) {
        self.addressView.addressModel = self.addressModel;
        self.tableView.tableHeaderView = self.addressView;
    }
}
#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.storeOrderList.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DRStoreOrderModel * storeOrderModel = self.storeOrderList[section];
    return storeOrderModel.detail.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRSubmitOrderGoodTableViewCell * cell = [DRSubmitOrderGoodTableViewCell cellWithTableView:tableView];
    DRStoreOrderModel * storeOrderModel = self.storeOrderList[indexPath.section];
    cell.model = storeOrderModel.detail[indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    DRSubmitOrderGoodHeaderView *headerView = [DRSubmitOrderGoodHeaderView headerFooterViewWithTableView:tableView];
    DRStoreOrderModel * storeOrderModel = self.storeOrderList[section];
    headerView.storeOrderModel = storeOrderModel;
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    DRSubmitOrderGoodFooterView *footerView = [DRSubmitOrderGoodFooterView headerFooterViewWithTableView:tableView];
    DRStoreOrderModel * storeOrderModel = self.storeOrderList[section];
    footerView.storeOrderModel = storeOrderModel;
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 9 + 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 37 + 37;
}

#pragma mark - 红包
- (void)chooseRedPacketViewDidTap
{
    DRChooseRedPacketViewController * chooseRedPacketVC = [[DRChooseRedPacketViewController alloc] init];
    chooseRedPacketVC.delegate = self;
    chooseRedPacketVC.couponUserId = self.couponUserId;
    chooseRedPacketVC.orderPrice = self.orderPrice;
    [self.navigationController pushViewController:chooseRedPacketVC animated:YES];
}

- (void)didChooseRedPacket:(DRRedPacketModel *)redPacketModel
{
    self.couponUserId = redPacketModel.couponUser.id;
    self.redPacketView.usableRedPacketLabel.text = [NSString stringWithFormat:@"已选择%@元红包", [DRTool formatFloat:[redPacketModel.coupon.couponValue doubleValue] / 100]];
    NSString * moneyStr = [NSString stringWithFormat:@"应付：¥%@", [DRTool formatFloat:self.orderPrice - [redPacketModel.coupon.couponValue doubleValue] / 100]];
    [self setMoneyByMoneyStr:moneyStr];
}

- (void)cancelRedPacket
{
    self.couponUserId = @"";
    self.redPacketView.couponNumber = self.couponNumber;
    NSString * moneyStr = [NSString stringWithFormat:@"应付：¥%@", [DRTool formatFloat:self.orderPrice]];
    [self setMoneyByMoneyStr:moneyStr];
}

#pragma mark - 提交订单
- (void)confirmButtonDidClick:(UIButton *)button
{
    if((!UserId || !Token))//未登录
    {
        DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
        [self presentViewController:loginVC animated:YES completion:nil];
        return;
    }
    
    if (DRStringIsEmpty(self.addressModel.id)) {
        [MBProgressHUD showError:@"您还未选择地址"];
        return;
    }
    
    NSDictionary *bodyDic_ = [NSDictionary dictionary];
    NSString * cmd;
    if (self.grouponType == 0) {
        cmd = @"S10";
        NSMutableArray * items = [NSMutableArray array];
        for (DRStoreOrderModel * storeOrderModel in self.storeOrderList) {
            for (DROrderItemDetailModel * orderItemDetailModel in storeOrderModel.detail) {
                NSDictionary * item = @{
                                      @"purchaseCount":orderItemDetailModel.purchaseCount,
                                        @"goodsId":orderItemDetailModel.goods.id,
                                        };
                [items addObject:item];
            }
        }
        NSDictionary * order = @{
                                 @"items":items,
                                 @"addressId":self.addressModel.id,
                                 };
        bodyDic_ = @{
                     @"order":order,
                     };
    }else
    {
        DRStoreOrderModel * storeOrderModel =  self.storeOrderList.firstObject;
        DROrderItemDetailModel * orderItemDetailModel = storeOrderModel.detail.firstObject;
        if (!orderItemDetailModel) {
            return;
        }
        if (self.grouponType == 1)//跟团
        {
            cmd = @"S04";
            bodyDic_ = @{
                         @"purchaseCount":orderItemDetailModel.purchaseCount,
                         @"groupId":self.groupId,
                         @"addressId":self.addressModel.id,
                         };
        }else//发起团购
        {
            cmd = @"S01";
            bodyDic_ = @{
                         @"purchaseCount":orderItemDetailModel.purchaseCount,
                         @"goodsId":orderItemDetailModel.goods.id,
                         @"addressId":self.addressModel.id,
                         };
        }
    }
    
    NSMutableDictionary * bodyDic = [NSMutableDictionary dictionaryWithDictionary:bodyDic_];
    if (!DRStringIsEmpty(self.couponUserId)) {//使用红包
        [bodyDic setObject:self.couponUserId forKey:@"couponUserId"];
    }
    
    waitingView
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":cmd,
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            [MBProgressHUD showSuccess:@"订单已提交"];
            if (self.grouponType == 0) {
                //删除购物车里的该商品
                NSMutableArray * goodArray = [NSMutableArray array];
                for (DRShoppingCarShopModel * carShopModel in self.dataArray) {
                    for (DRShoppingCarGoodModel * carGoodModel in carShopModel.goodArr) {
                        [goodArray addObject:carGoodModel];
                    }
                }
                for (DRShoppingCarGoodModel * carGoodModel in goodArray) {
                    [DRUserDefaultTool deleteGoodInShoppingCarWithGood:carGoodModel.goodModel];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"upSataShoppingCar" object:nil];
            }
            DRPayViewController * payVC = [[DRPayViewController alloc] init];
            payVC.grouponType = 0;
            payVC.orderId = json[@"orderDetail"][@"id"];
            payVC.price = [json[@"orderDetail"][@"amountPayable"] doubleValue] / 100;
            if (!DRStringIsEmpty(self.groupId)) {
                payVC.grouponId = self.groupId;
            }
            [self.navigationController pushViewController:payVC animated:YES];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        DRLog(@"error:%@",error);
    }];
}

#pragma mark - 初始化
- (NSArray *)storeOrderList
{
    if (_storeOrderList == nil) {
        _storeOrderList = [NSArray array];
    }
    return _storeOrderList;
}

@end
