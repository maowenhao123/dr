//
//  DRLoadHtmlFileViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/5/8.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRLoadHtmlFileViewController.h"
#import "DRLoginViewController.h"
#import "DRChatViewController.h"
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
#import "DRAddShowViewController.h"
#import "DRPraiseListViewController.h"
#import "WebViewJavascriptBridge.h"
#import "DRShareTool.h"

@interface DRLoadHtmlFileViewController ()<WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, copy) NSString *web;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, weak) WKWebView *webView;
@property WebViewJavascriptBridge* bridge;

@property (nonatomic, weak) UIView *progressView;
@property (nonatomic, assign) NSTimeInterval barAnimationDuration; // default 0.1
@property (nonatomic, assign) NSTimeInterval fadeAnimationDuration; // default 0.27
@property (nonatomic, assign) NSTimeInterval fadeOutDelay; // default 0.1

@end

@implementation DRLoadHtmlFileViewController

- (instancetype)initWithFileName:(NSString *)fileName
{
    if(self = [super init])
    {
        self.fileName = fileName;
    }
    return  self;
}

- (instancetype)initWithWeb:(NSString *)web
{
    if(self = [super init])
    {
        self.web = web;
    }
    return  self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.hiddenNav) {
        self.progressView.y = statusBarH;
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }
    if (DRStringIsEmpty(self.webView.title)) {
        [self loadWebView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.hiddenNav) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _barAnimationDuration = 0.27f;
    _fadeAnimationDuration = 0.27f;
    _fadeOutDelay = 0.1f;
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupChilds];
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
        [self loadWebView];
    }
}

- (void)setupChilds
{
    if (self.navigationController.viewControllers.count > 1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"black_back_bar"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    }
    
    WKWebView * webView =  [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH)];
    if (self.hiddenNav) {
        webView.height = screenHeight - tabBarH;
    }
    self.webView = webView;
    webView.navigationDelegate = self;
    webView.UIDelegate = self;
    webView.allowsBackForwardNavigationGestures = YES;
    [self.view addSubview:webView];
    [self loadWebView];
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    
    UIView *progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 2.5)];
    self.progressView = progressView;
    progressView.backgroundColor = DRDefaultColor;
    [self.view addSubview:progressView];
    
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
    
    [_bridge registerHandler:@"handleShareLink" handler:^(id data, WVJBResponseCallback responseCallback) {
        int platformIndex = [data[@"platform"] intValue];
        UMSocialPlatformType platformType = UMSocialPlatformType_WechatSession;
        if (platformIndex == 0) {
            platformType = UMSocialPlatformType_WechatSession;
        }else if (platformIndex == 1)
        {
            platformType = UMSocialPlatformType_WechatTimeLine;
        }else if (platformIndex == 2)
        {
            platformType = UMSocialPlatformType_QQ;
        }
        [DRShareTool shareWithTitle:data[@"title"] description:data[@"description"] imageUrl:data[@"image"] image:nil platformType:platformType url:data[@"url"]];
    }];
    
    [_bridge registerHandler:@"handleGetUserInfo" handler:^(id data, WVJBResponseCallback responseCallback) {
        if(!UserId || !Token)
        {
            DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
            [self presentViewController:loginVC animated:YES completion:nil];
            return;
        }
        waitingView
        NSDictionary *bodyDic = @{
                                  };
        NSDictionary *headDic = @{
                                  @"digest":[DRTool getDigestByBodyDic:bodyDic],
                                  @"cmd":@"U10",
                                  @"userId":UserId,
                                  };
        [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
            [MBProgressHUD hideHUDForView:self.view];
            if (SUCCESS) {
                //储存
                DRUser *user = [DRUser mj_objectWithKeyValues:json];
                NSString *jsonStr = [user toJSONString];
                NSLog(@"%@", jsonStr);
                responseCallback(jsonStr);
            }else
            {
                ShowErrorView
            }
        } failure:^(NSError *error) {
            DRLog(@"error:%@",error);
        }];
    }];
    
    [_bridge registerHandler:@"handleGetRequestHead" handler:^(id data, WVJBResponseCallback responseCallback) {
        if(!UserId || !Token)
        {
            DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
            [self presentViewController:loginVC animated:YES completion:nil];
            return;
        }
        NSDictionary *headDic = @{
                                  @"token":Token,
                                  @"userId":UserId,
                                  };
        responseCallback(headDic);
    }];
    
    [_bridge registerHandler:@"handlePostings" handler:^(id data, WVJBResponseCallback responseCallback) {
        DRAddShowViewController * addShowVC = [[DRAddShowViewController alloc] init];
        [self.navigationController pushViewController:addShowVC animated:YES];
    }];
    
    [_bridge registerHandler:@"handleMyRewards" handler:^(id data, WVJBResponseCallback responseCallback) {
        if(!UserId || !Token)
        {
            DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
            [self presentViewController:loginVC animated:YES completion:nil];
            return;
        }
        DRPraiseListViewController * praiseListVC = [[DRPraiseListViewController alloc] init];
        praiseListVC.index = 2;
        [self.navigationController pushViewController:praiseListVC animated:YES];
    }];
}

