//
//  DRShowModel.m
//  dr
//
//  Created by 毛文豪 on 2017/5/4.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShowModel.h"
#import "DRDateTool.h"

@implementation DRShowModel

- (void)setFrameCellH;
{
    CGSize titleLabelSize = [_name sizeWithLabelFont:[UIFont systemFontOfSize:DRGetFontSize(28)]];
    _titleLabelF = CGRectMake(DRMargin, 1 + 54 + 12, screenWidth - 2 * DRMargin, titleLabelSize.height);

    NSMutableAttributedString * detailAttStr = [[NSMutableAttributedString alloc] initWithString:_content];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;//行间距
    [detailAttStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, detailAttStr.length)];
    [detailAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(26)] range:NSMakeRange(0, detailAttStr.length)];
    _detailAttStr = detailAttStr;
    
    CGSize detailLabelSize = [detailAttStr boundingRectWithSize:CGSizeMake(screenWidth - 2 * DRMargin, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    _detailLabelF = CGRectMake(DRMargin, CGRectGetMaxY(_titleLabelF) + 12, screenWidth - 2 * DRMargin, detailLabelSize.height);
    
    NSArray * imageUrls = [_pics componentsSeparatedByString:@"|"];
    NSInteger imageCount = imageUrls.count;//图片数量
    if (imageCount == 1) {
        NSString * imageUrl = imageUrls[0];
        if (DRStringIsEmpty(imageUrl)) {
            imageCount = 0;
        }
    }
    CGFloat padding = 5;
    CGFloat imageViewWH = (screenWidth - 4 * padding) / 3;
    _headerViewH = 1 + 54 + 12 + titleLabelSize.height + 12 + detailLabelSize.height + 12 + (imageCount + 2) / 3 * (imageViewWH + padding) + 26;
    
    if ([_showPraiseModel.praiseCount intValue] > 0 || (_commentArray.count > 0 && _commentArray.count < 8)) {
        _triangleImageViewF = CGRectMake(DRMargin + 7.5 - 12 / 2, _headerViewH - 6, 12, 6);
    }else
    {
        _triangleImageViewF = CGRectZero;
    }
}

@end
