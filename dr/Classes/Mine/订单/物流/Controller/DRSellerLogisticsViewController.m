//
//  DRSellerLogisticsViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/5/25.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRSellerLogisticsViewController.h"
#import "DRLoadHtmlFileViewController.h"
#import "DROrderLogisticsModel.h"
#import "DRLogisticsProgressView.h"
#import "DRSellerLogisticsTableViewCell.h"
#import "DRSellerLogisticsHeaderView.h"

@interface DRSellerLogisticsViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic,strong) UIView * headerView;
@property (nonatomic,weak) DRLogisticsProgressView *progressView;
@property (nonatomic,weak) UIView * contentView;
@property (nonatomic,weak) UILabel * companyLabel;
@property (nonatomic,weak) UILabel * numberLabel;
@property (nonatomic,weak) UIButton * numberButton;
@property (nonatomic,strong) DROrderLogisticsModel *orderLogisticsModel;

@end

@implementation DRSellerLogisticsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"物流查询";
    [self setupChilds];
    [self getData];
}
- (void)getData
{
    NSDictionary *bodyDic_ = @{
                              };
    NSMutableDictionary * bodyDic = [NSMutableDictionary dictionaryWithDictionary:bodyDic_];
    if (!DRStringIsEmpty(self.orderId)) {
        [bodyDic setObject:self.orderId forKey:@"orderId"];
    }
    if (!DRStringIsEmpty(self.groupId)) {
        [bodyDic setObject:self.groupId forKey:@"groupId"];
    }
    
    NSString * cmd;
    if (self.isSeller) {
        cmd = @"S31";
    }else
    {
        cmd = @"S23";
    }
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":cmd,
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            DROrderLogisticsModel *orderLogisticsModel = [DROrderLogisticsModel mj_objectWithKeyValues:json[@"detail"]];
            NSArray *traces = [DRLogisticsTraceModel mj_objectArrayWithKeyValuesArray:json[@"traces"]];
            //倒序
            orderLogisticsModel.traces = [[traces reverseObjectEnumerator] allObjects];
            self.orderLogisticsModel = orderLogisticsModel;
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        DRLog(@"error:%@",error);
    }];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    //tableView
    CGFloat checkLogisticsButtonH = 45;
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH - [DRTool getSafeAreaBottom] - checkLogisticsButtonH) style:UITableViewStyleGrouped];
    self.tableView = tableView;
    tableView.backgroundColor = DRBackgroundColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    [self.view addSubview:tableView];

    //headerView
    self.headerView = [[UIView alloc] init];
    self.headerView.frame = CGRectMake(0, 0, screenWidth, 0);
    self.headerView.backgroundColor = DRBackgroundColor;
    
    //进度条
    DRLogisticsProgressView * progressView = [[DRLogisticsProgressView alloc] init];
    self.progressView = progressView;
    progressView.frame = CGRectMake(0, 0, screenWidth, 127);
    progressView.backgroundColor = [UIColor whiteColor];
    progressView.progressType = 1;
    progressView.hidden = YES;
    [self.headerView addSubview:progressView];
    
    //快递信息
    UIView * contentView = [[UIView alloc] init];
    self.contentView = contentView;
    contentView.frame = CGRectMake(0, 127 + 9, screenWidth, 55 + 9);
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.hidden = YES;
    [self.headerView addSubview:contentView];
    
    //物流公司
    UILabel * companyLabel = [[UILabel alloc] init];
    self.companyLabel = companyLabel;
    [contentView addSubview:companyLabel];
    
    //物流编号
    UILabel * numberLabel = [[UILabel alloc] init];
    self.numberLabel = numberLabel;
    numberLabel.textColor = DRGrayTextColor;
    numberLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [contentView addSubview:numberLabel];
    
    CGFloat copyButtonW = 37;
    CGFloat copyButtonH = 20;
    UIButton * copyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.numberButton = copyButton;
    copyButton.frame = CGRectMake(0, 0, copyButtonW, copyButtonH);
    [copyButton setTitle:@"复制" forState:UIControlStateNormal];
    [copyButton setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
    copyButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(22)];
    [copyButton addTarget:self action:@selector(copyButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    copyButton.layer.masksToBounds = YES;
    copyButton.layer.cornerRadius = 3;
    copyButton.layer.borderColor = DRGrayLineColor.CGColor;
    copyButton.layer.borderWidth = 1;
    [contentView addSubview:copyButton];
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 55, screenWidth, 9)];
    lineView.backgroundColor = DRBackgroundColor;
    [contentView addSubview:lineView];
    
    //查物流
    UIButton * checkLogisticsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    checkLogisticsButton.frame = CGRectMake(0, screenHeight - navBarH - statusBarH - [DRTool getSafeAreaBottom] - checkLogisticsButtonH, screenWidth, checkLogisticsButtonH);
    checkLogisticsButton.backgroundColor = DRDefaultColor;
    [checkLogisticsButton setTitle:@"查物流" forState:UIControlStateNormal];
    [checkLogisticsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    checkLogisticsButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [checkLogisticsButton addTarget:self action:@selector(checkLogisticsButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:checkLogisticsButton];
}
- (void)setOrderLogisticsModel:(DROrderLogisticsModel *)orderLogisticsModel
{
    _orderLogisticsModel = orderLogisticsModel;
    int type = [_orderLogisticsModel.type intValue];
    if (type == 0)
    {
        self.progressView.hidden = YES;
        self.contentView.hidden = NO;
        self.contentView.y = 9;
        self.headerView.height = 9 + 55 + 9;
        self.tableView.tableHeaderView = self.headerView;
    }else
    {
        self.progressView.hidden = NO;
        self.progressView.progressType = type;
        self.contentView.hidden = NO;
        self.contentView.y = 127 + 9;
        self.headerView.height = 127 + 9 + 55 + 9;
        self.tableView.tableHeaderView = self.headerView;
    }
    
    NSString *companyLabelStr = [NSString stringWithFormat:@"物流公司：%@", _orderLogisticsModel.logisticsName];
    NSMutableAttributedString * companyLabelAttStr = [[NSMutableAttributedString alloc] initWithString:companyLabelStr];
    [companyLabelAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(24)] range:NSMakeRange(0, companyLabelStr.length)];
    [companyLabelAttStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, 5)];
    [companyLabelAttStr addAttribute:NSForegroundColorAttributeName value:DRDefaultColor range:NSMakeRange(5, companyLabelStr.length - 5)];
    self.companyLabel.attributedText = companyLabelAttStr;
    
    self.numberLabel.text = [NSString  stringWithFormat:@"运单编号：%@", _orderLogisticsModel.logisticsNum];
    
    CGSize companyLabelSize = [self.companyLabel.attributedText boundingRectWithSize:CGSizeMake(screenWidth - 2 * DRMargin, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    CGSize numberLabelSize = [self.numberLabel.text sizeWithLabelFont:self.numberLabel.font];
    CGFloat padding = 7;
    CGFloat companyLabelY = (55 - companyLabelSize.height - padding - numberLabelSize.height) / 2;
    self.companyLabel.frame = CGRectMake(DRMargin, companyLabelY, companyLabelSize.width, companyLabelSize.height);
    self.numberLabel.frame = CGRectMake(DRMargin, CGRectGetMaxY(self.companyLabel.frame) + padding, numberLabelSize.width, numberLabelSize.height);
    
    self.numberButton.centerY = self.numberLabel.centerY;
    self.numberButton.x = CGRectGetMaxX(self.numberLabel.frame) + 5;
    
    [self.tableView reloadData];
}
- (void)copyButtonDidClick
{
    //复制账号
    UIPasteboard *pab = [UIPasteboard generalPasteboard];
    NSString *string = self.orderLogisticsModel.logisticsNum;
    [pab setString:string];
    [MBProgressHUD showSuccess:@"复制成功"];
}
- (void)checkLogisticsButtonDidClick
{
    DRLoadHtmlFileViewController * htmlVC = [[DRLoadHtmlFileViewController alloc] initWithWeb:@"http://www.kuaidi100.com"];
    [self.navigationController pushViewController:htmlVC animated:YES];
}
#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.orderLogisticsModel.traces.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRSellerLogisticsTableViewCell * cell = [DRSellerLogisticsTableViewCell cellWithTableView:tableView];
    DRLogisticsTraceModel * traceModel = self.orderLogisticsModel.traces[indexPath.row];
    traceModel.isFirst = NO;
    traceModel.isLast = NO;
    if (traceModel == self.orderLogisticsModel.traces.firstObject) {
        traceModel.isFirst = YES;
    }
    if (traceModel == self.orderLogisticsModel.traces.lastObject) {
        traceModel.isLast = YES;
    }
    cell.logisticsTraceModel = traceModel;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    DRSellerLogisticsHeaderView *headerView = [DRSellerLogisticsHeaderView headerFooterViewWithTableView:tableView];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRLogisticsTraceModel * traceModel = self.orderLogisticsModel.traces[indexPath.row];
    return traceModel.cellH;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

@end
