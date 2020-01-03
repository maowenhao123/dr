//
//  DRMyShopViewController.m
//  dr
//
//  Created by apple on 17/1/16.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRMyShopViewController.h"
#import "DRMyShopDetailViewController.h"
#import "DRShipmentListViewController.h"
#import "DRMailSettingViewController.h"
#import "DRReturnGoodManageViewController.h"
#import "DRWaitSettlementOrderViewController.h"
#import "DRChangeRealNameViewController.h"
#import "DRMyFansViewController.h"
#import "DRWithdrawViewController.h"
#import "DRBillingViewController.h"
#import "DRPublishGoodViewController.h"
#import "DRGoodShelfViewController.h"
#import "DRShopActivityViewController.h"
#import "DRLoadHtmlFileViewController.h"
#import "DRShopDetailViewController.h"
#import "DRItemView.h"
#import "DRIconTextTableViewCell.h"
#import "DRShopNewsView.h"

@interface DRMyShopViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) MJRefreshGifHeader *header;
@property (nonatomic, weak) UIImageView *shopLogoImageView;//头像
@property (nonatomic, weak) UILabel * shopNameLabel;//店名
@property (nonatomic, weak) UILabel *moneyLabel;
@property (nonatomic,strong) NSMutableArray *labelArray;
@property (nonatomic,strong) NSMutableArray *orderItemViews;
@property (nonatomic, strong) NSMutableArray *functionStatuss;

@end

@implementation DRMyShopViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"我的店铺";
    [self setupChilds];
    waitingView
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self showNews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setShopData) name:@"upDataMyShopAvatar" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setShopData) name:@"upDataMyShopName" object:nil];
}

#pragma mark - 请求数据
- (void)getData
{
    NSDictionary *bodyDic = @{
    };
    
    NSDictionary *headDic = @{
        @"digest":[DRTool getDigestByBodyDic:bodyDic],
        @"cmd":@"B01",
        @"userId":UserId,
    };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            DRMyShopModel *shopModel = [DRMyShopModel mj_objectWithKeyValues:json];
            [DRUserDefaultTool saveMyShopModel:shopModel];
            [self setShopData];
        }else
        {
            ShowErrorView
        }
        if ([self.header isRefreshing]) {
            [self.header endRefreshing];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        if ([self.header isRefreshing]) {
            [self.header endRefreshing];
        }
        DRLog(@"error:%@",error);
    }];
}

#pragma mark - 布局视图
- (void)showNews
{
    int noPromptShopNews = [[DRUserDefaultTool getObjectForKey:@"noPromptShopNews"] intValue];
    if (noPromptShopNews == 0) {
        DRShopNewsView * shopNewsView = [[DRShopNewsView alloc] initWithFrame:self.tabBarController.view.bounds];
        shopNewsView.block = ^{
            DRMailSettingViewController * mailSettingVC = [[DRMailSettingViewController alloc] init];
            [self.navigationController pushViewController:mailSettingVC animated:YES];
        };
        [self.tabBarController.view addSubview:shopNewsView];
    }
}

