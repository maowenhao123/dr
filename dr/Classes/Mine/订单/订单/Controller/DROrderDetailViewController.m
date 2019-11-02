//
//  DROrderDetailViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/5/22.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DROrderDetailViewController.h"
#import "DRReturnGoodViewController.h"
#import "DRSellerLogisticsViewController.h"
#import "DRReturnGoodOrderListViewController.h"
#import "DRCommentOrderListViewController.h"
#import "DRShopDetailViewController.h"
#import "DRGoodDetailViewController.h"
#import "DRPayViewController.h"
#import "DROrderDetailTableViewCell.h"
#import "DROrderListHeaderView.h"
#import "DROrderDetailFooterView.h"
#import "DROrderDetailSectionFooterView.h"
#import "DRSubmitOrderAddressView.h"
#import "DRShareTool.h"
#import "DRDateTool.h"

@interface DROrderDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) MJRefreshGifHeader *headerRefreshView;
@property (nonatomic,weak) UIView * headerView;
@property (nonatomic,strong) DROrderDetailFooterView * tableFooterView;
@property (nonatomic,weak) UILabel * statusLabel;
@property (nonatomic,weak) UILabel * timeLabel;
@property (nonatomic,weak) UIView * addressView;
@property (nonatomic, weak) UILabel *nameLabel;//名字
@property (nonatomic, weak) UILabel *phoneLabel;//电话
@property (nonatomic, weak) UILabel *addressLabel;//地址
@property (nonatomic, weak) UIImageView * addressImageView;
@property (nonatomic,weak) DRAddressLine * addressLine;
@property (nonatomic,weak) UIView * bottomView;
@property (nonatomic,weak) UIButton *button1;
@property (nonatomic,weak) UIButton *button2;
@property (nonatomic,weak) UIButton *button3;
@property (nonatomic,strong) DROrderModel *orderModel;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation DROrderDetailViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addSetDeadlineTimer];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeSetDeadlineTimer];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"订单详情";
    [self setupChilds];
    waitingView
    [self getData];
    //通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData) name:@"orderDetailRefresh" object:nil];
}
#pragma mark - 请求数据
- (void)getData
{
    NSDictionary *bodyDic = @{
                              @"orderId":self.orderId
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"S17",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            DROrderModel *orderModel = [DROrderModel mj_objectWithKeyValues:json[@"detail"]];
            NSArray *storeOrders_ = [DRStoreOrderModel  mj_objectArrayWithKeyValuesArray:json[@"detail"][@"storeOrders"]];
            orderModel.storeOrders = storeOrders_;
            for (DRStoreOrderModel * storeOrder in orderModel.storeOrders) {
                NSInteger index = [orderModel.storeOrders indexOfObject:storeOrder];
                NSArray *detail_ = [DROrderItemDetailModel  mj_objectArrayWithKeyValuesArray:json[@"detail"][@"storeOrders"][index][@"detail"]];
                storeOrder.detail = detail_;
            }
            self.orderModel = orderModel;
        }else
        {
            ShowErrorView
        }
        //结束刷新
        [self.headerRefreshView endRefreshing];
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        [MBProgressHUD hideHUDForView:self.view];
        //结束刷新
        [self.headerRefreshView endRefreshing];
    }];
}
- (void)confirmGoodWithOrderId:(NSString *)orderId
{
    NSDictionary *bodyDic = @{
                              @"id":orderId,
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"S08",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            //更新数据发送通知
            [[NSNotificationCenter defaultCenter] postNotificationName:@"upDataOrderStatus" object:nil];
            DRCommentOrderListViewController * commentOrderVC = [[DRCommentOrderListViewController alloc] init];
            commentOrderVC.orderId = orderId;
            [self.navigationController pushViewController:commentOrderVC animated:YES];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
- (void)deleteGoodWithOrderModel:(DROrderModel *)orderModel
{
    NSDictionary *bodyDic = @{
                              @"id":orderModel.id,
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"S06",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            //更新数据发送通知
            [[NSNotificationCenter defaultCenter] postNotificationName:@"upDataOrderStatus" object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
- (void)cancelOrderWithOrderModel:(DROrderModel *)orderModel
{
    NSDictionary *bodyDic = @{
                              @"id":orderModel.id,
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"S07",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            //更新数据发送通知
            [[NSNotificationCenter defaultCenter] postNotificationName:@"upDataOrderStatus" object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
#pragma mark - 布局视图
- (void)setupChilds
{
    //tableView
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH - 49) style:UITableViewStyleGrouped];
    self.tableView = tableView;
    tableView.backgroundColor = DRBackgroundColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    [self.view addSubview:tableView];
    
    //初始化头部刷新控件
    MJRefreshGifHeader *headerRefreshView = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshViewBeginRefreshing)];
    self.headerRefreshView = headerRefreshView;
    [DRTool setRefreshHeaderData:headerRefreshView];
    tableView.mj_header = headerRefreshView;
    
    //headerView
    UIView * headerView = [[UIView alloc] init];
    self.headerView = headerView;
    headerView.frame = CGRectMake(0, 0, screenWidth, 67);
    headerView.backgroundColor = [UIColor whiteColor];
    
    //订单状态
    UIView * statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 67)];
    statusView.backgroundColor = DRDefaultColor;
    [headerView addSubview:statusView];
    
    UILabel * statusLabel = [[UILabel alloc] init];
    self.statusLabel = statusLabel;
    statusLabel.textColor = [UIColor whiteColor];
    statusLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [statusView addSubview:statusLabel];
    
    UILabel * timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 0, screenWidth - 2 * DRMargin, 67)];
    self.timeLabel = timeLabel;
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    timeLabel.textAlignment = NSTextAlignmentRight;
    timeLabel.hidden = YES;
    [statusView addSubview:timeLabel];
    
    //订单地址
    UIView * addressView = [[UIView alloc] initWithFrame:CGRectMake(0, 67, screenWidth, 0)];
    self.addressView = addressView;
    addressView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:addressView];
    
    //名字
    UILabel * nameLabel = [[UILabel alloc]init];
    self.nameLabel = nameLabel;
    nameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    nameLabel.textColor = DRBlackTextColor;
    [addressView addSubview:nameLabel];
    
    //电话
    UILabel * phoneLabel = [[UILabel alloc]init];
    self.phoneLabel = phoneLabel;
    phoneLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    phoneLabel.textColor = DRBlackTextColor;
    [addressView addSubview:phoneLabel];
    
    //地址
    UIImageView * addressImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pay_address_icon"]];
    self.addressImageView = addressImageView;
    [addressView addSubview:addressImageView];
    
    UILabel * addressLabel = [[UILabel alloc]init];
    self.addressLabel = addressLabel;
    addressLabel.numberOfLines = 0;
    addressLabel.textColor = DRBlackTextColor;
    [addressView addSubview:addressLabel];
    
    //条纹
    DRAddressLine * addressLine = [[DRAddressLine alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 7)];
    self.addressLine = addressLine;
    addressLine.backgroundColor = [UIColor whiteColor];
    [addressView addSubview:addressLine];
    
    tableView.tableHeaderView = headerView;
    
    //footerView
    self.tableFooterView = [[DROrderDetailFooterView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    tableView.tableFooterView = self.tableFooterView;

    //底部视图
    CGFloat bottomViewH = 49;
    CGFloat bottomViewY = screenHeight - statusBarH - navBarH - bottomViewH - [DRTool getSafeAreaBottom];
    UIView * bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, bottomViewY, screenWidth, bottomViewH + [DRTool getSafeAreaBottom])];
    self.bottomView = bottomView;
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    //阴影
    bottomView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    bottomView.layer.shadowOffset = CGSizeMake(0, -0.2);
    bottomView.layer.shadowOpacity = 0.5;

    CGFloat buttonW = 77;
    CGFloat buttonH = 31;
    CGFloat buttonY = (bottomViewH - buttonH) / 2;
    for (int i = 0; i < 3; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i == 0) {
            self.button1 = button;
        }else if (i == 1)
        {
            self.button2 = button;
        }else if (i == 2)
        {
            self.button3 = button;
        }
        button.tag = i;
        button.frame = CGRectMake(screenWidth - (buttonW + DRMargin) * (i + 1), buttonY, buttonW, buttonH);
        [button setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        [button addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:button];
    }
}
- (void)headerRefreshViewBeginRefreshing
{
    [self getData];
}

