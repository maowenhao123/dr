//
//  DRSortTitleCollectionReusableView.m
//  dr
//
//  Created by 毛文豪 on 2018/2/28.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRSortTitleCollectionReusableView.h"
#import "DRGoodListViewController.h"

@interface DRSortTitleCollectionReusableView ()

@property (nonatomic, weak) UILabel * titleLabel;
@property (nonatomic,weak) UIButton * allButton;

@end

@implementation DRSortTitleCollectionReusableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 9)];
        lineView.backgroundColor = DRBackgroundColor;
        [self addSubview:lineView];
        
        UILabel * titleLabel = [[UILabel alloc] init];
        self.titleLabel = titleLabel;
        titleLabel.backgroundColor = [UIColor whiteColor];
        titleLabel.textColor = DRBlackTextColor;
        titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
        [self addSubview:titleLabel];
        
        UIButton * allButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.allButton = allButton;
        [allButton setTitle:@"全部>" forState:UIControlStateNormal];
        [allButton setTitleColor:DRDefaultColor forState:UIControlStateNormal];
        allButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
        CGSize allButtonSize = [allButton.currentTitle sizeWithLabelFont:allButton.titleLabel.font];
        allButton.frame = CGRectMake(self.width - 8 - allButtonSize.width, 8, allButtonSize.width, 33);
        [allButton addTarget:self action:@selector(allButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:allButton];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
    CGSize titleLabelSize = [self.titleLabel.text sizeWithLabelFont:self.titleLabel.font];
    self.titleLabel.frame = CGRectMake(8, 9, titleLabelSize.width, 33);
}

- (void)allButtonDidClick
{
    DRGoodListViewController * goodListVC = [[DRGoodListViewController alloc] init];
    goodListVC.categoryId = self.categoryId;
    [self.viewController.navigationController pushViewController:goodListVC animated:YES];
}

@end
