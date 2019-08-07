//
//  DRShoppingCarNoDataTableViewCell.m
//  dr
//
//  Created by dahe on 2019/8/7.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRShoppingCarNoDataTableViewCell.h"

@interface DRShoppingCarNoDataTableViewCell ()


@end

@implementation DRShoppingCarNoDataTableViewCell

+ (DRShoppingCarNoDataTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"ShoppingCarNoDataTableViewCellId";
    DRShoppingCarNoDataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRShoppingCarNoDataTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = DRBackgroundColor;
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
    //图片
    UIImage * image = [UIImage imageNamed:@"car_no_data"];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:imageView];
    
    //标题
    UILabel * titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"购物车竟然是空的";
    titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(32)];
    titleLabel.textColor = DRBlackTextColor;
    [self addSubview:titleLabel];
    
    //描述
    UILabel * detailTextLabel = [[UILabel alloc] init];
    detailTextLabel.text = @"快买个多肉萌翻自己~";
    detailTextLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    detailTextLabel.textColor = DRGrayTextColor;
    [self addSubview:detailTextLabel];
    
    CGFloat imageViewW = image.size.width;
    CGFloat imageViewH = image.size.height;
    CGFloat padding1 = 15;
    CGFloat padding2 = 10;
    
    CGSize titleLabelSize = [titleLabel.text sizeWithLabelFont:titleLabel.font];
    CGSize detailTextLabelSize = [detailTextLabel.text sizeWithLabelFont:detailTextLabel.font];
    
    CGFloat titleLabelW = titleLabelSize.width;
    CGFloat titleLabelH = titleLabelSize.height;
    CGFloat detailTextLabelW = detailTextLabelSize.width;
    CGFloat detailTextLabelH = detailTextLabelSize.height;
    CGFloat imageViewY = (300 - (imageViewH + padding1 + titleLabelH + padding2 + detailTextLabelH)) / 2;
    imageView.frame = CGRectMake((screenWidth - imageViewW) / 2, imageViewY, imageViewW, imageViewH);
    titleLabel.frame = CGRectMake((screenWidth - titleLabelW) / 2, CGRectGetMaxY(imageView.frame) + padding1, titleLabelW, titleLabelH);
    detailTextLabel.frame = CGRectMake((screenWidth - detailTextLabelW) / 2, CGRectGetMaxY(titleLabel.frame) + padding2, detailTextLabelW, detailTextLabelH);
}

@end
