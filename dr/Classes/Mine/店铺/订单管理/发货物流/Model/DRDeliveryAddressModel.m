//
//  DRDeliveryAddressModel.m
//  dr
//
//  Created by 毛文豪 on 2017/5/31.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRDeliveryAddressModel.h"

@implementation DRDeliveryAddressModel

- (CGFloat)cellH
{
    int statusInt = [_status intValue];
    CGFloat cellH = 0;
    if (statusInt == 20 || statusInt == 30) {
        if (!DRStringIsEmpty(_groupId)) {//团购
            cellH = DRMargin + _nameSize.height + DRMargin + _phoneSize.height + DRMargin + _addressSize.height + _countSize.height + DRMargin + DRMargin + _logisticsNameSize.height + DRMargin + _logisticsNumSize.height + DRMargin +  _typeSize.height + DRMargin;
        }else
        {
            cellH = DRMargin + _nameSize.height + DRMargin + _phoneSize.height + DRMargin + _addressSize.height + DRMargin + _logisticsNameSize.height + DRMargin + _logisticsNumSize.height + DRMargin +  _typeSize.height + DRMargin;
        }
    }else
    {
        if (!DRStringIsEmpty(_groupId)) {//团购
            cellH = DRMargin + _nameSize.height + DRMargin + _phoneSize.height + DRMargin + _addressSize.height + DRMargin + _countSize.height + DRMargin + _typeSize.height + DRMargin;
        }else
        {
            cellH = DRMargin + _nameSize.height + DRMargin + _phoneSize.height + DRMargin + _addressSize.height + DRMargin + _typeSize.height + DRMargin;
        }
    }
    if (!DRStringIsEmpty(_remarks)) {//有备注信息
        cellH += _remarkSize.height + DRMargin;
    }
    _cellH = cellH;
    return _cellH;
}

- (CGSize)countSize
{
    CGFloat titleLabelW = [self getTitleLabelW];
    
    CGSize size = [[NSString stringWithFormat:@"%@", _count] sizeWithFont:[UIFont systemFontOfSize:DRGetFontSize(24)] maxSize:CGSizeMake(screenWidth - titleLabelW - 2 * DRMargin, CGFLOAT_MAX)];
    _countSize = size;
    return _countSize;
}

- (CGSize)nameSize
{
    CGFloat titleLabelW = [self getTitleLabelW];
    
    CGSize size = [[NSString stringWithFormat:@"%@", _address.receiverName] sizeWithFont:[UIFont systemFontOfSize:DRGetFontSize(24)] maxSize:CGSizeMake(screenWidth - titleLabelW - 2 * DRMargin - 100, CGFLOAT_MAX)];
    _nameSize = size;
    return _nameSize;
}

- (CGSize)phoneSize
{
    CGFloat titleLabelW = [self getTitleLabelW];
    
    CGSize size = [[NSString stringWithFormat:@"%@", _address.phone] sizeWithFont:[UIFont systemFontOfSize:DRGetFontSize(24)] maxSize:CGSizeMake(screenWidth - titleLabelW - 2 * DRMargin, CGFLOAT_MAX)];
    _phoneSize = size;
    return _phoneSize;
}

- (CGSize)addressSize
{
    CGFloat titleLabelW = [self getTitleLabelW];

    CGSize size = [[NSString stringWithFormat:@"%@%@%@", _address.province, _address.city, _address.address] sizeWithFont:[UIFont systemFontOfSize:DRGetFontSize(24)] maxSize:CGSizeMake(screenWidth - titleLabelW - 3 * DRMargin, CGFLOAT_MAX)];
    _addressSize = size;
    return _addressSize;
}

- (CGSize)logisticsNameSize
{
    CGFloat titleLabelW = [self getTitleLabelW];
    
    CGSize size = [[NSString stringWithFormat:@"%@", _logisticsName] sizeWithFont:[UIFont systemFontOfSize:DRGetFontSize(24)] maxSize:CGSizeMake(screenWidth - titleLabelW - 2 * DRMargin, CGFLOAT_MAX)];
    _logisticsNameSize = size;
    return _logisticsNameSize;
}

- (CGSize)logisticsNumSize
{
    CGFloat titleLabelW = [self getTitleLabelW];
    
    CGSize size = [[NSString stringWithFormat:@"%@", _logisticsNum] sizeWithFont:[UIFont systemFontOfSize:DRGetFontSize(24)] maxSize:CGSizeMake(screenWidth - titleLabelW - 2 * DRMargin, CGFLOAT_MAX)];
    _logisticsNumSize = size;
    return _logisticsNumSize;
}

- (CGSize)typeSize
{
    CGFloat titleLabelW = [self getTitleLabelW];
    
    NSString * mailTypeStr;
    if ([_freight intValue] > 0) {
        mailTypeStr = [NSString stringWithFormat:@"%@元", [DRTool formatFloat:[_freight doubleValue] /100]];
    }else if ([_mailType intValue] == 0 && [_freight intValue] == 0)
    {
        mailTypeStr = @"包邮";
    }else if ([_mailType intValue] > 0)
    {
        NSArray * mailTypes = @[@"包邮", @"肉币支付", @"快递到付"];
        mailTypeStr = [NSString stringWithFormat:@"%@", mailTypes[[_mailType intValue] - 1]];
    }
    CGSize size = [mailTypeStr sizeWithFont:[UIFont systemFontOfSize:DRGetFontSize(24)] maxSize:CGSizeMake(screenWidth - titleLabelW - 2 * DRMargin, CGFLOAT_MAX)];
    _typeSize = size;
    return _typeSize;
}

- (CGSize)remarkSize
{
    CGFloat titleLabelW = [self getTitleLabelW];
    
    CGSize size = [[NSString stringWithFormat:@"%@", _remarks] sizeWithFont:[UIFont systemFontOfSize:DRGetFontSize(24)] maxSize:CGSizeMake(screenWidth - titleLabelW - 2 * DRMargin, CGFLOAT_MAX)];
    _remarkSize = size;
    return _remarkSize;
}

- (CGFloat)getTitleLabelW
{
    CGSize titleLabelSize = [@"收货地址：" sizeWithLabelFont:[UIFont systemFontOfSize:DRGetFontSize(24)]];
    return titleLabelSize.width;
}

@end
