//
//  DRChatViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/10/18.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRChatViewController.h"
#import "DRMessageChooseGoodViewController.h"
#import "DRShopDetailViewController.h"
#import "DRGoodDetailViewController.h"
#import "DRMessageGoodInfoTableViewCell.h"
#import "DRChatOrderView.h"
#import "IQKeyboardManager.h"
#import "DRIMTool.h"

@interface DRChatViewController ()<EaseMessageViewControllerDelegate, EaseMessageViewControllerDataSource, MessageChooseGoodViewControllerDelegate>

@property (nonatomic, strong) DRChatOrderView * orderView;

@end

@implementation DRChatViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager];
    keyboardManager.enable = NO;
    keyboardManager.enableAutoToolbar = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager];
    keyboardManager.enable = YES;
    keyboardManager.enableAutoToolbar = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = DRBackgroundColor;
    self.showRefreshHeader = YES;
    self.delegate = self;
    self.dataSource = self;
    [self _setupBarButtonItem];
    [self.chatBarMoreView insertItemWithImage:[UIImage imageNamed:@"send_goods_info"] highlightedImage:[UIImage imageNamed:@"send_goods_info"] title:@"发送商品"];
    
    self.orderView = [[DRChatOrderView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0) style:UITableViewStylePlain];
    [self.view addSubview:self.orderView];
    
    [self getOrderList];
}

- (void)_setupBarButtonItem
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"black_back_bar"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
   
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStylePlain target:self action:@selector(deleteAllMessages:)];
}

- (void)getOrderList
{
    NSDictionary *bodyDic = @{
                              @"pageIndex":@(1),
                              @"pageSize":@(1000000),
                              @"buyerUserId": self.conversation.conversationId
                              };
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"S20",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            NSMutableArray * dataArray = [NSMutableArray array];
            NSArray * newDataArray = [DROrderModel  mj_objectArrayWithKeyValuesArray:json[@"list"]];
            NSArray *orders = json[@"list"];
            for (DROrderModel * orderModel in newDataArray) {
                NSInteger index = [newDataArray indexOfObject:orderModel];
                NSArray *storeOrders = [DRStoreOrderModel  mj_objectArrayWithKeyValuesArray:orders[index][@"storeOrders"]];
                orderModel.storeOrders = storeOrders;
                
                NSArray *detail = orders[index][@"storeOrders"];
                for (DRStoreOrderModel * storeOrder in orderModel.storeOrders) {
                    NSInteger index_ = [orderModel.storeOrders indexOfObject:storeOrder];
                    NSArray *detail_ = [DROrderItemDetailModel  mj_objectArrayWithKeyValuesArray:detail[index_][@"detail"]];
                    storeOrder.detail = detail_;
                }
            }
            dataArray = [NSMutableArray arrayWithArray:newDataArray];
            if (!DRDictIsEmpty(self.goodInfo)) {
                [self setHeaderView];
            }else
            {
                if (dataArray.count > 0) {
                    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 30)];
                    headerView.backgroundColor = self.tableView.backgroundColor;
                    self.tableView.tableHeaderView = headerView;
                }
                self.orderView.dataArray = dataArray;
            }
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

- (void)setHeaderView
{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 137)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    //图片
    UIImageView * goodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, DRMargin, 80, 80)];
    goodImageView.contentMode = UIViewContentModeScaleAspectFill;
    goodImageView.layer.masksToBounds = YES;
    [headerView addSubview:goodImageView];
    NSString *imageUrl = [NSString stringWithFormat:@"%@%@%@", baseUrl, self.goodInfo[@"spreadPics"], smallPicUrl];
    [goodImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    //商品名称
    UILabel * goodNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(goodImageView.frame) + DRMargin, goodImageView.y, screenWidth - DRMargin - (CGRectGetMaxX(goodImageView.frame) + DRMargin), goodImageView.height - 30)];
    goodNameLabel.textColor = DRBlackTextColor;
    goodNameLabel.numberOfLines = 0;
    goodNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [headerView addSubview:goodNameLabel];
    NSString * name = self.goodInfo[@"name"];
    NSString * description = self.goodInfo[@"description"];
    if (DRStringIsEmpty(description)) {
        goodNameLabel.text = name;
    }else
    {
        NSMutableAttributedString * nameAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", name, description]];
        [nameAttStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, name.length)];
        [nameAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(name.length, nameAttStr.length - name.length)];
        goodNameLabel.attributedText = nameAttStr;
    }
    
    //商品价格
    UILabel * goodPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(goodImageView.frame) + DRMargin, CGRectGetMaxY(goodNameLabel.frame), screenWidth - DRMargin - (CGRectGetMaxX(goodImageView.frame) + DRMargin), goodImageView.height - CGRectGetMaxY(goodNameLabel.frame))];
    goodPriceLabel.textColor = [UIColor redColor];
    goodPriceLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    goodPriceLabel.text = self.goodInfo[@"price"];
    [headerView addSubview:goodPriceLabel];
    
    //发送链接
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat sendButtonW = 100;
    CGFloat sendButtonH = 27;
    CGFloat sendButtonX = (screenWidth - sendButtonW) / 2;
    sendButton.frame = CGRectMake(sendButtonX, 100, sendButtonW, sendButtonH);
    [sendButton setTitle:@"发送链接" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    sendButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    [sendButton addTarget:self action:@selector(sendGoodsInfo) forControlEvents:UIControlEventTouchUpInside];
    sendButton.layer.masksToBounds = YES;
    sendButton.layer.cornerRadius = sendButton.height / 2;
    sendButton.layer.borderColor = [UIColor redColor].CGColor;
    sendButton.layer.borderWidth = 1;
    [headerView addSubview:sendButton];
    
    self.tableView.tableHeaderView = headerView;
}

