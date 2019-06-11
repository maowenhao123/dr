//
//  DRShowTableView.m
//  dr
//
//  Created by 毛文豪 on 2018/12/13.
//  Copyright © 2018 JG. All rights reserved.
//

#import "DRShowTableView.h"
#import "DRShowDetailViewController.h"
#import "DRLoginViewController.h"
#import "DRShowSectionHeaderView.h"
#import "DRShowSectionFooterView.h"
#import "DRShowPraiseTableViewCell.h"
#import "DRShowListCommentTableViewCell.h"
#import "DRShowHeaderView.h"
#import "IQKeyboardManager.h"
#import "XLPhotoBrowser.h"

@interface DRShowTableView ()<UITableViewDelegate, UITableViewDataSource, ShowHeaderDelegate, ShowDetailDelegate ,SendCommentViewDelegate, XLPhotoBrowserDatasource>

@property (nonatomic, assign) int pageIndex;//页数
@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, weak) MJRefreshGifHeader *headerView;
@property (nonatomic, weak) MJRefreshBackGifFooter *footerView;
@property (nonatomic, weak) UIButton * backTopBtn;
@property (nonatomic,assign) CGFloat keyboardHeight;
@property (nonatomic,strong) DRShowModel * showModel;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, assign) CGFloat topY;
@property (nonatomic, assign) BOOL headerRefreshing;

@end

@implementation DRShowTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style userId:(NSString *)userId type:(NSNumber *)type topY:(CGFloat)topY 
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.userId = userId;
        self.topY = topY;
        self.type = type;
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [self setEstimatedSectionHeaderHeightAndFooterHeight];
        self.pageIndex = 1;
//        [MBProgressHUD showMessage:@"加载中..."];
        [self getData];
        //接收登录成功的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData) name:@"loginSuccess" object:nil];
        // 监听键盘弹出
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTopButtonDidClick:) name:@"ShowTopButtonDidClick" object:nil];
    }
    return self;
}

- (void)showTopButtonDidClick:(NSNotification *)note
{
    NSDictionary * objectDic = note.object;
    self.type = @([objectDic[@"index"] intValue]);

    self.pageIndex = 1;
    self.headerRefreshing = YES;
    [self getData];
}