- (void)setupChilds
{
    //tableView
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight) style:UITableViewStyleGrouped];
    self.tableView = tableView;
    tableView.backgroundColor = DRBackgroundColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    [self.view addSubview:tableView];
    
    //初始化头部刷新控件
    MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(getData)];
    self.header = header;
    [DRTool setRefreshHeaderData:header];
    tableView.mj_header = header;
    
    //headerView
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, scaleScreenWidth(177) + 200 + 9 + DRCellH + 70)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UIImageView * backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, scaleScreenWidth(177))];
    if (iPhone4 || iPhone5)
    {
        backImageView.image = [UIImage imageNamed:@"mine_top_back_320"];
    }else if (iPhone6 || iPhoneX)
    {
        backImageView.image = [UIImage imageNamed:@"mine_top_back_375"];
    }else if (iPhone6P || iPhoneXR || iPhoneXSMax)
    {
        backImageView.image = [UIImage imageNamed:@"mine_top_back_414"];
    }else
    {
        backImageView.image = [UIImage imageNamed:@"mine_top_back_375"];
    }
    [headerView addSubview:backImageView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(shopViewDidClick)];
    backImageView.userInteractionEnabled = YES;
    [backImageView addGestureRecognizer:tap];
    
    //返回
    UIButton * backButon = [UIButton buttonWithType:UIButtonTypeCustom];
    backButon.frame = CGRectMake(5, statusBarH + 6, 34, 30);
    [backButon setImage:[UIImage imageNamed:@"white_back_bar"] forState:UIControlStateNormal];
    [backButon addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:backButon];
    
    //头像
    UIView * shopLogoView = [[UIView alloc]initWithFrame:CGRectMake(DRMargin - 3, statusBarH + 62 - 3, 55 + 2 * 3, 55 + 2 * 3)];
    shopLogoView.layer.masksToBounds = YES;
    shopLogoView.layer.cornerRadius = shopLogoView.width / 2;
    shopLogoView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.3].CGColor;
    shopLogoView.layer.borderWidth = 3;
    [backImageView addSubview:shopLogoView];
    
    UIImageView * shopLogoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(3, 3, 55, 55)];
    self.shopLogoImageView = shopLogoImageView;
    shopLogoImageView.layer.masksToBounds = YES;
    shopLogoImageView.layer.cornerRadius = shopLogoImageView.width / 2;
    [shopLogoView addSubview:shopLogoImageView];
    
    //店铺名
    CGFloat shopNameLabelX = CGRectGetMaxX(shopLogoView.frame) + 15;
    CGFloat shopNameLabelW = screenWidth - shopNameLabelX - 20;
    UILabel * shopNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(shopNameLabelX, 0, shopNameLabelW, 20)];
    self.shopNameLabel = shopNameLabel;
    shopNameLabel.centerY = shopLogoView.centerY;
    shopNameLabel.textColor = [UIColor whiteColor];
    shopNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(32)];
    [backImageView addSubview:shopNameLabel];
    
    //accessory
    UIImageView * accessoryImageView = [[UIImageView alloc] init];
    accessoryImageView.image = [UIImage imageNamed:@"white_accessory_icon"];
    accessoryImageView.frame = CGRectMake(screenWidth - DRMargin - 10, 0, 10, 16);
    accessoryImageView.centerY = shopLogoView.centerY;
    [backImageView addSubview:accessoryImageView];
    
    //店铺金额
    UIView *moneyView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(backImageView.frame), screenWidth, 200)];
    moneyView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:moneyView];
    
    CGFloat labelH = 20;
    CGFloat labelPadding = 12;
    for (int i = 0; i < 5; i++) {
        UILabel *moneyLabel = [[UILabel alloc] init];
        if (i == 0) {
            moneyLabel.frame = CGRectMake(DRMargin, labelPadding + (labelH + labelPadding) * i, screenWidth - 2 * DRMargin, labelH);
        }else if (i == 3)
        {
            moneyLabel.frame = CGRectMake(DRMargin * 2, labelPadding + (labelH + labelPadding) * i, screenWidth - 4 * DRMargin, labelH * 2);
        }else if (i == 4)
        {
            moneyLabel.frame = CGRectMake(DRMargin * 2, labelPadding + (labelH + labelPadding) * i + labelH, screenWidth - 4 * DRMargin, labelH);
        }else
        {
            moneyLabel.frame = CGRectMake(DRMargin * 2, labelPadding + (labelH + labelPadding) * i, screenWidth - 4 * DRMargin, labelH);
        }
        moneyLabel.textColor = DRBlackTextColor;
        moneyLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
        moneyLabel.numberOfLines = 0;
        [moneyView addSubview:moneyLabel];
        [self.labelArray addObject:moneyLabel];
    }
    [self setMoneyLabelText];
    
    //充值提款
    CGFloat rechargeBtnH = 25;
    CGFloat rechargeBtnW = 63;
    for (int i = 0; i < 4; i++) {
        UILabel * moneyLabel = self.labelArray[i + 1];
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 100 + i;
        button.frame = CGRectMake(screenWidth - (rechargeBtnW + 15), 15 + (rechargeBtnH + 10) * i, rechargeBtnW, rechargeBtnH);
        if (i == 0)
        {
            [button setTitle:@"账单" forState:UIControlStateNormal];
            [button setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
            button.layer.borderColor = DRGrayTextColor.CGColor;
        }else if (i == 1)
        {
            [button setTitle:@"提款" forState:UIControlStateNormal];
            [button setTitleColor:DRViceColor forState:UIControlStateNormal];
            button.layer.borderColor = DRViceColor.CGColor;
        }else if (i == 2)
        {
            [button setTitle:@"详情" forState:UIControlStateNormal];
            [button setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
            button.layer.borderColor = DRGrayTextColor.CGColor;
        }else if (i == 3)
        {
            [button setTitle:@"详情" forState:UIControlStateNormal];
            [button setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
            button.layer.borderColor = DRGrayTextColor.CGColor;
        }
        button.centerY = moneyLabel.centerY;
        button.layer.borderWidth = 1;
        button.layer.cornerRadius = 3;
        button.layer.masksToBounds = YES;
        button.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
        [button addTarget:self action:@selector(butonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [moneyView addSubview:button];
    }
    
    //分割线
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(moneyView.frame), screenWidth, 9)];
    lineView.backgroundColor = DRBackgroundColor;
    [headerView addSubview:lineView];
    
    //订单管理
    UIView *orderView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame), screenWidth, DRCellH)];
    orderView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:orderView];
    
    UITapGestureRecognizer *orderViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(orderViewDidTap)];
    [orderView addGestureRecognizer:orderViewTap];
    
    UILabel * orderLabel = [[UILabel alloc] init];
    orderLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    orderLabel.textColor = DRBlackTextColor;
    orderLabel.text = @"订单管理";
    [orderView addSubview:orderLabel];
    
    CGSize orderLabelSize = [orderLabel.text sizeWithLabelFont:orderLabel.font];
    orderLabel.frame = CGRectMake(DRMargin, 0, orderLabelSize.width, orderView.height);
    
    //角标
    CGFloat accessoryImageViewWH = 12;
    CGFloat accessoryImageView2Y = (DRCellH - accessoryImageViewWH) / 2;
    UIImageView * accessoryImageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth - DRMargin - accessoryImageViewWH, accessoryImageView2Y, accessoryImageViewWH, accessoryImageViewWH)];
    accessoryImageView2.image = [UIImage imageNamed:@"big_black_accessory_icon"];
    [orderView addSubview:accessoryImageView2];
    
    UILabel * orderDetailLabel = [[UILabel alloc] init];
    orderDetailLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    orderDetailLabel.textColor = DRGrayTextColor;
    orderDetailLabel.text = @"全部";
    [orderView addSubview:orderDetailLabel];
    
    CGSize orderDetailLabelSize = [orderDetailLabel.text sizeWithLabelFont:orderDetailLabel.font];
    orderDetailLabel.frame = CGRectMake(accessoryImageView.x - 1 - orderDetailLabelSize.width, 0, orderDetailLabelSize.width, orderView.height);
    
    //分割线
    UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(0, orderView.height - 1, screenWidth, 1)];
    line2.backgroundColor = DRWhiteLineColor;
    [orderView addSubview:line2];
    
    //订单选项
    UIView *allOrderItemView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(orderView.frame), screenWidth, 70)];
    allOrderItemView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:allOrderItemView];
    
    NSArray *orderItemTitles = @[@"待发货", @"待付款", @"待成团", @"已发货", @"待退款"];
    NSArray *orderItemImageNames = @[@"order_wait_deliver_icon", @"order_wait_pay_icon", @"order_wait_groupon_icon", @"order_wait_receiving_icon", @"order_return_icon"];
    
    CGFloat orderItemViewW = screenWidth / orderItemTitles.count;
    for (int i = 0; i < orderItemTitles.count; i++) {
        DRItemView * itemView = [[DRItemView alloc] initWithFrame:CGRectMake(orderItemViewW * i, 0, orderItemViewW, allOrderItemView.height)];
        itemView.tag = i;
        itemView.text = orderItemTitles[i];
        itemView.imageName = orderItemImageNames[i];
        [allOrderItemView addSubview:itemView];
        
        UITapGestureRecognizer *itemViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(orderItemViewDidTap:)];
        [itemView addGestureRecognizer:itemViewTap];
        
        [self.orderItemViews addObject:itemView];
    }
    
    tableView.tableHeaderView = headerView;
}

