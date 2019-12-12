//
//  DRTabBarViewController.m
//  dr
//
//  Created by apple on 17/1/14.
//  Copyright © 2017年 JG. All rights reserved.
//
#import <StoreKit/StoreKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "DRTabBarViewController.h"
#import "DRBaseNavigationController.h"
#import "DRHomePageViewController.h"
#import "DRLoadHtmlFileViewController.h"
#import "DRGoodSortViewController.h"
#import "DRGrouponViewController.h"
#import "DRShowViewController.h"
#import "DRShoppingCarViewController.h"
#import "DRMineViewController.h"
#import "DRLoginViewController.h"
#import "DRConversationListController.h"
#import "DRChatViewController.h"
#import "DRUpGradeView.h"
#import <HyphenateLite/HyphenateLite.h>
#import <UserNotifications/UserNotifications.h>
#import "EMCDDeviceManager.h"
#import "EaseUI.h"
#import "UITabBar+DRBage.h"
#import "DRGiveVoucherView.h"
#import "DRRewardView.h"

//两次提示的默认间隔
static const CGFloat kDefaultPlaySoundInterval = 3.0;
static NSString *kMessageType = @"MessageType";
static NSString *kConversationChatter = @"ConversationChatter";

@interface DRTabBarViewController ()<UITabBarControllerDelegate, EMChatManagerDelegate>

@property (strong, nonatomic) NSDate *lastPlaySoundDate;

@end

@implementation DRTabBarViewController

+ (void)initialize
{
    UITabBar * tabBar = [UITabBar appearance];
    // 设置背景
    [tabBar setBackgroundImage:[UIImage ImageFromColor:[UIColor whiteColor] WithRect:CGRectMake(0, 0, screenWidth, tabBarH)]];
    tabBar.tintColor = DRColor(10, 178, 137, 1);
    
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:DRGetFontSize(20)];
    [[UITabBarItem appearance] setTitleTextAttributes:textAttrs
                                             forState:UIControlStateNormal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    //初始化tabbar
    [self setupTabbars];
    
    //接收去首页的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoHomePage) name:@"gotoHomePage" object:nil];
    //去消息中心的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoMessage) name:@"gotoMessage" object:nil];
    //接收个人中心的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoMine) name:@"gotoMine" object:nil];
    //登录成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:@"loginSuccess" object:nil];
    //接收下单成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoMine) name:@"checkoutSuccess" object:nil];
    //未读消息数改变时的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupUnreadMessageCount) name:@"setupUnreadMessageCount" object:nil];
    //有新消息时的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupUnreadMessageCount) name:@"haveNewMessageNote" object:nil];
    //环信登录成功时的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupUnreadMessageCount) name:@"hxLoginSuccess" object:nil];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    
    //检查升级
    [self checkUpgrade];
    
    //赠送红包
    [self getGiveVoucherData];
    
    //抽奖能力
    long long currentTimeSp = [[NSDate date] timeIntervalSince1970];
    NSArray *closeRewardTimeSps = [[NSUserDefaults standardUserDefaults] objectForKey:@"closeRewardTimeSps"];
    if (closeRewardTimeSps && closeRewardTimeSps.count >= 3) {
        long long lastGradeTimeSp = [closeRewardTimeSps[2] longLongValue];
        if (currentTimeSp - lastGradeTimeSp > 7 * 24 * 60 * 60) {//一周最多显示三次
            [self getRewardDrawAbilty];
        }
    }else
    {
        [self getRewardDrawAbilty];
    }
    
    //小红点
    [self setupUnreadMessageCount];
    
    //评分
    long long lastGradeTimeSp = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lastGradeTimeSp"] longLongValue];
    if (currentTimeSp - lastGradeTimeSp > 7 * 24 * 60 * 60) {
        [self addAppReview];
    }
    [[NSUserDefaults standardUserDefaults] setObject:@(currentTimeSp) forKey:@"lastGradeTimeSp"];
}

