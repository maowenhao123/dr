//
//  DRPraiseListView.m
//  dr
//
//  Created by 毛文豪 on 2018/12/18.
//  Copyright © 2018 JG. All rights reserved.
//

#import "DRPraiseListView.h"
#import "DRPraiseListViewController.h"
#import "DRShowDetailViewController.h"
#import "DRPraiseListCollectionViewCell.h"
#import "DRDateTool.h"

NSString * const PraiseListCollectionViewCellId = @"PraiseListCollectionViewCellId";

@interface DRPraiseListView ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) UILabel * listTitleLabel;
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger timeInterval;

@end

@implementation DRPraiseListView

- (instancetype)initWithFrame:(CGRect)frame type:(int)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.type = type;
        [self setupChildViews];
        [self getPraiseData];
    }
    return self;
}

#pragma mark - 请求数据
- (void)getPraiseData
{
    /*
     type=1 按时间查询
     type=2 点赞数最多
     type=3 本周点赞排名
     type=4 本月点赞排名*/
    NSDictionary *bodyDic = @{
                              @"pageIndex":@(1),
                              @"pageSize":@(4),
                              @"type":@(self.type + 3),
                              };
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"A03",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        if (SUCCESS) {
            self.praiseList = [DRPraiseModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            [self.collectionView reloadData];
            long long systemTime = [json[@"systemTime"] longLongValue];
            long long endTime = [json[@"endTime"] longLongValue];
            self.timeInterval = (endTime - systemTime) / 1000;
            [self addSetDeadlineTimer];
        }else
        {
            if (self.type == 1) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowPraiseActivityEnd" object:nil];
            }
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

#pragma mark - 布局视图
- (void)setupChildViews
{
    //倒计时
    UILabel * listTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, screenWidth - 15 - 70, 20)];
    self.listTitleLabel = listTitleLabel;
    if (self.type == 0) {
        listTitleLabel.text = @"人气周榜";
    }else
    {
        listTitleLabel.text = @"人气月榜";
    }
    listTitleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    listTitleLabel.textColor = DRBlackTextColor;
    [self addSubview:listTitleLabel];
    
    //全部
    CGFloat listButtonW = 50;
    CGFloat listButtonH = 20;
    UIButton * listButton = [UIButton buttonWithType:UIButtonTypeCustom];
    listButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    [listButton setTitle:@"全部>" forState:UIControlStateNormal];
    [listButton setTitleColor:DRGrayTextColor forState:UIControlStateNormal];
    listButton.frame = CGRectMake(screenWidth - (listButtonW + 10), 10, listButtonW, listButtonH);
    [listButton addTarget:self action:@selector(listButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:listButton];
    
    //列表
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.minimumInteritemSpacing = 0.0;//列间距
    layout.minimumLineSpacing = 0.0;//行间距
    
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 40, screenWidth, 105) collectionViewLayout:layout];
    self.collectionView = collectionView;
    collectionView.scrollEnabled = NO;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.pagingEnabled = YES;
    
    //注册
    [collectionView registerClass:[DRPraiseListCollectionViewCell class] forCellWithReuseIdentifier:PraiseListCollectionViewCellId];
    [self addSubview:collectionView];
}

- (void)listButtonDidClick
{
    DRPraiseListViewController * praiseListVC = [[DRPraiseListViewController alloc] init];
    praiseListVC.index = 0;
    praiseListVC.realTimeIndex = self.type;
    [self.viewController.navigationController pushViewController:praiseListVC animated:YES];
}

#pragma mark - UICollectionViewDelegateFlowLayout
//配置item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(screenWidth / 4, 105);
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.praiseList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DRPraiseListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PraiseListCollectionViewCellId forIndexPath:indexPath];
    cell.praiseModel = self.praiseList[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DRPraiseModel *praiseModel = self.praiseList[indexPath.row];
    
    DRShowDetailViewController * showDetailVC = [[DRShowDetailViewController alloc] init];
    showDetailVC.showId = praiseModel.id;
    [self.viewController.navigationController pushViewController:showDetailVC animated:YES];
}

#pragma mark - 倒计时
- (void)addSetDeadlineTimer
{
    if(self.timer == nil)//空才创建
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(setTimeLabelText) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        [self.timer fire];
    }
}

- (void)setTimeLabelText
{
    NSString * titleStr = @"";
    if (self.type == 0) {
        titleStr = @"人气周榜 ";
    }else
    {
        titleStr = @"人气月榜 ";
    }
    NSString * timeStr = @"";
    if (self.timeInterval > 0) {
        NSDateComponents *dateComponents = [DRDateTool getDateComponentsBySeconds:self.timeInterval];
        if(dateComponents.day > 0)//相差超过一天，就显示天、小时
        {
            timeStr = [NSString stringWithFormat:@"距结束%02ld天%02ld时%02ld分%02ld秒", (long)dateComponents.day, (long)dateComponents.hour, (long)dateComponents.minute, (long)dateComponents.second];
        }else if (dateComponents.hour > 0)//相差超过一小时，就显示小时、分
        {
            timeStr = [NSString stringWithFormat:@"距结束%02ld时%02ld分%02ld秒", (long)dateComponents.hour, (long)dateComponents.minute, (long)dateComponents.second];
        }else if(dateComponents.minute > 0 || dateComponents.second > 0)//相差超过一分钟或者一秒钟，就显示分、秒
        {
            timeStr = [NSString stringWithFormat:@"距结束%02ld分%02ld秒", (long)dateComponents.minute, (long)dateComponents.second];
        }
        self.timeInterval--;
    }else
    {
        if (self.type == 0) {
            timeStr = @"本周活动已结束";
        }else
        {
            timeStr = @"本月活动已结束";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowPraiseActivityEnd" object:nil];
        }
        [self removeSetDeadlineTimer];
    }
    NSMutableAttributedString * listTitleAttStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@", titleStr, timeStr]];
    [listTitleAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(30)] range:NSMakeRange(0, listTitleAttStr.length)];
    [listTitleAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(26)] range:[listTitleAttStr.string rangeOfString:@"距结束"]];
    [listTitleAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(26)] range:[listTitleAttStr.string rangeOfString:@"天"]];
    [listTitleAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(26)] range:[listTitleAttStr.string rangeOfString:@"时"]];
    [listTitleAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(26)] range:[listTitleAttStr.string rangeOfString:@"分"]];
    [listTitleAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(26)] range:[listTitleAttStr.string rangeOfString:@"秒"]];
    [listTitleAttStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:[listTitleAttStr.string rangeOfString:titleStr]];
    [listTitleAttStr addAttribute:NSForegroundColorAttributeName value:DRDefaultColor range:[listTitleAttStr.string rangeOfString:timeStr]];
    self.listTitleLabel.attributedText = listTitleAttStr;
}

#pragma  mark - 销毁对象
- (void)dealloc
{
    [self removeSetDeadlineTimer];
}

- (void)removeSetDeadlineTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

@end
