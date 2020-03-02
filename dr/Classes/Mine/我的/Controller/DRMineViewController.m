//
//  DRMineViewController.m
//  dr
//
//  Created by apple on 17/1/14.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRMineViewController.h"
#import "DRLoadHtmlFileViewController.h"
#import "DRLoginViewController.h"
#import "DRMyFansViewController.h"
#import "DRChatViewController.h"
#import "DRSettingViewController.h"
#import "DRAccountInfoViewController.h"
#import "DRBillingViewController.h"
#import "DRRedPacketViewController.h"
#import "DRGradeDetailViewController.h"
#import "DROrderListViewController.h"
#import "DRCommentOrderListViewController.h"
#import "DRReturnGoodListViewController.h"
#import "DRMyGrouponViewController.h"
#import "DRUserShowViewController.h"
#import "DRMyAttentionViewController.h"
#import "DRSetupShopViewController.h"
#import "DRMyShopViewController.h"
#import "DRMineTableHeaderView.h"
#import "DRTextTableViewCell.h"
#import "DRItemView.h"
#import "DRShareTool.h"

@interface DRMineViewController ()<UITableViewDelegate,UITableViewDataSource, DRMineTableHeaderViewDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) DRMineTableHeaderView *mineTableHeaderView;
@property (nonatomic, strong) NSMutableArray *functionStatuss;
@property (nonatomic, weak) MJRefreshGifHeader *header;
@property (nonatomic,strong) NSMutableArray *orderItemViews;
@property (nonatomic,strong) NSMutableArray *functionItemViews;
@property (nonatomic, strong) NSArray *functionNames;

@end

@implementation DRMineViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        //通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData) name:@"loginSuccess" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData) name:@"setupShopSuccess" object:nil];
        //接收下单成功的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkoutSuccess:) name:@"checkoutSuccess" object:nil];
        //提款后的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData) name:@"withdrawSuccess" object:nil];
        //未读消息数改变时的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupUnreadMessageCount) name:@"setupUnreadMessageCount" object:nil];
        //有新消息时的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupUnreadMessageCount) name:@"haveNewMessageNote" object:nil];
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getData];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
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
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}
// 统计未读消息数
-(void)setupUnreadMessageCount
{
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    int unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
    }
    
    if (self.functionItemViews.count > 0) {
        DRItemView * itemView = self.functionItemViews[1];
        itemView.bage = unreadCount;
    }
}

- (void)getData
{
    if (!UserId || !Token) {
        return;
    }
    NSDictionary *bodyDic = @{
    };
    
    NSDictionary *headDic = @{
        @"digest":[DRTool getDigestByBodyDic:bodyDic],
        @"cmd":@"U10",
        @"userId":UserId,
    };
    //190710150926010002
    //170831213407010086
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            //储存
            DRUser *user = [DRUser mj_objectWithKeyValues:json];
            [DRUserDefaultTool saveUser:user];
            [self setData];
        }else
        {
            ShowErrorView
        }
        if ([self.header isRefreshing]) {
            [self.header endRefreshing];
        }
    } failure:^(NSError *error) {
        if ([self.header isRefreshing]) {
            [self.header endRefreshing];
        }
        DRLog(@"error:%@",error);
    }];
}

