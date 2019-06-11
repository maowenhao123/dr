//
//  DRShowDetailHeaderView.m
//  dr
//
//  Created by 毛文豪 on 2018/3/6.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRShowDetailHeaderView.h"

@interface DRShowDetailHeaderView ()

@property (nonatomic, weak) UILabel * commentNumberLabel;

@end

@implementation DRShowDetailHeaderView

+ (DRShowDetailHeaderView *)headerFooterViewWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"ShowDetailHeaderViewId";
    DRShowDetailHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:ID];
    if(headerView == nil)
    {
        headerView = [[DRShowDetailHeaderView alloc] initWithReuseIdentifier:ID];
    }
    return headerView;
}
//初始化子控件
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithReuseIdentifier:reuseIdentifier])
    {
        [self setupChildViews];
    }
    return self;
}

- (void)setupChildViews
{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 35)];
    headerView.backgroundColor = [UIColor whiteColor];
    [self addSubview:headerView];
    
    UILabel * commentNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 0, headerView.width - 2 * DRMargin, headerView.height)];
    self.commentNumberLabel = commentNumberLabel;
    commentNumberLabel.textColor = DRBlackTextColor;
    commentNumberLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [headerView addSubview:commentNumberLabel];
    
    //分割线
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, headerView.width, 1)];
    line1.backgroundColor = DRWhiteLineColor;
    [headerView addSubview:line1];
    
    UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(0, headerView.height - 1, headerView.width, 1)];
    line2.backgroundColor = DRWhiteLineColor;
    [headerView addSubview:line2];
}

- (void)setModel:(DRShowModel *)model
{
    _model = model;
    
    self.commentNumberLabel.text = [NSString stringWithFormat:@"评论 %@", _model.commentCount];
}

@end
