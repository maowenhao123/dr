//
//  DRGoodsDetailViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/11/29.
//  Copyright © 2017年 JG. All rights reserved.
//
#import "DRGoodDetailViewController.h"
#import "DRShopDetailViewController.h"
#import "DRLoginViewController.h"
#import "DRSubmitOrderViewController.h"
#import "DRShoppingCarViewController.h"
#import "DRChatViewController.h"
#import "DRGoodCommentCollectionReusableView.h"
#import "DRGoodTitleCollectionReusableView.h"
#import "DRGoodHeaderCollectionViewCell.h"
#import "DRGoodCommentCollectionViewCell.h"
#import "DRGoodShopMessageCollectionViewCell.h"
#import "DRRecommendGoodCollectionViewCell.h"
#import "UIButton+DR.h"
#import "DRWholesaleNumberView.h"
#import "DRJoinGrouponView.h"
#import "DRStartGrouponView.h"
#import "DRMenuView.h"
#import "DRShareTool.h"
#import "DRShoppingCarShopModel.h"
#import "DRGrouponModel.h"
#import "DRVideoFloatingWindow.h"
#import "DRDateTool.h"
#import "DRIMTool.h"

NSString * const GoodCommentHeaderId = @"GoodCommentHeaderId";
NSString * const GoodTitleHeaderId = @"GoodTitleHeaderId";
NSString * const GoodHeaderId = @"GoodHeaderId";
NSString * const GoodCommentId = @"GoodCommentId";
NSString * const GoodShopMessageId = @"GoodShopMessageId";
NSString * const WebViewCellId = @"WebViewCellId";
NSString * const GoodDetailRecommendGoodCellId = @"GoodDetailRecommendGoodCellId";

@interface DRGoodDetailViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, UIWebViewDelegate, WholesaleNumberViewDelegate, JoinGrouponViewDelegate, StartGrouponViewDelegate, MenuViewDelegate, GoodHeaderCollectionViewCellDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) UIView *barView;
@property (nonatomic, weak) UILabel * barGoodNameLabel;
@property (nonatomic, weak) UIButton * backButton;
@property (nonatomic, weak) UIButton * moreButton;
@property (nonatomic,weak) UIButton * carButton;
@property (nonatomic,weak) UILabel * timeLabel;
@property (nonatomic,weak) UILabel * bageLabel;
@property (nonatomic, weak) UIButton * attentionButon;
@property (nonatomic, weak) UIView *backView;
@property (nonatomic,weak) UIButton *buyButton;
@property (nonatomic,weak) UIButton *addCarButton;
@property (nonatomic,weak) DRWholesaleNumberView *wholesaleNumberView;
@property (nonatomic,weak) DRStartGrouponView *startGrouponView;
@property (nonatomic,weak) DRJoinGrouponView *joinGrouponView;
@property (nonatomic,strong) UIWebView *webView;
@property (nonatomic, weak) DRVideoFloatingWindow *videoFloatingWindow;
@property (nonatomic,strong) DRGoodHeaderFrameModel *goodHeaderFrameModel;
@property (nonatomic,strong) DRGoodModel *goodModel;
@property (nonatomic,strong) DRGrouponModel *grouponModel;
@property (nonatomic,strong) id groupJson;
@property (nonatomic, strong) NSArray * commentDataArray;
@property (nonatomic,strong) NSArray *goodDataArray;
@property (nonatomic, weak) MJRefreshGifHeader *headerView;
@property (nonatomic,assign) BOOL isAttention;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation DRGoodDetailViewController

