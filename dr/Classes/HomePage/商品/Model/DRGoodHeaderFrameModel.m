//
//  DRGoodHeaderFrameModel.m
//  dr
//
//  Created by 毛文豪 on 2018/1/23.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRGoodHeaderFrameModel.h"

@implementation DRGoodHeaderFrameModel

- (CGFloat)GoodHeaderCellH
{
    CGSize goodNameLabelSize = [_goodModel.name sizeWithFont:[UIFont boldSystemFontOfSize:DRGetFontSize(32)] maxSize:CGSizeMake(screenWidth - 2 * DRMargin, MAXFLOAT)];
    _goodNameLabelF = CGRectMake(DRMargin, 390 + 10, goodNameLabelSize.width, goodNameLabelSize.height);
    
    NSString * detailStr = _goodModel.description_;
    if (!DRStringIsEmpty(detailStr)) {
        NSMutableAttributedString * detailAttStr = [[NSMutableAttributedString alloc] initWithString:detailStr];
        [detailAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(24)] range:NSMakeRange(0, detailStr.length)];
        [detailAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(0, detailStr.length)];
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 2;//行间距
        [detailAttStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, detailStr.length)];
        CGSize goodDetailLabelSize = [detailAttStr boundingRectWithSize:CGSizeMake(screenWidth - 2 * DRMargin, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        _detailAttStr = detailAttStr;
        _goodDetailLabelF = CGRectMake(DRMargin, CGRectGetMaxY(_goodNameLabelF) + 7, goodDetailLabelSize.width, goodDetailLabelSize.height);
    }else
    {
        _goodDetailLabelF = CGRectMake(0, CGRectGetMaxY(_goodNameLabelF) + 7, 0, 0);
    }
    
    NSString * goodPriceStr = @"";
    if (_isGroupon) {
        goodPriceStr = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[_grouponModel.price doubleValue] / 100]];
    }else
    {
        if ([_goodModel.sellType intValue] == 1) {//一物一拍/零售
            if ([DRTool showDiscountPriceWithGoodModel:_goodModel]) {
                NSString * newPriceStr = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[_goodModel.discountPrice doubleValue] / 100]];
                NSString * oldPriceStr = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[_goodModel.price doubleValue] / 100]];
                NSString * priceStr = [NSString stringWithFormat:@"%@ %@", newPriceStr, oldPriceStr];
                NSMutableAttributedString * priceAttStr = [[NSMutableAttributedString alloc]initWithString:priceStr];
                [priceAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(36)] range:NSMakeRange(0, newPriceStr.length)];
                [priceAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(26)] range:NSMakeRange(priceStr.length - oldPriceStr.length, oldPriceStr.length)];
                [priceAttStr addAttribute:NSForegroundColorAttributeName value:DRDefaultColor range:NSMakeRange(0, newPriceStr.length)];
                [priceAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(priceStr.length - oldPriceStr.length, oldPriceStr.length)];
                [priceAttStr addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(priceStr.length - oldPriceStr.length, oldPriceStr.length)];
                _goodPriceAttStr = priceAttStr;
                goodPriceStr = @"";
            }else if (_goodModel.specifications.count > 0)
            {
                double minPrice = 0;
                double maxPrice = 0;
                for (DRGoodSpecificationModel * specificationModel in _goodModel.specifications) {
                    NSInteger index = [ _goodModel.specifications indexOfObject:specificationModel];
                    int price = [specificationModel.price intValue];
                    if (index == 0) {
                        minPrice = price;
                    }else
                    {
                        minPrice = price < minPrice ? price : minPrice;
                    }
                    maxPrice = price < maxPrice ? maxPrice : price;
                }
                if (maxPrice == minPrice) {
                    goodPriceStr = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:maxPrice/ 100]];
                }else
                {
                    goodPriceStr = [NSString stringWithFormat:@"¥%@ ~ ¥%@", [DRTool formatFloat:maxPrice/ 100], [DRTool formatFloat:minPrice / 100]];
                }
            }else
            {
                goodPriceStr = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[_goodModel.price doubleValue] / 100]];
            }
        }else//批发
        {
            double minPrice = 0;
            double maxPrice = 0;
            for (NSDictionary * wholesaleRuleDic in _goodModel.wholesaleRule) {
                NSInteger index = [ _goodModel.wholesaleRule indexOfObject:wholesaleRuleDic];
                int price = [wholesaleRuleDic[@"price"] intValue];
                if (index == 0) {
                    minPrice = price;
                }else
                {
                    minPrice = price < minPrice ? price : minPrice;
                }
                maxPrice = price < maxPrice ? maxPrice : price;
            }
            
            if (maxPrice == minPrice) {
               goodPriceStr = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:maxPrice/ 100]];
            }else
            {
               goodPriceStr = [NSString stringWithFormat:@"¥%@ ~ ¥%@", [DRTool formatFloat:maxPrice/ 100], [DRTool formatFloat:minPrice / 100]];
            }
        }
    }
    if (!DRStringIsEmpty(goodPriceStr)) {
        NSMutableAttributedString * priceAttStr = [[NSMutableAttributedString alloc]initWithString:goodPriceStr];
        [priceAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(36)] range:NSMakeRange(0, priceAttStr.length)];
        [priceAttStr addAttribute:NSForegroundColorAttributeName value:DRDefaultColor range:NSMakeRange(0, priceAttStr.length)];
        for (NSString * tag in _goodModel.tags) {
            NSMutableAttributedString * tagAttStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@" %@ ", tag]];
            [tagAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(22)] range:NSMakeRange(0, tagAttStr.length)];
            [tagAttStr addAttribute:NSForegroundColorAttributeName value:DRViceColor range:NSMakeRange(0, tagAttStr.length)];
            [tagAttStr addAttribute:NSBackgroundColorAttributeName value:DRColor(255, 242, 204, 1) range:NSMakeRange(0, tagAttStr.length)];
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.maximumLineHeight = 18;
            [priceAttStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, priceAttStr.length)];
            [priceAttStr appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
            [priceAttStr appendAttributedString:tagAttStr];
        }
        
        _goodPriceAttStr = priceAttStr;
    }
    CGSize goodPriceLabelSize = [_goodPriceAttStr boundingRectWithSize:CGSizeMake(screenWidth - 2 * DRMargin, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    _goodPriceLabelF = CGRectMake(DRMargin, CGRectGetMaxY(_goodDetailLabelF) + 7, screenWidth - 2 * DRMargin, goodPriceLabelSize.height);
    
    NSString * mailTypeStr;
    if ([_goodModel.store.ruleMoney intValue] > 0) {
        mailTypeStr = [NSString stringWithFormat:@"满%@包邮", [DRTool formatFloat:[_goodModel.store.ruleMoney doubleValue] / 100]];
    }else if ([_goodModel.store.ruleMoney intValue] == 0 && [_goodModel.store.ruleMoney intValue] == 0 && [_goodModel.mailType intValue] == 0)
    {
        mailTypeStr = @"包邮";
    }else
    {
        NSDictionary *mailTypeDic = @{
                                      @"1":@"包邮",
                                      @"2":@"肉币支付",
                                      @"3":@"快递到付",
                                      };
        mailTypeStr = [NSString stringWithFormat:@"配送方式：%@", mailTypeDic[_goodModel.mailType]];
    }
    _mailTypeStr = mailTypeStr;
    CGSize goodMailTypeLabelSize = [_mailTypeStr sizeWithLabelFont:[UIFont systemFontOfSize:DRGetFontSize(24)]];
    _goodMailTypeLabelF = CGRectMake(DRMargin, CGRectGetMaxY(_goodPriceLabelF) + 7, goodMailTypeLabelSize.width, goodMailTypeLabelSize.height);
   
    CGSize goodSaleCountLabelSize = [[NSString stringWithFormat:@"销量：%@", _goodModel.sellCount] sizeWithLabelFont:[UIFont systemFontOfSize:DRGetFontSize(24)]];
    _goodSaleCountLabelF = CGRectMake(CGRectGetMaxX(_goodMailTypeLabelF) + DRMargin, CGRectGetMaxY(_goodPriceLabelF) + 7, goodSaleCountLabelSize.width, goodSaleCountLabelSize.height);
    
    if (_goodModel.specifications.count > 0) {
        _specificationViewF = CGRectMake(0, CGRectGetMaxY(_goodSaleCountLabelF) + 7, screenWidth, 75);
        _GoodHeaderCellH = CGRectGetMaxY(_specificationViewF);
    }else
    {
        _GoodHeaderCellH = CGRectGetMaxY(_goodSaleCountLabelF) + 7;
    }
    
    return _GoodHeaderCellH;
}

@end
