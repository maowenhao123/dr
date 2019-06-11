//
//  DRBillingHeaderView.m
//  dr
//
//  Created by 毛文豪 on 2018/6/4.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRBillingHeaderView.h"

@interface DRBillingHeaderView ()

@property (nonatomic, weak) UILabel * titleLabel;

@end

@implementation DRBillingHeaderView

+ (DRBillingHeaderView *)headerFooterViewWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"DRBillingHeaderViewId";
    DRBillingHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:ID];
    if(headerView == nil)
    {
        headerView = [[DRBillingHeaderView alloc] initWithReuseIdentifier:ID];
    }
    return headerView;
}
//初始化子控件
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithReuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = DRBackgroundColor;
        [self setupChildViews];
    }
    return self;
}

- (void)setupChildViews
{
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, screenWidth - 20, 0)];
    self.titleLabel = titleLabel;
    titleLabel.textColor = DRBlackTextColor;
    titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    titleLabel.numberOfLines = 0;
    [self addSubview:titleLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleLabel.height = self.height;
}
- (void)setSectionModel:(DRMoneyDetailSectionModel *)sectionModel
{
    _sectionModel = sectionModel;
 
    if (!DRStringIsEmpty(_sectionModel.income) && !DRStringIsEmpty(_sectionModel.expenditure)) {
        NSString * string = [NSString stringWithFormat:@"%@\n收入：¥%@  提款：¥%@", _sectionModel.month, [DRTool formatFloat:[_sectionModel.income doubleValue] / 100], [DRTool formatFloat:fabs([_sectionModel.expenditure doubleValue]) / 100]];
        NSMutableAttributedString * attStr = [[NSMutableAttributedString alloc]initWithString:string];
        [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(30)] range:NSMakeRange(0, _sectionModel.month.length)];
        [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(24)] range:NSMakeRange(_sectionModel.month.length, string.length - _sectionModel.month.length)];
        [attStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, _sectionModel.month.length)];
        [attStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(_sectionModel.month.length, string.length - _sectionModel.month.length)];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:5];
        [attStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attStr.length)];
        self.titleLabel.attributedText = attStr;
    }else
    {
        self.titleLabel.text = _sectionModel.month;
    }
}

@end
