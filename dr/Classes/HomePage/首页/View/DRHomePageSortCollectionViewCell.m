//
//  DRHomePageSortCollectionViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/10/9.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRHomePageSortCollectionViewCell.h"
#import "DRLoadHtmlFileViewController.h"
#import "DRGrouponViewController.h"
#import "DRGoodDetailViewController.h"
#import "DRShowViewController.h"
#import "DRSetupShopViewController.h"
#import "DRMyShopViewController.h"
#import "DRMaintainViewController.h"
#import "DRGoodListViewController.h"
#import "DRLoginViewController.h"
#import "DRHomePageSortItemCollectionViewCell.h"

NSString * const HomePageSortItemCellId = @"HomePageSortItemCellId";

@interface DRHomePageSortCollectionViewCell ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) UICollectionView *collectionView;

@end

@implementation DRHomePageSortCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupChildViews];
    }
    return self;
}

- (void)setData
{
    self.collectionView.height = self.height;
    [self.collectionView reloadData];
}

- (void)setupChildViews
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.minimumInteritemSpacing = 0.0;//列间距
    layout.minimumLineSpacing = 0.0;//行间距
    
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
    self.collectionView = collectionView;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.scrollEnabled = NO;
    
    //注册
    [collectionView registerClass:[DRHomePageSortItemCollectionViewCell class] forCellWithReuseIdentifier:HomePageSortItemCellId];
    [self addSubview:collectionView];
}
#pragma mark - UICollectionViewDelegateFlowLayout
//配置item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(screenWidth / 5, 80);
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
    DRHomePageSortItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:HomePageSortItemCellId forIndexPath:indexPath];
    DRHomePageSortStatus * status = self.dataArray[indexPath.row];
    cell.status = status;
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DRHomePageSortStatus * sortStatus = self.dataArray[indexPath.row];
    
    if ([sortStatus.type intValue] == 1) {//webview
        DRLoadHtmlFileViewController * htmlVC = [[DRLoadHtmlFileViewController alloc] initWithWeb:[NSString stringWithFormat:@"%@",sortStatus.data]];
        [self.viewController.navigationController pushViewController:htmlVC animated:YES];
    }else if ([sortStatus.type intValue] == 2)//跳转到某商品
    {
        DRGoodDetailViewController * goodVC = [[DRGoodDetailViewController alloc] init];
        goodVC.goodId = sortStatus.data;
        [self.viewController.navigationController pushViewController:goodVC animated:YES];
    }else if ([sortStatus.type intValue] == 3)//跳转到一个activity，根据data值预先定义跳转到哪个页面，
    {
        if ([sortStatus.data intValue] == 1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"gotoGroupon" object:nil];
        }else if ([sortStatus.data intValue] == 10)
        {
            if(!UserId || !Token)
            {
                DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
                [self.viewController presentViewController:loginVC animated:YES completion:nil];
                return;
            }
            DRShowViewController * showVC = [[DRShowViewController alloc] init];
            [self.viewController.navigationController pushViewController:showVC animated:YES];
        }else if ([sortStatus.data intValue] == 20)
        {
            DRMaintainViewController * maintainVC = [[DRMaintainViewController alloc] init];
            [self.viewController.navigationController pushViewController:maintainVC animated:YES];
        }else if ([sortStatus.data intValue] == 30)
        {
            if(!UserId || !Token)
            {
                DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
                [self.viewController presentViewController:loginVC animated:YES completion:nil];
                return;
            }
            DRUser *user = [DRUserDefaultTool user];
            if ([user.type intValue] == 0) {//未开店
                DRSetupShopViewController * setupShopVC = [[DRSetupShopViewController alloc] init];
                [self.viewController.navigationController pushViewController:setupShopVC animated:YES];
            }else
            {
                DRMyShopViewController * myShopVC = [[DRMyShopViewController alloc] init];
                [self.viewController.navigationController pushViewController:myShopVC animated:YES];
            }
        }else if ([sortStatus.data intValue] == 40)
        {
            DRGrouponViewController * myShopVC = [[DRGrouponViewController alloc] init];
            [self.viewController.navigationController pushViewController:myShopVC animated:YES];
        }
    }else if ([sortStatus.type intValue] == 4)//跳转到一个售卖类型
    {
        DRGoodListViewController * goodListVC = [[DRGoodListViewController alloc] init];
        if ([sortStatus.data intValue] == 1) {//一物一拍
            goodListVC.sellType = @"1";
        }else if ([sortStatus.data intValue] == 2) {//批发
            goodListVC.isGroup = @"0";
            goodListVC.sellType = @"2";
        }else if ([sortStatus.data intValue] == 3)//团购
        {
            goodListVC.isGroup = @"1";
        }
        [self.viewController.navigationController pushViewController:goodListVC animated:YES];
    }else if ([sortStatus.type intValue] == 5)//跳转到一个商品分类列表
    {
        DRGoodListViewController * goodListVC = [[DRGoodListViewController alloc] init];
        goodListVC.categoryId = [NSString stringWithFormat:@"%@",sortStatus.data];
        [self.viewController.navigationController pushViewController:goodListVC animated:YES];
    }
}
#pragma mark - 初始化
- (NSArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSArray array];
    }
    return _dataArray;
}

@end