#pragma mark - 控制器的生命周期
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addSetDeadlineTimer];
    [self scrollViewDidScroll:self.collectionView];
    if (self.videoFloatingWindow) {
        [self.videoFloatingWindow.playerView playVideo];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self scrollViewDidScroll:self.collectionView];
    [self setBageText];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self removeSetDeadlineTimer];
    
    if (self.videoFloatingWindow) {
        [self.videoFloatingWindow.playerView pausePlay];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupChilds];
    if (self.isGroupon) {
        [self getGrouponData];
    }else
    {
        [self getGoodData];
        [self getCommentData];
        [self getAttentionData];
    }
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}
#pragma mark - 请求数据
- (void)getGrouponData
{
    if (!self.grouponId) {
        return;
    }
    NSDictionary *bodyDic = @{
                              @"id":self.grouponId,
                              };
    
    NSDictionary *headDic = @{
                              @"cmd":@"S18",
                              };
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            self.grouponModel = [DRGrouponModel mj_objectWithKeyValues:json[@"group"]];
            self.goodId = self.grouponModel.goods.id;
            [self getGoodData];
            [self getCommentData];
            [self getAttentionData];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
- (void)getGoodData
{
    if (!self.goodId) {
        return;
    }
    NSDictionary *bodyDic = @{
                              @"id":self.goodId,
                              };
    
    NSDictionary *headDic = @{
                              @"cmd":@"B08",
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            DRGoodModel * goodModel = [DRGoodModel mj_objectWithKeyValues:json[@"goods"]];
            self.goodModel = goodModel;
            if (self.grouponModel) {
                self.grouponModel.goods = goodModel;
            }
            [self getDataWithCategoryId:self.goodModel.categoryId];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        DRLog(@"error:%@",error);
    }];
}
- (void)getAttentionData
{
    if (!Token || !UserId || !self.goodId) {
        return;
    }
    NSDictionary *bodyDic = @{
                              @"id":self.goodId,
                              @"type":@(1)
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U25",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            self.isAttention = [json[@"focus"] boolValue];
            if (self.isAttention) {
                [self.attentionButon setImage:[UIImage imageNamed:@"red_attention_icon"] forState:UIControlStateNormal];
                [self.attentionButon setTitle:@"已关注" forState:UIControlStateNormal];
            }else
            {
                [self.attentionButon setImage:[UIImage imageNamed:@"gray_attention_icon"] forState:UIControlStateNormal];
                [self.attentionButon setTitle:@"关注" forState:UIControlStateNormal];
            }
            [self.attentionButon setButtonTitleWithImageAlignment:UIButtonTitleWithImageAlignmentUp imgTextDistance:3];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        DRLog(@"error:%@",error);
    }];
}
- (void)attentionButonDidClick
{
    if (!Token || !UserId || !self.goodId) {
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
                              @"id":self.goodId,
                              @"type":@(1)
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":cmd,
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            self.isAttention = !self.isAttention;
            if (self.isAttention) {
                [self.attentionButon setImage:[UIImage imageNamed:@"red_attention_icon"] forState:UIControlStateNormal];
                [self.attentionButon setTitle:@"已关注" forState:UIControlStateNormal];
            }else
            {
                [self.attentionButon setImage:[UIImage imageNamed:@"gray_attention_icon"] forState:UIControlStateNormal];
                [self.attentionButon setTitle:@"关注" forState:UIControlStateNormal];
            }
            [self.attentionButon setButtonTitleWithImageAlignment:UIButtonTitleWithImageAlignmentUp imgTextDistance:3];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
- (void)grouponButtonDidClick
{
    if(!UserId || !Token)
    {
        DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
        [self presentViewController:loginVC animated:YES completion:nil];
        return;
    }
    
    NSDictionary *bodyDic = @{
                              @"goodsId":self.goodId,
                              };
    
    NSDictionary *headDic = @{
                              @"cmd":@"S03"
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            self.grouponId = json[@"group"][@"id"];
            self.groupJson = json[@"group"];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
- (void)getCommentData
{
    if (!self.goodId) {
        return;
    }
    NSDictionary *bodyDic = @{
                              @"pageIndex":@1,
                              @"pageSize":@2,
                              @"goodsId":self.goodId,
                              };
    
    NSDictionary *headDic = @{
                              
                              @"cmd":@"B21",
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        if (SUCCESS) {
            self.commentDataArray = [DRGoodCommentModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];//刷新数据
        }else
        {
            ShowErrorView
        }
        //结束刷新
        if ([self.headerView isRefreshing]) {
            [self.headerView endRefreshing];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        //结束刷新
        if ([self.headerView isRefreshing]) {
            [self.headerView endRefreshing];
        }
    }];
}
- (void)getDataWithCategoryId:(NSString *)categoryId
{
    if (DRStringIsEmpty(categoryId)) {
        return;
    }
    NSDictionary *bodyDic = @{
                              @"pageIndex":@1,
                              @"pageSize":@10,
                              @"categoryId":categoryId,
                              };
    
    NSDictionary *headDic = @{
                              @"cmd":@"B07",
                              };
    
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        if (SUCCESS) {
            self.goodDataArray = [DRGoodModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:4]];//刷新数据
        }else
        {
            ShowErrorView
        }
        //结束刷新
        if ([self.headerView isRefreshing]) {
            [self.headerView endRefreshing];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        //结束刷新
        if ([self.headerView isRefreshing]) {
            [self.headerView endRefreshing];
        }
    }];
}
#pragma mark - 布局视图
- (void)setupChilds
{
    //collectionView
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    CGFloat bottomViewH = 45;
    CGFloat collectionViewH = screenHeight - bottomViewH - [DRTool getSafeAreaBottom];
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, collectionViewH) collectionViewLayout:layout];
    self.collectionView = collectionView;
    collectionView.backgroundColor = DRBackgroundColor;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    
    //注册
    [collectionView registerClass:[DRGoodCommentCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:GoodCommentId];
    [collectionView registerClass:[DRGoodTitleCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:GoodTitleHeaderId];
    [collectionView registerClass:[DRGoodHeaderCollectionViewCell class] forCellWithReuseIdentifier:GoodHeaderId];
    [collectionView registerClass:[DRGoodCommentCollectionViewCell class] forCellWithReuseIdentifier:GoodCommentId];
    [collectionView registerClass:[DRGoodShopMessageCollectionViewCell class] forCellWithReuseIdentifier:GoodShopMessageId];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:WebViewCellId];
    [collectionView registerClass:[DRRecommendGoodCollectionViewCell class] forCellWithReuseIdentifier:GoodDetailRecommendGoodCellId];
    [self.view addSubview:collectionView];
    
    //barView
    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, statusBarH + navBarH)];
    self.barView = barView;
    barView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    [self.view addSubview:barView];
    
    UILabel *barGoodNameLabel = [[UILabel alloc] init];
    self.barGoodNameLabel = barGoodNameLabel;
    barGoodNameLabel.tag = 0;
    barGoodNameLabel.textColor = DRBlackTextColor;
    barGoodNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(35)];
    [barView addSubview:barGoodNameLabel];
    
    //返回
    UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backButton = backButton;
    backButton.tag = 1;
    backButton.frame = CGRectMake(10, statusBarH + 6, 32, 32);
    [backButton setImage:[UIImage imageNamed:@"gray_background_back_bar"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [barView addSubview:backButton];
    
    //更多
    UIButton * moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.moreButton = moreButton;
    moreButton.tag = 2;
    moreButton.frame = CGRectMake(screenWidth - 12 - 32, statusBarH + 6, 32, 32);
    [moreButton setImage:[UIImage imageNamed:@"gray_background_more_bar"] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [barView addSubview:moreButton];
    
    //购物车
    UIButton * carButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.carButton = carButton;
    carButton.tag = 3;
    carButton.frame = CGRectMake(moreButton.x - 12 - 32, statusBarH + 6, 32, 32);
    [carButton setImage:[UIImage imageNamed:@"gray_background_car_bar"] forState:UIControlStateNormal];
    [carButton addTarget:self action:@selector(carButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [barView addSubview:carButton];
    
    CGFloat bageLabelWH = 15;
    UILabel * bageLabel = [[UILabel alloc] initWithFrame:CGRectMake(carButton.width - bageLabelWH + 2, -2, bageLabelWH, bageLabelWH)];
    self.bageLabel = bageLabel;
    bageLabel.backgroundColor = DRDefaultColor;
    bageLabel.textColor = [UIColor whiteColor];
    bageLabel.font = [UIFont systemFontOfSize:DRGetFontSize(20)];
    bageLabel.adjustsFontSizeToFitWidth = YES;
    bageLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    bageLabel.textAlignment = NSTextAlignmentCenter;
    bageLabel.layer.masksToBounds = YES;
    bageLabel.layer.cornerRadius = bageLabel.width / 2;
    [carButton addSubview:bageLabel];
    [self setBageText];
    
    //底部试图
    UIView * bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(collectionView.frame), screenWidth, bottomViewH)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    //阴影
    bottomView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    bottomView.layer.shadowOffset = CGSizeMake(0, -1);
    bottomView.layer.shadowOpacity = 0.5;
    
    //立刻购买按钮
    UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.buyButton = buyButton;
    buyButton.frame = CGRectMake(screenWidth - 100, 0, 100, bottomView.height);
    [buyButton setBackgroundImage:[UIImage ImageFromColor:DRDefaultColor WithRect:buyButton.bounds] forState:UIControlStateNormal];
    [buyButton setBackgroundImage:[UIImage ImageFromColor:[UIColor lightGrayColor] WithRect:buyButton.bounds] forState:UIControlStateDisabled];
    if (self.isGroupon) {
        [buyButton setTitle:@"立即参团" forState:UIControlStateNormal];
    }else
    {
        [buyButton setTitle:@"立刻购买" forState:UIControlStateNormal];
    }
    [buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    buyButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [buyButton addTarget:self action:@selector(buyButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:buyButton];
    
    CGFloat timeLabelW = 120 * screenWidth / 375;
    if (self.isGroupon) {
        UILabel * timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(buyButton.x - timeLabelW, 0, timeLabelW, bottomView.height)];
        self.timeLabel = timeLabel;
        timeLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        timeLabel.textColor = DRDefaultColor;
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.numberOfLines = 0;
        [bottomView addSubview:timeLabel];
    }else
    {
        //加入购物车按钮
        UIButton *addCarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.addCarButton = addCarButton;
        addCarButton.frame = CGRectMake(buyButton.x - 100, 0, 100, bottomView.height);
        [addCarButton setBackgroundImage:[UIImage ImageFromColor:DRColor(20, 215, 167, 1) WithRect:addCarButton.bounds] forState:UIControlStateNormal];
        [addCarButton setTitle:@"加入购物车" forState:UIControlStateNormal];
        [addCarButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        addCarButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
        [addCarButton addTarget:self action:@selector(addCarButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:addCarButton];
    }
    
    NSArray * bottomButtonTitles = @[@"聊天", @"关注", @"进店"];
    NSArray * bottomButtonImages = @[@"good_message_icon",@"gray_attention_icon",@"good_shop_icon"];
    CGFloat bottomButtonW;
    if (self.isGroupon) {
        bottomButtonW = (buyButton.x - timeLabelW) / bottomButtonTitles.count;
    }else
    {
        bottomButtonW = (buyButton.x - 100) / bottomButtonTitles.count;
    }
    for (int i = 0; i < bottomButtonTitles.count; i++) {
        UIButton *bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
        bottomButton.tag = i;
        bottomButton.frame = CGRectMake(bottomButtonW * i, 0, bottomButtonW, bottomView.height);
        bottomButton.backgroundColor = [UIColor whiteColor];
        [bottomButton setImage:[UIImage imageNamed:bottomButtonImages[i]] forState:UIControlStateNormal];
        [bottomButton setTitle:bottomButtonTitles[i] forState:UIControlStateNormal];
        [bottomButton setTitleColor:DRGrayTextColor forState:UIControlStateNormal];
        bottomButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(22)];
        bottomButton.adjustsImageWhenHighlighted = NO;
        [bottomButton setButtonTitleWithImageAlignment:UIButtonTitleWithImageAlignmentUp imgTextDistance:3];
        [bottomButton addTarget:self action:@selector(bottomButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:bottomButton];
        if (i == 1) {
            self.attentionButon = bottomButton;
        }
        if (i != 2 || self.isGroupon)
        {
            UIView * line = [[UIView alloc] initWithFrame:CGRectMake(bottomButton.width - 1, 0, 1, bottomButton.height)];
            line.backgroundColor = DRWhiteLineColor;
            [bottomButton addSubview:line];
        }
    }
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.scrollView.scrollEnabled = NO;
    
    //浮窗视频
    DRVideoFloatingWindow *videoFloatingWindow = [[DRVideoFloatingWindow alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 390)];
    self.videoFloatingWindow = videoFloatingWindow;
    videoFloatingWindow.barView = self.barView;
    videoFloatingWindow.hidden = YES;
    videoFloatingWindow.floatingWindowType = BannerVideoFloatingWindow;
    [self.view addSubview:videoFloatingWindow];
    
    //初始化头部刷新控件
    MJRefreshGifHeader *headerRefreshView = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshViewBeginRefreshing)];
    self.headerView = headerRefreshView;
    [DRTool setRefreshHeaderData:headerRefreshView];
    collectionView.mj_header = headerRefreshView;
    
    [self.view bringSubviewToFront:self.barView];
}

- (void)headerRefreshViewBeginRefreshing
{
    if (self.isGroupon) {
        [self getGrouponData];
    }else
    {
        [self getGoodData];
        [self getCommentData];
        [self getAttentionData];
    }
}
#pragma mark - 倒计时
- (void)addSetDeadlineTimer
{
    if(self.timer == nil && self.isGroupon)//空才创建
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(setTimeLabelText) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        [self.timer fire];
    }
}
- (void)setTimeLabelText
{
    //倒计时
    NSDateComponents * components = [DRDateTool getDeltaDateToTimestampg:self.grouponModel.createTime + 2 * 24 * 60 * 60 * 1000];
    if (components.day > 0 || components.hour > 0 || components.minute > 0 || components.second > 0) {
        self.buyButton.enabled = YES;
        if (components.day > 0) {
            self.timeLabel.text = [NSString stringWithFormat:@"距结束\n%ld天 %02ld:%02ld:%02ld", components.day, components.hour, components.minute, components.second];
        }else if (components.hour > 0)
        {
            self.timeLabel.text = [NSString stringWithFormat:@"距结束\n%02ld:%02ld:%02ld", components.hour, components.minute, components.second];
        }
    }else
    {
        self.buyButton.enabled = NO;
        self.timeLabel.text = @"距结束\n00:00:00";
    }
}
#pragma mark - 设置数据
- (void)setGoodModel:(DRGoodModel *)goodModel
{
    _goodModel = goodModel;
    
    self.goodHeaderFrameModel.goodModel = _goodModel;
    self.goodHeaderFrameModel.isGroupon = self.isGroupon;
    self.goodHeaderFrameModel.grouponModel = self.grouponModel;
    
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];//刷新数据
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:2]];//刷新数据
    
    if ([_goodModel.sellType intValue] == 1) {//一物一拍/零售
        self.buyButton.hidden = NO;
        [self.buyButton setTitle:@"立刻购买" forState:UIControlStateNormal];
        [self.addCarButton setTitle:@"加入购物车" forState:UIControlStateNormal];
    } else//批发
    {
        [self.buyButton setTitle:@"我要拼团" forState:UIControlStateNormal];
        [self.addCarButton setTitle:@"批发" forState:UIControlStateNormal];
    }
    
    if ([_goodModel.sellType intValue] == 2 && !(_goodModel.isGroup || self.isGroupon)) {//批发非团购商品
        self.buyButton.hidden = YES;
        self.addCarButton.width = 200;
    }
    
    self.barGoodNameLabel.text = _goodModel.name;
   
    NSString * htmlStr = self.goodModel.detail;
    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"\n" withString:@"</br>"];
    if (!DRStringIsEmpty(htmlStr)) {
        [self.webView loadHTMLString:htmlStr baseURL:[NSURL URLWithString:baseUrl]];
    }
    
    //视频
    if (!DRStringIsEmpty(_goodModel.video)) {
        self.videoFloatingWindow.urlString = _goodModel.video;
    }
    //frame
    CGSize barGoodNameLabelSize = [self.barGoodNameLabel.text sizeWithLabelFont:self.barGoodNameLabel.font];
    self.barGoodNameLabel.frame = CGRectMake((screenWidth - barGoodNameLabelSize.width) / 2, statusBarH, barGoodNameLabelSize.width, navBarH);
}
- (void)setBageText
{
    if ([DRUserDefaultTool getShoppingCarGoodCount] > 99) {
        self.bageLabel.text = @"...";
    }else
    {
        self.bageLabel.text = [NSString stringWithFormat:@"%ld",(long)[DRUserDefaultTool getShoppingCarGoodCount]];
    }
    self.bageLabel.hidden = [self.bageLabel.text isEqualToString:@"0"];
}
#pragma mark - 按钮点击
- (void)backButtonDidClick
{
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)moreButtonDidClick
{
    DRMenuView * menuView = [[DRMenuView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) titleArray:@[@"首页", @"分享"] left:NO];
    menuView.delegate = self;
    [self.view addSubview:menuView];
}
- (void)carButtonDidClick
{
    DRShoppingCarViewController * carVC = [[DRShoppingCarViewController alloc] init];
    [self.navigationController pushViewController:carVC animated:YES];
}
- (void)menuViewButtonDidClick:(UIButton *)button
{
    if (button.tag == 0) {//去首页
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
    }else if (button.tag == 1) {//分享
        if (self.isGroupon) {
            [DRShareTool shareGrouponByGrouponId:self.grouponModel.id];
        }else
        {
            [DRShareTool shareGrouponByGoodId:self.goodId];
        }
    }
}

