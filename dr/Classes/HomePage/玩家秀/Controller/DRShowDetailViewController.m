//
//  DRShowDetailViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/3/31.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShowDetailViewController.h"
#import "DRLoginViewController.h"
#import "DRShopDetailViewController.h"
#import "DRShowDetailHeaderView.h"
#import "DRShowPraiseTableViewCell.h"
#import "DRShowCommentTableViewCell.h"
#import "IQKeyboardManager.h"
#import "DRShareView.h"
#import "DRDateTool.h"
#import "DRShareTool.h"
#import "UIBarButtonItem+DR.h"
#import "DRSendCommentView.h"

@interface DRShowDetailViewController ()<UITableViewDelegate, UITableViewDataSource, ShowCommentTableViewCellDelegate, SendCommentViewDelegate>

@property (nonatomic, weak) UIView * tableHeaderView;
@property (nonatomic, weak) UIView * contentView;
@property (nonatomic,weak) UIButton * attentionButton;
@property (nonatomic, weak) UITableView * tableView;
@property (nonatomic, weak) UIImageView * avatarImageView;
@property (nonatomic, weak) UILabel * nameLabel;
@property (nonatomic, weak) UILabel * timeLabel;
@property (nonatomic, weak) UILabel * titleLabel;
@property (nonatomic, weak) UILabel * detailLabel;
@property (nonatomic,weak) DRSendCommentView * sendCommentTextView;
@property (nonatomic, assign) int pageIndex;//页数
@property (nonatomic, weak) MJRefreshGifHeader *headerView;
@property (nonatomic, weak) MJRefreshBackGifFooter *footerView;
@property (nonatomic,assign) BOOL isAttention;
@property (nonatomic,assign) CGFloat keyboardHeight;
@property (nonatomic, strong) NSMutableArray * imageViews;
@property (nonatomic, strong) DRShowModel * showModel;
@property (nonatomic, weak) UIImageView * praiseGifImageView;

@end

@implementation DRShowDetailViewController