- (void)setOrderModel:(DROrderModel *)orderModel
{
    _orderModel = orderModel;
    
    //设置数据
    int statusInt = [_orderModel.status intValue];
    if (statusInt == 30) {
        self.statusLabel.text = @"已完成";
    }else if (statusInt == 0) {
        self.statusLabel.text = @"待付款";
        self.timeLabel.hidden = NO;
    }else if (statusInt == 5) {
        self.statusLabel.text = @"待成团";
    }else if (statusInt == 10) {
        if ([_orderModel.orderType integerValue] == 2) {//团购
            self.statusLabel.text = @"拼团成功，待发货";
        }else{
            self.statusLabel.text = @"待发货";
        }
    }else if (statusInt == 20) {
        self.statusLabel.text = @"待收货";
    }else if (statusInt == -1) {
        self.statusLabel.text = @"已取消";
    }else if (statusInt == -5) {
        self.statusLabel.text = @"拼单失败撤单";
    }else if (statusInt == -6) {
        self.statusLabel.text = @"无货撤单";
    }else if (statusInt == -10 || statusInt == -100) {
        self.statusLabel.text = @"已删除";
    }else if (statusInt == -101)
    {
        self.statusLabel.text = @"已支付";
    }

    self.nameLabel.text = _orderModel.address.receiverName;
    self.phoneLabel.text = _orderModel.address.phone;
    NSMutableAttributedString * attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@",_orderModel.address.province, _orderModel.address.city, _orderModel.address.address]];
    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(26)] range:NSMakeRange(0, attStr.length)];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;//行间距
    [attStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attStr.length)];
    self.addressLabel.attributedText = attStr;
    
    self.tableFooterView.orderModel = _orderModel;
    self.tableView.tableFooterView = self.tableFooterView;
    
    //设置frame
    CGSize statusLabelSize = [self.statusLabel.text sizeWithLabelFont:self.statusLabel.font];
    self.statusLabel.frame = CGRectMake(DRMargin, 0, statusLabelSize.width, 67);
    
    CGFloat addressLabelX = DRMargin + 18 + 3;
    CGFloat addressLabelW = screenWidth - addressLabelX - DRMargin;
    CGSize nameLabelSize = [self.nameLabel.text sizeWithLabelFont:self.nameLabel.font];
    CGSize phoneLabelSize = [self.phoneLabel.text sizeWithLabelFont:self.phoneLabel.font];
    CGSize addressLabelSize = [self.addressLabel.attributedText boundingRectWithSize:CGSizeMake(addressLabelW, screenHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    self.nameLabel.frame = CGRectMake(addressLabelX, DRMargin, nameLabelSize.width, nameLabelSize.height);
    self.phoneLabel.frame = CGRectMake(CGRectGetMaxX(self.nameLabel.frame) + DRMargin, DRMargin, phoneLabelSize.width, phoneLabelSize.height);
    self.addressLabel.frame = CGRectMake(addressLabelX, CGRectGetMaxY(self.nameLabel.frame) + DRMargin, addressLabelSize.width, addressLabelSize.height);
    self.addressImageView.frame = CGRectMake(DRMargin, 0, 18, 18);
    self.addressImageView.centerY = self.addressLabel.centerY;
    self.addressLine.frame = CGRectMake(0, CGRectGetMaxY(self.addressLabel.frame) + DRMargin, screenWidth, 7);
    self.addressView.height = CGRectGetMaxY(self.addressLine.frame) - 1;
    self.headerView.height = CGRectGetMaxY(self.addressView.frame);
    self.tableView.tableHeaderView = self.headerView;
    
    //设置底部按钮
    self.bottomView.hidden = YES;
    self.tableView.height = screenHeight - statusBarH - navBarH;
    if (statusInt == 30) {//已完成
        self.bottomView.hidden = NO;
        self.tableView.height = screenHeight - statusBarH - navBarH - self.bottomView.height;
        int unCommentCount = [_orderModel.unCommentCount intValue];
        if (unCommentCount > 0) { //有未评价的商品
            self.button1.hidden = NO;
            [self.button1 setTitle:@"去评价" forState:UIControlStateNormal];
            self.button2.hidden = NO;
            [self.button2 setTitle:@"查看物流" forState:UIControlStateNormal];
            self.button3.hidden = NO;
            [self.button3 setTitle:@"删除订单" forState:UIControlStateNormal];
        }else
        {
            self.button1.hidden = NO;
            [self.button1 setTitle:@"查看物流" forState:UIControlStateNormal];
            self.button2.hidden = NO;
            [self.button2 setTitle:@"删除订单" forState:UIControlStateNormal];
            self.button3.hidden = YES;
        }
    }else if (statusInt == 0) {//待付款
        self.bottomView.hidden = NO;
        self.tableView.height = screenHeight - statusBarH - navBarH - self.bottomView.height;
        self.button1.hidden = NO;
        [self.button1 setTitle:@"去支付" forState:UIControlStateNormal];
        self.button2.hidden = NO;
        [self.button2 setTitle:@"取消订单" forState:UIControlStateNormal];
        self.button3.hidden = YES;
    }else if (statusInt == 5) {//待成团
        self.bottomView.hidden = NO;
        self.tableView.height = screenHeight - statusBarH - navBarH - self.bottomView.height;
        self.button1.hidden = NO;
        [self.button1 setTitle:@"邀请好友拼团" forState:UIControlStateNormal];
        self.button1.width = 99;
        self.button1.x -= (99 - 79);
        self.button2.hidden = YES;
        self.button3.hidden = YES;
    }else if (statusInt == 20) {//待收货
        self.bottomView.hidden = NO;
        self.tableView.height = screenHeight - statusBarH - navBarH - self.bottomView.height;
        [self.button1 setTitle:@"确认收货" forState:UIControlStateNormal];
        self.button2.hidden = NO;
        [self.button2 setTitle:@"查看物流" forState:UIControlStateNormal];
        self.button3.hidden = NO;
        [self.button3 setTitle:@"退款" forState:UIControlStateNormal];
    }else if (statusInt == -1) {//已取消
        self.bottomView.hidden = NO;
        self.tableView.height = screenHeight - statusBarH - navBarH - self.bottomView.height;
        self.button1.hidden = NO;
        [self.button1 setTitle:@"删除订单" forState:UIControlStateNormal];
        self.button2.hidden = YES;
        self.button3.hidden = YES;
    }
    [self setButtonBorder:self.button1];
    [self setButtonBorder:self.button2];
    [self setButtonBorder:self.button3];
    
    //刷新tableView
    [self.tableView reloadData];
}
- (void)addSetDeadlineTimer
{
    if(self.timer == nil)//空才创建
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(setTimeLabelText) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        [self.timer fire];
    }
}