- (void)buyButtonDidClick:(UIButton *)button
{
    if(!UserId || !Token)
    {
        DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
        [self presentViewController:loginVC animated:YES completion:nil];
        return;
    }
    if (!self.goodModel){
        return;
    }
    
    if (self.isGroupon) {
        CGFloat backViewH = screenHeight - [DRTool getSafeAreaBottom];
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, backViewH)];
        self.backView = backView;
        backView.backgroundColor = DRColor(0, 0, 0, 0.4);
        [self.view addSubview:backView];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeBackView:)];
        tap.delegate = self;
        [backView addGestureRecognizer:tap];
        
        DRJoinGrouponView *joinGrouponView = [[DRJoinGrouponView alloc] initWithFrame:CGRectMake(0, backView.height - 10, screenWidth, 378) goodModel:self.grouponModel.goods plusCount:[self.grouponModel.plusCount intValue] payCount:[self.grouponModel.payCount intValue] successCount:[self.grouponModel.successCount intValue]];
        self.joinGrouponView = joinGrouponView;
        joinGrouponView.delegate = self;
        [backView addSubview:joinGrouponView];
        
        //动画
        [UIView animateWithDuration:DRAnimateDuration animations:^{
            joinGrouponView.y = backView.height - 378;
        }];
    }else
    {
        if ([button.currentTitle isEqualToString:@"立刻购买"]) {
            CGFloat backViewH = screenHeight - [DRTool getSafeAreaBottom];
            UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, backViewH)];
            self.backView = backView;
            backView.backgroundColor = DRColor(0, 0, 0, 0.4);
            [self.view addSubview:backView];
            
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeBackView:)];
            tap.delegate = self;
            [backView addGestureRecognizer:tap];
            
            DRWholesaleNumberView *wholesaleNumberView = [[DRWholesaleNumberView alloc] initWithFrame:CGRectMake(0, backView.height - 10, screenWidth, 378) goodModel:self.goodModel isBuy:YES];
            self.wholesaleNumberView = wholesaleNumberView;
            wholesaleNumberView.delegate = self;
            [backView addSubview:wholesaleNumberView];
            
            //动画
            [UIView animateWithDuration:DRAnimateDuration animations:^{
                wholesaleNumberView.y = backView.height - 378;
            }];
        }else
        {
            [self grouponButtonDidClick];
        }
    }
}
- (void)wholesaleNumberView:(DRWholesaleNumberView *)wholesaleNumberView selectedNumber:(int)number price:(float)price isBuy:(BOOL)isBuy
{
    [self.backView removeFromSuperview];
    if (isBuy) {
        if(!UserId || !Token)
        {
            DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
            [self presentViewController:loginVC animated:YES completion:nil];
            return;
        }
        
        NSMutableArray * goodArray = [NSMutableArray array];
        DRShoppingCarGoodModel * carGoodModel = [[DRShoppingCarGoodModel alloc] init];
        carGoodModel.count = number;
        if ([self.goodModel.sellType intValue] == 2) {
            //根据数量改变价格
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO];
            NSArray *wholesaleRule = [self.goodModel.wholesaleRule sortedArrayUsingDescriptors:@[sortDescriptor]];//排序
            
            for (NSDictionary * wholesaleRuleDic in wholesaleRule) {
                int count = [wholesaleRuleDic[@"count"] intValue];
                if (carGoodModel.count >= count) {
                    self.goodModel.price = [NSNumber numberWithInt:[wholesaleRuleDic[@"price"] intValue]];
                    break;
                }
            }
        }
        
        carGoodModel.goodModel = self.goodModel;
        [goodArray addObject:carGoodModel];
        DRSubmitOrderViewController * submitOrderVC = [[DRSubmitOrderViewController alloc] init];
        DRShoppingCarShopModel *carShopModel = [[DRShoppingCarShopModel alloc] init];
        [carShopModel.goodDic setValue:carGoodModel forKey:carGoodModel.goodModel.id];
        [carShopModel.goodArr addObject:carGoodModel];
        carShopModel.shopModel = self.goodModel.store;
        submitOrderVC.dataArray = @[carShopModel];
        [self.navigationController pushViewController:submitOrderVC animated:YES];
    }else
    {
        [MBProgressHUD showSuccess:@"加入购物车成功"];
        [DRUserDefaultTool addGoodInShoppingCarWithGood:self.goodModel count:number];
        [self setBageText];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"upSataShoppingCar" object:nil];
    }
}
- (void)addCarButtonDidClick:(UIButton *)button
{
    if (!self.goodModel) {
        return;
    }
    
    CGFloat backViewH = screenHeight - [DRTool getSafeAreaBottom];
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, backViewH)];
    self.backView = backView;
    backView.backgroundColor = DRColor(0, 0, 0, 0.4);
    [self.view addSubview:backView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeBackView:)];
    tap.delegate = self;
    [backView addGestureRecognizer:tap];
    
    DRWholesaleNumberView *wholesaleNumberView = [[DRWholesaleNumberView alloc] initWithFrame:CGRectMake(0, backView.height - 10, screenWidth, 378) goodModel:self.goodModel isBuy:NO];
    self.wholesaleNumberView = wholesaleNumberView;
    wholesaleNumberView.delegate = self;
    [backView addSubview:wholesaleNumberView];
    
    //动画
    [UIView animateWithDuration:DRAnimateDuration animations:^{
        wholesaleNumberView.y = backView.height - 378;
    }];
}
- (void)bottomButtonDidClick:(UIButton *)button
{
    if ([button.currentTitle containsString:@"聊天"]) {
        if((!UserId || !Token))
        {
            DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
            [self presentViewController:loginVC animated:YES completion:nil];
        }
        if (!self.goodModel){
            return;
        }
        DRChatViewController *chatVC = [[DRChatViewController alloc] initWithConversationChatter:self.goodModel.store.id conversationType:EMConversationTypeChat];
        chatVC.title = self.goodModel.store.storeName;
        NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@", baseUrl, self.goodModel.store.storeImg];
        [DRIMTool saveUserProfileWithUsername:self.goodModel.store.id forNickName:self.goodModel.store.storeName avatarURLPath:imageUrlStr];
        NSMutableDictionary * goodInfo = [NSMutableDictionary dictionary];
        DRGoodHeaderCollectionViewCell * headerCollectionViewCell = (DRGoodHeaderCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        
        // 商品名称
        if (!DRStringIsEmpty(headerCollectionViewCell.goodNameLabel.text)) {
            [goodInfo setObject:headerCollectionViewCell.goodNameLabel.text forKey:@"name"];
        }
        
        //商品描述
        if (!DRStringIsEmpty(headerCollectionViewCell.goodDetailLabel.text)) {
            [goodInfo setObject:headerCollectionViewCell.goodDetailLabel.text forKey:@"description"];
        }
        
        // 商品价格
        if (!DRStringIsEmpty(headerCollectionViewCell.goodPriceLabel.text)) {
            [goodInfo setObject:headerCollectionViewCell.goodPriceLabel.text forKey:@"price"];
        }
        
         // 推广图片
        if (!DRStringIsEmpty(self.goodModel.spreadPics)) {
            [goodInfo setObject:self.goodModel.spreadPics forKey:@"spreadPics"];
        }
        
        if (self.isGroupon) {//团购
            [goodInfo setObject:@"2" forKey:@"sellType"];
            if (!DRStringIsEmpty(self.grouponId)) {
                [goodInfo setObject:self.grouponId forKey:@"grouponId"];
            }
        }else
        {
            [goodInfo setObject:@"1" forKey:@"sellType"];
            if (!DRStringIsEmpty(self.goodId)) {
                [goodInfo setObject:self.goodId forKey:@"goodsId"];
            }
        }
        chatVC.goodInfo = goodInfo;
        [self.navigationController pushViewController:chatVC animated:YES];
    }else if ([button.currentTitle containsString:@"关注"]) {
        if(!UserId || !Token)
        {
            DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
            [self presentViewController:loginVC animated:YES completion:nil];
            return;
        }
        [self attentionButonDidClick];
    }else if ([button.currentTitle isEqualToString:@"进店"]) {//店铺
        if (DRStringIsEmpty(self.goodModel.store.id)){
            return;
        }
        DRShopDetailViewController * shopVC = [[DRShopDetailViewController alloc] init];
        shopVC.shopId = self.goodModel.store.id;
        [self.navigationController pushViewController:shopVC animated:YES];
    }
}
- (void)setGroupJson:(id)groupJson
{
    _groupJson = groupJson;
    if (_groupJson) {//参加团购
        CGFloat backViewH = screenHeight - [DRTool getSafeAreaBottom];
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, backViewH)];
        self.backView = backView;
        backView.backgroundColor = DRColor(0, 0, 0, 0.4);
        [self.view addSubview:backView];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeBackView:)];
        tap.delegate = self;
        [backView addGestureRecognizer:tap];
        
        DRJoinGrouponView *joinGrouponView = [[DRJoinGrouponView alloc] initWithFrame:CGRectMake(0, backView.height - 10, screenWidth, 378) goodModel:self.goodModel plusCount:[_groupJson[@"plusCount"] intValue] payCount:[_groupJson[@"payCount"] intValue] successCount:[_groupJson[@"successCount"] intValue]];
        self.joinGrouponView = joinGrouponView;
        joinGrouponView.delegate = self;
        [backView addSubview:joinGrouponView];
        
        //动画
        [UIView animateWithDuration:DRAnimateDuration animations:^{
            joinGrouponView.y = backView.height - 378;
        }];
    }else
    {
        CGFloat backViewH = screenHeight - [DRTool getSafeAreaBottom];
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, backViewH)];
        self.backView = backView;
        backView.backgroundColor = DRColor(0, 0, 0, 0.4);
        [self.view addSubview:backView];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeBackView:)];
        tap.delegate = self;
        [backView addGestureRecognizer:tap];
        
        DRStartGrouponView *startGrouponView = [[DRStartGrouponView alloc] initWithFrame:CGRectMake(0, backView.height - 10, screenWidth, 378) goodModel:self.goodModel successCount:[self.goodModel.groupNumber intValue]];
        self.startGrouponView = startGrouponView;
        startGrouponView.delegate = self;
        [backView addSubview:startGrouponView];
        
        //动画
        [UIView animateWithDuration:DRAnimateDuration animations:^{
            startGrouponView.y = backView.height - 378;
        }];
    }
}
- (void)JoinGrouponView:(DRJoinGrouponView *)joinGrouponView selectedNumber:(int)number
{
    [self.backView removeFromSuperview];
    
    if(!UserId || !Token)
    {
        DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
        [self presentViewController:loginVC animated:YES completion:nil];
        return;
    }
    
    DRSubmitOrderViewController * submitOrderVC = [[DRSubmitOrderViewController alloc] init];
    NSMutableArray * goodArray = [NSMutableArray array];
    DRShoppingCarGoodModel * carGoodModel = [[DRShoppingCarGoodModel alloc] init];
    carGoodModel.count = number;
    carGoodModel.goodModel = self.goodModel;
    [goodArray addObject:carGoodModel];
    DRShoppingCarShopModel *carShopModel = [[DRShoppingCarShopModel alloc] init];
    [carShopModel.goodDic setValue:carGoodModel forKey:carGoodModel.goodModel.id];
    [carShopModel.goodArr addObject:carGoodModel];
    carShopModel.shopModel = self.goodModel.store;
    submitOrderVC.grouponType = 1;
    submitOrderVC.groupId = self.grouponId;
    submitOrderVC.dataArray = @[carShopModel];
    [self.navigationController pushViewController:submitOrderVC animated:YES];
}