#pragma mark - 控制器的生命周期
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager];
    keyboardManager.enableAutoToolbar = NO;
    keyboardManager.enable = NO;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager];
    keyboardManager.enableAutoToolbar = YES;
    keyboardManager.enable = YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.pageIndex = 1;
    self.showModel.commentArray = [NSArray array];
    self.showModel.showPraiseModel = [[DRShowPraiseModel alloc] init];
    
    [self setupChilds];
    [self getShowData];
    // 监听键盘弹出
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark - 键盘
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
                         self.sendCommentTextView.y = screenHeight - statusBarH - navBarH - self.sendCommentTextView.height - endFrame.size.height;
                     }];
    self.sendCommentTextView.praiseButton.hidden = YES;
    self.sendCommentTextView.sendButton.hidden = NO;
}
- (void)keyboardWillHide:(NSNotification *)note
{
    self.sendCommentTextView.textView.myPlaceholder = nil;
    // 获取键盘弹出时长
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration
                     animations:^{
                         self.sendCommentTextView.y = screenHeight - statusBarH - navBarH - self.sendCommentTextView.height - [DRTool getSafeAreaBottom];
                         
                     }];
    self.sendCommentTextView.praiseButton.hidden = NO;
    self.sendCommentTextView.sendButton.hidden = YES;
}
#pragma mark - 请求数据
- (void)getShowData
{
    if (DRStringIsEmpty(self.showId)) {
        return;
    }
    NSDictionary *bodyDic = @{
                              @"id":self.showId
                              };
    
    NSDictionary *headDic = @{
                              @"cmd":@"A04",
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            self.showModel = [DRShowModel mj_objectWithKeyValues:json[@"article"]];
            [self.showModel setFrameCellH];
            [self getCommentData];
            [self getAttentionData];
            
            [self setData];
        }else
        {
            ShowErrorView
        }
        
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
- (void)getCommentData
{
    if (DRStringIsEmpty(self.showId)) {
        return;
    }
    NSDictionary *bodyDic = @{
                              @"pageIndex":@(self.pageIndex),
                              @"pageSize":DRPageSize,
                              @"praisePageIndex":@1,
                              @"praisePageSize":@(1000000),
                              @"artId":self.showId,
                              };
    
    NSDictionary *headDic = @{
                              @"cmd":@"A21",
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            DRShowPraiseModel * showPraiseModel = [[DRShowPraiseModel alloc] init];
            NSArray * praiseList = [DRPraiseUserModel mj_objectArrayWithKeyValuesArray:json[@"praiseList"]];
            showPraiseModel.praiseCount = @(praiseList.count);
            showPraiseModel.praiseList = praiseList;
            NSArray *dataArr = [DRShowCommentModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            for (DRShowCommentModel * showCommentModel in dataArr) {
                [showCommentModel setFrameCellH];
            }
            NSMutableArray * dataArray = [NSMutableArray arrayWithArray:self.showModel.commentArray];
            if (DRArrayIsEmpty(dataArray)) {
                dataArray = [NSMutableArray array];
            }
            [dataArray addObjectsFromArray:dataArr];
            self.showModel.showPraiseModel = showPraiseModel;
            self.showModel.commentArray = dataArray;
            [self.sendCommentTextView.praiseButton setTitle:[NSString stringWithFormat:@"%@", self.showModel.showPraiseModel.praiseCount] forState:UIControlStateNormal];
            NSMutableArray *praiseUserIdArray = [NSMutableArray array];
            for (DRPraiseUserModel *praiseUserModel in self.showModel.showPraiseModel.praiseList) {
                [praiseUserIdArray addObject:praiseUserModel.userId];
            }
            self.sendCommentTextView.praiseButton.selected = [praiseUserIdArray containsObject:UserId];
            [self.tableView reloadData];//刷新数据
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
        DRLog(@"error:%@",error);
        //结束刷新
        if ([self.headerView isRefreshing]) {
            [self.headerView endRefreshing];
        }
        if ([self.footerView isRefreshing]) {
            [self.footerView endRefreshing];
        }
    }];
}
- (void)getAttentionData
{
    if(!UserId || !Token)
    {
        return;
    }

    if (DRStringIsEmpty(self.showId)) {
        return;
    }
    
    NSDictionary *bodyDic = @{
                              @"id":self.showModel.userId,
                              @"type":@(3)
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
            if (![UserId isEqualToString:self.showModel.userId]) {//不是自己的
                if (self.isAttention) {
                    [self.attentionButton setTitle:@"已关注" forState:UIControlStateNormal];
                }else
                {
                    [self.attentionButton setTitle:@"关注" forState:UIControlStateNormal];
                }
            }
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        DRLog(@"error:%@",error);
    }];
}
- (void)attentionButtonDidClick
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
                              @"id":self.showModel.userId,
                              @"type":@(3)
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
- (void)deleteButtonDidClick
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"确认删除该文章?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * alertAction1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction * alertAction2 = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSDictionary *bodyDic = @{
                                  @"id":self.showId,
                                  };
        
        NSDictionary *headDic = @{
                                  @"digest":[DRTool getDigestByBodyDic:bodyDic],
                                  @"cmd":@"A02",
                                  @"userId":UserId,
                                  };
        [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
            DRLog(@"%@",json);
            if (SUCCESS) {
                if (_delegate && [_delegate respondsToSelector:@selector(deleteShowSuccess)]) {
                    [_delegate deleteShowSuccess];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
        } failure:^(NSError *error) {
            DRLog(@"error:%@",error);
        }];
    }];
    [alertController addAction:alertAction1];
    [alertController addAction:alertAction2];
    [self presentViewController:alertController animated:YES completion:nil];
}
//发表评论
- (void)commentButtonDidClickToUserId:(NSString *)toUserId
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
                               @"artId":self.showId,
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
            [self headerRefreshViewBeginRefreshing];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
