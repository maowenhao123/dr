//
//  AppDelegate.m
//  dr
//
//  Created by apple on 17/1/14.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <AlipaySDK/AlipaySDK.h>
#import <UMSocialCore/UMSocialCore.h>
#import <HyphenateLite/HyphenateLite.h>
#import <UserNotifications/UserNotifications.h>
#import "AppDelegate.h"
#import "DRTabBarViewController.h"
#import "DRShowDetailViewController.h"
#import "DRGoodDetailViewController.h"
#import "DRShopDetailViewController.h"
#import "DRBaseNavigationController.h"
#import "AFNetworkReachabilityManager.h"
#import "IQKeyboardManager.h"
#import "WXApi.h"
#import "UMMobClick/MobClick.h"
#import "EaseSDKHelper.h"

@interface AppDelegate ()<WXApiDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    application.statusBarHidden = NO;
    
    //处理键盘
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    [IQKeyboardManager sharedManager].toolbarDoneBarButtonItemText = @"完成";
    
    //微信注册
    [WXApi registerApp:WXAppId];
    
    //友盟统计
    UMConfigInstance.appKey = UMengId;
    [MobClick startWithConfigure:UMConfigInstance];
    
    //友盟注册
    [[UMSocialManager defaultManager] openLog:YES];
    [[UMSocialManager defaultManager] setUmSocialAppkey:UMengId];
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession
                                          appKey:WXAppId
                                       appSecret:WXAppSecret
                                     redirectURL:@"http://mobile.umeng.com/social"];
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ
                                          appKey:QQAPPId
                                       appSecret:QQAppSecret
                                     redirectURL:@"http://mobile.umeng.com/social"];
    
    //环信注册
    [self registerForRemoteNotificationsWithApplication:application];
    NSString *apnsCertName = nil;
#if DEBUG
    apnsCertName = @"duorou_dev";
#else
    apnsCertName = @"duorou_dis";
#endif
    EMOptions *options = [EMOptions optionsWithAppkey:EaseMobAppKey];
    options.apnsCertName = apnsCertName;
    EMError *error = [[EMClient sharedClient] initializeSDKWithOptions:options];
    if (error) {
        DRLog(@"%@", error.errorDescription);
    }
    
    [DRTool loginImAccount];
    
    NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (!DRDictIsEmpty(userInfo)) {
        //刷新是否有新消息
        [[NSNotificationCenter defaultCenter] postNotificationName:@"haveNewMessageNote" object:nil];
        DRLog(@"userInfo：%@",userInfo);
    }
    
    //判断token是否过期
    NSString * lastLoginTime = [DRUserDefaultTool getObjectForKey:@"lastLoginTime"];
    NSString * currentTime = [DRTool getNowTimeTimestamp];
    long long timestamp = [currentTime longLongValue] - [lastLoginTime longLongValue];
    long long retainTime = 30 * 24 * 60 * 60;
    if (timestamp / 1000 >= retainTime) {//token过期
        [DRUserDefaultTool removeObjectForKey:@"userId"];
        [DRUserDefaultTool removeObjectForKey:@"token"];
    }
    
    application.keyWindow.rootViewController = [[DRTabBarViewController alloc] init];
    
    [self jumpUrlViewController];
    return YES;
}

