//
//  DRGoodGroupCollectionViewCell.m
//  dr
//
//  Created by dahe on 2019/11/20.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRGoodGroupCollectionViewCell.h"
#import "SDCycleScrollView.h"
#import "DRGoodGroupView.h"
#import "DRGoodGroupUserViewController.h"

@interface DRGoodGroupCollectionViewCell ()<SDCycleScrollViewDelegate>

@property (nonatomic, weak) SDCycleScrollView * cycleScrollView;

@end

@implementation DRGoodGroupCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupChildViews];
    }
    return self;
}

- (void)setupChildViews
{
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 9)];
    lineView.backgroundColor = DRBackgroundColor;
    [self addSubview:lineView];
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 9 + 10, screenWidth - DRMargin, 30)];
    titleLabel.text = @"TA们正在拼团";
    titleLabel.font = [UIFont boldSystemFontOfSize:DRGetFontSize(34)];
    titleLabel.textColor = DRBlackTextColor;
    [self addSubview:titleLabel];
    
    UIButton * allButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [allButton setTitle:@"全部>" forState:UIControlStateNormal];
    [allButton setTitleColor:DRDefaultColor forState:UIControlStateNormal];
    allButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    CGSize allButtonSize = [allButton.currentTitle sizeWithLabelFont:allButton.titleLabel.font];
    allButton.frame = CGRectMake(screenWidth - DRMargin - allButtonSize.width, 9 + 10, allButtonSize.width, 30);
    [allButton addTarget:self action:@selector(allButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:allButton];
    
    //滚动
    SDCycleScrollView * cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame), screenWidth, 70) delegate:self placeholderImage:nil];
    self.cycleScrollView = cycleScrollView;
    cycleScrollView.scrollDirection = UICollectionViewScrollDirectionVertical;
    cycleScrollView.localizationImageNamesGroup = @[@"1", @"1", @"1", @"1", @"1", @"1"];
    cycleScrollView.showPageControl = NO;
    cycleScrollView.autoScrollTimeInterval = 5;
    [self addSubview:cycleScrollView];
}

- (void)allButtonDidClick
{
    DRGoodGroupUserViewController * goodGroupUserVC = [[DRGoodGroupUserViewController alloc] init];
    [self.viewController.navigationController pushViewController:goodGroupUserVC animated:YES];
}

- (Class)customCollectionViewCellClassForCycleScrollView:(SDCycleScrollView *)view
{
    return [DRGoodGroupView class];
}

- (void)setupCustomCell:(UICollectionViewCell *)cell forIndex:(NSInteger)index cycleScrollView:(SDCycleScrollView *)view
{
    
}

@end