#pragma mark - 布局视图
- (void)setupChilds
{
    UIBarButtonItem * shareBar = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"black_share_bar"] style:UIBarButtonItemStylePlain target:self action:@selector(shareBarDidClick)];
    self.navigationItem.rightBarButtonItem = shareBar;
    
    //tableView
    CGFloat commentViewH = 40;
    CGFloat tableViewH = screenHeight - statusBarH - navBarH - commentViewH - [DRTool getSafeAreaBottom];
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, tableViewH) style:UITableViewStyleGrouped];
    self.tableView = tableView;
    tableView.backgroundColor = DRBackgroundColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    [self.view addSubview:tableView];
    
    //headerView
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0)];
    self.tableHeaderView = headerView;
    headerView.backgroundColor = DRBackgroundColor;
    
    //内容
    UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 9, screenWidth, 0)];
    self.contentView = contentView;
    contentView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:contentView];
    
    //头像
    UIImageView * avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, 9, 36, 36)];
    self.avatarImageView = avatarImageView;
    avatarImageView.image = [UIImage imageNamed:@"avatar_placeholder"];
    avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.layer.cornerRadius = avatarImageView.width / 2;
    [contentView addSubview:avatarImageView];
    
    //昵称
    UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(avatarImageView.frame) + 5, 9, screenWidth - (CGRectGetMaxX(avatarImageView.frame) + 5) - 2 * DRMargin, 20)];
    self.nameLabel = nameLabel;
    nameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    nameLabel.textColor = DRBlackTextColor;
    [contentView addSubview:nameLabel];
    
    //时间
    UILabel * timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.x, CGRectGetMaxY(nameLabel.frame), screenWidth - nameLabel.x - 2 * DRMargin, 16)];
    self.timeLabel = timeLabel;
    timeLabel.font = [UIFont systemFontOfSize:DRGetFontSize(22)];
    timeLabel.textColor = DRGrayTextColor;
    [contentView addSubview:timeLabel];
    
    //关注
    UIButton * attentionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.attentionButton = attentionButton;
    attentionButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    attentionButton.frame = CGRectMake(screenWidth - (60 + DRMargin), (53 - 28) / 2, 60, 28);
    attentionButton.layer.masksToBounds = YES;
    attentionButton.layer.cornerRadius = 4;
    attentionButton.layer.borderWidth = 1;
    [contentView addSubview:attentionButton];
    
    //分割线
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, 53, screenWidth, 1)];
    line.backgroundColor = DRWhiteLineColor;
    [contentView addSubview:line];
    
    //标题
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(line.frame), 0, 0)];
    self.titleLabel = titleLabel;
    titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    titleLabel.textColor = DRBlackTextColor;
    [contentView addSubview:titleLabel];
    
    //描述
    UILabel * detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(line.frame), 0, 0)];
    self.detailLabel = detailLabel;
    detailLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    detailLabel.textColor = DRGrayTextColor;
    detailLabel.numberOfLines = 0;
    [contentView addSubview:detailLabel];
    
    //图片
    CGFloat padding = 9;
    CGFloat imageViewWH = screenWidth - 2 * DRMargin;
    for (int i = 0; i < 9; i++) {
        UIImageView * imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(DRMargin, CGRectGetMaxY(detailLabel.frame) + 9 + (imageViewWH + padding) * i, imageViewWH, imageViewWH);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.masksToBounds = YES;
        imageView.hidden = YES;
        [contentView addSubview:imageView];
        [self.imageViews addObject:imageView];
    }
    
    contentView.height = CGRectGetMaxY(detailLabel.frame);
    headerView.height = CGRectGetMaxY(contentView.frame) + 9;
    tableView.tableHeaderView = headerView;
    
    DRSendCommentView * sendCommentTextView = [[DRSendCommentView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tableView.frame), screenWidth, commentViewH)];
    self.sendCommentTextView = sendCommentTextView;
    sendCommentTextView.delegate = self;
    sendCommentTextView.praiseButton.hidden = NO;
    sendCommentTextView.sendButton.hidden = YES;
    [self.view addSubview:sendCommentTextView];
    //初始化头部刷新控件
    MJRefreshGifHeader *headerRefreshView = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshViewBeginRefreshing)];
    self.headerView = headerRefreshView;
    [DRTool setRefreshHeaderData:headerRefreshView];
    tableView.mj_header = headerRefreshView;
    
    //初始化底部刷新控件
    MJRefreshBackGifFooter *footerView = [MJRefreshBackGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshViewBeginRefreshing)];
    self.footerView = footerView;
    [DRTool setRefreshFooterData:footerView];
    tableView.mj_footer = footerView;
    
    //点赞gif
    CGFloat praiseGifImageViewW = 137;
    CGFloat praiseGifImageViewH = 126;
    UIImageView * praiseGifImageView = [[UIImageView alloc] init];
    self.praiseGifImageView = praiseGifImageView;
    praiseGifImageView.bounds = CGRectMake(0, 0, praiseGifImageViewW, praiseGifImageViewH);
    praiseGifImageView.center = CGPointMake(self.view.centerX, self.view.centerY - self.view.height * 0.13);
    NSMutableArray * animationImages = [NSMutableArray array];
    for (int i = 0; i < 7; i++) {
        UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"show_praise_gif%d", i + 1]];
        [animationImages addObject:image];
    }
    praiseGifImageView.animationImages = animationImages;
    praiseGifImageView.animationDuration = 1;
    praiseGifImageView.animationRepeatCount = 1;
    [self.view addSubview:praiseGifImageView];
}

