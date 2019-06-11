//
//  DRLoadHtmlFileViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/5/8.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "DRHomePageHtmlViewController.h"
#import "DRLoginViewController.h"
#import "DRLoadHtmlFileViewController.h"
#import "DRConversationListController.h"
#import "DRGoodDetailViewController.h"
#import "DRShopDetailViewController.h"
#import "DRShopListViewController.h"
#import "DRHomePageSerachViewController.h"
#import "DRSetupShopViewController.h"
#import "DRMyShopViewController.h"
#import "DRShowViewController.h"
#import "DRMaintainViewController.h"
#import "DRGoodListViewController.h"
#import "DRMaintainDetailViewController.h"
#import "DRShowDetailViewController.h"
#import "DRGrouponViewController.h"
#import "WebViewJavascriptBridge.h"

@interface DRHomePageHtmlViewController ()<WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, weak) WKWebView * webView;
@property WebViewJavascriptBridge* bridge;

@end

@implementation DRHomePageHtmlViewController

#pragma mark - 控制器的生命周期
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupChilds];
    self.view.backgroundColor = [UIColor whiteColor];
    if (@available(iOS 11.0, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadWebView) name:@"applicationWillEnterForeground" object:nil];
}

- (void)reloadWebView
{
    if (DRStringIsEmpty(self.webView.title)) {
        [self.webView reload];
    }
}

- (void)setupChilds
{
    WKWebView * webView =  [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - tabBarH)];
    self.webView = webView;
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    [self.view addSubview:webView];
   
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseH5Url, @"/index.html"]];//创建URL
    NSURLRequest* request = [NSURLRequest requestWithURL:url];//创建NSURLRequest
    [self.webView loadRequest:request];//加载
    
    //注册Bridge
    [WebViewJavascriptBridge enableLogging];
    _bridge = [WebViewJavascriptBridge bridgeForWebView:webView];
    [_bridge setWebViewDelegate:self];
    //js调用原生
    [_bridge registerHandler:@"handleStatusBarStyleDefault" handler:^(id data, WVJBResponseCallback responseCallback) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }];
    [_bridge registerHandler:@"handleStatusBarStyleLight" handler:^(id data, WVJBResponseCallback responseCallback) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }];
    
    [_bridge registerHandler:@"handleOpenPage" handler:^(id data, WVJBResponseCallback responseCallback) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }];
    [_bridge registerHandler:@"handleClosePage" handler:^(id data, WVJBResponseCallback responseCallback) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }];
    
    [_bridge registerHandler:@"handleSearch" handler:^(id data, WVJBResponseCallback responseCallback) {
        DRHomePageSerachViewController * searchVC = [[DRHomePageSerachViewController alloc] init];
        [self.navigationController pushViewController:searchVC animated:YES];
    }];
    
    [_bridge registerHandler:@"handleCarousel" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString * type = data[@"type"];
        NSString * data_ = data[@"data"];
        [self bannerJumpWithType:type data:data_];
    }];
    
    [_bridge registerHandler:@"handleGrid" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString * type = data[@"type"];
        NSString * data_ = data[@"data"];
        [self gridJumpWithType:type data:data_];
    }];
    
    [_bridge registerHandler:@"handleADs" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString * type = data[@"type"];
        NSString * data_ = data[@"data"];
        if ([type intValue] == 1) {
            if(!UserId || !Token)
            {
                DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
                [self presentViewController:loginVC animated:YES completion:nil];
                return;
            }
        }
        DRLoadHtmlFileViewController * htmlVC = [[DRLoadHtmlFileViewController alloc] initWithWeb:[NSString stringWithFormat:@"%@", data_]];
        [self.navigationController pushViewController:htmlVC animated:YES];
    }];
    
    [_bridge registerHandler:@"handleStore" handler:^(id data, WVJBResponseCallback responseCallback) {
        DRShopDetailViewController * shopVC = [[DRShopDetailViewController alloc] init];
        shopVC.shopId = data[@"data"];
        [self.navigationController pushViewController:shopVC animated:YES];
    }];
    
    [_bridge registerHandler:@"handleStoreList" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString * type = [NSString stringWithFormat:@"%@", data[@"type"]];
        if ([type isEqualToString:@"1"]) {
            DRShopListViewController * shopVC = [[DRShopListViewController alloc] init];
            [self.navigationController pushViewController:shopVC animated:YES];
        }
    }];
    
    [_bridge registerHandler:@"handleModules" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString * type = [NSString stringWithFormat:@"%@", data[@"type"]];
        NSString * jumpId = [NSString stringWithFormat:@"%@", data[@"jumpId"]];
        if ([type isEqualToString:@"2"]) {
            DRGoodDetailViewController * goodVC = [[DRGoodDetailViewController alloc] init];
            goodVC.goodId = jumpId;
            [self.navigationController pushViewController:goodVC animated:YES];
        }else if ([type isEqualToString:@"3"]){
            DRGoodListViewController * goodListVC = [[DRGoodListViewController alloc] init];
            goodListVC.subjectId = jumpId;
            [self.navigationController pushViewController:goodListVC animated:YES];
        }else if ([type isEqualToString:@"4"]){
            DRGoodListViewController * goodListVC = [[DRGoodListViewController alloc] init];
            goodListVC.likeName = jumpId;
            [self.navigationController pushViewController:goodListVC animated:YES];
        }else if ([type isEqualToString:@"5"]){
            DRGoodListViewController * goodListVC = [[DRGoodListViewController alloc] init];
            goodListVC.categoryId = jumpId;
            [self.navigationController pushViewController:goodListVC animated:YES];
        }
    }];
    
    [_bridge registerHandler:@"handleCategory" handler:^(id data, WVJBResponseCallback responseCallback) {
        DRGoodListViewController * goodListVC = [[DRGoodListViewController alloc] init];
        goodListVC.categoryId = data[@"data"];
        [self.navigationController pushViewController:goodListVC animated:YES];
    }];
    
    [_bridge registerHandler:@"handleTalentShows" handler:^(id data, WVJBResponseCallback responseCallback) {
        DRShowDetailViewController * showDetailVC = [[DRShowDetailViewController alloc] init];
        showDetailVC.showId = data[@"id"];
        showDetailVC.isHomePage = YES;
        [self.navigationController pushViewController:showDetailVC animated:YES];
    }];
    
    [_bridge registerHandler:@"handleArticle" handler:^(id data, WVJBResponseCallback responseCallback) {
        DRMaintainDetailViewController * maintainVC = [[DRMaintainDetailViewController alloc] init];
        maintainVC.maintainId = data[@"id"];
        [self.navigationController pushViewController:maintainVC animated:YES];
    }];
    
    [_bridge registerHandler:@"handleGoodsDetail" handler:^(id data, WVJBResponseCallback responseCallback) {
        DRGoodDetailViewController * goodVC = [[DRGoodDetailViewController alloc] init];
        goodVC.goodId = data[@"id"];
        [self.navigationController pushViewController:goodVC animated:YES];
    }];
    [_bridge registerHandler:@"handleCheckLogin" handler:^(id data, WVJBResponseCallback responseCallback) {
        if(!UserId || !Token)
        {
            responseCallback(@(false));
        }else
        {
            responseCallback(@(true));
        }
    }];
}

