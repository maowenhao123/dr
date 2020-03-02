//
//  DRShopDetailViewController.m
//  dr
//
//  Created by apple on 17/1/16.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShopDetailViewController.h"
#import "DRLoginViewController.h"
#import "DRGoodDetailViewController.h"
#import "DRChatViewController.h"
#import "DRMenuView.h"
#import "DRShopHeaderCollectionViewCell.h"
#import "DRRecommendGoodCollectionViewCell.h"
#import "DRShareTool.h"
#import "DRIMTool.h"

NSString * const ShopGoodCellId = @"ShopGoodCellId";
NSString * const ShopHeaderCellId = @"ShopHeaderCellId";

@interface DRShopDetailViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, MenuViewDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) UIView *barView;
@property (nonatomic,weak) UIImageView *barShopLogoImageView;
@property (nonatomic, weak) UILabel * barShopNameLabel;
@property (nonatomic, weak) UIButton * backButon;
@property (nonatomic, weak) UIButton * moreButon;
@property (nonatomic,strong) NSMutableArray *goodDataArray;
@property (nonatomic,assign) BOOL isAttention;
@property (nonatomic, assign) int pageIndex;//页数
@property (nonatomic, weak) MJRefreshGifHeader *headerView;
@property (nonatomic, weak) MJRefreshBackGifFooter *footerView;
@property (nonatomic, strong) DRShopModel * shopModel;

@end

@implementation DRShopDetailViewController