- (void)checkoutSuccess:(NSNotification *)note
{
    NSDictionary * objectDic = note.object;
    if ([objectDic[@"grouponType"] intValue] == 0) {//普通订单
        DROrderListViewController * myOrderVC = [[DROrderListViewController alloc] init];
        myOrderVC.currentIndex = 2;
        [self.navigationController pushViewController:myOrderVC animated:NO];
    }else//团购订单
    {
        DRMyGrouponViewController * myGrouponVC = [[DRMyGrouponViewController alloc] init];
        if ([objectDic[@"grouponFull"] intValue] == 0) {//未满员
            myGrouponVC.currentIndex = 1;
        }else
        {
            myGrouponVC.currentIndex = 2;
        }
        [self.navigationController pushViewController:myGrouponVC animated:NO];
    }
}
#pragma mark - 布局视图
- (void)setupChilds
{
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - tabBarH) style:UITableViewStyleGrouped];
    self.tableView = tableView;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    tableView.backgroundColor = DRBackgroundColor;
    [self.view addSubview:tableView];
    
    //初始化头部刷新控件
    MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(getData)];
    self.header = header;
    [DRTool setRefreshHeaderData:header];
    tableView.mj_header = header;
    
    //headerView
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    DRMineTableHeaderView * mineTableHeaderView = [[DRMineTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, scaleScreenWidth(177) + 60 + 9)];
    self.mineTableHeaderView = mineTableHeaderView;
    mineTableHeaderView.delegate = self;
    [headerView addSubview:mineTableHeaderView];
    
    //我的订单
    UIView *orderView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(mineTableHeaderView.frame), screenWidth, DRCellH)];
    orderView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:orderView];
    
    UITapGestureRecognizer *orderViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(orderViewDidTap)];
    [orderView addGestureRecognizer:orderViewTap];
    
    UILabel * orderLabel = [[UILabel alloc] init];
    orderLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    orderLabel.textColor = DRBlackTextColor;
    orderLabel.text = @"我的订单";
    [orderView addSubview:orderLabel];
    
    CGSize orderLabelSize = [orderLabel.text sizeWithLabelFont:orderLabel.font];
    orderLabel.frame = CGRectMake(DRMargin, 0, orderLabelSize.width, orderView.height);
    
    //角标
    CGFloat accessoryImageViewWH = 12;
    CGFloat accessoryImageViewY = (DRCellH - accessoryImageViewWH) / 2;
    UIImageView * accessoryImageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth - DRMargin - accessoryImageViewWH, accessoryImageViewY, accessoryImageViewWH, accessoryImageViewWH)];
    accessoryImageView.image = [UIImage imageNamed:@"big_black_accessory_icon"];
    [orderView addSubview:accessoryImageView];
    
    UILabel * orderDetailLabel = [[UILabel alloc] init];
    orderDetailLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    orderDetailLabel.textColor = DRGrayTextColor;
    orderDetailLabel.text = @"全部";
    [orderView addSubview:orderDetailLabel];
    
    CGSize orderDetailLabelSize = [orderDetailLabel.text sizeWithLabelFont:orderDetailLabel.font];
    orderDetailLabel.frame = CGRectMake(accessoryImageView.x - 1 - orderDetailLabelSize.width, 0, orderDetailLabelSize.width, orderView.height);
    
    //分割线
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, orderView.height - 1, screenWidth, 1)];
    line.backgroundColor = DRWhiteLineColor;
    [orderView addSubview:line];
    
    //订单选项
    UIView *allOrderItemView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(orderView.frame), screenWidth, 64)];
    allOrderItemView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:allOrderItemView];
    
    NSArray *orderItemTitles = @[@"待付款", @"待发货", @"待收货", @"待评价", @"退款"];
    NSArray *orderItemImageNames = @[@"order_wait_pay_icon", @"order_wait_deliver_icon", @"order_wait_receiving_icon", @"order_wait_comment_icon", @"order_return_icon"];
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
    
    //分割线
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(allOrderItemView.frame), screenWidth, 9)];
    lineView.backgroundColor = DRBackgroundColor;
    [headerView addSubview:lineView];
    
    //功能选项
    UIView *allFunctionItemView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame), screenWidth, 64)];
    allFunctionItemView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:allFunctionItemView];
    
    NSArray *functionItemTitles = @[@"我的拼团", @"我的消息", @"我的秀场", @"我的关注", @"我要开店"];
    NSArray *functionItemImageNames = @[@"my_groupon_icon", @"my_message_icon", @"my_show_icon", @"my_attention_icon", @"my_shop_icon"];
    DRUser *user = [DRUserDefaultTool user];
    if ([user.type intValue] == 1) {//已开店
        functionItemTitles = @[@"我的拼团", @"我的消息", @"我的秀场", @"我的关注", @"我的店铺"];
        functionItemImageNames = @[@"my_groupon_icon", @"my_message_icon", @"my_show_icon", @"my_attention_icon", @"shop"];
    }
    CGFloat functionItemViewW = screenWidth / functionItemTitles.count;
    for (int i = 0; i < functionItemTitles.count; i++) {
        DRItemView * itemView = [[DRItemView alloc] initWithFrame:CGRectMake(functionItemViewW * i, 0, functionItemViewW, allFunctionItemView.height)];
        itemView.tag = i;
        itemView.imageName = functionItemImageNames[i];
        itemView.text = functionItemTitles[i];
        [allFunctionItemView addSubview:itemView];
        
        UITapGestureRecognizer *itemViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(functionItemViewDidTap:)];
        [itemView addGestureRecognizer:itemViewTap];
        
        [self.functionItemViews addObject:itemView];
    }
    
    headerView.height = CGRectGetMaxY(allFunctionItemView.frame);
    tableView.tableHeaderView = headerView;
}
//设置数据
- (void)setData
{
    DRUser *user = [DRUserDefaultTool user];
    DRItemView * itemView = self.functionItemViews.lastObject;
    if ([user.type intValue] == 0) {//未开店
        itemView.text = @"我要开店";
        itemView.imageName = @"my_shop_icon";
    }else
    {
        itemView.text = @"我的店铺";
        itemView.imageName = @"shop";
    }
    [self.mineTableHeaderView reloadData];
    
    for (int i = 0; i < self.orderItemViews.count; i++) {
        DRItemView * itemView = self.orderItemViews[i];
        if (i == 0) {
            itemView.bage = [user.waitPayCount intValue];
        }else if (i == 1) {
            itemView.bage = [user.waitDeliveryCount intValue];
        }else if (i == 2) {
            itemView.bage = [user.waitReceiveCount intValue];
        }else if (i == 3) {
            itemView.bage = [user.waitCommentCount intValue];
        }else if (i == 4) {
            itemView.bage = 0;
        }
    }
    
    DRItemView * itemView0 = self.functionItemViews[0];
    itemView0.bage = [user.waitGroupCount intValue];
}
#pragma mark - DRMineTableHeaderViewDelegate
- (void)headerViewDidClickUserInfo
{
    DRAccountInfoViewController * accountInfoVC = [[DRAccountInfoViewController  alloc]init];
    [self.navigationController pushViewController:accountInfoVC animated:YES];
}
- (void)headerViewSettingButtonDidClickUserInfo
{
    DRSettingViewController * settingVC = [[DRSettingViewController  alloc]init];
    [self.navigationController pushViewController:settingVC animated:YES];
}
- (void)headerViewDidClickRechargeButton:(UIButton *)button
{
    if (button.tag == 0)//账单
    {
        DRBillingViewController * billingListVC = [[DRBillingViewController alloc] init];
        [self.navigationController pushViewController:billingListVC animated:YES];
    }else if (button.tag == 1)//红包
    {
        DRRedPacketViewController * redPacketVC = [[DRRedPacketViewController alloc] init];
        [self.navigationController pushViewController:redPacketVC animated:YES];
    }if (button.tag == 2)//积分
    {
        DRGradeDetailViewController * gradeDetailVC = [[DRGradeDetailViewController alloc] init];
        [self.navigationController pushViewController:gradeDetailVC animated:YES];
    }
}
#pragma mark - 按钮点击
- (void)orderViewDidTap
{
    DROrderListViewController * myOrderVC = [[DROrderListViewController alloc] init];
    [self.navigationController pushViewController:myOrderVC animated:YES];
}
- (void)orderItemViewDidTap:(UITapGestureRecognizer *)tap
{
    NSInteger tag = tap.view.tag;
    
    if (tag == 3) {
        DRCommentOrderListViewController* commentOrderListVC = [[DRCommentOrderListViewController alloc] init];
        [self.navigationController pushViewController:commentOrderListVC animated:YES];
    }else if (tag == 4)
    {
        DRReturnGoodListViewController* returnGoodListVC = [[DRReturnGoodListViewController alloc] init];
        [self.navigationController pushViewController:returnGoodListVC animated:YES];
    }
    else
    {
        int currentIndex = 0;
        if (tag == 0) {
            currentIndex = 1;
        }else if (tag == 1)
        {
            currentIndex = 2;
        }else if (tag == 2){
            currentIndex = 3;
        }
        
        DROrderListViewController * myOrderVC = [[DROrderListViewController alloc] init];
        myOrderVC.currentIndex = currentIndex;
        [self.navigationController pushViewController:myOrderVC animated:YES];
    }
}
- (void)functionItemViewDidTap:(UITapGestureRecognizer *)tap
{
    NSInteger tag = tap.view.tag;
    if (tag == 0)//我的拼团
    {
        DRMyGrouponViewController * myGrouponVC = [[DRMyGrouponViewController alloc] init];
        [self.navigationController pushViewController:myGrouponVC animated:YES];
    }else if (tag == 1)//我的消息
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"gotoMessage" object:nil];
    }else if (tag == 2)//我的秀场
    {
        DRUserShowViewController * myShowVC = [[DRUserShowViewController alloc] init];
        DRUser *user = [DRUserDefaultTool user];
        myShowVC.userId = UserId;
        myShowVC.nickName = user.nickName;
        myShowVC.userHeadImg = user.headImg;
        [self.navigationController pushViewController:myShowVC animated:YES];
    }else if (tag == 3)//我的关注
    {
        DRMyAttentionViewController * myAttentionVC = [[DRMyAttentionViewController alloc] init];
        [self.navigationController pushViewController:myAttentionVC animated:YES];
    }else if (tag == 4)//我的店铺
    {
        DRUser *user = [DRUserDefaultTool user];
        if ([user.type intValue] == 0) {//未开店
            if (DRStringIsEmpty(user.phone) || DRStringIsEmpty(user.realName)) {
                UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"完善信息后才能开店哦" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * alertAction1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction * alertAction2 = [UIAlertAction actionWithTitle:@"去完善" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    if (DRStringIsEmpty(user.realName))
                    {
                        DRChangeRealNameViewController * realNameVC = [[DRChangeRealNameViewController alloc]init];
                        [self.navigationController pushViewController:realNameVC animated:YES];
                    }else if (DRStringIsEmpty(user.phone))
                    {
                        DRBindingPhoneViewController * bindingPhoneVC = [[DRBindingPhoneViewController alloc]init];
                        [self.navigationController pushViewController:bindingPhoneVC animated:YES];
                    }
                }];
                [alertController addAction:alertAction1];
                [alertController addAction:alertAction2];
                [self presentViewController:alertController animated:YES completion:nil];
            }else
            {
                DRSetupShopViewController * setupShopVC = [[DRSetupShopViewController alloc] init];
                [self.navigationController pushViewController:setupShopVC animated:YES];
            }
        }else//已开店
        {
            NSDictionary *bodyDic = @{
            };
            
            NSDictionary *headDic = @{
                @"digest":[DRTool getDigestByBodyDic:bodyDic],
                @"cmd":@"B01",
                @"userId":UserId,
            };
            waitingView
            [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
                DRLog(@"%@",json);
                [MBProgressHUD hideHUDForView:self.view];
                if (SUCCESS) {
                    DRMyShopViewController * myShopVC = [[DRMyShopViewController alloc] init];
                    [self.navigationController pushViewController:myShopVC animated:YES];
                }else
                {
                    ShowErrorView
                }
            } failure:^(NSError *error) {
                [MBProgressHUD hideHUDForView:self.view];
                if ([self.header isRefreshing]) {
                    [self.header endRefreshing];
                }
                DRLog(@"error:%@",error);
            }];
        }
    }
}
#pragma mark - cell delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.functionNames.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRTextTableViewCell * cell = [DRTextTableViewCell cellWithTableView:tableView];
    cell.functionName = self.functionNames[indexPath.row];
    //分割线
    if (indexPath.row == 0) {
        cell.line.hidden = YES;
    }else
    {
        cell.line.hidden = NO;
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return DRCellH;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 9;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 9;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [DRShareTool shareApp];
    }else if (indexPath.row == 1)
    {
        if((!UserId || !Token))
        {
            DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
            [self presentViewController:loginVC animated:YES completion:nil];
        }
        DRChatViewController *chatVC = [[DRChatViewController alloc] initWithConversationChatter:@"200000000000000003" conversationType:EMConversationTypeChat];
        chatVC.title = @"吾花肉客服";
        [self.navigationController pushViewController:chatVC animated:YES];
    }else if (indexPath.row == 2)
    {
        DRMyFansViewController * myFansVC = [[DRMyFansViewController alloc] init];
        [self.navigationController pushViewController:myFansVC animated:YES];
    }else if (indexPath.row == 3)
    {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"微信公众号：Wuhuarou_2017，复制并打开微信？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * alertAction1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction * alertAction2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //复制账号
            UIPasteboard *pab = [UIPasteboard generalPasteboard];
            NSString *string = @"wuhuarou_2017";
            [pab setString:string];
            [MBProgressHUD showSuccess:@"复制成功"];
            [self performSelector:@selector(skipWeixin) withObject:self afterDelay:1.0f];
        }];
        [alertController addAction:alertAction1];
        [alertController addAction:alertAction2];
        [self presentViewController:alertController animated:YES completion:nil];
    }else if (indexPath.row == 4)
    {
        DRLoadHtmlFileViewController * htmlVC = [[DRLoadHtmlFileViewController alloc] initWithWeb:[NSString stringWithFormat:@"%@/static/maijia.html", baseUrl]];
        [self.navigationController pushViewController:htmlVC animated:YES];
    }else if (indexPath.row == 5)
    {
        DRSettingViewController * settingVC = [[DRSettingViewController  alloc]init];
        [self.navigationController pushViewController:settingVC animated:YES];
    }
}

- (void)skipWeixin
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"weixin://"]];
}

#pragma mark - 初始化
- (NSMutableArray *)functionItemViews
{
    if (!_functionItemViews) {
        _functionItemViews = [NSMutableArray array];
    }
    return _functionItemViews;
}
- (NSMutableArray *)orderItemViews
{
    if (!_orderItemViews) {
        _orderItemViews = [NSMutableArray array];
    }
    return _orderItemViews;
}
#pragma mark - 初始化
- (NSArray *)functionNames
{
    if (!_functionNames) {
        _functionNames = @[@"分享好友", @"在线客服", @"我的粉丝", @"微信公众号", @"买家须知", @"设置"];
    }
    return _functionNames;
}

@end