- (void)bannerJumpWithType:(NSString *)type data:(NSString *)data
{
    if ([type intValue] == 1) {//webview
        if ([data rangeOfString:@"jiaoshui"].location != NSNotFound) {
            if(!UserId || !Token)
            {
                DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
                [self presentViewController:loginVC animated:YES completion:nil];
                return;
            }
        }
        DRLoadHtmlFileViewController * htmlVC = [[DRLoadHtmlFileViewController alloc] initWithWeb:[NSString stringWithFormat:@"%@",data]];
        [self.navigationController pushViewController:htmlVC animated:YES];
    }else if ([type intValue] == 2)//跳转到某商品
    {
        DRGoodDetailViewController * goodVC = [[DRGoodDetailViewController alloc] init];
        goodVC.goodId = data;
        [self.navigationController pushViewController:goodVC animated:YES];
    }else if ([type intValue] == 3)//跳转到一个activity，根据data值预先定义跳转到哪个页面，
    {
        if ([data intValue] == 10)
        {
            if(!UserId || !Token)
            {
                DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
                [self presentViewController:loginVC animated:YES completion:nil];
                return;
            }
            DRShowViewController * showVC = [[DRShowViewController alloc] init];
            [self.navigationController pushViewController:showVC animated:YES];
        }else if ([data intValue] == 20)
        {
            DRMaintainViewController * maintainVC = [[DRMaintainViewController alloc] init];
            [self.navigationController pushViewController:maintainVC animated:YES];
        }else if ([data intValue] == 30)
        {
            if(!UserId || !Token)
            {
                DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
                [self presentViewController:loginVC animated:YES completion:nil];
                return;
            }
            DRUser *user = [DRUserDefaultTool user];
            if ([user.type intValue] == 0) {//未开店
                DRSetupShopViewController * setupShopVC = [[DRSetupShopViewController alloc] init];
                [self.navigationController pushViewController:setupShopVC animated:YES];
            }else
            {
                DRMyShopViewController * myShopVC = [[DRMyShopViewController alloc] init];
                [self.navigationController pushViewController:myShopVC animated:YES];
            }
        }else if ([data intValue] == 40)
        {
            DRGrouponViewController * myShopVC = [[DRGrouponViewController alloc] init];
            [self.navigationController pushViewController:myShopVC animated:YES];
        }
    }else if ([type intValue] == 4)//跳转到一个售卖类型
    {
        DRGoodListViewController * goodListVC = [[DRGoodListViewController alloc] init];
        goodListVC.subjectId = [NSString stringWithFormat:@"%@",data];
        [self.navigationController pushViewController:goodListVC animated:YES];
    }else if ([type intValue] == 5)//跳转到一个商品分类列表
    {
        DRGoodListViewController * goodListVC = [[DRGoodListViewController alloc] init];
        goodListVC.categoryId = [NSString stringWithFormat:@"%@",data];
        [self.navigationController pushViewController:goodListVC animated:YES];
    }
}