- (void)loginSuccess
{
    [self getGiveVoucherData];
    long long currentTimeSp = [[NSDate date] timeIntervalSince1970];
    NSArray *closeRewardTimeSps = [[NSUserDefaults standardUserDefaults] objectForKey:@"closeRewardTimeSps"];
    if (closeRewardTimeSps && closeRewardTimeSps.count >= 3) {
        long long lastGradeTimeSp = [closeRewardTimeSps[2] longLongValue];
        if (currentTimeSp - lastGradeTimeSp > 7 * 24 * 60 * 60) {//一周最多显示三次
            [self getRewardDrawAbilty];
        }
    }else
    {
        [self getRewardDrawAbilty];
    }
}
// 统计未读消息数
-(void)setupUnreadMessageCount
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
        int unreadCount = 0;
        for (EMConversation *conversation in conversations) {
            unreadCount += conversation.unreadMessagesCount;
        }
        
        if (unreadCount > 0) {
            //显示
            [self.tabBar showBadgeOnItemIndex:2];
        } else {
            //隐藏x
            [self.tabBar hideBadgeOnItemIndex:2];
        }
        [UIApplication sharedApplication].applicationIconBadgeNumber = unreadCount;
    });
}

#pragma mark - 添加控制器
- (void)setupTabbars
{
    // 1.购彩
//    DRHomePageViewController *homePageVC = [[DRHomePageViewController alloc] init];
//    DRHomePageHtmlViewController *homePageVC = [[DRHomePageHtmlViewController alloc] init];
    DRLoadHtmlFileViewController *homePageVC = [[DRLoadHtmlFileViewController alloc] initWithWeb:[NSString stringWithFormat:@"%@%@", baseH5Url, @"/index.html"]];
    homePageVC.hiddenNav = YES;
    UITabBarItem * tabberItem1 = [self getTabberByImage:[UIImage imageNamed:@"tabber_home_icon"] selectedImage:[UIImage imageNamed:@"tabber_home_selected_icon"] title:@"首页"];
    homePageVC.tabBarItem = tabberItem1;
    DRBaseNavigationController *homePage_nav = [[DRBaseNavigationController alloc]initWithRootViewController:homePageVC];
    homePage_nav.view.tag = 1;
    
    // 2.分类
    DRGoodSortViewController *sortVC = [[DRGoodSortViewController alloc] init];
    UITabBarItem * tabberItem2 = [self getTabberByImage:[UIImage imageNamed:@"tabber_sort"] selectedImage:[UIImage imageNamed:@"tabber_sort_selected"] title:@"分类"];
    sortVC.tabBarItem = tabberItem2;
    DRBaseNavigationController *sortVC_nav = [[DRBaseNavigationController alloc]initWithRootViewController:sortVC];
    sortVC_nav.view.tag = 2;
    
    // 3.团购
    DRConversationListController *conversationListVC = [[DRConversationListController alloc] init];
    UITabBarItem * tabberItem3 = [self getTabberByImage:[UIImage imageNamed:@"tabber_message"] selectedImage:[UIImage imageNamed:@"tabber_message_selected"] title:@"消息"];
    conversationListVC.tabBarItem = tabberItem3;
    DRBaseNavigationController *conversationList_nav = [[DRBaseNavigationController alloc]initWithRootViewController:conversationListVC];
    conversationList_nav.view.tag = 3;
    
    // 4.购物车
    DRShoppingCarViewController *shoppingCarVC = [[DRShoppingCarViewController alloc] init];
    UITabBarItem * tabberItem4 = [self getTabberByImage:[UIImage imageNamed:@"tabber_shoppingCart"] selectedImage:[UIImage imageNamed:@"tabber_shoppingCart_selected"] title:@"购物车"];
    shoppingCarVC.tabBarItem = tabberItem4;
    DRBaseNavigationController *shoppingCarVC_nav = [[DRBaseNavigationController alloc]initWithRootViewController:shoppingCarVC];
    shoppingCarVC_nav.view.tag = 4;
    
    // 5.我的
    DRMineViewController *mineVC = [[DRMineViewController alloc] init];
    UITabBarItem * tabberItem5 = [self getTabberByImage:[UIImage imageNamed:@"tabber_mine"] selectedImage:[UIImage imageNamed:@"tabber_mine_selected"] title:@"我的"];
    mineVC.tabBarItem = tabberItem5;
    DRBaseNavigationController *mineVC_nav = [[DRBaseNavigationController alloc]initWithRootViewController:mineVC];
    mineVC_nav.view.tag = 5;
    
    self.viewControllers = @[homePage_nav,sortVC_nav,conversationList_nav,shoppingCarVC_nav,mineVC_nav];
}