- (void)setTimeLabelText
{
    //支付倒计时 15分钟
    NSDateComponents * components = [DRDateTool getDeltaDateToTimestampg:_orderModel.createTime + 15 * 60 * 1000];
    int statusInt = [_orderModel.status intValue];
    if ((components.minute <= 0 && components.second <= 0) || statusInt != 0) {
        self.timeLabel.hidden = YES;
    }else
    {
        self.timeLabel.text = [NSString stringWithFormat:@"支付倒计时：%ld分%ld秒", components.minute, components.second];
    }
}

- (void)setButtonBorder:(UIButton *)button
{
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = button.height / 2;
    button.layer.borderWidth = 1;
    if ([button.currentTitle isEqualToString:@"去支付"] || [button.currentTitle isEqualToString:@"去评价"] || [button.currentTitle isEqualToString:@"邀请好友拼团"]) {
        [button setTitleColor:DRDefaultColor forState:UIControlStateNormal];
        button.layer.borderColor = DRDefaultColor.CGColor;
    }else
    {
        [button setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
        button.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
}
- (void)buttonDidClick:(UIButton *)button
{
    if ([button.currentTitle isEqualToString:@"查看物流"])
    {
        DRSellerLogisticsViewController * sellerLogisticsVC = [[DRSellerLogisticsViewController alloc] init];
        sellerLogisticsVC.orderId = self.orderModel.id;
        [self.navigationController pushViewController:sellerLogisticsVC animated:YES];
    }else if ([button.currentTitle isEqualToString:@"确认收货"])
    {
        [self confirmGoodWithOrderId:self.orderModel.id];
    }else if ([button.currentTitle isEqualToString:@"删除订单"])
    {
        [self deleteGoodWithOrderModel:self.orderModel];
    }else if ([button.currentTitle isEqualToString:@"取消订单"])
    {
        [self cancelOrderWithOrderModel:self.orderModel];
    }else if ([button.currentTitle isEqualToString:@"去支付"])
    {
        DRPayViewController * payVC = [[DRPayViewController alloc] init];
        payVC.type = 2;
        payVC.orderId = self.orderModel.id;
        payVC.grouponType = 0;
        payVC.price = [self.orderModel.amountPayable doubleValue] / 100;
        [self.navigationController pushViewController:payVC animated:YES];
    }else if ([button.currentTitle isEqualToString:@"去评价"])
    {
        DRCommentOrderListViewController * commentOrderVC = [[DRCommentOrderListViewController alloc] init];
        commentOrderVC.orderId = self.orderModel.id;
        [self.navigationController pushViewController:commentOrderVC animated:YES];
    }else if ([button.currentTitle isEqualToString:@"退款"])
    {
        DRReturnGoodOrderListViewController* returnGoodListVC = [[DRReturnGoodOrderListViewController alloc] init];
        returnGoodListVC.orderId = self.orderModel.id;
        [self.navigationController pushViewController:returnGoodListVC animated:YES];
    }else if ([button.currentTitle isEqualToString:@"邀请好友拼团"])
    {
        [DRShareTool shareGrouponByGrouponId:self.orderModel.group.id];
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.orderModel.storeOrders.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DRStoreOrderModel * storeOrder = self.orderModel.storeOrders[section];
    return storeOrder.detail.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DROrderDetailTableViewCell * cell = [DROrderDetailTableViewCell cellWithTableView:tableView];
    DRStoreOrderModel * storeOrderModel = self.orderModel.storeOrders[indexPath.section];
    cell.detailModel = storeOrderModel.detail[indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    DROrderListHeaderView *headerView = [DROrderListHeaderView headerFooterViewWithTableView:tableView];
    DRStoreOrderModel * storeOrderModel = self.orderModel.storeOrders[section];
    NSString * avatarUrlStr = [NSString stringWithFormat:@"%@%@", baseUrl, storeOrderModel.storeImg];
    [headerView.shopLogoImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrlStr] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
    headerView.shopNameLabel.text = storeOrderModel.storeName;
    headerView.statusLabel.hidden = YES;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerViewDidClick:)];
    [headerView addGestureRecognizer:tap];
    
    return headerView;
}

- (void)headerViewDidClick:(UITapGestureRecognizer *)tap
{
    DRShopDetailViewController * shopVC = [DRShopDetailViewController new];
    DRStoreOrderModel * storeOrderModel = self.orderModel.storeOrders[tap.view.tag];
    shopVC.shopId = storeOrderModel.storeId;
    [self.navigationController pushViewController:shopVC animated:YES];
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (self.orderModel.storeOrders.count > 1) {//多个店铺
        DROrderDetailSectionFooterView *footerView = [DROrderDetailSectionFooterView headerFooterViewWithTableView:tableView];
        footerView.storeOrderModel = self.orderModel.storeOrders[section];
        return footerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35 + 9;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (self.orderModel.storeOrders.count > 1) {//多个店铺
        return 35 * 2;
    }
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRStoreOrderModel * storeOrderModel = self.orderModel.storeOrders[indexPath.section];
    DROrderItemDetailModel * detailModel = storeOrderModel.detail[indexPath.row];
    DRGoodDetailViewController * goodDetailVC = [[DRGoodDetailViewController alloc] init];
    goodDetailVC.goodId = detailModel.goods.id;
    [self.navigationController pushViewController:goodDetailVC animated:YES];
}

#pragma  mark - 销毁对象
- (void)removeSetDeadlineTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

@end