// 键盘弹出会调用
- (void)keyboardWillShow:(NSNotification *)note
{
    // 获取键盘frame
    CGRect endFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyboardHeight = endFrame.size.height;
    // 获取键盘弹出时长
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration
                     animations:^{
                         self.sendCommentTextView.y = screenHeight - self.topY - self.sendCommentTextView.height - endFrame.size.height;
                     }];
}
- (void)keyboardWillHide:(NSNotification *)note
{
    self.sendCommentTextView.textView.myPlaceholder = nil;
    // 获取键盘弹出时长
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration
                     animations:^{
                         self.sendCommentTextView.y = screenHeight - self.topY;
                     }];
}
#pragma mark - 请求数据
- (void)getData
{
    NSString *userId = @"";
    if (!DRStringIsEmpty(self.userId)) {
        userId = self.userId;
    }
    //type 为0 获取自己的，type为1 获取所有用户的
    NSDictionary *bodyDic = @{
                              @"pageIndex":@(self.pageIndex),
                              @"pageSize":DRPageSize,
                              @"type":self.type,
                              @"userId":userId,
                              };
    NSDictionary *headDic = @{
                              @"cmd":@"A03",
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        [MBProgressHUD hideHUD];
        NSLog(@"A03:%@", json);
        if (SUCCESS) {
            if (self.headerRefreshing) {
                [self.dataArray removeAllObjects];
                self.headerRefreshing = NO;
            }
            NSArray *dataArr = [DRShowModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            [self.dataArray addObjectsFromArray:dataArr];
            for (DRShowModel * showModel in dataArr) {
                [showModel setFrameCellH];
                [self getPraiseAndCommentDataById:showModel.id index:[self.dataArray indexOfObject:showModel]];
            }
            
            [self reloadData];//刷新数据
            if ([self.footerView isRefreshing]) {
                if (dataArr.count == 0) {
                    [self.footerView endRefreshingWithNoMoreData];
                }else
                {
                    [self.footerView endRefreshing];
                }
            }
        }else
        {
            ShowErrorView
            if ([self.footerView isRefreshing]) {
                [self.footerView endRefreshing];
            }
        }
        //结束刷新
        if ([self.headerView isRefreshing]) {
            [self.headerView endRefreshing];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUD];
        //结束刷新
        if ([self.headerView isRefreshing]) {
            [self.headerView endRefreshing];
        }
        if ([self.footerView isRefreshing]) {
            [self.footerView endRefreshing];
        }
    }];
}
- (void)getPraiseAndCommentDataById:(NSString *)artId index:(NSInteger)index
{
    NSDictionary *bodyDic = @{
                              @"artId":artId,
                              @"pageIndex":@(1),
                              @"pageSize":DRPageSize,
                              @"praisePageIndex":@1,
                              @"praisePageSize":@10000,
                              };
    
    NSDictionary *headDic = @{
                              @"cmd":@"A21",
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            DRShowModel * showModel = self.dataArray[index];
            DRShowPraiseModel * showPraiseModel = [[DRShowPraiseModel alloc] init];
            NSArray * praiseList = [DRPraiseUserModel mj_objectArrayWithKeyValuesArray:json[@"praiseList"]];
            showPraiseModel.praiseCount = @(praiseList.count);
            if (praiseList.count > 20) {
                praiseList = [praiseList subarrayWithRange:NSMakeRange(0, 20)];
            }
            showPraiseModel.praiseList = praiseList;
            NSArray *commentArray = [DRShowCommentModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            for (DRShowCommentModel * showCommentModel in commentArray) {
                [showCommentModel setFrameListCellH];
            }
            showModel.showPraiseModel = showPraiseModel;
            showModel.commentArray = commentArray;
            [UIView performWithoutAnimation:^{
                [self reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationNone];
            }];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
//点赞
- (void)praiseButtonDidClickArtId:(NSString *)artId index:(NSInteger)index
{
    if(!UserId || !Token)
    {
        return;
    }
    
    NSDictionary *bodyDic = @{
                              @"artId":artId,
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"A23",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            [self.praiseGifImageView startAnimating];
            [self getPraiseAndCommentDataById:artId index:index];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
//发表评论
- (void)commentButtonDidClickArtId:(NSString *)artId toUserId:(NSString *)toUserId index:(NSInteger)index
{
    if(!UserId || !Token)
    {
        return;
    }
    
    if (DRStringIsEmpty(self.sendCommentTextView.textView.text)) {
        [MBProgressHUD showError:@"请输入评论内容"];
        return;
    }
    
    NSDictionary *bodyDic_ = @{
                               @"content":self.sendCommentTextView.textView.text,
                               @"artId":artId,
                               };
    NSMutableDictionary * bodyDic = [NSMutableDictionary dictionaryWithDictionary:bodyDic_];
    if (!DRStringIsEmpty(toUserId)) {
        [bodyDic setObject:toUserId forKey:@"toUserId"];
    }
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"A20",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            [self.sendCommentTextView reset];
            [self.sendCommentTextView.textView resignFirstResponder];
            [self getPraiseAndCommentDataById:artId index:index];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
#pragma mark - 布局视图
- (void)setupChilds
{
    //初始化头部刷新控件
    MJRefreshGifHeader *headerView = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshViewBeginRefreshing)];
    self.headerView = headerView;
    [DRTool setRefreshHeaderData:headerView];
    self.mj_header = headerView;
    
    //初始化底部刷新控件
    MJRefreshBackGifFooter *footerView = [MJRefreshBackGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshViewBeginRefreshing)];
    self.footerView = footerView;
    [DRTool setRefreshFooterData:footerView];
    self.mj_footer = footerView;
    
    DRSendCommentView * sendCommentTextView = [[DRSendCommentView alloc] initWithFrame:CGRectMake(0, screenHeight - self.topY, screenWidth, 40)];
    self.sendCommentTextView = sendCommentTextView;
    sendCommentTextView.delegate = self;
    [self.viewController.view addSubview:sendCommentTextView];
    
    //点赞gif
    CGFloat praiseGifImageViewW = 137;
    CGFloat praiseGifImageViewH = 126;
    UIImageView * praiseGifImageView = [[UIImageView alloc] init];
    self.praiseGifImageView = praiseGifImageView;
    praiseGifImageView.bounds = CGRectMake(0, 0, praiseGifImageViewW, praiseGifImageViewH);
    praiseGifImageView.center = self.center;
    NSMutableArray * animationImages = [NSMutableArray array];
    for (int i = 0; i < 7; i++) {
        UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"show_praise_gif%d", i + 1]];
        [animationImages addObject:image];
    }
    praiseGifImageView.animationImages = animationImages;
    praiseGifImageView.animationDuration = 1;
    praiseGifImageView.animationRepeatCount = 1;
    [self.viewController.view addSubview:praiseGifImageView];
    
    //回到顶部按钮
    UIButton * backTopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backTopBtn = backTopBtn;
    CGFloat backTopBtnW = 40;
    CGFloat backTopBtnH = 40;
    CGFloat backTopBtnX = screenWidth - backTopBtnW - 20;
    CGFloat backTopBtnY = screenHeight - statusBarH - navBarH - [DRTool getSafeAreaBottom] - backTopBtnH - 20;
    backTopBtn.frame = CGRectMake(backTopBtnX, backTopBtnY, backTopBtnW, backTopBtnH);
    [backTopBtn setBackgroundImage:[UIImage imageNamed:@"go_top"] forState:UIControlStateNormal];
    [backTopBtn addTarget:self action:@selector(backTopBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    backTopBtn.hidden = YES;
    [self.viewController.view addSubview:backTopBtn];
}

- (void)backTopBtnDidClick
{
    [self setContentOffset:CGPointMake(self.contentOffset.x, 0) animated:YES];
}

- (void)deleteShowSuccess
{
    [self headerRefreshViewBeginRefreshing];
}

- (void)headerRefreshViewBeginRefreshing
{
    self.pageIndex = 1;
    self.headerRefreshing = YES;
    [self getData];
}

- (void)footerRefreshViewBeginRefreshing
{
    self.pageIndex++;
    [self getData];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DRShowModel * showModel = self.dataArray[section];
    NSInteger commentCount = showModel.commentArray.count > 7 ? 7 : showModel.commentArray.count;
    return 1 + commentCount;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRShowModel * showModel = self.dataArray[indexPath.section];
    if (indexPath.row == 0) {
        DRShowPraiseTableViewCell *cell = [DRShowPraiseTableViewCell cellWithTableView:tableView];
        cell.isList = YES;
        cell.showPraiseModel = showModel.showPraiseModel;
        return cell;
    }else
    {
        DRShowListCommentTableViewCell * cell = [DRShowListCommentTableViewCell cellWithTableView:tableView];
        DRShowCommentModel * model = showModel.commentArray[indexPath.row - 1];
        if (indexPath.row == 1) {
            model.isFirst = YES;
        }else
        {
            model.isFirst = NO;
        }
        cell.model = model;
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    DRShowSectionHeaderView *headerView = [DRShowSectionHeaderView headerViewWithTableView:tableView];
    headerView.delegate = self;
    DRShowModel * model = self.dataArray[section];
    model.index = section;
    headerView.model = model;
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (self.dataArray.count == 0) {
        return nil;
    }
    DRShowModel * model = self.dataArray[section];
    if ([model.commentCount intValue] > 7) {
        DRShowSectionFooterView *footerView = [DRShowSectionFooterView headerFooterViewWithTableView:tableView];
        footerView.tag = section;
        footerView.model = model;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(footerViewDidClick:)];
        [footerView addGestureRecognizer:tap];
        return footerView;
    }
    return nil;
}

- (void)footerViewDidClick:(UIGestureRecognizer *)tap
{
    if ([self.sendCommentTextView.textView isFirstResponder]) {
        [self endEditing:YES];
        return;
    }
    DRShowModel * model = self.dataArray[tap.view.tag];
    DRShowDetailViewController * showDetailVC = [[DRShowDetailViewController alloc] init];
    showDetailVC.showId = model.id;
    showDetailVC.index = tap.view.tag;
    showDetailVC.delegate = self;
    [self.viewController.navigationController pushViewController:showDetailVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    DRShowModel * model = self.dataArray[section];
    return model.headerViewH;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        DRShowModel * showModel = self.dataArray[indexPath.section];
        DRShowPraiseModel *showPraiseModel = showModel.showPraiseModel;
        return showPraiseModel.cellH;
    }else
    {
        DRShowModel * showModel = self.dataArray[indexPath.section];
        DRShowCommentModel * model = showModel.commentArray[indexPath.row - 1];
        return model.listCellH;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    DRShowModel * model = self.dataArray[section];
    if ([model.commentCount intValue] > 7) {
        return 35;
    }
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.sendCommentTextView.textView isFirstResponder]) {
        [self.sendCommentTextView.textView resignFirstResponder];
        return;
    }
    
    if (indexPath.row == 0) {
        return;
    }
    
    if(!UserId || !Token)
    {
        DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
        [self.viewController presentViewController:loginVC animated:YES completion:nil];
        return;
    }
    
    DRShowModel * model = self.dataArray[indexPath.section];
    DRShowCommentModel * showCommentModel = model.commentArray[indexPath.row - 1];
    [self.sendCommentTextView.textView becomeFirstResponder];
    self.sendCommentTextView.textView.myPlaceholder = [NSString stringWithFormat:@"回复：%@", showCommentModel.userNickName];
    self.sendCommentTextView.toUserId = showCommentModel.userId;
    self.sendCommentTextView.artId = model.id;
    self.sendCommentTextView.index = indexPath.section;
    self.sendCommentTextView.indexPath = indexPath;
    
    //移动
    CGRect rect = [tableView rectForRowAtIndexPath:indexPath];
    CGFloat pointY = CGRectGetMaxY(rect) + self.sendCommentTextView.height + self.keyboardHeight - self.height;
    pointY = pointY <= 0 ? 0 : pointY;
    [tableView setContentOffset:CGPointMake(0, pointY) animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[UITableView class]]) {//collectionView的偏移量
        CGFloat contentOffsetY = scrollView.contentOffset.y;
        if (contentOffsetY >= screenHeight) {//大于屏幕高度才显示
            self.backTopBtn.hidden = NO;
        }else
        {
            self.backTopBtn.hidden = YES;
        }
    }
    
    if (_showDelegate && [_showDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [_showDelegate scrollViewDidScroll:self];
    }
}

#pragma mark - 协议
- (void)textViewChangeHeight:(CGFloat)height
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.sendCommentTextView.y = screenHeight - self.topY - height - self.keyboardHeight;
                     }];
    //移动
    if (self.sendCommentTextView.toUserId) {
        CGRect rect = [self rectForRowAtIndexPath:self.sendCommentTextView.indexPath];
        CGFloat pointY = CGRectGetMaxY(rect) + self.sendCommentTextView.height + self.keyboardHeight - self.height;
        pointY = pointY <= 0 ? 0 : pointY;
        [self setContentOffset:CGPointMake(0, pointY) animated:YES];
    }else
    {
        CGRect rect = [self rectForHeaderInSection:self.sendCommentTextView.index];
        CGFloat pointY = CGRectGetMaxY(rect) + self.sendCommentTextView.height + self.keyboardHeight - self.height;
        pointY = pointY <= 0 ? 0 : pointY;
        [self setContentOffset:CGPointMake(0, pointY) animated:YES];
    }
}

