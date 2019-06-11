//
//  DRSellerLogisticsTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/6/13.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRSellerLogisticsTableViewCell.h"

@interface DRSellerLogisticsTableViewCell ()

@property (nonatomic,weak) UIView * line1;
@property (nonatomic,weak) UIView * line2;
@property (nonatomic,weak) UIImageView * dotImageView;
@property (nonatomic,weak) UILabel *contentLabel;

@end

@implementation DRSellerLogisticsTableViewCell

+ (DRSellerLogisticsTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"SellerLogisticsTableViewCellId";
    DRSellerLogisticsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRSellerLogisticsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    return  cell;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupChildViews];
    }
    return self;
}
- (void)setupChildViews
{
    //分割线
    CGFloat line1X = 2 * 15 + 10;
    UIView * line1 = [[UIView alloc] initWithFrame:CGRectMake(line1X, 0, screenWidth - line1X, 1)];
    self.line1 = line1;
    line1.backgroundColor = DRWhiteLineColor;
    [self addSubview:line1];

    //分割线
    CGFloat line2X = 15 + 5;
    UIView * line2 = [[UIView alloc] initWithFrame:CGRectMake(line2X, 0, 1, 0)];
    self.line2 = line2;
    line2.backgroundColor = DRWhiteLineColor;
    [self addSubview:line2];
    
    //圆点
    UIImageView * dotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 10, 10)];
    self.dotImageView = dotImageView;
    dotImageView.image = [UIImage imageNamed:@"logistics_dot_gray"];
    [self addSubview:dotImageView];
    
    UILabel * contentLabel = [[UILabel alloc] init];
    self.contentLabel = contentLabel;
    contentLabel.numberOfLines = 0;
    [self addSubview:contentLabel];
    
}
- (void)setLogisticsTraceModel:(DRLogisticsTraceModel *)logisticsTraceModel
{
    _logisticsTraceModel = logisticsTraceModel;
    
    if (_logisticsTraceModel.isFirst) {
        self.line1.hidden = YES;
        self.line2.y = CGRectGetMaxY(self.dotImageView.frame);
        self.line2.height = _logisticsTraceModel.cellH - CGRectGetMaxY(self.dotImageView.frame);
        self.dotImageView.image = [UIImage imageNamed:@"logistics_dot_green"];
        self.dotImageView.width = 16;
        self.dotImageView.height = 16;
        self.dotImageView.centerX = self.line2.centerX;
    }else
    {
        self.line1.hidden = NO;
        self.line2.y = 0;
        self.line2.height = _logisticsTraceModel.cellH;
        self.dotImageView.image = [UIImage imageNamed:@"logistics_dot_gray"];
        self.dotImageView.width = 10;
        self.dotImageView.height = 10;
        self.dotImageView.centerX = self.line2.centerX;
    }
    
    if (_logisticsTraceModel.isLast) {
        self.line2.height = self.dotImageView.y;
    }else
    {
        self.line2.height = _logisticsTraceModel.cellH;
    }
    
    self.contentLabel.attributedText = _logisticsTraceModel.contentAttStr;
    CGFloat contentLabelX = 15 * 2 + 10;
    self.contentLabel.frame = CGRectMake(contentLabelX , 0, screenWidth - contentLabelX - DRMargin, _logisticsTraceModel.cellH);
}

@end
