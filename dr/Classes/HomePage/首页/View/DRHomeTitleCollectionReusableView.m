//
//  DRHomeTitleCollectionReusableView.m
//  dr
//
//  Created by 毛文豪 on 2018/2/28.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRHomeTitleCollectionReusableView.h"
#import "DRShopListViewController.h"
#import "DRGoodListViewController.h"

@interface DRHomeTitleCollectionReusableView ()

@property (nonatomic, weak) UILabel * titleLabel;
@property (nonatomic,weak) UIButton * allButton;

@end

@implementation DRHomeTitleCollectionReusableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 9)];
        lineView.backgroundColor = DRBackgroundColor;
        [self addSubview:lineView];
        
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 9, screenWidth, 40)];
        self.titleLabel = titleLabel;
        titleLabel.backgroundColor = [UIColor whiteColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:DRGetFontSize(28)];
        titleLabel.textColor = DRBlackTextColor;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        
        UIButton * allButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.allButton = allButton;
        [allButton setTitle:@"全部>" forState:UIControlStateNormal];
        [allButton setTitleColor:DRDefaultColor forState:UIControlStateNormal];
        allButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
        CGSize allButtonSize = [allButton.currentTitle sizeWithLabelFont:allButton.titleLabel.font];
        allButton.frame = CGRectMake(screenWidth - DRMargin - allButtonSize.width, 10, allButtonSize.width, 40);
        [allButton addTarget:self action:@selector(allButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:allButton];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}

- (void)setIndex:(NSInteger)index
{
    _index = index;
    self.allButton.hidden = _index == 2;
}

- (void)allButtonDidClick
{
    if ([self.title isEqualToString:@"—— 精品推荐 ——"]) {
        DRGoodListViewController * goodListVC = [[DRGoodListViewController alloc] init];
        goodListVC.type = @"1";
        [self.viewController.navigationController pushViewController:goodListVC animated:YES];
    }else if ([self.title isEqualToString:@"—— 发现好店 ——"])
    {
        DRShopListViewController * shopListVC = [[DRShopListViewController alloc] init];
        [self.viewController.navigationController pushViewController:shopListVC animated:YES];
    }
}

@end
