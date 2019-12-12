//
//  DRHomePageBannerCollectionViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/10/9.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRHomePageBannerCollectionViewCell.h"
#import "DRLoadHtmlFileViewController.h"
#import "DRGoodDetailViewController.h"
#import "DRShowViewController.h"
#import "DRSetupShopViewController.h"
#import "DRMyShopViewController.h"
#import "DRMaintainViewController.h"
#import "DRGoodListViewController.h"
#import "DRLoginViewController.h"
#import "SDCycleScrollView.h"
#import "DRHomePageBannerModel.h"

@interface DRHomePageBannerCollectionViewCell ()<SDCycleScrollViewDelegate>

@property (nonatomic, weak) SDCycleScrollView * cycleScrollView;
@property (nonatomic, strong) NSMutableArray * dataArray;

@end

@implementation DRHomePageBannerCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self getData];
        [self setupChildViews];
    }
    return self;
}
- (void)getData
{
    NSDictionary *bodyDic = @{
                              };
    
    NSDictionary *headDic = @{
                              @"cmd":@"P02",
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            self.dataArray = [DRHomePageBannerModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            NSMutableArray *imageURLStringsGroups = [NSMutableArray array];
            for (DRHomePageBannerModel * model in self.dataArray) {
                [imageURLStringsGroups addObject:[NSString stringWithFormat:@"%@%@",baseUrl,model.image]];
            }
            self.cycleScrollView.imageURLStringsGroup = imageURLStringsGroups;
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
    // 设置图片
    UIImage * placeholderImage = [UIImage imageNamed:@"banner_placeholder"];
    //轮播图
    SDCycleScrollView * cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:self.bounds delegate:self placeholderImage:placeholderImage];
    self.cycleScrollView = cycleScrollView;
    cycleScrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
    cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
    cycleScrollView.currentPageDotColor = [UIColor whiteColor]; // 自定义分页控件小圆标颜色
    cycleScrollView.pageDotColor = [UIColor colorWithWhite:1 alpha:0.44];
    [self addSubview:cycleScrollView];
}
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    DRHomePageBannerModel *model = self.dataArray[index];
    if ([model.type intValue] == 1) {//webview
        if ([model.data rangeOfString:@"jiaoshui"].location != NSNotFound) {
            if(!UserId || !Token)
            {
                DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
                loginVC.modalPresentationStyle = UIModalPresentationFullScreen;
                [self.viewController presentViewController:loginVC animated:YES completion:nil];
                return;
            }
        }
        DRLoadHtmlFileViewController * htmlVC = [[DRLoadHtmlFileViewController alloc] initWithWeb:[NSString stringWithFormat:@"%@",model.data]];
        [self.viewController.navigationController pushViewController:htmlVC animated:YES];
    }else if ([model.type intValue] == 2)//跳转到某商品
    {
        DRGoodDetailViewController * goodVC = [[DRGoodDetailViewController alloc] init];
        goodVC.goodId = model.data;
        [self.viewController.navigationController pushViewController:goodVC animated:YES];
    }else if ([model.type intValue] == 3)//跳转到一个activity，根据data值预先定义跳转到哪个页面，
    {
        if ([model.data intValue] == 1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"gotoGroupon" object:nil];
        }else if ([model.data intValue] == 10)
        {
            if(!UserId || !Token)
            {
                DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
                [self.viewController presentViewController:loginVC animated:YES completion:nil];
                return;
            }
            DRShowViewController * showVC = [[DRShowViewController alloc] init];
            [self.viewController.navigationController pushViewController:showVC animated:YES];
        }else if ([model.data intValue] == 20)
        {
            DRMaintainViewController * maintainVC = [[DRMaintainViewController alloc] init];
            [self.viewController.navigationController pushViewController:maintainVC animated:YES];
        }else if ([model.data intValue] == 30)
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
        }
    }else if ([model.type intValue] == 4)//跳转到一个售卖类型
    {
        DRGoodListViewController * goodListVC = [[DRGoodListViewController alloc] init];
        goodListVC.subjectId = [NSString stringWithFormat:@"%@",model.data];
        [self.viewController.navigationController pushViewController:goodListVC animated:YES];
    }else if ([model.type intValue] == 5)//跳转到一个商品分类列表
    {
        DRGoodListViewController * goodListVC = [[DRGoodListViewController alloc] init];
        goodListVC.categoryId = [NSString stringWithFormat:@"%@",model.data];
        [self.viewController.navigationController pushViewController:goodListVC animated:YES];
    }
}
#pragma mark - 初始化
- (NSArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
