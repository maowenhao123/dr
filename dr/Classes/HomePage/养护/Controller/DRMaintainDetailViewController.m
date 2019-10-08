//
//  DRMaintainDetailViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/5/9.
//  Copyright © 2017年 JG. All rights reserved.
//
#import <WebKit/WebKit.h>
#import "DRMaintainDetailViewController.h"
#import "DRLoginViewController.h"
#import "DRShareTool.h"
#import "DRDateTool.h"

@interface DRMaintainDetailViewController ()<WKNavigationDelegate, UIScrollViewDelegate>

@property (nonatomic, copy) NSString *web;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, weak)  UIView * headerView;
@property (nonatomic, weak) UILabel * titleLabel;
@property (nonatomic, weak) UILabel * timeLabel;
@property (nonatomic, weak) UILabel * readCountLabel;
@property (nonatomic, weak) UIView * line;
@property (nonatomic, weak) WKWebView *webView;
@property (nonatomic, strong) UIBarButtonItem * attentionBar;
@property (nonatomic,assign) BOOL isAttention;

@property (nonatomic, weak) UIView *progressView;
@property (nonatomic, assign) NSTimeInterval barAnimationDuration; // default 0.1
@property (nonatomic, assign) NSTimeInterval fadeAnimationDuration; // default 0.27
@property (nonatomic, assign) NSTimeInterval fadeOutDelay; // default 0.1

@end

