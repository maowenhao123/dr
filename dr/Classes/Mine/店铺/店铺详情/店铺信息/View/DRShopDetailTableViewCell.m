//
//  DRShopDetailTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/8/25.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShopDetailTableViewCell.h"

@interface DRShopDetailTableViewCell ()

@property (nonatomic,weak) UILabel * detailTitleLabel;
@property (nonatomic,weak) UILabel * shopDetailLabel;

@end

@implementation DRShopDetailTableViewCell

+ (DRShopDetailTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"ShopDetailTableViewCellId";
    DRShopDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRShopDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    line.backgroundColor = DRWhiteLineColor;
    [self addSubview:line];
    
    //名字
    UILabel * detailTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 15, screenWidth - 2 * DRMargin, 20)];
    self.detailTitleLabel = detailTitleLabel;
    detailTitleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    detailTitleLabel.textColor = DRBlackTextColor;
    [self addSubview:detailTitleLabel];
    
    //简介
    UILabel * shopDetailLabel = [[UILabel alloc] init];
    self.shopDetailLabel = shopDetailLabel;
    shopDetailLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    shopDetailLabel.textColor = DRGrayTextColor;
    shopDetailLabel.numberOfLines = 0;
    [self addSubview:shopDetailLabel];
}

- (void)setDetailTitleStr:(NSString *)detailTitleStr
{
    _detailTitleStr = detailTitleStr;
    
    self.detailTitleLabel.text = _detailTitleStr;
}

- (void)setShopDetailStr:(NSString *)shopDetailStr
{
    _shopDetailStr = shopDetailStr;
    
    self.shopDetailLabel.text = _shopDetailStr;
    CGSize size = [self.shopDetailLabel.text sizeWithFont:self.shopDetailLabel.font maxSize:CGSizeMake(screenWidth - 2 * 10, MAXFLOAT)];
    CGFloat height = size.height < 20 ? 20 : size.height;
    self.shopDetailLabel.frame = CGRectMake(DRMargin, 35, screenWidth - 2 * DRMargin, height + 10);
}

@end