#pragma mark - 按钮点击
- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shopViewDidClick
{
    DRMyShopDetailViewController * myShopDetailVC = [[DRMyShopDetailViewController alloc] init];
    [self.navigationController pushViewController:myShopDetailVC animated:YES];
}

//点击充值提现
- (void)butonDidClick:(UIButton *)button
{
    if (button.tag - 100 == 1)//提款
    {
        DRWithdrawViewController * withdrawVC = [[DRWithdrawViewController alloc] init];
        [self.navigationController pushViewController:withdrawVC animated:YES];
    }else if (button.tag - 100 == 0)//账单
    {
        DRBillingViewController * billingListVC = [[DRBillingViewController alloc] init];
        billingListVC.isShop = YES;
        [self.navigationController pushViewController:billingListVC animated:YES];
    }else if (button.tag - 100 == 2)//待结算订单
    {
        DRWaitSettlementOrderViewController * waitSettlementOrderVC = [[DRWaitSettlementOrderViewController alloc] init];
        [self.navigationController pushViewController:waitSettlementOrderVC animated:YES];
    }else if (button.tag - 100 == 3)//粉丝
    {
        DRMyFansViewController * myFansVC = [[DRMyFansViewController alloc] init];
        myFansVC.isShop = YES;
        [self.navigationController pushViewController:myFansVC animated:YES];
    }
}