- (void)back
{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma  mark - 加载HTML文件
- (void)loadWebView
{
    if (self.fileName) {
        NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
        NSString *filePath  = [resourcePath stringByAppendingPathComponent:self.fileName];
        NSString *htmlstring =[[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        [self.webView loadHTMLString:htmlstring  baseURL:[NSURL fileURLWithPath: [[NSBundle mainBundle] bundlePath]]];
    }else if (self.web)
    {
        if (![self.web containsString:@"http"]) {
            self.web = [NSString stringWithFormat:@"%@%@", baseH5Url, self.web];
        }
        NSURL* url = [NSURL URLWithString:self.web];//创建URL
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
        //获取记录的response headers
        NSDictionary *cachedHeaders = [[NSUserDefaults standardUserDefaults] objectForKey:url.absoluteString];
        //设置request headers
        if (cachedHeaders) {
            NSString *etag = [cachedHeaders objectForKey:@"Etag"];
            if (etag) {
                [request setValue:etag forHTTPHeaderField:@"If-None-Match"];
            }
            NSString *lastModified = [cachedHeaders objectForKey:@"Last-Modified"];
            if (lastModified) {
                [request setValue:lastModified forHTTPHeaderField:@"If-Modified-Since"];
            }
        }
        
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSLog(@"statusCode == %@", @(httpResponse.statusCode));
            if (httpResponse.statusCode == 304 || httpResponse.statusCode == 0) {
                //如果状态码为304或者0(网络不通?)，则设置request的缓存策略为读取本地缓存
                [request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
            }else {
                //如果状态码为200，则保存本次的response headers，并设置request的缓存策略为忽略本地缓存，重新请求数据
                [[NSUserDefaults standardUserDefaults] setObject:httpResponse.allHeaderFields forKey:request.URL.absoluteString];
                //如果状态码为200，则设置request的缓存策略为忽略本地缓存
                [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.webView loadRequest:request];
            });
        }] resume];
    }
}

#pragma mark - 跳转页面
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
        goodListVC.categoryId = [NSString stringWithFormat:@"%@", data];
        [self.navigationController pushViewController:goodListVC animated:YES];
    }else if ([type intValue] == 7)//跳转到搜索
    {
        DRHomePageSerachViewController * searchVC = [[DRHomePageSerachViewController alloc] init];
        searchVC.keyWord = [NSString stringWithFormat:@"%@", data];
        [self.navigationController pushViewController:searchVC animated:YES];
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

#pragma mark - WKNavigationDelegate
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    [webView reload];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL *URL = navigationAction.request.URL;
    NSString *scheme = [URL scheme];
    NSString * urlStr = URL.relativeString;
    if ([urlStr isEqualToString:@"http://wpa.qq.com/msgrd?v=3&uin=2998354652&site=qq&menu=yes"]) {//跳转qq
        NSString * urlstr = @"mqq://im/chat?chat_type=wpa&uin=2998354652&version=1&src_type=web";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlstr]];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }else if ([scheme isEqualToString:@"esodar"])//复制
    {
        if ([URL.relativeString containsString:@"copywenxin"]) {
            //复制账号
            UIPasteboard *pab = [UIPasteboard generalPasteboard];
            NSString *string = @"wuhuarou_2017";
            [pab setString:string];
            [MBProgressHUD showSuccess:@"复制成功"];
            [self performSelector:@selector(skipWeixin) withObject:self afterDelay:1.0f];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }else if ([URL.relativeString containsString:@"copyzaixian"])//在线客服
        {
            if((!UserId || !Token))
            {
                DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
                [self presentViewController:loginVC animated:YES completion:nil];
            }
            DRChatViewController *chatVC = [[DRChatViewController alloc] initWithConversationChatter:@"200000000000000003" conversationType:EMConversationTypeChat];
            chatVC.title = @"吾花肉客服";
            [self.navigationController pushViewController:chatVC animated:YES];
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}
- (void)skipWeixin
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"weixin://"]];
}

#pragma mark - 进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        [self setProgress:_webView.estimatedProgress animated:YES];
    } else if ([keyPath isEqualToString:@"title"]) {
        if (self.navigationController.navigationBarHidden == NO && self.navigationController.viewControllers.count > 1) {
            self.title = self.webView.title;
        }
    }
}

- (void)setProgress:(float)progress animated:(BOOL)animated {
    BOOL isGrowing = progress > 0.0;
    [UIView animateWithDuration:(isGrowing && animated) ? _barAnimationDuration : 0.0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect frame = self.progressView.frame;
        frame.size.width = progress * self.view.size.width;
        self.progressView.frame = frame;
    } completion:nil];
    
    if (progress >= 1.0) {
        [UIView animateWithDuration:animated ? _fadeAnimationDuration : 0.0 delay:_fadeOutDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.progressView.alpha = 0.0;
        } completion:^(BOOL completed){
            CGRect frame = self.progressView.frame;
            frame.size.width = 0;
            self.progressView.frame = frame;
        }];
    }
    else {
        [UIView animateWithDuration:animated ? _fadeAnimationDuration : 0.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.progressView.alpha = 1.0;
        } completion:nil];
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

#pragma mark - dealloc
- (void)dealloc
{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
}


@end