- (void)textViewSendButtonDidClickWithText:(NSString *)text
{
    [self commentButtonDidClickArtId:self.sendCommentTextView.artId toUserId:self.sendCommentTextView.toUserId index:self.sendCommentTextView.index];
}

- (void)showHeaderViewShowDidClickWithHeaderView:(DRShowSectionHeaderView *)headerView
{
    if ([self.sendCommentTextView.textView isFirstResponder]) {
        [self.sendCommentTextView.textView resignFirstResponder];
        return;
    }
    DRShowDetailViewController * showDetailVC = [[DRShowDetailViewController alloc] init];
    showDetailVC.showId = headerView.model.id;
    showDetailVC.delegate = self;
    showDetailVC.index = [self.dataArray indexOfObject:headerView.model];
    [self.viewController.navigationController pushViewController:showDetailVC animated:YES];
}

- (void)showHeaderViewShowImageDidClickWithHeaderView:(DRShowSectionHeaderView *)headerView imageView:(UIImageView *)imageView
{
    if ([self.sendCommentTextView.textView isFirstResponder]) {
        [self.sendCommentTextView.textView resignFirstResponder];
        return;
    }
    
    self.showModel = headerView.model;
    NSArray * imageUrls = [self.showModel.pics componentsSeparatedByString:@"|"];
    XLPhotoBrowser * photoBrowser = [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:imageView.tag imageCount:imageUrls.count datasource:self];
    photoBrowser.browserStyle = XLPhotoBrowserStyleSimple;
}