- (void)sendGoodsInfo
{
    NSDictionary * ext = @{
                           @"ProductMessage":[DRTool jsonStringWithObject:self.goodInfo],
                           };
    [self sendTextMessage:@"" withExt:ext];
}
#pragma mark - EaseMessageViewControllerDelegate
- (UITableViewCell *)messageViewController:(UITableView *)tableView
                       cellForMessageModel:(id<IMessageModel>)messageModel
{
    if (messageModel.bodyType == EMMessageBodyTypeText) {
        NSDictionary *ext = [[NSDictionary alloc]initWithDictionary:messageModel.message.ext];
        NSString *goodsInfo = ext[@"ProductMessage"];
        if (!DRStringIsEmpty(goodsInfo)) {
            NSString *CellIdentifier = [DRMessageGoodInfoTableViewCell cellIdentifierWithModel:messageModel];
            DRMessageGoodInfoTableViewCell *cell = (DRMessageGoodInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[DRMessageGoodInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier model:messageModel];
                cell.delegate = self;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.model = messageModel;
            return cell;
        }
    }
    return nil;
}

- (CGFloat)messageViewController:(EaseMessageViewController *)viewController heightForMessageModel:(id<IMessageModel>)messageModel withCellWidth:(CGFloat)cellWidth
{
    if (messageModel.bodyType == EMMessageBodyTypeText) {
        NSDictionary *ext = [[NSDictionary alloc]initWithDictionary:messageModel.message.ext];
        NSString *goodsInfo = ext[@"ProductMessage"];
        if (!DRStringIsEmpty(goodsInfo)) {
            return [DRMessageGoodInfoTableViewCell cellHeightWithModel:messageModel];
        }
    }
    return 0;
}

- (BOOL)messageViewController:(EaseMessageViewController *)viewController didSelectMessageModel:(id<IMessageModel>)messageModel
{
    if (messageModel.bodyType == EMMessageBodyTypeText) {
        NSDictionary *ext = [[NSDictionary alloc]initWithDictionary:messageModel.message.ext];
        NSString *goodsInfo = ext[@"ProductMessage"];
        if (!DRStringIsEmpty(goodsInfo)) {
            [self gotoGoodDetailVCWithDic:[DRTool dictionaryWithJsonString:goodsInfo]];
            return YES;
        }
    }
    return NO;
}

- (void)gotoGoodDetailVCWithDic:(NSDictionary *)goodsInfo
{
    DRGoodDetailViewController * goodDetailVC = [[DRGoodDetailViewController alloc] init];
    if ([goodsInfo[@"sellType"] intValue] == 1) {//普通商品
        goodDetailVC.goodId = goodsInfo[@"goodsId"];
    }else
    {
        goodDetailVC.isGroupon = YES;
        goodDetailVC.grouponId = goodsInfo[@"grouponId"];
    }
    [self.navigationController pushViewController:goodDetailVC animated:YES];
}

- (void)messageViewController:(EaseMessageViewController *)viewController
            didSelectMoreView:(EaseChatBarMoreView *)moreView
                      AtIndex:(NSInteger)index
{
    if (index == 2) {
        DRMessageChooseGoodViewController * chooseGoodVC = [[DRMessageChooseGoodViewController alloc] init];
        chooseGoodVC.delegate = self;
        [self.navigationController pushViewController:chooseGoodVC animated:YES];
    }
}
- (void)chooseGoodWithArray:(NSArray *)goodArray
{
    for (NSDictionary * dic in goodArray) {
        NSDictionary * ext = @{
                               @"ProductMessage":[DRTool jsonStringWithObject:dic],
                               };
        [self sendTextMessage:@"" withExt:ext];
    }
}
#pragma mark - EaseMessageViewControllerDataSource

- (id<IMessageModel>)messageViewController:(EaseMessageViewController *)viewController
                           modelForMessage:(EMMessage *)message
{
    id<IMessageModel> model = nil;
    model = [[EaseMessageModel alloc] initWithMessage:message];
    if (model.isSender)//自己
    {
        DRUser *user = [DRUserDefaultTool user];
        DRMyShopModel * shopModel = [DRUserDefaultTool myShopModel];
        
        //头像
        if ([user.type intValue] == 0) {//未开店
            if (DRStringIsEmpty(user.headImg)) {
                model.avatarImage = [UIImage imageNamed:@"chat_avatar_placeholder"];
            }else
            {
                model.avatarImage = [UIImage imageNamed:@"chat_avatar_placeholder"];
                model.avatarURLPath = [NSString stringWithFormat:@"%@%@", baseUrl, user.headImg];
            }
        }else
        {
            if (DRStringIsEmpty(shopModel.storeImg)) {
                model.avatarImage = [UIImage imageNamed:@"chat_avatar_placeholder"];
            }else
            {
                model.avatarImage = [UIImage imageNamed:@"chat_avatar_placeholder"];
                model.avatarURLPath = [NSString stringWithFormat: @"%@%@",baseUrl, shopModel.storeImg];
            }
        }
        
        //昵称
        if ([user.type intValue] == 0) {//未开店
            if (DRStringIsEmpty(user.nickName)) {
                model.nickname = @"我";
            }else
            {
                model.nickname = user.nickName;
            }
        }else
        {
            if (DRStringIsEmpty(shopModel.storeName)) {
                model.nickname = @"我";
            }else
            {
                model.nickname = shopModel.storeName;
            }
        }
    }else//对方
    {
        //头像
        if ([self.conversation.conversationId isEqualToString:@"200000000000000003"]) {
            model.avatarImage = [UIImage imageNamed:@"kefu_avatar"];
        }else
        {
            if (DRStringIsEmpty(model.message.ext[@"avatar"])) {
                model.avatarImage = [UIImage imageNamed:@"chat_avatar_placeholder"];
                model.avatarURLPath = [DRIMTool getavatarURLPathWithUsername:self.conversation.conversationId];
            }else
            {
                model.avatarImage = [UIImage imageNamed:@"chat_avatar_placeholder"];
                model.avatarURLPath = model.message.ext[@"avatar"];
            }
        }
        //昵称
        if ([self.conversation.conversationId isEqualToString:@"200000000000000003"]) {
            model.nickname = @"吾花肉客服";
        }else
        {
            if (DRStringIsEmpty(model.message.ext[@"nickName"])) {
                model.avatarURLPath = [DRIMTool getNickNameWithUsername:self.conversation.conversationId];
            }else
            {
                model.nickname = model.message.ext[@"nickName"];
            }
        }
    }
    return model;
}

- (BOOL)messageViewController:(EaseMessageViewController *)viewController
   canLongPressRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)messageViewController:(EaseMessageViewController *)viewController
   didLongPressRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataArray objectAtIndex:indexPath.row];
    if (![object isKindOfClass:[NSString class]]) {
        EaseMessageCell *cell = (EaseMessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[EaseMessageCell class]]) {
            [cell becomeFirstResponder];
            self.menuIndexPath = indexPath;
            [self showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:cell.model.bodyType];
        }
    }
    return YES;
}

- (void)messageViewController:(EaseMessageViewController *)viewController
  didSelectAvatarMessageModel:(id<IMessageModel>)messageModel
{
    NSDictionary *ext = messageModel.message.ext;
    if (!DRStringIsEmpty(ext[@"storeId"])) {
        DRShopDetailViewController * shopVC = [[DRShopDetailViewController alloc] init];
        shopVC.shopId = ext[@"storeId"];
        [self.navigationController pushViewController:shopVC animated:YES];
    }
}
#pragma mark - action
//返回
- (void)backAction
{
    if (self.deleteConversationIfNull) {
        //判断当前会话是否为空，若符合则删除该会话
        EMMessage *message = [self.conversation latestMessage];
        if (message == nil) {
            [[EMClient sharedClient].chatManager deleteConversation:self.conversation.conversationId isDeleteMessages:NO completion:nil];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
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
        self.messageTimeIntervalTag = -1;
        [self.conversation deleteAllMessages:nil];
        [self.dataArray removeAllObjects];
        [self.messsagesSource removeAllObjects];
        
        [self.tableView reloadData];
    }];
    [alertController addAction:alertAction1];
    [alertController addAction:alertAction2];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
