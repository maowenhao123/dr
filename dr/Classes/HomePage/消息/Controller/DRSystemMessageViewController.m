//
//  DRSystemMessageViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/10/20.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRSystemMessageViewController.h"
#import "DRLoadHtmlFileViewController.h"
#import "DRLoginViewController.h"
#import "DRGoodDetailViewController.h"
#import "DRShowViewController.h"
#import "DRShowDetailViewController.h"
#import "DRMyFansViewController.h"
#import "DRMaintainViewController.h"
#import "DRMaintainDetailViewController.h"
#import "DRGoodListViewController.h"
#import "DRShipmentListViewController.h"
#import "DRShipmentDetailViewController.h"
#import "DRReturnGoodHandleViewController.h"
#import "DRReturnGoodDetailViewController.h"
#import "DROrderDetailViewController.h"
#import "UITableView+DRNoData.h"

@interface DRSystemMessageViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,weak) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation DRSystemMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupChilds];
    [self getData];
    //有新消息时的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData) name:@"haveNewMessageNote" object:nil];
}

- (void)getData
{
    [self.conversation loadMessagesStartFromId:nil count:10000 searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
        if (!aError && [aMessages count]) {
            aMessages = [[aMessages reverseObjectEnumerator] allObjects];
            self.dataArray = [NSMutableArray arrayWithArray:aMessages];
            [self.tableView reloadData];
        }
    }];
    
    EMError * error;
    [self.conversation markAllMessagesAsRead:&error];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setupUnreadMessageCount" object:nil];
}

- (void)setupChilds
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStylePlain target:self action:@selector(deleteAllMessages:)];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH)];
    self.tableView = tableView;
    tableView.backgroundColor = DRBackgroundColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    [self.view addSubview:tableView];
}