- (UITabBarItem *)getTabberByImage:(UIImage *)image selectedImage:(UIImage *)selectedImage title:(NSString *)title
{
    UITabBarItem * tabberItem = [[UITabBarItem alloc]init];
    tabberItem.title = title;
    tabberItem.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabberItem.selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return tabberItem;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if((viewController.view.tag == 3 || viewController.view.tag == 5) && (!UserId || !Token))
    {
        DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
        [self presentViewController:loginVC animated:YES completion:nil];
        return NO;
    }
    return YES;
}

#pragma mark - 跳转
//去首页
- (void)gotoHomePage
{
    self.selectedIndex = 0;
}
- (void)gotoMessage
{
    self.selectedIndex = 2;
}
- (void)gotoShoppingCar
{
    self.selectedIndex = 3;
}
- (void)gotoMine
{
    self.selectedIndex = 4;
}

//评分
- (void)addAppReview{
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"去给吾花肉APP打个分吧！" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *fiveStar = [UIAlertAction actionWithTitle:@"去评分" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *appReviewUrl = [NSURL URLWithString:[NSString stringWithFormat: @"itms-apps://itunes.apple.com/app/id%@?action=write-review", @"1276983899"]];
        CGFloat version = [[[UIDevice currentDevice]systemVersion]floatValue];
        if (version >= 10.0) {
            /// 大于等于10.0系统使用此openURL方法
            [[UIApplication sharedApplication] openURL:appReviewUrl options:@{} completionHandler:nil];
        }else{
            [[UIApplication sharedApplication] openURL:appReviewUrl];
        }
    }];
    //不做任何操作
    UIAlertAction *noReview = [UIAlertAction actionWithTitle:@"用用再说" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertVC removeFromParentViewController];
    }];
    [alertVC addAction:noReview];
    [alertVC addAction:fiveStar];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertVC animated:YES completion:nil];
    });
}

