//
//  DRHomePageNewCollectionViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/10/9.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRHomePageNewCollectionViewCell.h"
#import "DRGoodDetailViewController.h"
#import "DRHomePageNewItemCollectionViewCell.h"

NSString * const NewItemCellId = @"NewItemCellId";

@interface DRHomePageNewCollectionViewCell ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic, weak) UICollectionView *collectionView;

@end

@implementation DRHomePageNewCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self getData];
        [self setupChildViews];
    }
    return self;
}
- (void)getData
{
    NSDictionary *bodyDic = @{
                              @"pageIndex":@(1),
                              @"pageSize":@(10),
                              @"type":@"1"
                              };
    NSDictionary *headDic = @{
                              @"cmd":@"B07",
                              };
    
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            self.dataArray = [DRGoodModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            [self.collectionView reloadData];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
- (void)setupChildViews
{
    //商品列表
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
    layout.minimumInteritemSpacing = 0.0;//列间距
    layout.minimumLineSpacing = 10.0;//行间距
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;//水平方向滚动
    
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 175) collectionViewLayout:layout];
    self.collectionView = collectionView;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.showsHorizontalScrollIndicator = NO;
    //注册
    [collectionView registerClass:[DRHomePageNewItemCollectionViewCell class] forCellWithReuseIdentifier:NewItemCellId];
    [self addSubview:collectionView];
}
#pragma mark - UICollectionViewDelegateFlowLayout
//配置item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(130, 175);
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DRHomePageNewItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NewItemCellId forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DRGoodDetailViewController * goodVC = [[DRGoodDetailViewController alloc] init];
    DRGoodModel * model = self.dataArray[indexPath.row];
    goodVC.goodId = model.id;
    [self.viewController.navigationController pushViewController:goodVC animated:YES];
}
#pragma mark - 初始化
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
@end
