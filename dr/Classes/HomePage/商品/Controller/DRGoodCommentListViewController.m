//
//  DRGoodCommentListViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/6/22.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRGoodCommentListViewController.h"
#import "DRGoodCommentTableViewCell.h"
#import "UITableView+DRNoData.h"

@interface DRGoodCommentListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, weak) MJRefreshGifHeader *headerView;
@property (nonatomic,weak) MJRefreshBackGifFooter *footerView;
@property (nonatomic, assign) int pageIndex;//页数

@end

@implementation DRGoodCommentListViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"商品评论";
    self.pageIndex = 1;
    [self getData];
    [self setupChilds];
}

#pragma mark - 请求数据
- (void)getData
{
    if (!self.goodModel.id) {
        return;
    }
    NSDictionary *bodyDic = @{
                              @"pageIndex":@(self.pageIndex),
                              @"pageSize":DRPageSize,
                              @"goodsId":self.goodModel.id,
                              };
    
    NSDictionary *headDic = @{
                              @"cmd":@"B21",
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            NSArray * dataArray = [DRGoodCommentModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            [self.dataArray addObjectsFromArray:dataArray];
            [self.tableView reloadData];//刷新数据
            if ([self.footerView isRefreshing]) {
                if (dataArray.count == 0) {
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

#pragma mark - 布局视图
- (void)setupChilds
{
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH)];
    self.tableView = tableView;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundColor = DRBackgroundColor;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    [self.view addSubview:tableView];
    
    //contentView
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 9 + 50)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    //商品图片
    UIImageView * goodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, 5, 40, 40)];
    goodImageView.contentMode = UIViewContentModeScaleAspectFill;
    goodImageView.layer.masksToBounds = YES;
    NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@", baseUrl, self.goodModel.spreadPics];
    [goodImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    [headerView addSubview:goodImageView];
    
    //商品名称
    UILabel * goodNameLabel = [[UILabel alloc] init];
    goodNameLabel.text = self.goodModel.name;
    goodNameLabel.textColor = DRBlackTextColor;
    goodNameLabel.numberOfLines = 0;
    goodNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [headerView addSubview:goodNameLabel];
    
    CGSize goodNameLabelSize = [goodNameLabel.text sizeWithLabelFont:goodNameLabel.font];
    CGFloat goodNameLabelX = CGRectGetMaxX(goodImageView.frame) + 10;
    goodNameLabel.frame = CGRectMake(goodNameLabelX, 0, goodNameLabelSize.width, 50);
    
    //分割线
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 50, screenWidth, 9)];
    lineView.backgroundColor = DRBackgroundColor;
    [headerView addSubview:lineView];
    
    tableView.tableHeaderView = headerView;
    
    //初始化头部刷新控件
    MJRefreshGifHeader *headerRefreshView = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshViewBeginRefreshing)];
    [DRTool setRefreshHeaderData:headerRefreshView];
    self.headerView = headerRefreshView;
    tableView.mj_header = headerRefreshView;
    
    //初始化底部刷新控件
    MJRefreshBackGifFooter *footerView = [MJRefreshBackGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshViewBeginRefreshing)];
    [DRTool setRefreshFooterData:footerView];
    self.footerView = footerView;
    tableView.mj_footer = footerView;

}
- (void)headerRefreshViewBeginRefreshing
{
    self.pageIndex = 1;
    [self.dataArray removeAllObjects];
    [self getData];
}
- (void)footerRefreshViewBeginRefreshing
{
    self.pageIndex++;
    [self getData];
}
#pragma mark - cell delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [tableView showNoDataWithTitle:@"" description:@"该商品没有评论" rowCount:self.dataArray.count];
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRGoodCommentTableViewCell *cell = [DRGoodCommentTableViewCell cellWithTableView:tableView];
    DRGoodCommentModel * model = self.dataArray[indexPath.row];
    model.floor = indexPath.row + 1;
    cell.model = model;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRGoodCommentModel * model = self.dataArray[indexPath.row];
    return model.cellH;
}
#pragma mark - 初始化
- (NSMutableArray *)dataArray
{
    if(_dataArray == nil)
    {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


@end
