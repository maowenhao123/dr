//
//  DRTextTableViewCell.m
//  dr
//
//  Created by apple on 17/1/16.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRTextTableViewCell.h"

@implementation DRTextTableViewCell

+ (DRTextTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"TextTableViewCell";
    DRTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRTextTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    self.line = line;
    line.backgroundColor = DRWhiteLineColor;
    [self addSubview:line];
    
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
    
    //头像
    UIImageView * avatarImageView = [[UIImageView alloc] init];
    self.avatarImageView = avatarImageView;
    avatarImageView.hidden = YES;
    [self addSubview:avatarImageView];
    avatarImageView.layer.masksToBounds = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.functionNameLabel.height = self.height;
    self.functionDetailLabel.height = self.height;
    
    CGFloat accessoryImageViewWH = 10;
    CGFloat accessoryImageViewY = (self.height - accessoryImageViewWH) / 2;
    self.accessoryImageView.frame = CGRectMake(screenWidth - DRMargin - accessoryImageViewWH, accessoryImageViewY, accessoryImageViewWH, accessoryImageViewWH);
    
    CGFloat avatarImageViewWH = 50;
    self.avatarImageView.frame = CGRectMake(screenWidth - DRMargin - avatarImageViewWH - 15, (self.height - avatarImageViewWH) / 2, avatarImageViewWH, avatarImageViewWH);
    self.avatarImageView.layer.cornerRadius = avatarImageViewWH / 2;
}

- (void)setFunctionName:(NSString *)functionName
{
    _functionName = functionName;
    self.functionNameLabel.text = functionName;
    CGSize functionNameLabelSize = [self.functionNameLabel.text sizeWithLabelFont:self.functionNameLabel.font];
    self.functionNameLabel.frame = CGRectMake(DRMargin, CGRectGetMaxY(self.line.frame), functionNameLabelSize.width, self.height);
}

- (void)setFunctionDetail:(NSString *)functionDetail
{
    _functionDetail = functionDetail;
    
    self.functionDetailLabel.text = _functionDetail;
    CGSize functionDetailLabelSize = [self.functionDetailLabel.text sizeWithFont:self.functionDetailLabel.font maxSize:CGSizeMake(screenWidth - 2 * DRMargin - CGRectGetMaxX(self.functionNameLabel.frame), self.height)];
    self.functionDetailLabel.frame = CGRectMake(screenWidth - DRMargin - 5 - DRMargin - functionDetailLabelSize.width, CGRectGetMaxY(self.line.frame), functionDetailLabelSize.width, self.height);
    
}

@end
