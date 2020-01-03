//
//  DRConversationListController.m
//  dr
//
//  Created by 毛文豪 on 2017/10/18.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRConversationListController.h"
#import "DRSystemMessageViewController.h"
#import "DRChatViewController.h"
#import "DRSystemMessageView.h"
#import "DRDateTool.h"
#import "DRIMTool.h"

@interface DRConversationListController ()<EaseConversationListViewControllerDelegate, EaseConversationListViewControllerDataSource, SystemMessageViewDelegate>

@property (nonatomic,weak) DRSystemMessageView * orderMessageView;
@property (nonatomic,weak) DRSystemMessageView * systemMessageView;
@property (nonatomic,weak) DRSystemMessageView * interactiveMessageView;
@property (strong, nonatomic) EMConversation *orderConversation;
@property (strong, nonatomic) EMConversation *systemConversation;
@property (strong, nonatomic) EMConversation *interactiveConversation;

@end

@implementation DRConversationListController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self tableViewDidTriggerHeaderRefresh];
    [self removeEmptyConversationsFromDB];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"消息中心";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"重新连接" style:UIBarButtonItemStylePlain target:self action:@selector(reconnection)];
    self.delegate = self;
    self.dataSource = self;
    self.showRefreshHeader = YES;
    [self _setupTableViewHeaderView];
    [self getSystemMessage];
    //有新消息时的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(haveNewMessage) name:@"haveNewMessageNote" object:nil];
    //消息状态改变时的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(haveNewMessage) name:@"setupUnreadMessageCount" object:nil];
    //环信登录成功时的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(haveNewMessage) name:@"hxLoginSuccess" object:nil];
}

- (void)reconnection
{
    [DRTool loginImAccount];
}

- (void)_setupTableViewHeaderView
{
    CGFloat cellH = 60;
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, cellH * 3 + 9)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    DRMessageModel * orderMessageModel = [DRMessageModel new];
    orderMessageModel.title = @"订单消息";
    orderMessageModel.imageName = @"order_message";
    orderMessageModel.detail = @"暂无消息";
    DRSystemMessageView * orderMessageView = [[DRSystemMessageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, cellH)];
    self.orderMessageView = orderMessageView;
    orderMessageView.delegate = self;
    orderMessageView.messageModel = orderMessageModel;
    [headerView addSubview:orderMessageView];
    
    DRMessageModel * systemMessageModel = [DRMessageModel new];
    systemMessageModel.title = @"系统消息";
    systemMessageModel.imageName = @"note_message";
    systemMessageModel.detail = @"暂无消息";
    DRSystemMessageView * systemMessageView = [[DRSystemMessageView alloc] initWithFrame:CGRectMake(0, cellH, screenWidth, cellH)];
    self.systemMessageView = systemMessageView;
    systemMessageView.delegate = self;
    systemMessageView.messageModel = systemMessageModel;
    [headerView addSubview:systemMessageView];
    
    DRMessageModel * interactiveMessageModel = [DRMessageModel new];
    interactiveMessageModel.title = @"互动消息";
    interactiveMessageModel.imageName = @"interactive_message";
    interactiveMessageModel.detail = @"暂无消息";
    DRSystemMessageView * interactiveMessageView = [[DRSystemMessageView alloc] initWithFrame:CGRectMake(0, cellH * 2, screenWidth, cellH)];
    self.interactiveMessageView = interactiveMessageView;
    interactiveMessageView.delegate = self;
    interactiveMessageView.messageModel = interactiveMessageModel;
    [headerView addSubview:interactiveMessageView];
    
    //分割线
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, cellH * 3, screenWidth, 9)];
    lineView.backgroundColor = DRBackgroundColor;
    [headerView addSubview:lineView];
    
    self.tableView.tableHeaderView = headerView;
}

- (void)haveNewMessage
{
    dispatch_async(dispatch_get_main_queue(),^{//主线程
        [self tableViewDidTriggerHeaderRefresh];
        [self getSystemMessage];
    });
}

- (void)getSystemMessage
{
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    for (EMConversation *conversation in conversations) {
        //获取订单消息
        if ([conversation.conversationId isEqualToString:@"system"]) {
            self.orderConversation = conversation;
            [self setOrderMessageData];
        }
        //获取系统消息
        if ([conversation.conversationId isEqualToString:@"message"]) {
            self.systemConversation = conversation;
            [self setSystemMessageData];
        }
        //获取互动消息
        if ([conversation.conversationId isEqualToString:@"interact"]) {
            self.interactiveConversation = conversation;
            [self setInteractiveMessageData];
        }
    }
}

- (void)setOrderMessageData
{
    [self.orderConversation loadMessagesStartFromId:nil count:1 searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
        if (!aError && [aMessages count]) {
            EMMessage *emessageModel = aMessages.lastObject;
            
            DRMessageModel * orderMessageModel = self.orderMessageView.messageModel;
            orderMessageModel.time = [NSString stringWithFormat:@"%@",[DRDateTool getTimeByTimestamp:emessageModel.localTime format:@"yyyy-MM-dd"]];
            EMMessageBody *messageBody = emessageModel.body;
            if (messageBody.type == EMMessageBodyTypeText) {
                orderMessageModel.detail = ((EMTextMessageBody *)messageBody).text;
            }
            self.orderMessageView.messageModel = orderMessageModel;
        }else
        {
            self.orderMessageView.timeLabel.text = nil;
            self.orderMessageView.contentLabel.text = @"暂无消息";
        }
    }];
    
    int unReadCount = [self.orderConversation unreadMessagesCount];
    self.orderMessageView.badge = unReadCount;
}