- (void)orderViewDidTap
{
    DRShipmentListViewController * shipmentVC = [[DRShipmentListViewController alloc] init];
    [self.navigationController pushViewController:shipmentVC animated:YES];
}

- (void)orderItemViewDidTap:(UITapGestureRecognizer *)tap
{
    NSInteger tag = tap.view.tag;
    
    if (tag == 4) {
        DRReturnGoodManageViewController * returnGoodManageVC = [[DRReturnGoodManageViewController alloc] init];
        [self.navigationController pushViewController:returnGoodManageVC animated:YES];
    }else{
        int currentIndex = 0;
        if (tag == 0) {
            currentIndex = 3;
        }else if (tag == 1){
            currentIndex = 1;
        }else if (tag == 2){
            currentIndex = 2;
        }else if (tag == 3){
            currentIndex = 4;
        }
        DRShipmentListViewController * shipmentVC = [[DRShipmentListViewController alloc] init];
        shipmentVC.currentIndex = currentIndex;
        [self.navigationController pushViewController:shipmentVC animated:YES];
    }
}
#pragma mark - 设置数据
- (void)setShopData
{
    DRMyShopModel * shopModel = [DRUserDefaultTool myShopModel];
    [self.shopLogoImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%@%@",baseUrl,shopModel.storeImg]] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
    
    //店铺名
    NSMutableAttributedString * shopNameAttStr = [[NSMutableAttributedString alloc] initWithString:shopModel.storeName];
    NSAttributedString * spaceAttStr = [[NSAttributedString alloc] initWithString:@" "];
    for (NSString * tag in shopModel.tags) {
        NSURL * imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl, tag]];
        NSData * imageData = [NSData dataWithContentsOfURL:imageUrl];
        NSTextAttachment *certificationTextAttachment = [[NSTextAttachment alloc] init];
        UIImage * image = [UIImage imageWithData:imageData];
        CGFloat certificationTextAttachmentH = self.shopNameLabel.font.pointSize - 1;
        if ([tag containsString:@"base_authentication_yes"])
        {
            certificationTextAttachmentH = self.shopNameLabel.font.pointSize + 4;
        }
        CGFloat certificationTextAttachmentW = image.size.width * (certificationTextAttachmentH / image.size.height);
        certificationTextAttachment.bounds = CGRectMake(0, -1 + (self.shopNameLabel.font.pointSize - certificationTextAttachmentH) / 2, certificationTextAttachmentW, certificationTextAttachmentH);
        certificationTextAttachment.image = image;
        NSAttributedString *certificationTextAttStr = [NSAttributedString attributedStringWithAttachment:certificationTextAttachment];
        [shopNameAttStr appendAttributedString:spaceAttStr];
        [shopNameAttStr appendAttributedString:certificationTextAttStr];
    }
    self.shopNameLabel.attributedText = shopNameAttStr;
    
    [self setMoneyLabelText];
    
    for (int i = 0; i < self.orderItemViews.count; i++) {
        DRItemView * itemView = self.orderItemViews[i];
        if (i == 0) {
            itemView.bage = [shopModel.waitDeliveryCount intValue];
        }else if (i == 1) {
            itemView.bage = [shopModel.waitPayCount intValue];
        }else if (i == 2) {
            itemView.bage = [shopModel.waitPendingRegimentCount intValue];
        }else if (i == 3) {
            itemView.bage = [shopModel.waitReceiveCount intValue];
        }else if (i == 4) {
            itemView.bage = [shopModel.waitRefundCount intValue];
        }
    }
}
#pragma mark - cell delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.functionStatuss.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRIconTextTableViewCell *cell = [DRIconTextTableViewCell cellWithTableView:tableView];
    DRFunctionStatus * status = self.functionStatuss[indexPath.section];
    cell.functionName = status.functionName;
    cell.icon = status.functionIconName;
    cell.line.hidden = YES;
    if ([status.functionName isEqualToString:@"优惠活动"]) {
        cell.functionNameLabel.textColor = DRRedTextColor;
    }else
    {
        cell.functionNameLabel.textColor = DRBlackTextColor;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return DRCellH;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 9;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 9)];
    headerView.backgroundColor = DRBackgroundColor;
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0)//发布商品
    {
        [self judgeMail];
    }else if (indexPath.section == 1)//货架管理
    {
        DRGoodShelfViewController * goodShelfVC = [[DRGoodShelfViewController alloc] init];
        [self.navigationController pushViewController:goodShelfVC animated:YES];
    }else if (indexPath.section == 2)//优惠活动
    {
        DRShopActivityViewController * activityManageVC = [[DRShopActivityViewController alloc] init];
        [self.navigationController pushViewController:activityManageVC animated:YES];
    }else if (indexPath.section == 3)//运费设置
    {
        DRMailSettingViewController * mailSettingVC = [[DRMailSettingViewController alloc] init];
        [self.navigationController pushViewController:mailSettingVC animated:YES];
    }else if (indexPath.section == 4)//浏览店铺
    {
        DRLoadHtmlFileViewController * htmlVC = [[DRLoadHtmlFileViewController alloc] initWithWeb:[NSString stringWithFormat:@"%@/static/kaidian.html", baseUrl]];
        [self.navigationController pushViewController:htmlVC animated:YES];
    }else if (indexPath.section == 5)//卖家须知
    {
        DRShopDetailViewController * shopDetailVC = [[DRShopDetailViewController alloc] init];
        DRMyShopModel * shopModel = [DRUserDefaultTool myShopModel];
        shopDetailVC.shopId = shopModel.id;
        [self.navigationController pushViewController:shopDetailVC animated:YES];
    }
}