- (void)showHeaderViewPraiseDidClickWithHeaderView:(DRShowSectionHeaderView *)headerView
{
    if ([self.sendCommentTextView.textView isFirstResponder]) {
        [self.sendCommentTextView.textView resignFirstResponder];
        return;
    }
    
    if(!UserId || !Token)
    {
        DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
        [self.viewController presentViewController:loginVC animated:YES completion:nil];
        return;
    }
    
    [self praiseButtonDidClickArtId:headerView.model.id index:headerView.model.index];
}

- (void)showHeaderViewCommentDidClickWithHeaderView:(DRShowSectionHeaderView *)headerView
{
    if ([self.sendCommentTextView.textView isFirstResponder]) {
        [self.sendCommentTextView.textView resignFirstResponder];
        return;
    }
    
    if(!UserId || !Token)
    {
        DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
        [self.viewController presentViewController:loginVC animated:YES completion:nil];
        return;
    }
    
    self.sendCommentTextView.artId = headerView.model.id;
    self.sendCommentTextView.index = headerView.model.index;
    [self.sendCommentTextView.textView becomeFirstResponder];
    
    //移动
    CGRect rect = [self rectForHeaderInSection:headerView.model.index];
    CGFloat pointY = CGRectGetMaxY(rect) + self.sendCommentTextView.height + self.keyboardHeight - self.height;
    pointY = pointY <= 0 ? 0 : pointY;
    [self setContentOffset:CGPointMake(0, pointY) animated:YES];
}

#pragma mark - XLPhotoBrowserDatasource
- (UIImage *)photoBrowser:(XLPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    DRShowSectionHeaderView *headerView = (DRShowSectionHeaderView *)[self headerViewForSection:self.showModel.index];
    UIImageView * imageView = headerView.imageViews[index];
    return imageView.image;
}
- (NSURL *)photoBrowser:(XLPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    NSMutableArray *URLArray = [NSMutableArray array];
    NSArray * imageUrls = [self.showModel.pics componentsSeparatedByString:@"|"];
    for (NSString * imageUrl in imageUrls) {
        NSString * urlStr = [NSString stringWithFormat:@"%@%@",baseUrl, imageUrl];
        [URLArray addObject:[NSURL URLWithString:urlStr]];
    }
    return URLArray[index];
}
- (UIView *)photoBrowser:(XLPhotoBrowser *)browser sourceImageViewForIndex:(NSInteger)index
{
    DRShowSectionHeaderView *headerView = (DRShowSectionHeaderView *)[self headerViewForSection:self.showModel.index];
    return headerView.imageViews[index];
}

#pragma mark - 初始化
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