#pragma mark - 检查升级
- (void)checkUpgrade
{
    NSString * version = [NSString stringWithFormat:@"%@", [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"]];
    NSDictionary *bodyDic = @{
                              @"type":@"2",
                              @"version":version,
                              };
    
    NSDictionary *headDic = @{
                              @"cmd":@"P01",
                              };
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            DRUpgradeModel * upgradeModel = [DRUpgradeModel mj_objectWithKeyValues:json];
            NSString * newVersion = [upgradeModel.version stringByReplacingOccurrencesOfString:@"v" withString:@""];
            if (![newVersion isEqualToString:version]) {//有最新版本
                DRUpGradeView * upGradeView = [[DRUpGradeView alloc] initWithFrame:self.view.bounds upgradeModel:upgradeModel];
                [self.view addSubview:upGradeView];
            }
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

#pragma mark - 赠送红包
- (void)getGiveVoucherData
{
    if (!UserId) return;
    NSDictionary * bodyDic = @{};
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"L18",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            NSArray *redPacketList = [DRVoucherModel mj_objectArrayWithKeyValuesArray:json[@"registGiveRewardList"]];
            if (redPacketList.count > 0) {
                DRGiveVoucherView * giveVoucherView = [[DRGiveVoucherView alloc] initWithFrame:self.view.bounds redPacketList:redPacketList];
                giveVoucherView.owerViewController = self.selectedViewController;
                [self.view addSubview:giveVoucherView];
            }
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

#pragma mark - 抽奖
- (void)getRewardDrawAbilty
{
    if (!UserId) return;
    NSDictionary * bodyDic = @{
                               @"userId":UserId,
                               };
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"GET_USER_WEEK_REWARD_DRAW_ABILITY",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            if ([json[@"ability"] boolValue]) {
                DRRewardView * rewardView = [[DRRewardView alloc] initWithFrame:self.view.bounds drawUrl:json[@"drawUrl"]];
                rewardView.owerViewController = self.selectedViewController;
                [self.view addSubview:rewardView];
            }
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

#pragma mark - 收到新消息
- (void)messagesDidReceive:(NSArray *)aMessages
{
    EMMessage *message = aMessages.firstObject;
    DRChatViewController *chatViewContrller = [self getCurrentChatView];
    BOOL isChatting = NO;
    if (chatViewContrller) {
        isChatting = [message.conversationId isEqualToString:chatViewContrller.conversation.conversationId];
    }
    NSDictionary *objectDic = @{
                                @"message":message
                                };
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    switch (state) {
        case UIApplicationStateActive:
            [self playSoundAndVibration];
            break;
        case UIApplicationStateInactive:
            [self playSoundAndVibration];
            break;
        case UIApplicationStateBackground:
            [self showNotificationWithMessage:message];
            break;
        default:
            break;
    }
    if (chatViewContrller == nil || !isChatting || state == UIApplicationStateBackground) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"haveNewMessageNote" object:objectDic];
    }
}

- (void)playSoundAndVibration
{
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        //如果距离上次响铃和震动时间太短, 则跳过响铃
        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
        return;
    }
    
    //保存最后一次响铃时间
    self.lastPlaySoundDate = [NSDate date];
    
    // 收到消息时，播放音频
    [[EMCDDeviceManager sharedInstance] playNewMessageSound];
    // 收到消息时，震动
    [[EMCDDeviceManager sharedInstance] playVibration];
}

- (void)showNotificationWithMessage:(EMMessage *)message
{
    EMPushOptions *options = [[EMClient sharedClient] pushOptions];
    NSString *alertBody = nil;
    if (options.displayStyle == EMPushDisplayStyleMessageSummary) {
        EMMessageBody *messageBody = message.body;
        NSString *messageStr = nil;
        switch (messageBody.type) {
            case EMMessageBodyTypeText:
            {
                messageStr = ((EMTextMessageBody *)messageBody).text;
            }
                break;
            case EMMessageBodyTypeImage:
            {
                messageStr = @"[图片]";
            }
                break;
            case EMMessageBodyTypeLocation:
            {
                messageStr = @"[位置]";
            }
                break;
            case EMMessageBodyTypeVoice:
            {
                messageStr = @"[音频]";
            }
                break;
            case EMMessageBodyTypeVideo:{
                messageStr = @"[视频]";
            }
                break;
            default:
                break;
        }
        alertBody = messageStr;
    }
    else{
        alertBody = @"您有一条新消息";
    }
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastPlaySoundDate];
    BOOL playSound = NO;
    if (!self.lastPlaySoundDate || timeInterval >= kDefaultPlaySoundInterval) {
        self.lastPlaySoundDate = [NSDate date];
        playSound = YES;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInt:message.chatType] forKey:kMessageType];
    [userInfo setObject:message.conversationId forKey:kConversationChatter];
    
    //发送本地推送
    if (NSClassFromString(@"UNUserNotificationCenter")) {
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.01 repeats:NO];
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        if (playSound) {
            content.sound = [UNNotificationSound defaultSound];
        }
        content.body = alertBody;
        content.userInfo = userInfo;
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:message.messageId content:content trigger:trigger];
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
    }
    else {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [NSDate date]; //触发通知的时间
        notification.alertBody = alertBody;
        notification.timeZone = [NSTimeZone defaultTimeZone];
        if (playSound) {
            notification.soundName = UILocalNotificationDefaultSoundName;
        }
        notification.userInfo = userInfo;
        
        //发送通知
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}


- (DRChatViewController *)getCurrentChatView
{
    DRBaseNavigationController * nav = self.selectedViewController;
    NSArray *viewControllers = nav.viewControllers;
    DRChatViewController *chatViewContrller = nil;
    for (id viewController in viewControllers)
    {
        if ([viewController isKindOfClass:[DRChatViewController class]])
        {
            chatViewContrller = viewController;
            break;
        }
    }
    return chatViewContrller;
}


@end