- (void)registerForRemoteNotificationsWithApplication:(UIApplication *)application
{
    if (NSClassFromString(@"UNUserNotificationCenter")) {
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError *error) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [application registerForRemoteNotifications];
                });
            }
        }];
        return;
    }
    
    if([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
    }
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"aliPayResultStatus" object:nil userInfo:resultDic];
            NSLog(@"%@",resultDic);
        }];
    }else if([[url absoluteString] rangeOfString:[NSString stringWithFormat:@"%@://pay",WXAppId]].location == 0) {//微信支付
        return [WXApi handleOpenURL:url delegate:self];
    }else if ([url.absoluteString containsString:@"esodar://copy/playShow/detail"])
    {
        NSArray * urlParamArray = [url.absoluteString componentsSeparatedByString:@"="];
        NSString * showId = urlParamArray[1];
        DRShowDetailViewController * showDetailVC = [[DRShowDetailViewController alloc] init];
        showDetailVC.isHomePage = YES;
        showDetailVC.showId = showId;
        [[self getCurNavController] pushViewController:showDetailVC animated:YES];
    }else if ([url.absoluteString containsString:@"esodar://rddapp_goods"])
    {
        DRGoodDetailViewController * goodDetailVC = [[DRGoodDetailViewController alloc] init];
        NSArray * urlParamArray = [[NSString stringWithFormat:@"%@", [url.absoluteString componentsSeparatedByString:@"?"][1]] componentsSeparatedByString:@"&"];
        for (NSString * urlParamStr in urlParamArray) {
            NSArray * urlParamArr = [urlParamStr componentsSeparatedByString:@"="];
            if ([[NSString stringWithFormat:@"%@", urlParamArr[0]] isEqualToString:@"goodsId"]) {
                goodDetailVC.goodId = [NSString stringWithFormat:@"%@", urlParamArr[1]];
                goodDetailVC.grouponId = [NSString stringWithFormat:@"%@", urlParamArr[1]];
            }else if ([[NSString stringWithFormat:@"%@", urlParamArr[0]] isEqualToString:@"isGroup"])
            {
                goodDetailVC.isGroupon = [urlParamArr[1] boolValue];
            }
        }
        [[self getCurNavController] pushViewController:goodDetailVC animated:YES];
    }else
    {
        return [[UMSocialManager defaultManager] handleOpenURL:url];//友盟回调
    }
    return YES;
}
/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 */
-(void)onResp:(BaseResp*)resp
{
    //支付
    if ([resp isKindOfClass:[PayResp class]])
    {
        PayResp *response = (PayResp *)resp;
        if (response.errCode == WXSuccess)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WeiXinRechargeSuccessNote" object:nil];
        }
    }
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    /// Required - 注册 DeviceToken
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError * error = [[EMClient sharedClient] bindDeviceToken:deviceToken];
        if (error) {
            DRLog(@"%@", error.errorDescription);
        }
    });
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"haveNewMessageNote" object:nil];
    DRLog(@"userInfo：%@",userInfo);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(nonnull UNNotificationResponse *)response withCompletionHandler:(nonnull void (^)(void))completionHandler
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"haveNewMessageNote" object:nil];
    completionHandler();
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    DRLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

// APP进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}

// APP将要从后台返回
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationWillEnterForeground" object:nil];
    [[EMClient sharedClient] applicationWillEnterForeground:application];
    
    [self jumpUrlViewController];
}

- (void)jumpUrlViewController
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString * urlString = pasteboard.string;
    if (!DRStringIsEmpty(urlString)) {
        NSArray * urlStringArray = [urlString componentsSeparatedByString:@"?"];
        NSString * urlDomain = urlStringArray[0];
        if ([urlDomain isEqualToString:@"esodar://copy/playShow/detail"]) {
            NSString * urlParam = urlStringArray[1];
            NSArray * urlParamArray = [urlParam componentsSeparatedByString:@"="];
            NSString * showId = urlParamArray[1];
            DRShowDetailViewController * showDetailVC = [[DRShowDetailViewController alloc] init];
            showDetailVC.isHomePage = YES;
            showDetailVC.showId = showId;
            [[self getCurNavController] pushViewController:showDetailVC animated:YES];
            [UIPasteboard generalPasteboard].string = @"";
        }
    }
}

- (UINavigationController *)getCurNavController
{
    UITabBarController *rootViewController = (UITabBarController *)self.window.rootViewController;
    UINavigationController* navController = (UINavigationController*)rootViewController.selectedViewController;
    return navController;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
