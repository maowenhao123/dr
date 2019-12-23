//
//  DRIconTextTableViewCell.m
//  dr
//
//  Created by apple on 17/1/16.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRIconTextTableViewCell.h"

@interface DRIconTextTableViewCell ()

@end

@implementation DRIconTextTableViewCell

+ (DRIconTextTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"IconTextTableViewCell";
    DRIconTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRIconTextTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.accessoryType = UITableViewCellAccessoryNone;
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
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    self.line = line;
    line.backgroundColor = DRWhiteLineColor;
    [self addSubview:line];
    
    //icon
    UIImageView * iconImageView = [[UIImageView alloc]init];
    self.iconImageView = iconImageView;
    [self addSubview:iconImageView];
    
    //名字
    UILabel * functionNameLabel = [[UILabel alloc] init];
    self.functionNameLabel = functionNameLabel;
    functionNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    functionNameLabel.textColor = DRBlackTextColor;
    [self addSubview:functionNameLabel];
    
    //Detail
    UILabel * functionDetailLabel = [[UILabel alloc] init];
    self.functionDetailLabel = functionDetailLabel;
    functionDetailLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    functionDetailLabel.textColor = DRGrayTextColor;
    [self addSubview:functionDetailLabel];
    
    //角标
    UIImageView * accessoryImageView = [[UIImageView alloc] init];
    self.accessoryImageView = accessoryImageView;
    accessoryImageView.image = [UIImage imageNamed:@"big_black_accessory_icon"];
    [self addSubview:accessoryImageView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat iconImageViewWH = self.height * 0.6;
    CGFloat iconImageViewY = (self.height - iconImageViewWH) / 2;
    self.iconImageView.frame = CGRectMake(DRMargin, iconImageViewY, iconImageViewWH, iconImageViewWH);
    
    CGFloat accessoryImageViewWH = 10;
    CGFloat accessoryImageViewY = (self.height - accessoryImageViewWH) / 2;
    self.accessoryImageView.frame = CGRectMake(self.width - DRMargin - accessoryImageViewWH, accessoryImageViewY, accessoryImageViewWH, accessoryImageViewWH);
    
    CGSize functionNameLabelSize = [self.functionNameLabel.text sizeWithLabelFont:self.functionNameLabel.font];
    self.functionNameLabel.frame = CGRectMake(CGRectGetMaxX(self.iconImageView.frame) + 13, 0, functionNameLabelSize.width, self.height);
    
    CGSize functionDetailLabelSize = [self.functionDetailLabel.text sizeWithFont:self.functionDetailLabel.font maxSize:CGSizeMake(self.width - 2 * DRMargin - CGRectGetMaxX(self.functionNameLabel.frame), DRCellH)];
    self.functionDetailLabel.frame = CGRectMake(self.width - DRMargin - 5 - DRMargin - functionDetailLabelSize.width, CGRectGetMaxY(self.line.frame), functionDetailLabelSize.width, self.height);
}
#pragma mark - setter
- (void)setIcon:(NSString *)icon
{
    _icon = icon;
    self.iconImageView.image = [UIImage imageNamed:_icon];
}

- (void)setFunctionName:(NSString *)functionName
{
    _functionName = functionName;
    self.functionNameLabel.text = functionName;
}
- (void)setFunctionDetail:(NSString *)functionDetail
{
    _functionDetail = functionDetail;
    
    self.functionDetailLabel.text = _functionDetail;
}

@end