//判断是否设置邮费
- (void)judgeMail
{
    NSDictionary *bodyDic = @{
        
    };
    
    NSDictionary *headDic = @{
        @"digest":[DRTool getDigestByBodyDic:bodyDic],
        @"cmd":@"B15",
        @"userId":UserId,
    };
    waitingView
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            NSString * conditionalMailId = json[@"conditionalMailId"];
            double ruleMoney = [json[@"ruleMoney"] doubleValue];
            double freight = [json[@"freight"] doubleValue];
            if (DRStringIsEmpty(conditionalMailId) || (ruleMoney > 0 && freight == 0)) {
                UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您的运费信息不完善，请完善。" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * alertAction1 = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction * alertAction2 = [UIAlertAction actionWithTitle:@"去完善" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    DRMailSettingViewController * mailSettingVC = [[DRMailSettingViewController alloc] init];
                    [self.navigationController pushViewController:mailSettingVC animated:YES];
                }];
                [alertController addAction:alertAction1];
                [alertController addAction:alertAction2];
                [self presentViewController:alertController animated:YES completion:nil];
            }else
            {
                DRPublishGoodViewController * addGoodVC = [[DRPublishGoodViewController alloc] init];
                [self.navigationController pushViewController:addGoodVC animated:YES];
            }
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
- (NSMutableArray *)functionStatuss
{
    if (!_functionStatuss) {
        _functionStatuss = [NSMutableArray array];
        
        NSArray * iconNames = @[@"delivery_icon", @"good_shelf_icon", @"shop_activity_icon", @"mail_setting", @"seller_notice", @"black_my_store"];
        NSArray * functionNames = @[@"发布商品", @"宝贝管理", @"优惠活动", @"运费设置", @"卖家须知", @"浏览店铺"];
        for (int i = 0; i < iconNames.count; i++) {
            DRFunctionStatus * status = [[DRFunctionStatus alloc]init];
            status.functionName = functionNames[i];
            status.functionIconName = iconNames[i];
            [_functionStatuss addObject:status];
        }
    }
    return _functionStatuss;
}