- (void)gridJumpWithType:(NSString *)type data:(NSString *)data
{
    if ([type intValue] == 1) {//webview
        DRLoadHtmlFileViewController * htmlVC = [[DRLoadHtmlFileViewController alloc] initWithWeb:[NSString stringWithFormat:@"%@",data]];
        [self.navigationController pushViewController:htmlVC animated:YES];
    }else if ([type intValue] == 2)//跳转到某商品
    {
        DRGoodDetailViewController * goodVC = [[DRGoodDetailViewController alloc] init];
        goodVC.goodId = data;
        [self.navigationController pushViewController:goodVC animated:YES];
    }else if ([type intValue] == 3)//跳转到一个activity，根据data值预先定义跳转到哪个页面，
    {
        if ([data intValue] == 10)
        {
            if(!UserId || !Token)
            {
                DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
                [self presentViewController:loginVC animated:YES completion:nil];
                return;
            }
            DRShowViewController * showVC = [[DRShowViewController alloc] init];
            [self.navigationController pushViewController:showVC animated:YES];
        }else if ([data intValue] == 20)
        {
            DRMaintainViewController * maintainVC = [[DRMaintainViewController alloc] init];
            [self.navigationController pushViewController:maintainVC animated:YES];
        }else if ([data intValue] == 30)
        {
            if(!UserId || !Token)
            {
                DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
                [self presentViewController:loginVC animated:YES completion:nil];
                return;
            }
            DRUser *user = [DRUserDefaultTool user];
            if ([user.type intValue] == 0) {//未开店
                DRSetupShopViewController * setupShopVC = [[DRSetupShopViewController alloc] init];
                [self.navigationController pushViewController:setupShopVC animated:YES];
            }else
            {
                DRMyShopViewController * myShopVC = [[DRMyShopViewController alloc] init];
                [self.navigationController pushViewController:myShopVC animated:YES];
            }
        }else if ([data intValue] == 40)
        {
            DRGrouponViewController * myShopVC = [[DRGrouponViewController alloc] init];
            [self.navigationController pushViewController:myShopVC animated:YES];
        }
    }else if ([type intValue] == 4)//跳转到一个售卖类型
    {
        DRGoodListViewController * goodListVC = [[DRGoodListViewController alloc] init];
        if ([data intValue] == 1) {//一物一拍
            goodListVC.sellType = @"1";
        }else if ([data intValue] == 2) {//批发
            goodListVC.isGroup = @"0";
            goodListVC.sellType = @"2";
        }else if ([data intValue] == 3)//团购
        {
            goodListVC.isGroup = @"1";
        }
        [self.navigationController pushViewController:goodListVC animated:YES];
    }else if ([type intValue] == 5)//跳转到一个商品分类列表
    {
        DRGoodListViewController * goodListVC = [[DRGoodListViewController alloc] init];
        goodListVC.categoryId = [NSString stringWithFormat:@"%@",data];
        [self.navigationController pushViewController:goodListVC animated:YES];
    }
}

#pragma mark - WKUIDelegate
//此方法作为js的alert方法接口的实现，默认弹出窗口应该只有提示信息及一个确认按钮，当然可以添加更多按钮以及其他内容，但是并不会起到什么作用
//点击确认按钮的相应事件需要执行completionHandler，这样js才能继续执行
////参数 message为  js 方法 alert(<message>) 中的<message>
-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

//作为js中confirm接口的实现，需要有提示信息以及两个相应事件， 确认及取消，并且在completionHandler中回传相应结果，确认返回YES， 取消返回NO
//参数 message为  js 方法 confirm(<message>) 中的<message>
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

//作为js中prompt接口的实现，默认需要有一个输入框一个按钮，点击确认按钮回传输入值
//当然可以添加多个按钮以及多个输入框，不过completionHandler只有一个参数，如果有多个输入框，需要将多个输入框中的值通过某种方式拼接成一个字符串回传，js接收到之后再做处理

//参数 prompt 为 prompt(<message>, <defaultValue>);中的<message>
//参数defaultText 为 prompt(<message>, <defaultValue>);中的 <defaultValue>
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - WKNavigationDelegate
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    [webView reload];
}


@end
