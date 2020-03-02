//
//  DRShowHeaderView.m
//  dr
//
//  Created by 毛文豪 on 2018/12/17.
//  Copyright © 2018 JG. All rights reserved.
//

#import "DRShowHeaderView.h"
#import "DRLoadHtmlFileViewController.h"
#import "SDCycleScrollView.h"
#import "DRTitleCycleScrollView.h"
#import "DRPraiseListView.h"
#import "DRDateTool.h"

@interface DRShowHeaderView ()<UIScrollViewDelegate, SDCycleScrollViewDelegate>

@property (nonatomic, weak) UIView *activityView;
@property (nonatomic, weak) SDCycleScrollView * cycleScrollView;
@property (nonatomic, weak) UIView *activityContentView;
@property (nonatomic, weak) UIView * cycleNewView;
@property (nonatomic, weak) DRTitleCycleScrollView *titleCycleScrollView;
@property (nonatomic, weak) UIScrollView *praiseListScrollView;
@property (nonatomic, weak) DRPraiseListView * weekPraiseListView;
@property (nonatomic, weak) DRPraiseListView * monthPraiseListView;
@property (nonatomic,weak) UIPageControl *pageControl;
@property (nonatomic, weak) UIView *topBtnView;
@property (nonatomic, weak) UIButton *selectedTopButton;//被选中的顶部按钮
@property (nonatomic, weak) UIView * topBtnLine;
@property (nonatomic, strong) NSArray *bannerArray;

@end

@implementation DRShowHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupChildViews];
        [self getBannerData];
        [self getNewData];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPraiseActivityEnd) name:@"ShowPraiseActivityEnd" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addShowSuccess) name:@"AddShowSuccess" object:nil];
    }
    return self;
}

- (void)addShowSuccess
{
    [self topBtnClick:self.topBtnView.subviews[0]];
}

- (void)showPraiseActivityEnd
{
    self.activityContentView.hidden = YES;
    self.activityView.height = CGRectGetMaxY(self.cycleScrollView.frame) + 10;
    self.topBtnView.y = CGRectGetMaxY(self.activityView.frame);
    self.height = CGRectGetMaxY(self.topBtnView.frame);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowPraiseActivityEnd1" object:nil];
}