- (void)setData
{
    self.title = self.showModel.name;
    
    NSString * avatarUrlStr = [NSString stringWithFormat:@"%@%@",baseUrl,self.showModel.userHeadImg];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrlStr] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
    
    self.nameLabel.text = self.showModel.userNickName;
 
    self.timeLabel.text = [DRDateTool getTimeByTimestamp:self.showModel.createTime format:@"yyyy-MM-dd HH:mm:ss"];
    
    if ([UserId isEqualToString:self.showModel.userId]) {//是自己的
        [self.attentionButton setTitle:@"删除" forState:UIControlStateNormal];
        [self.attentionButton setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
        self.attentionButton.layer.borderColor = DRGrayTextColor.CGColor;
        [self.attentionButton addTarget:self action:@selector(deleteButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    }else
    {
        [self.attentionButton setTitle:@"关注" forState:UIControlStateNormal];
        [self.attentionButton setTitleColor:DRDefaultColor forState:UIControlStateNormal];
        self.attentionButton.layer.borderColor = DRDefaultColor.CGColor;
        [self.attentionButton addTarget:self action:@selector(attentionButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    }
   
    self.titleLabel.text = self.showModel.name;
    CGSize titleLabelSize = [self.titleLabel.text sizeWithLabelFont:self.titleLabel.font];
    self.titleLabel.frame = CGRectMake(DRMargin, 53 + 12, screenWidth - 2 * DRMargin, titleLabelSize.height);
    
    NSMutableAttributedString * detailAttStr = [[NSMutableAttributedString alloc] initWithString:self.showModel.content];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;//行间距
    [detailAttStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, detailAttStr.length)];
    [detailAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(24)] range:NSMakeRange(0, detailAttStr.length)];
    self.detailLabel.attributedText = detailAttStr;
    CGSize detailLabelSize = [self.detailLabel.attributedText boundingRectWithSize:CGSizeMake(screenWidth - 2 * DRMargin, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    self.detailLabel.frame = CGRectMake(DRMargin, CGRectGetMaxY(self.titleLabel.frame) + 13, screenWidth - 2 * DRMargin, detailLabelSize.height);
    
    NSArray * imageUrls = [self.showModel.pics componentsSeparatedByString:@"|"];
    NSInteger imageCount = imageUrls.count;//图片数量
    if (imageCount == 1) {
        NSString * imageUrl = imageUrls[0];
        if (DRStringIsEmpty(imageUrl)) {
            imageCount = 0;
        }
    }
    CGFloat padding = 9;
    CGFloat imageViewWH = screenWidth - 2 * DRMargin;
    
    for (int i = 0; i < 9; i++) {
        UIImageView * imageView = self.imageViews[i];
        if (i < imageCount) {
            imageView.hidden = NO;
            imageView.y = CGRectGetMaxY(self.detailLabel.frame) + 9 + (imageViewWH + padding) * i;
            NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@",baseUrl,imageUrls[i]];
            [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        }
    }
    
    self.contentView.height = CGRectGetMaxY(self.detailLabel.frame) + 9 + (imageViewWH + padding) * imageCount;
    self.tableHeaderView.height = CGRectGetMaxY(self.contentView.frame) + 9;
    self.tableView.tableHeaderView = self.tableHeaderView;
    
    self.sendCommentTextView.artId = self.showModel.id;
}

- (void)headerRefreshViewBeginRefreshing
{
    self.pageIndex = 1;
    self.showModel.commentArray = nil;
    [self getCommentData];
}
- (void)footerRefreshViewBeginRefreshing
{
    self.pageIndex++;
    [self getCommentData];
}

- (void)shareBarDidClick
{
    NSArray * imageUrls = [self.showModel.pics componentsSeparatedByString:@"|"];
    [DRShareTool shareShowWithShowId:self.showModel.id userNickName:self.showModel.userNickName title:self.showModel.name content:self.showModel.content imageUrl:[NSString stringWithFormat:@"%@%@%@", baseUrl, imageUrls.firstObject, smallPicUrl]];
}

- (void)goShopDetailBarDidClick
{
    DRShopDetailViewController * shopVC = [[DRShopDetailViewController alloc] init];
    shopVC.shopId = self.showModel.userId;
    [self.navigationController pushViewController:shopVC animated:YES];
}
#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return self.showModel.commentArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        DRShowPraiseTableViewCell *cell = [DRShowPraiseTableViewCell cellWithTableView:tableView];
        cell.showPraiseModel = self.showModel.showPraiseModel;
        return cell;
    }else
    {
        DRShowCommentTableViewCell * cell = [DRShowCommentTableViewCell cellWithTableView:tableView];
        DRShowCommentModel * model = self.showModel.commentArray[indexPath.row];
        cell.model = model;
        if (model == self.showModel.commentArray.firstObject) {
            cell.line.hidden = YES;
        }else
        {
            cell.line.hidden = NO;
        }
        cell.delegate = self;
        return cell;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) return nil;
    DRShowDetailHeaderView *headerView = [DRShowDetailHeaderView headerFooterViewWithTableView:tableView];
    headerView.model = self.showModel;
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        DRShowPraiseModel *showPraiseModel = self.showModel.showPraiseModel;
        return showPraiseModel.cellH;
    }
    DRShowCommentModel * model = self.showModel.commentArray[indexPath.row];
    return model.cellH;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) return CGFLOAT_MIN;
    return 35;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.sendCommentTextView.textView isFirstResponder]) {
        [self.sendCommentTextView.textView resignFirstResponder];
        return;
    }
}
#pragma mark - 协议
- (void)textViewChangeHeight:(CGFloat)height
{
    [UIView animateWithDuration:DRAnimateDuration
                     animations:^{
                         self.sendCommentTextView.y = screenHeight - statusBarH - navBarH  - height - self.keyboardHeight;
                     }];
    
    //移动
    if (self.sendCommentTextView.toUserId) {
        CGRect rect = [self.tableView rectForRowAtIndexPath:self.sendCommentTextView.indexPath];
        CGFloat pointY = CGRectGetMaxY(rect) + self.sendCommentTextView.height + self.keyboardHeight - self.view.height;
        [self.tableView setContentOffset:CGPointMake(0, pointY) animated:YES];
    }
}
- (void)textViewSendButtonDidClickWithText:(NSString *)text
{
    if(!UserId || !Token)
    {
        DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
        [self presentViewController:loginVC animated:YES completion:nil];
        return;
    }
    
    [self commentButtonDidClickToUserId:self.sendCommentTextView.toUserId];
}
- (void)textViewPraiseDidClick
{
    [self.praiseGifImageView startAnimating];
    
    self.pageIndex = 1;
    self.showModel.commentArray = [NSArray array];
    self.showModel.showPraiseModel = [[DRShowPraiseModel alloc] init];
    [self getShowData];
    
    if (!self.isHomePage) {
        if (_delegate && [_delegate respondsToSelector:@selector(praiseButtonDidClickArtId:index:)]) {
            NSString *artId = [NSString stringWithFormat:@"%@", self.showId];
            [_delegate praiseButtonDidClickArtId:artId index:self.index];
        }
    }
}