- (void)startGrouponView:(DRStartGrouponView *)startGrouponView selectedNumber:(int)number price:(float)price
{
    [self.backView removeFromSuperview];
    
    if(!UserId || !Token)
    {
        DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
        [self presentViewController:loginVC animated:YES completion:nil];
        return;
    }
    
    DRSubmitOrderViewController * submitOrderVC = [[DRSubmitOrderViewController alloc] init];
    NSMutableArray * goodArray = [NSMutableArray array];
    DRShoppingCarGoodModel * carGoodModel = [[DRShoppingCarGoodModel alloc] init];
    carGoodModel.count = number;
    self.goodModel.price = [NSNumber numberWithFloat:price];
    carGoodModel.goodModel = self.goodModel;
    [goodArray addObject:carGoodModel];
    DRShoppingCarShopModel *carShopModel = [[DRShoppingCarShopModel alloc] init];
    [carShopModel.goodDic setValue:carGoodModel forKey:carGoodModel.goodModel.id];
    [carShopModel.goodArr addObject:carGoodModel];
    carShopModel.shopModel = self.goodModel.store;
    submitOrderVC.dataArray = @[carShopModel];
    submitOrderVC.grouponType = 2;
    submitOrderVC.groupId = self.grouponId;
    [self.navigationController pushViewController:submitOrderVC animated:YES];
}
- (void)removeBackView:(UITapGestureRecognizer *)tap
{
    [self.backView removeFromSuperview];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // 获取内容高度
    CGFloat height = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
    self.webView.height = height;
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:3]];//刷新数据
}
#pragma mark - UICollectionViewDelegateFlowLayout
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    if (section == 4) {
        return 5;
    }
    return 0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    if (section == 4) {
        return 5;
    }
    return 0;
}
//配置item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return CGSizeMake(screenWidth, self.goodHeaderFrameModel.GoodHeaderCellH);
    }else if (indexPath.section == 1)
    {
        DRGoodCommentModel * model = self.commentDataArray[indexPath.item];
        return CGSizeMake(screenWidth, model.cellH);
    }else if (indexPath.section == 2)
    {
        return CGSizeMake(screenWidth, 90);
    }else if (indexPath.section == 3)
    {
        if (DRStringIsEmpty(self.goodModel.detail)) {
            return CGSizeMake(screenWidth, 0.01);
        }
        return CGSizeMake(screenWidth, self.webView.height);
    }else if (indexPath.section == 4)
    {
        CGFloat width = (screenWidth - 5) / 2;
        return CGSizeMake(width, width + 75);
    }
    return CGSizeZero;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == 1 && [self.goodModel.commentCount intValue] > 0) {
        return CGSizeMake(screenWidth, 9 + 35);
    }else if (section == 3 && !DRStringIsEmpty(self.goodModel.detail))
    {
        return CGSizeMake(screenWidth, 9 + 40);
    }else if (section == 4 && self.goodDataArray.count > 0)
    {
        return CGSizeMake(screenWidth, 9 + 40);
    }
    return CGSizeZero;
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 5;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0 || section == 2 || section == 3) {
        return 1;
    }else if (section == 1)
    {
        return self.commentDataArray.count;
    }else if (section == 4)
    {
        return self.goodDataArray.count;
    }
    return 0;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        DRGoodHeaderCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GoodHeaderId forIndexPath:indexPath];
        cell.goodHeaderFrameModel = self.goodHeaderFrameModel;
        cell.barView = self.barView;
        cell.delegate = self;
        return cell;
    }else if (indexPath.section == 1)
    {
        DRGoodCommentCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GoodCommentId forIndexPath:indexPath];
        cell.model = self.commentDataArray[indexPath.item];
        return cell;
    }else if (indexPath.section == 2)
    {
        DRGoodShopMessageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GoodShopMessageId forIndexPath:indexPath];
        cell.store = self.goodModel.store;
        return cell;
    }else if (indexPath.section == 3)
    {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:WebViewCellId forIndexPath:indexPath];
        [cell addSubview:self.webView];
        return cell;
    }else if (indexPath.section == 4)
    {
        DRRecommendGoodCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GoodDetailRecommendGoodCellId forIndexPath:indexPath];
        cell.model = self.goodDataArray[indexPath.item];
        return cell;
    }
    return nil;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader && (indexPath.section == 1 && [self.goodModel.commentCount intValue] > 0)) {
        DRGoodCommentCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:GoodCommentId forIndexPath:indexPath];
        headerView.goodModel = self.goodModel;
        return headerView;
    }else if (kind == UICollectionElementKindSectionHeader && ((indexPath.section == 3 && !DRStringIsEmpty(self.goodModel.detail)) || (indexPath.section == 4 && self.goodDataArray.count > 0)))
    {
        DRGoodTitleCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:GoodTitleHeaderId forIndexPath:indexPath];
        if (indexPath.section == 3 && !DRStringIsEmpty(self.goodModel.detail)) {
            headerView.title = @"—— 商品详情 ——";
        }else if (indexPath.section == 4 && self.goodDataArray.count > 0)
        {
            headerView.title = @"—— 同类推荐 ——";
        }
        return headerView;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 4) {
        DRGoodDetailViewController * goodVC = [[DRGoodDetailViewController alloc] init];
        DRGoodModel * goodModel = self.goodDataArray[indexPath.item];
        goodVC.goodId = goodModel.id;
        [self.navigationController pushViewController:goodVC animated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView) {
        CGFloat offsetY = scrollView.contentOffset.y;
        CGFloat scale = offsetY / (390 - statusBarH - navBarH + 80);
        scale = scale > 1 ? 1 : scale;
        //设置bar背景色
        self.barView.backgroundColor = [UIColor colorWithWhite:1 alpha:scale];
        self.barGoodNameLabel.alpha = scale;
        if (offsetY <= 390 - statusBarH - navBarH) {
            if(self.videoFloatingWindow.hidden == NO)
            {
                for (UIView * subView in self.barView.subviews) {
                    subView.hidden = YES;
                    if (subView.tag == 1) {
                        subView.hidden = NO;
                    }
                }
            }
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            [self.backButton setImage:[UIImage imageNamed:@"gray_background_back_bar"] forState:UIControlStateNormal];
            [self.moreButton setImage:[UIImage imageNamed:@"gray_background_more_bar"] forState:UIControlStateNormal];
            [self.carButton setImage:[UIImage imageNamed:@"gray_background_car_bar"] forState:UIControlStateNormal];
            self.videoFloatingWindow.y = -offsetY;
            if (self.videoFloatingWindow.floatingWindowType == SmallVideoFloatingWindow) {
                self.videoFloatingWindow.frame = CGRectMake(0, 0, screenWidth, 390);
                self.videoFloatingWindow.floatingWindowType = BannerVideoFloatingWindow;
            }
        }else
        {
            for (UIView * subView in self.barView.subviews) {
                subView.hidden = NO;
            }
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
            [self.backButton setImage:[UIImage imageNamed:@"black_back_bar"] forState:UIControlStateNormal];
            [self.moreButton setImage:[UIImage imageNamed:@"black_more_bar"] forState:UIControlStateNormal];
            [self.carButton setImage:[UIImage imageNamed:@"black_car_bar"] forState:UIControlStateNormal];
            if (self.videoFloatingWindow.floatingWindowType == BannerVideoFloatingWindow) {
                CGFloat SmallVideoFloatingWindowW = 180;
                CGFloat SmallVideoFloatingWindowH = 112;
                self.videoFloatingWindow.frame = CGRectMake(screenWidth - SmallVideoFloatingWindowW, statusBarH + navBarH, SmallVideoFloatingWindowW, SmallVideoFloatingWindowH);
                self.videoFloatingWindow.floatingWindowType = SmallVideoFloatingWindow;
            }
        }
    }
}

