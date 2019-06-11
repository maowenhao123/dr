//
//  DRPraiseListHeaderFooterView.m
//  dr
//
//  Created by 毛文豪 on 2019/1/7.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRPraiseListHeaderFooterView.h"

@interface DRPraiseListHeaderFooterView ()

@property (nonatomic, weak) UILabel * weekLabel;

@end

@implementation DRPraiseListHeaderFooterView

+ (DRPraiseListHeaderFooterView *)headerViewWithTableView:(UITableView *)talbeView
{
    static NSString *ID = @"PraiseListHeaderFooterViewId";
    DRPraiseListHeaderFooterView *headerView = [talbeView dequeueReusableHeaderFooterViewWithIdentifier:ID];
    if(headerView == nil)
    {
        headerView = [[DRPraiseListHeaderFooterView alloc] initWithReuseIdentifier:ID];
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
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    //点
    CGFloat dotViewWH = 12;
    UIView * dotView = [[UIView alloc] initWithFrame:CGRectMake(10, (40 - dotViewWH) / 2, dotViewWH, dotViewWH)];
    dotView.backgroundColor = DRViceColor;
    dotView.layer.masksToBounds = YES;
    dotView.layer.cornerRadius = dotViewWH / 2;
    [self.contentView addSubview:dotView];
    
    //第几周
    UILabel * weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(dotView.frame) + 7, 0, screenWidth - DRMargin - CGRectGetMaxX(dotView.frame) - 7, 40)];
    self.weekLabel = weekLabel;
    weekLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    weekLabel.textColor = DRBlackTextColor;
    [self.contentView addSubview:weekLabel];
    
    //分割线
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 39, screenWidth, 1)];
    lineView.backgroundColor = DRWhiteLineColor;
    [self.contentView addSubview:lineView];
}

- (void)setPraiseSectionModel:(DRPraiseSectionModel *)praiseSectionModel
{
    _praiseSectionModel = praiseSectionModel;
    
    self.weekLabel.text = [NSString stringWithFormat:@"%@获奖名单", _praiseSectionModel.cycle];
}

@end