- (void)showCommentTableViewCellcommentButtonDidClickWithCell:(DRShowCommentTableViewCell *)cell
{
    if ([self.sendCommentTextView.textView isFirstResponder]) {
        [self.sendCommentTextView.textView resignFirstResponder];
        return;
    }

    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    
    if(!UserId || !Token)
    {
        DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
        [self presentViewController:loginVC animated:YES completion:nil];
        return;
    }
    
    DRShowCommentModel * showCommentModel = self.showModel.commentArray[indexPath.row];
    [self.sendCommentTextView.textView becomeFirstResponder];
    self.sendCommentTextView.textView.myPlaceholder = [NSString stringWithFormat:@"回复：%@", showCommentModel.userNickName];
    self.sendCommentTextView.toUserId = showCommentModel.userId;
    self.sendCommentTextView.indexPath = indexPath;
    
    //移动
    CGRect rect = [self.tableView rectForRowAtIndexPath:indexPath];
    CGFloat pointY = CGRectGetMaxY(rect) + self.sendCommentTextView.height + self.keyboardHeight - self.view.height;
    [self.tableView setContentOffset:CGPointMake(0, pointY) animated:YES];
}

#pragma mark - 初始化
- (NSMutableArray *)imageViews
{
    if (!_imageViews) {
        _imageViews = [NSMutableArray array];
    }
    return _imageViews;
}
- (DRShowModel *)showModel
{
    if (!_showModel) {
        _showModel = [[DRShowModel alloc] init];
    }
    return _showModel;
}

#pragma mark - dealloc
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UIKeyboardWillShowNotification
                                                 object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UIKeyboardWillHideNotification
                                                 object:nil];
}

@end