- (void)goodHeaderCollectionViewPlayDidClickWithCell:(DRGoodHeaderCollectionViewCell *)cell
{
    self.videoFloatingWindow.hidden = NO;
    [self.videoFloatingWindow.playerView resetPlay];
}

#pragma mark - 初始化
- (NSArray *)commentDataArray
{
    if (!_commentDataArray) {
        _commentDataArray = [NSArray array];
    }
    return _commentDataArray;
}
- (NSArray *)goodDataArray
{
    if (!_goodDataArray) {
        _goodDataArray = [NSArray array];
    }
    return _goodDataArray;
}
- (DRGoodHeaderFrameModel *)goodHeaderFrameModel
{
    if (!_goodHeaderFrameModel) {
        _goodHeaderFrameModel = [[DRGoodHeaderFrameModel alloc] init];
    }
    return _goodHeaderFrameModel;
}
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        if (CGRectContainsPoint(self.wholesaleNumberView.frame, [touch locationInView:self.wholesaleNumberView.superview]) || CGRectContainsPoint(self.startGrouponView.frame, [touch locationInView:self.startGrouponView.superview]) || CGRectContainsPoint(self.joinGrouponView.frame, [touch locationInView:self.joinGrouponView.superview])) {
            return NO;
        }
    }
    return YES;
}
#pragma  mark - 销毁对象
- (void)removeSetDeadlineTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)dealloc
{
    if (self.videoFloatingWindow) {
        [self.videoFloatingWindow.playerView destroyPlayer];
    }
}

@end

