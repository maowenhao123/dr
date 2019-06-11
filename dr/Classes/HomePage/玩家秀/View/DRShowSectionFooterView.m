//
//  DRShowSectionFooterView.m
//  dr
//
//  Created by 毛文豪 on 2018/3/14.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRShowSectionFooterView.h"

@interface DRShowSectionFooterView ()

@property (nonatomic,weak) UILabel * detailLabel;

@end

@implementation DRShowSectionFooterView

+ (DRShowSectionFooterView *)headerFooterViewWithTableView:(UITableView *)talbeView
{
    static NSString *ID = @"ShowFooterViewId";
    DRShowSectionFooterView *headerView = [talbeView dequeueReusableHeaderFooterViewWithIdentifier:ID];
    if(headerView == nil)
    {
        headerView = [[DRShowSectionFooterView alloc] initWithReuseIdentifier:ID];
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
    UILabel * detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 0, screenWidth - 2 * DRMargin, 35)];
    self.detailLabel = detailLabel;
    detailLabel.text = [NSString stringWithFormat:@"查看全部评论（%@）", @"0"];
    detailLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    detailLabel.textColor = DRDefaultColor;
    [self addSubview:detailLabel];
}

- (void)setModel:(DRShowModel *)model
{
    _model = model;
    
    self.detailLabel.text = [NSString stringWithFormat:@"查看全部评论（%@）", _model.commentCount];
}

@end