- (NSMutableArray *)orderItemViews
{
    if (!_orderItemViews) {
        _orderItemViews = [NSMutableArray array];
    }
    return _orderItemViews;
}

#pragma mark - 自定义方法
- (void)setMoneyLabelText
{
    DRMyShopModel * shopModel = [DRUserDefaultTool myShopModel];
    
    for (int i = 0; i < self.labelArray.count; i++) {
        UILabel * moneyLabel = self.labelArray[i];
        if (i == 0) {
            NSString * totalIncomeStr = [DRTool formatFloat:[shopModel.totalIncome doubleValue] / 100];
            moneyLabel.text = [NSString stringWithFormat:@"总收入%@元", totalIncomeStr];
        }else if (i == 1)
        {
            NSString * withdrawMoney = [DRTool formatFloat:[shopModel.withdrawMoney doubleValue] / 100];
            moneyLabel.text = [NSString stringWithFormat:@"已提款%@元", withdrawMoney];
        }else if (i == 2)
        {
            NSString * balanceStr = [DRTool formatFloat:[shopModel.balance doubleValue] / 100];
            NSMutableAttributedString * moneyAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"待提款%@元", balanceStr]];
            [moneyAttStr addAttribute:NSForegroundColorAttributeName value:DRDefaultColor range:[ moneyAttStr.string rangeOfString:balanceStr]];
            moneyLabel.attributedText = moneyAttStr;
        }else if (i == 3)
        {
            NSString * receivablesStr = [DRTool formatFloat:[shopModel.receivables doubleValue] / 100];
            NSString * promptStr = @"(买家已支付，等待卖家发货或买家确认收货)";
            NSMutableAttributedString * moneyAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"待结算%@元\n%@", receivablesStr, promptStr]];
            [moneyAttStr addAttribute:NSForegroundColorAttributeName value:DRDefaultColor range:[moneyAttStr.string rangeOfString:receivablesStr]];
            [moneyAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:[moneyAttStr.string rangeOfString:promptStr]];
            [moneyAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(22)] range:[moneyAttStr.string rangeOfString:promptStr]];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = 30 - [UIFont systemFontOfSize:DRGetFontSize(26)].lineHeight - [UIFont systemFontOfSize:DRGetFontSize(22)].lineHeight;
            [moneyAttStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, moneyAttStr.length)];
            moneyLabel.attributedText = moneyAttStr;
        }else if (i == 4)
        {
            NSString * fansCountStr = [NSString stringWithFormat:@"%@", shopModel.fansCount];
            NSMutableAttributedString * fansCountAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"店铺粉丝%@人", fansCountStr]];
            [fansCountAttStr addAttribute:NSForegroundColorAttributeName value:DRDefaultColor range:[fansCountAttStr.string rangeOfString:fansCountStr]];
            moneyLabel.attributedText = fansCountAttStr;
        }
    }
}

#pragma mark - 初始化
- (NSMutableArray *)labelArray
{
    if (!_labelArray) {
        _labelArray = [NSMutableArray array];
    }
    return _labelArray;
}

@end
