//
//  UITableView+DRNoData.m
//  dr
//
//  Created by 毛文豪 on 2017/5/27.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "UITableView+DRNoData.h"

@implementation UITableView (DRNoData)

- (void)showNoDataWithTitle:(NSString *)title description:(NSString *)description rowCount:(NSInteger)rowCount
{
    [self showNoDataWithTitle:title description:description rowCount:rowCount offY:0];
}

- (void)showNoDataWithTitle:(NSString *)title description:(NSString *)description rowCount:(NSInteger)rowCount offY:(CGFloat)offY
{
    UIView * backView = [[UIView alloc] initWithFrame:self.bounds];
    
    //图片
    UIImage * image = [UIImage imageNamed:@"no_data"];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
    [backView addSubview:imageView];
    
    //标题
    UILabel * titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(32)];
    titleLabel.textColor = DRBlackTextColor;
    [backView addSubview:titleLabel];
    
    //描述
    UILabel * detailTextLabel = [[UILabel alloc] init];
    detailTextLabel.text = description;
    detailTextLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    detailTextLabel.textColor = DRGrayTextColor;
    [backView addSubview:detailTextLabel];
    
    CGFloat imageViewW = image.size.width;
    CGFloat imageViewH = image.size.height;
    CGFloat padding1 = 15;
    CGFloat padding2 = 10;
    
    CGSize titleLabelSize = [titleLabel.text sizeWithLabelFont:titleLabel.font];
    if (DRStringIsEmpty(title)) {
        padding1 = 0;
        detailTextLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    }
    CGSize detailTextLabelSize = [detailTextLabel.text sizeWithLabelFont:detailTextLabel.font];
    
    CGFloat titleLabelW = titleLabelSize.width;
    CGFloat titleLabelH = titleLabelSize.height;
    CGFloat detailTextLabelW = detailTextLabelSize.width;
    CGFloat detailTextLabelH = detailTextLabelSize.height;
    CGFloat imageViewY = offY + (backView.height - (imageViewH + padding1 + titleLabelH + padding2 + detailTextLabelH)) * 0.39;
    imageView.frame = CGRectMake((backView.width - imageViewW) / 2, imageViewY, imageViewW, imageViewH);
    titleLabel.frame = CGRectMake((backView.width - titleLabelW) / 2, CGRectGetMaxY(imageView.frame) + padding1, titleLabelW, titleLabelH);
    if (DRStringIsEmpty(title)) {
        detailTextLabel.frame = CGRectMake((backView.width - detailTextLabelW) / 2, CGRectGetMaxY(imageView.frame) + padding2, detailTextLabelW, detailTextLabelH);
    }else
    {
        detailTextLabel.frame = CGRectMake((backView.width - detailTextLabelW) / 2, CGRectGetMaxY(titleLabel.frame) + padding2, detailTextLabelW, detailTextLabelH);
    }
    
    if (rowCount == 0) {
        self.backgroundView = backView;
    }else
    {
        self.backgroundView = nil;
    }
}

@end
