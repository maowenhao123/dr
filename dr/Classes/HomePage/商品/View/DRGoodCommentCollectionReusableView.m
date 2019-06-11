//
//  DRGoodCommentCollectionReusableView.m
//  dr
//
//  Created by 毛文豪 on 2018/2/28.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRGoodCommentCollectionReusableView.h"
#import "DRGoodCommentListViewController.h"

@interface DRGoodCommentCollectionReusableView ()

@property (nonatomic, weak) UILabel * commentNumberLabel;

@end

@implementation DRGoodCommentCollectionReusableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 9)];
        lineView.backgroundColor = DRBackgroundColor;
        [self addSubview:lineView];
        
        UILabel * commentNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 9, screenWidth - 2 * DRMargin, 35)];
        self.commentNumberLabel = commentNumberLabel;
        commentNumberLabel.textColor = DRBlackTextColor;
        commentNumberLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
        [self addSubview:commentNumberLabel];
        
        UIButton * allCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [allCommentButton setTitle:@"查看全部>" forState:UIControlStateNormal];
        [allCommentButton setTitleColor:DRGrayTextColor forState:UIControlStateNormal];
        allCommentButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(22)];
        CGSize allCommentButtonSize = [allCommentButton.currentTitle sizeWithLabelFont:allCommentButton.titleLabel.font];
        allCommentButton.frame = CGRectMake(screenWidth - DRMargin - allCommentButtonSize.width, 9, allCommentButtonSize.width, 35);
        [allCommentButton addTarget:self action:@selector(allCommentButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:allCommentButton];
        
        
    }
    return self;
}

- (void)setGoodModel:(DRGoodModel *)goodModel
{
    _goodModel = goodModel;
    
    self.commentNumberLabel.text = [NSString stringWithFormat:@"评论 %@", [DRTool getNumber:_goodModel.commentCount]];
}

- (void)allCommentButtonDidClick
{
    DRGoodCommentListViewController * goodCommentListVC = [[DRGoodCommentListViewController alloc] init];
    goodCommentListVC.goodModel = self.goodModel;
    [self.viewController.navigationController pushViewController:goodCommentListVC animated:YES];
}

@end