#pragma mark - 控制器的生命周期
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self scrollViewDidScroll:self.collectionView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageIndex = 1;
    [self setupChilds];
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    waitingView
    [self getData];
}
#pragma mark - 请求数据
- (void)getData
{
    [self getShopData];
    [self getGoodData];
    [self getAttentionData];
}
- (void)getShopData
{
    if (!self.shopId) {
        return;
    }
    NSDictionary *bodyDic = @{
                              @"storeId":self.shopId,
                              };
    
    NSDictionary *headDic = @{
                              @"cmd":@"B01",
                              };
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            DRShopModel * shopModel = [DRShopModel mj_objectWithKeyValues:json];
            self.shopModel = shopModel;
            [UIView performWithoutAnimation:^{
                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            }];
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
    if (!self.shopId) {
        return;
    }
    NSDictionary *bodyDic = @{
                              @"pageIndex":@(self.pageIndex),
                              @"pageSize":DRPageSize,
                              @"storeId":self.shopId,
                              };
    
    NSDictionary *headDic = @{
                              @"cmd":@"B07",
                              };
    
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            NSArray *goodDataArray = [DRGoodModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            for (DRGoodModel * goodModel in goodDataArray) {
                NSInteger index = [goodDataArray indexOfObject:goodModel];
                goodModel.specifications = [DRGoodSpecificationModel mj_objectArrayWithKeyValuesArray:json[@"list"][index][@"specifications"]];
            }
            [self.goodDataArray addObjectsFromArray:goodDataArray];
            [UIView performWithoutAnimation:^{
                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
            }];
            
            [self.headerView endRefreshing];
            if (goodDataArray.count == 0) {
                [self.footerView endRefreshingWithNoMoreData];
            }else
            {
                [self.footerView endRefreshing];
            }
        }else
        {
            ShowErrorView
            [self.headerView endRefreshing];
            [self.footerView endRefreshing];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        [MBProgressHUD hideHUDForView:self.view];
        //结束刷新
        [self.headerView endRefreshing];
        [self.footerView endRefreshing];
    }];
}
- (void)getAttentionData
{
    if (!Token || !UserId || !self.shopId) {
        return;
    }
    NSDictionary *bodyDic = @{
                              @"id": self.shopId,
                              @"type":@(2)
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
            [UIView performWithoutAnimation:^{
                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            }];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
- (void)attentionButonDidClick
{
    if (!Token || !UserId || !self.shopModel.id) {
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
                              @"id":self.shopModel.id,
                              @"type":@(2)
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":cmd,
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            self.isAttention = !self.isAttention;
            NSInteger fansCount = [self.shopModel.fansCount integerValue];
            if (self.isAttention) {
                fansCount ++;
            }else
            {
                fansCount --;
            }
            self.shopModel.fansCount = @(fansCount);
            [UIView performWithoutAnimation:^{
                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            }];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        [MBProgressHUD hideHUDForView:self.view];
    }];
}
#pragma mark - 布局视图
- (void)setupChilds
{
    //layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.minimumInteritemSpacing = 5;//列间距
    layout.minimumLineSpacing = 5;//行间距
    
    //collectionView
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight) collectionViewLayout:layout];
    self.collectionView = collectionView;
    collectionView.backgroundColor = DRBackgroundColor;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    //注册
    [collectionView registerClass:[DRRecommendGoodCollectionViewCell class] forCellWithReuseIdentifier:ShopGoodCellId];
    [collectionView registerClass:[DRShopHeaderCollectionViewCell class] forCellWithReuseIdentifier:ShopHeaderCellId];
    [self.view addSubview:collectionView];
  
    //barView
    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, statusBarH + navBarH)];
    self.barView = barView;
    barView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    [self.view addSubview:barView];
    
    UILabel *barShopNameLabel = [[UILabel alloc] init];
    self.barShopNameLabel = barShopNameLabel;
    barShopNameLabel.textColor = DRBlackTextColor;
    barShopNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    [barView addSubview:barShopNameLabel];
    
    UIImageView * barShopLogoImageView = [[UIImageView alloc] init];
    self.barShopLogoImageView = barShopLogoImageView;
    barShopLogoImageView.contentMode = UIViewContentModeScaleAspectFill;
    barShopLogoImageView.layer.masksToBounds = YES;
    [barView addSubview:barShopLogoImageView];

    //返回
    UIButton * backButon = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backButon = backButon;
    backButon.frame = CGRectMake(7, statusBarH + 6, 34, 30);
    [backButon setImage:[UIImage imageNamed:@"white_back_bar"] forState:UIControlStateNormal];
    [backButon addTarget:self action:@selector(backButonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [barView addSubview:backButon];
    
    //更多
    UIButton * moreButon = [UIButton buttonWithType:UIButtonTypeCustom];
    self.moreButon = moreButon;
    moreButon.frame = CGRectMake(screenWidth - 12 - 34, statusBarH + 6, 34, 30);
    [moreButon setImage:[UIImage imageNamed:@"white_more_bar"] forState:UIControlStateNormal];
    [moreButon addTarget:self action:@selector(moreButonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [barView addSubview:moreButon];
    
    //初始化头部刷新控件
    MJRefreshGifHeader *headerRefreshView = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshViewBeginRefreshing)];
    self.headerView = headerRefreshView;
    [DRTool setRefreshHeaderData:headerRefreshView];
    collectionView.mj_header = headerRefreshView;
    
    //初始化底部刷新控件
    MJRefreshBackGifFooter *footerView = [MJRefreshBackGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshViewBeginRefreshing)];
    self.footerView = footerView;
    [DRTool setRefreshFooterData:footerView];
    collectionView.mj_footer = footerView;
}
- (void)setShopModel:(DRShopModel *)shopModel
{
    _shopModel = shopModel;
    
    self.barShopNameLabel.text = _shopModel.storeName;
    NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@",baseUrl,_shopModel.storeImg];
    [self.barShopLogoImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
    
    //frmae
    CGSize barShopNameLabelSize = [self.barShopNameLabel.text sizeWithLabelFont:self.barShopNameLabel.font];
    CGFloat barShopLogoImageViewWH = 35;
    CGFloat barShopLogoImageViewX = (screenWidth - barShopLogoImageViewWH - barShopNameLabelSize.width - 2) / 2;
    self.barShopLogoImageView.frame = CGRectMake(barShopLogoImageViewX, statusBarH + (navBarH - barShopLogoImageViewWH) / 2, barShopLogoImageViewWH, barShopLogoImageViewWH);
    self.barShopLogoImageView.layer.cornerRadius = self.barShopLogoImageView.width / 2;
    self.barShopNameLabel.frame = CGRectMake(CGRectGetMaxX(self.barShopLogoImageView.frame) + 2, statusBarH, barShopNameLabelSize.width, navBarH);
}
- (void)headerRefreshViewBeginRefreshing
{
    self.pageIndex = 1;
    [self.goodDataArray removeAllObjects];
    [self getGoodData];
}
- (void)footerRefreshViewBeginRefreshing
{
    self.pageIndex++;
    [self getGoodData];
}
- (void)backButonDidClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)moreButonDidClick
{
    DRMenuView * menuView = [[DRMenuView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) titleArray:@[@"首页", @"分享"] left:NO];
    menuView.delegate = self;
    [self.view addSubview:menuView];
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
    }else if (button.tag == 1)//分享
    {
        [DRShareTool shareGrouponByShopId:self.shopModel.id];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
//配置item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (DRObjectIsEmpty(self.shopModel)) {
            return CGSizeMake(screenWidth, 202 + 16 + 9);
        }
 
        CGFloat tagH = 0;
        if (!DRArrayIsEmpty(self.shopModel.tags) && _shopModel.storeName.length > 4) {
            tagH = 24;
        }
        NSString * detailStr = self.shopModel.description_;
        NSMutableAttributedString * detailAttStr = [[NSMutableAttributedString alloc] initWithString:detailStr];
        [detailAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(24)] range:NSMakeRange(0, detailStr.length)];
        [detailAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(0, detailStr.length)];
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 2;//行间距
        [detailAttStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, detailStr.length)];
        //frmae
        CGSize detailLabelSize = [detailAttStr boundingRectWithSize:CGSizeMake(screenWidth - 2 * DRMargin, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        return CGSizeMake(screenWidth, 202 + tagH + detailLabelSize.height + 16 + 9);
    }
    CGFloat width = (screenWidth - 5) / 2;
    return CGSizeMake(width, width + 75);
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return self.goodDataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        DRShopHeaderCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ShopHeaderCellId forIndexPath:indexPath];
        cell.shopModel = self.shopModel;
        [cell.attentionButton addTarget:self action:@selector(attentionButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.chatButton addTarget:self action:@selector(chatButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
        if (self.isAttention) {
            [cell.attentionButton setTitle:@"已关注" forState:UIControlStateNormal];
        }else
        {
            [cell.attentionButton setTitle:@"+关注" forState:UIControlStateNormal];
        }
        return cell;
    }else
    {
        DRRecommendGoodCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ShopGoodCellId forIndexPath:indexPath];
        cell.model = self.goodDataArray[indexPath.row];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return;
    }
    DRGoodDetailViewController * goodVC = [[DRGoodDetailViewController alloc] init];
    DRGoodModel * model = self.goodDataArray[indexPath.row];
    goodVC.goodId = model.id;
    [self.navigationController pushViewController:goodVC animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView) {
        CGFloat offsetY = scrollView.contentOffset.y;
        CGFloat scale = offsetY / 100.0;
        scale = scale > 1 ? 1 : scale;
        //设置bar背景色
        self.barView.backgroundColor = [UIColor colorWithWhite:1 alpha:scale];
        self.barShopLogoImageView.alpha = scale;
        self.barShopNameLabel.alpha = scale;
        if (offsetY <= 100) {
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            [self.backButon setImage:[UIImage imageNamed:@"white_back_bar"] forState:UIControlStateNormal];
            [self.moreButon setImage:[UIImage imageNamed:@"white_more_bar"] forState:UIControlStateNormal];
        }else
        {
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
            [self.backButon setImage:[UIImage imageNamed:@"black_back_bar"] forState:UIControlStateNormal];
            [self.moreButon setImage:[UIImage imageNamed:@"black_more_bar"] forState:UIControlStateNormal];
        }
    }
}
- (void)attentionButtonDidClick:(UIButton *)button
{
    if(!UserId || !Token)
    {
        DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
        [self presentViewController:loginVC animated:YES completion:nil];
        return;
    }
    [self attentionButonDidClick];
}
- (void)chatButtonDidClick
{
    if((!UserId || !Token))
    {
        DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
        [self presentViewController:loginVC animated:YES completion:nil];
        return;
    }
    DRChatViewController *chatVC = [[DRChatViewController alloc] initWithConversationChatter:self.shopId conversationType:EMConversationTypeChat];
    chatVC.title = self.shopModel.storeName;
    NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@", baseUrl, self.shopModel.storeImg];
    [DRIMTool saveUserProfileWithUsername:self.shopModel.id forNickName:self.shopModel.storeName avatarURLPath:imageUrlStr];
    [self.navigationController pushViewController:chatVC animated:YES];
}

#pragma mark - 初始化
- (NSMutableArray *)goodDataArray
{
    if (!_goodDataArray) {
        _goodDataArray = [NSMutableArray array];
    }
    return _goodDataArray;
}

@end