- (void)setSystemMessageData
{
    [self.systemConversation loadMessagesStartFromId:nil count:1 searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
        if (!aError && [aMessages count]) {
            EMMessage *emessageModel = aMessages.lastObject;
            
            DRMessageModel * systemMessageModel = self.systemMessageView.messageModel;
            systemMessageModel.time = [NSString stringWithFormat:@"%@",[DRDateTool getTimeByTimestamp:emessageModel.localTime format:@"yyyy-MM-dd"]];
            EMMessageBody *messageBody = emessageModel.body;
            if (messageBody.type == EMMessageBodyTypeText) {
                systemMessageModel.detail = ((EMTextMessageBody *)messageBody).text;
            }
            self.systemMessageView.messageModel = systemMessageModel;
        }else
        {
            self.systemMessageView.timeLabel.text = nil;
            self.systemMessageView.contentLabel.text = @"暂无消息";
        }
    }];
    
    int unReadCount = [self.systemConversation unreadMessagesCount];
    self.systemMessageView.badge = unReadCount;
}

- (void)setInteractiveMessageData
{
    [self.interactiveConversation loadMessagesStartFromId:nil count:1 searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
        if (!aError && [aMessages count]) {
            EMMessage *emessageModel = aMessages.lastObject;
            
            DRMessageModel * interactiveMessageModel = self.interactiveMessageView.messageModel;
            interactiveMessageModel.time = [NSString stringWithFormat:@"%@",[DRDateTool getTimeByTimestamp:emessageModel.localTime format:@"yyyy-MM-dd"]];
            EMMessageBody *messageBody = emessageModel.body;
            if (messageBody.type == EMMessageBodyTypeText) {
                interactiveMessageModel.detail = ((EMTextMessageBody *)messageBody).text;
            }
            self.interactiveMessageView.messageModel = interactiveMessageModel;
        }else
        {
            self.interactiveMessageView.timeLabel.text = nil;
            self.interactiveMessageView.contentLabel.text = @"暂无消息";
        }
    }];
    
    int unReadCount = [self.interactiveConversation unreadMessagesCount];
    self.interactiveMessageView.badge = unReadCount;
}

- (void)systemMessageViewDidClick:(DRSystemMessageView *)systemMessageView
{
    DRSystemMessageViewController * messageVC = [[DRSystemMessageViewController alloc] init];
    messageVC.title = systemMessageView.messageModel.title;
    if (self.orderMessageView == systemMessageView) {
        messageVC.systemMessageType = OrderMessage;
        messageVC.conversation = self.orderConversation;
    }else if (self.systemMessageView == systemMessageView)
    {
        messageVC.systemMessageType = SystemMessage;
        messageVC.conversation = self.systemConversation;
    }else if (self.interactiveMessageView == systemMessageView)
    {
        messageVC.systemMessageType = InteractiveMessage;
        messageVC.conversation = self.interactiveConversation;
    }
    [self.navigationController pushViewController:messageVC animated:YES];
}

- (void)removeEmptyConversationsFromDB
{
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    NSMutableArray *needRemoveConversations;
    for (EMConversation *conversation in conversations) {
        if (!conversation.latestMessage || (conversation.type == EMConversationTypeChatRoom)) {
            if (!needRemoveConversations) {
                needRemoveConversations = [[NSMutableArray alloc] initWithCapacity:0];
            }
            
            [needRemoveConversations addObject:conversation];
        }
    }
    
    if (needRemoveConversations && needRemoveConversations.count > 0) {
        [[EMClient sharedClient].chatManager deleteConversations:needRemoveConversations isDeleteMessages:YES completion:nil];
    }
}

#pragma mark - EaseConversationListViewControllerDelegate

- (void)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
            didSelectConversationModel:(id<IConversationModel>)conversationModel
{
    if (conversationModel) {
        EMConversation *conversation = conversationModel.conversation;
        if (conversation)
        {
            DRChatViewController *chatVC = [[DRChatViewController alloc] initWithConversationChatter:conversation.conversationId conversationType:conversation.type];
            chatVC.title = conversationModel.title;
            [self.navigationController pushViewController:chatVC animated:YES];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setupUnreadMessageCount" object:nil];
        [self.tableView reloadData];
    }
}

#pragma mark - EaseConversationListViewControllerDataSource

- (id<IConversationModel>)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
                                    modelForConversation:(EMConversation *)conversation
{
    EaseConversationModel *model = [[EaseConversationModel alloc] initWithConversation:conversation];
    if ([model.title isEqualToString:@"system"] || [model.title isEqualToString:@"message"] || [model.title isEqualToString:@"interact"]) {
        return model;
    }
    NSDictionary * ext = model.conversation.lastReceivedMessage.ext;
    
    //头像
    if ([model.conversation.conversationId isEqualToString:@"200000000000000003"]) {//客服头像
        model.avatarImage = [UIImage imageNamed:@"kefu_avatar"];
    }else
    {
        if (DRStringIsEmpty(ext[@"avatar"])) {
            model.avatarImage = [UIImage imageNamed:@"chat_avatar_placeholder"];
            model.avatarURLPath = [DRIMTool getavatarURLPathWithUsername:conversation.conversationId];
        }else
        {
            model.avatarURLPath = ext[@"avatar"];
        }
    }
    
    //昵称
    if ([model.conversation.conversationId isEqualToString:@"200000000000000003"]) {
        model.title = @"吾花肉客服";
    }else
    {
        if (DRStringIsEmpty(ext[@"nickName"])) {
            model.title = [DRIMTool getNickNameWithUsername:conversation.conversationId];
        }else
        {
            model.title = ext[@"nickName"];
        }
    }
    return model;
}

@end