#pragma mark - 请求数据
- (void)getBannerData
{
    NSDictionary *bodyDic = @{
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"G01",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            if ([json[@"status"] intValue] == 1) {
                self.bannerArray = [DRHomePageBannerModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            }
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

- (void)getNewData
{
    NSDictionary *bodyDic = @{
                              };
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"G06",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        if (SUCCESS) {
            self.titleCycleScrollView.titleArray = json[@"list"];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

- (void)setBannerArray:(NSArray *)bannerArray
{
    _bannerArray = bannerArray;
    
    NSMutableArray *imageURLStringsGroups = [NSMutableArray array];
    for (DRHomePageBannerModel * model in _bannerArray) {
        [imageURLStringsGroups addObject:[NSString stringWithFormat:@"%@%@", baseUrl,model.image]];
    }
    self.cycleScrollView.imageURLStringsGroup = imageURLStringsGroups;
}

#pragma mark - 布局视图
- (void)setupChildViews
{
    //活动
    UIView * activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0)];
    self.activityView = activityView;
    activityView.backgroundColor = DRBackgroundColor;
    activityView.hidden = YES;
    [self addSubview:activityView];
    
    //轮播图
    SDCycleScrollView * cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, screenWidth, screenWidth * 150 / 375) delegate:self placeholderImage:[UIImage imageNamed:@"banner_placeholder"]];
    self.cycleScrollView = cycleScrollView;
    cycleScrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
    cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    cycleScrollView.currentPageDotColor = [UIColor whiteColor]; // 自定义分页控件小圆标颜色
    cycleScrollView.pageDotColor = [UIColor colorWithWhite:1 alpha:0.44];
    [activityView addSubview:cycleScrollView];
    
    //活动内容
    UIView * activityContentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(cycleScrollView.frame), screenWidth, 0)];
    self.activityContentView = activityContentView;
    activityContentView.backgroundColor = [UIColor whiteColor];
    [activityView addSubview:activityContentView];
    
    //金币
    CGFloat newImageViewWH = 20;
    UIImageView * newImageView = [[UIImageView alloc]init];
    newImageView.image = [UIImage imageNamed:@"praise_new_icon"];
    newImageView.frame = CGRectMake(DRMargin, (40 - newImageViewWH) / 2, newImageViewWH, newImageViewWH);
    [activityContentView addSubview:newImageView];
    
    //轮播的文字
    DRTitleCycleScrollView * titleCycleScrollView = [[DRTitleCycleScrollView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(newImageView.frame) + 5, 0, screenWidth - CGRectGetMaxX(newImageView.frame) - 5, 40) titleArray:nil animationDuration:2.5f];
    self.titleCycleScrollView = titleCycleScrollView;
    //点击事件
    titleCycleScrollView.TapActionBlock = ^(NSInteger pageIndex){
        
    };
    [activityContentView addSubview:titleCycleScrollView];
    
    //分割线
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(titleCycleScrollView.frame), screenWidth, 10)];
    lineView.backgroundColor = DRBackgroundColor;
    [activityContentView addSubview:lineView];
    
    //榜单人员
    UIScrollView *praiseListScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame), screenWidth, 145)];
    praiseListScrollView.delegate = self;
    praiseListScrollView.contentSize = CGSizeMake(screenWidth * 2, praiseListScrollView.height);
    praiseListScrollView.showsHorizontalScrollIndicator = NO;
    praiseListScrollView.pagingEnabled = YES;
    [activityContentView addSubview:praiseListScrollView];
    
    for (int i = 0; i < 2; i++) {
        DRPraiseListView * praiseListView = [[DRPraiseListView alloc] initWithFrame:CGRectMake(screenWidth * i, 0, screenWidth, 145) type:i];
        if (i == 0) {
            self.weekPraiseListView = praiseListView;
        }else
        {
            self.monthPraiseListView = praiseListView;
        }
        [praiseListScrollView addSubview:praiseListView];
    }
    
    //pageControl
    UIPageControl * pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(praiseListScrollView.frame), self.width, 30)];
    self.pageControl = pageControl;
    pageControl.currentPage = 0;
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = DRDefaultColor;
    pageControl.numberOfPages = 2;
    [activityContentView addSubview:pageControl];
    
    activityContentView.height = CGRectGetMaxY(pageControl.frame);
    activityView.height = CGRectGetMaxY(activityContentView.frame) + 10;
    
    //顶部按钮
    UIView * topBtnView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 40)];
    self.topBtnView = topBtnView;
    topBtnView.backgroundColor = [UIColor whiteColor];
    [self addSubview:topBtnView];
    
    CGFloat topBtnW = (screenWidth - 10) / 2;
    NSArray * topBtnTitles = @[@"最新", @"最热"];
    for(int i = 0;i < 2;i++)
    {
        UIButton *topBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        topBtn.tag = i;
        [topBtn setTitle:topBtnTitles[i] forState:UIControlStateNormal];
        topBtn.frame = CGRectMake(5 + i * topBtnW, 0, topBtnW, 38);
        topBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        topBtn.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        [topBtn setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
        [topBtn setTitleColor:DRDefaultColor forState:UIControlStateSelected];
        if (i == 0) {
            self.selectedTopButton = topBtn;
            topBtn.selected = YES;
        }
        [topBtn addTarget:self action:@selector(topBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [topBtnView addSubview:topBtn];
    }
    //底部线
    UIView * topBtnLine = [[UIView alloc]init];
    self.topBtnLine = topBtnLine;
    topBtnLine.frame = CGRectMake(5 + 5, 38, topBtnW - 5 * 2, 2);
    topBtnLine.backgroundColor = DRDefaultColor;
    [topBtnView addSubview:topBtnLine];
}

- (void)setOpenActivity:(BOOL)openActivity
{
    _openActivity = openActivity;
    
    if (_openActivity) {
        self.activityView.hidden = NO;
        self.topBtnView.y = CGRectGetMaxY(self.activityView.frame);
    }else
    {
        self.activityView.hidden = YES;
        self.topBtnView.y = 0;
    }
    self.height = CGRectGetMaxY(self.topBtnView.frame);
}

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    DRHomePageBannerModel * model = self.bannerArray[index];
    
    DRLoadHtmlFileViewController * htmlVC = [[DRLoadHtmlFileViewController alloc] initWithWeb:model.url];
    [self.viewController.navigationController pushViewController:htmlVC animated:YES];
}

//pagecontroll的委托方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page = ceil(scrollView.contentOffset.x / scrollView.width);
    self.pageControl.currentPage = page;
}

- (void)topBtnClick:(UIButton *)button
{    
    self.selectedTopButton.selected = NO;
    self.selectedTopButton.userInteractionEnabled = YES;
    button.selected = YES;
    button.userInteractionEnabled = NO;
    self.selectedTopButton = button;
    //红线动画
    [UIView animateWithDuration:DRAnimateDuration
                     animations:^{
                         self.topBtnLine.center = CGPointMake(button.centerX, self.topBtnLine.centerY);
                     }];
    
    NSDictionary *objectDic = @{
                                @"index":@(button.tag + 1)
                                };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowTopButtonDidClick" object:objectDic];
}


@end