//清空所有消息
- (void)deleteAllMessages:(id)sender
{
    if (self.dataArray.count == 0) {
        [MBProgressHUD showError:@"消息已经清空"];
        return;
    }
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"确认清空所有消息吗?"  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * alertAction1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction * alertAction2 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self.conversation deleteAllMessages:nil];
        [self.dataArray removeAllObjects];
        [self.tableView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setupUnreadMessageCount" object:nil];
    }];
    [alertController addAction:alertAction1];
    [alertController addAction:alertAction2];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 0) {
        [tableView showNoDataWithTitle:@"" description:@"暂无消息" rowCount:self.dataArray.count];
    }
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRSystemMessageTableViewCell *cell = [DRSystemMessageTableViewCell cellWithTableView:tableView];
    cell.systemMessageType = self.systemMessageType;
    cell.messageModel = self.dataArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EMMessage * messageModel = self.dataArray[indexPath.row];
    
    EMMessageBody *messageBody = messageModel.body;
    if (messageBody.type == EMMessageBodyTypeText) {
        NSString * titleStr = @"";
        if (self.systemMessageType == SystemMessage) {
            NSDictionary * data = [DRTool dictionaryWithJsonString:messageModel.ext[@"data"]];
            titleStr = data[@"name"];
        }else
        {
            NSString * type = [NSString stringWithFormat:@"%@", messageModel.ext[@"type"]];
            NSDictionary * typeDic = @{
                                        @"101":@"发货提醒",
                                        @"102":@"收货通知",
                                        @"103":@"退款申请",
                                        @"105":@"团购撤单",
                                        @"201":@"发货通知",
                                        @"202":@"退款结果",
                                        @"203":@"拼团成功",
                                        @"204":@"无货撤单",
                                        @"205":@"团购过期",
                                        };
            titleStr = typeDic[type];
        }
        CGSize titleLabelSize = [titleStr sizeWithFont:[UIFont systemFontOfSize:DRGetFontSize(28)] maxSize:CGSizeMake(screenWidth - 2 * DRMargin - 90 - 2 * DRMargin, CGFLOAT_MAX)];
        NSString *messageStr = ((EMTextMessageBody *)messageBody).text;
        NSMutableAttributedString *messageAttStr = [[NSMutableAttributedString alloc] initWithString:messageStr];
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 3;//行间距
        [messageAttStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, messageAttStr.length)];
        [messageAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(26)] range:NSMakeRange(0, messageAttStr.length)];
        CGSize detailLabelize = [messageAttStr boundingRectWithSize:CGSizeMake(screenWidth - 2 * DRMargin - 90 - 2 * DRMargin, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        CGFloat customContentViewH = DRMargin + 5 + titleLabelSize.height + DRMargin + detailLabelize.height + DRMargin;
        customContentViewH = customContentViewH < 100 ? 100 : customContentViewH;
        return 30 + customContentViewH;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EMMessage * messageModel = self.dataArray[indexPath.row];
    /*
     type =1 一物一拍
     type =2 批发
     type =3 团购
     type =4 玩家秀
     type =5 养护
     type =6 土壤
     type =7 盆器
     type =8 药肥
     type =9 工具
     */
    if (self.systemMessageType == SystemMessage) {//系统消息
        int type = [messageModel.ext[@"type"] intValue];
        NSDictionary * data = [DRTool dictionaryWithJsonString:messageModel.ext[@"data"]];
        if (type == 4) {
            if(!UserId || !Token)
            {
                DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
                [self presentViewController:loginVC animated:YES completion:nil];
                return;
            }
            DRShowViewController * showVC = [[DRShowViewController alloc] init];
            [self.navigationController pushViewController:showVC animated:YES];
        }else if (type == 5)
        {
            NSString * twoTabId = [NSString stringWithFormat:@"%@", data[@"twoTabId"]];
            if (DRStringIsEmpty(twoTabId)) {
                DRMaintainViewController * maintainVC = [[DRMaintainViewController alloc] init];
                [self.navigationController pushViewController:maintainVC animated:YES];
            }else
            {
                DRMaintainDetailViewController * maintainVC = [[DRMaintainDetailViewController alloc] init];
                maintainVC.maintainId = twoTabId;
                [self.navigationController pushViewController:maintainVC animated:YES];
            }
        }else if (type == 10)
        {
            DRLoadHtmlFileViewController * htmlVC = [[DRLoadHtmlFileViewController alloc] initWithWeb:[NSString stringWithFormat:@"%@",data[@"url"]]];
            [self.navigationController pushViewController:htmlVC animated:YES];
        }else
        {
            NSString * twoTabId = [NSString stringWithFormat:@"%@", data[@"twoTabId"]];
            if (DRStringIsEmpty(twoTabId)) {
                DRGoodListViewController * goodListVC = [[DRGoodListViewController alloc] init];
                if (type == 1) {//一物一拍
                    goodListVC.sellType = @"1";
                }else if (type == 2) {//批发
                    goodListVC.isGroup = @"0";
                    goodListVC.sellType = @"2";
                }else if (type == 3)//团购
                {
                    goodListVC.isGroup = @"1";
                }else
                {
                    NSDictionary * data = [DRTool dictionaryWithJsonString:messageModel.ext[@"data"]];
                    goodListVC.categoryId = [NSString stringWithFormat:@"%@", data[@"categoryId"]];
                }
                [self.navigationController pushViewController:goodListVC animated:YES];
            }else
            {
                DRGoodDetailViewController * goodVC = [[DRGoodDetailViewController alloc] init];
                goodVC.goodId = twoTabId;
                [self.navigationController pushViewController:goodVC animated:YES];
            }
        }
    }else if (self.systemMessageType == OrderMessage)
    {
        if (DRStringIsEmpty(messageModel.ext[@"orderId"])) {
            return;
        }
        int type = [messageModel.ext[@"type"] intValue];
        if (type == 101) {//发货提醒
            DRShipmentListViewController * shipmentListVC = [[DRShipmentListViewController alloc] init];
            shipmentListVC.currentIndex = 3;
            [self.navigationController pushViewController:shipmentListVC animated:YES];
        }else if (type == 102 || type == 105)//收货通知 团购撤单
        {
            DRShipmentDetailViewController * shipmentDetailVC = [[DRShipmentDetailViewController alloc] init];
            shipmentDetailVC.orderId = messageModel.ext[@"orderId"];
            [self.navigationController pushViewController:shipmentDetailVC animated:YES];
        }else if (type == 103)//退款申请
        {
            DRReturnGoodHandleViewController * returnGoodManageVC = [[DRReturnGoodHandleViewController alloc] init];
            returnGoodManageVC.returnGoodId = messageModel.ext[@"orderId"];
            [self.navigationController pushViewController:returnGoodManageVC animated:YES];
        }else if (type == 202)//退款结果
        {
            DRReturnGoodDetailViewController* returnGoodVC = [[DRReturnGoodDetailViewController alloc] init];
            returnGoodVC.returnGoodId = messageModel.ext[@"orderId"];
            [self.navigationController pushViewController:returnGoodVC animated:YES];
        }else if (type == 201 || type == 203 || type == 204 || type == 205)//@"发货通知",@"拼团成功",@"无货撤单",@"团购过期",
        {
            DROrderDetailViewController * orderDetailVC = [[DROrderDetailViewController alloc] init];
            orderDetailVC.orderId = messageModel.ext[@"orderId"];
            [self.navigationController pushViewController:orderDetailVC animated:YES];
        }
    }else if (self.systemMessageType == InteractiveMessage)
    {
        NSDictionary *ext = messageModel.ext;
        NSString * type = [NSString stringWithFormat:@"%@", ext[@"type"]];
        NSDictionary * data = [DRTool dictionaryWithJsonString:ext[@"data"]];
        if ([type isEqualToString:@"INTERACT_ART_SHOW_PRAISE"] || [type isEqualToString:@"INTERACT_ART_SHOW_COMMENT"] || [type isEqualToString:@"INTERACT_ART_SHOW_COMMENT_REPLY"]) {
            DRShowDetailViewController * showDetailVC = [[DRShowDetailViewController alloc] init];
            showDetailVC.showId = [NSString stringWithFormat:@"%@", data[@"detailId"]];
            [self.navigationController pushViewController:showDetailVC animated:YES];
        }else if ([type isEqualToString:@"INTERACT_GOODS_COMMENT"])
        {
            DRGoodDetailViewController * goodVC = [[DRGoodDetailViewController alloc] init];
            goodVC.goodId = [NSString stringWithFormat:@"%@", data[@"detailId"]];
            [self.navigationController pushViewController:goodVC animated:YES];
        }else if ([type isEqualToString:@"INTERACT_STORE_FOCUS"])
        {
            DRMyFansViewController * myFansVC = [[DRMyFansViewController alloc] init];
            myFansVC.isShop = YES;
            [self.navigationController pushViewController:myFansVC animated:YES];
        }else if ([type isEqualToString:@"INTERACT_USER_FOCUS"])
        {
            DRMyFansViewController * myFansVC = [[DRMyFansViewController alloc] init];
            [self.navigationController pushViewController:myFansVC animated:YES];
        }
    }
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