@implementation DRMaintainDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"养护详情";
    _barAnimationDuration = 0.27f;
    _fadeAnimationDuration = 0.27f;
    _fadeOutDelay = 0.1f;
    [self setupChilds];
    [self getData];
    [self getAttentionData];
}
#pragma mark - 请求数据
- (void)getData
{
    waitingView;
    NSDictionary *bodyDic = @{
                               @"id":self.maintainId,
                               };

    NSDictionary *headDic = @{
                              @"cmd":@"P12",
                              };
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            self.dic = [NSDictionary dictionaryWithDictionary:json[@"article"]];
            [self setData];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        [MBProgressHUD hideHUDForView:self.view];
    }];
}
- (void)getAttentionData
{
    if(!UserId || !Token)
    {
        return;
    }
    
    NSDictionary *bodyDic = @{
                              @"id":self.maintainId,
                              @"type":@(4)
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U25",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            self.isAttention = [json[@"focus"] boolValue];
            UIImage *attentionImage;
            if (self.isAttention) {
                attentionImage = [[UIImage imageNamed:@"red_favorite_bar"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            }else
            {
                attentionImage = [[UIImage imageNamed:@"black_favorite_bar"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            }
            self.attentionBar.image = attentionImage;
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
- (void)attentionBarDidClick
{
    if(!UserId || !Token)
    {
        DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
        [self presentViewController:loginVC animated:YES completion:nil];
        return;
    }
    
    NSString * cmd;
    if (self.isAttention) {//取消关注
        cmd = @"U23";
    }else//添加关注
    {
        cmd = @"U22";
    }
    NSDictionary *bodyDic = @{
                              @"id":self.maintainId,
                              @"type":@(4)
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":cmd,
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            [self getAttentionData];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
#pragma mark - 布局视图
- (void)setupChilds
{
    //rightBarButtonItems
    self.attentionBar = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"black_favorite_bar"] style:UIBarButtonItemStylePlain target:self action:@selector(attentionBarDidClick)];
    UIBarButtonItem * shareBar = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"black_share_bar"] style:UIBarButtonItemStylePlain target:self action:@selector(shareBarDidClick)];
    UIBarButtonItem * goHomeBar = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"black_goHome_bar"] style:UIBarButtonItemStylePlain target:self action:@selector(goHomeBarDidClick)];
    NSArray * rightBarButtonItems = @[goHomeBar, shareBar, self.attentionBar];
    self.navigationItem.rightBarButtonItems = rightBarButtonItems;
    
    //适合手机
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    [wkUController addUserScript:wkUScript];
    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    wkWebConfig.userContentController = wkUController;
    
    WKWebView * webView =  [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH) configuration:wkWebConfig];
    self.webView = webView;
    webView.navigationDelegate = self;
    webView.scrollView.contentInset = UIEdgeInsetsMake(60, 0 , 0, 0);
    webView.scrollView.mj_offsetY = -60;
    webView.scrollView.delegate = self;
    webView.scrollView.showsVerticalScrollIndicator = NO;
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.view addSubview:webView];
    
    //headerView
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60)];
    self.headerView = headerView;
    headerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headerView];
    
    //标题
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 10, screenWidth - 2 * DRMargin, 20)];
    self.titleLabel = titleLabel;
    titleLabel.textColor = DRBlackTextColor;
    titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(32)];
    titleLabel.numberOfLines = 0;
    [headerView addSubview:titleLabel];
    
    //时间
    UILabel * timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 35, screenWidth - 2 * DRMargin, 20)];
    self.timeLabel = timeLabel;
    timeLabel.textColor = DRGrayTextColor;
    timeLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [headerView addSubview:timeLabel];
    
    //阅读数量
    UILabel * readCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth - DRMargin - 100, 35, 100, 20)];
    self.readCountLabel = readCountLabel;
    readCountLabel.textColor = DRGrayTextColor;
    readCountLabel.textAlignment = NSTextAlignmentRight;
    readCountLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [headerView addSubview:readCountLabel];
    
    //分割线
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, headerView.height - 1, screenWidth, 1)];
    self.line = line;
    line.backgroundColor = DRWhiteLineColor;
    [headerView addSubview:line];
    
    //进度条
    UIView *progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 2.5)];
    self.progressView = progressView;
    progressView.backgroundColor = DRDefaultColor;
    [self.view addSubview:progressView];
}
- (void)setData
{
    CGSize titleLabelSize = [self.dic[@"title"] sizeWithFont:self.titleLabel.font maxSize:CGSizeMake(screenWidth - 2 * DRMargin, MAXFLOAT)];
    CGFloat titleLabelH = titleLabelSize.height;
    if (titleLabelH > 30) {
        titleLabelH = 50;
    }else
    {
        titleLabelH = 30;
    }
    self.titleLabel.frame = CGRectMake(DRMargin, 10, screenWidth - 2 * DRMargin, titleLabelH);
    self.timeLabel.frame = CGRectMake(DRMargin, CGRectGetMaxY(self.titleLabel.frame), screenWidth - 2 * DRMargin, 20);
    self.readCountLabel.frame = CGRectMake(screenWidth - DRMargin - 100, CGRectGetMaxY(self.titleLabel.frame), 100, 20);
    self.line.frame = CGRectMake(0, CGRectGetMaxY(self.timeLabel.frame) + 4, screenWidth, 1);
    self.headerView.height = CGRectGetMaxY(self.line.frame);
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(self.headerView.height, 0 , 0, 0);
    self.webView.scrollView.mj_offsetY = -self.headerView.height;
    
    self.titleLabel.text = self.dic[@"title"];
    self.timeLabel.text = [NSString stringWithFormat:@"%@", [DRDateTool getTimeByTimestamp:[self.dic[@"createTime"] longLongValue] format:@"yyyy-MM-dd HH:mm:ss"]];
    self.readCountLabel.text = [NSString stringWithFormat:@"%@人阅读", self.dic[@"hits"]];
    [self.webView loadHTMLString:self.dic[@"content"]  baseURL:[NSURL URLWithString:baseUrl]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MaintainReadNotification" object:nil];
}
#pragma mark - 按钮点击
- (void)shareBarDidClick
{
    [DRShareTool shareGrouponByMaintainDic:self.dic];
}
- (void)goHomeBarDidClick
{
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:NO];
        });
    }];

    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"gotoHomePage" object:nil];
        });
    }];
    [op2 addDependency:op1];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue waitUntilAllOperationsAreFinished];
    [queue addOperation:op1];
    [queue addOperation:op2];
}
#pragma mark - UIWebViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.headerView.y = - self.headerView.height - scrollView.mj_offsetY;
}

#pragma mark - 进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        
        [self setProgress:_webView.estimatedProgress animated:YES];
        
    } else if ([keyPath isEqualToString:@"title"]) {
        
        self.title = self.webView.title;
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

- (void)dealloc
{
    if (iOS8) {
        self.webView.scrollView.delegate = nil;
    }
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

@end
