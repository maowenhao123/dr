//
//  DRDeliveryAddressModel.m
//  dr
//
//  Created by 毛文豪 on 2017/5/31.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRDeliveryAddressModel.h"

@implementation DRDeliveryAddressModel

- (CGSize)countSize
{
    CGSize titleLabelSize = [@"收货地址" sizeWithLabelFont:[UIFont systemFontOfSize:DRGetFontSize(24)]];
    CGFloat titleLabelW = titleLabelSize.width;
    
    CGSize size = [[NSString stringWithFormat:@"%@", _count] sizeWithFont:[UIFont systemFontOfSize:DRGetFontSize(24)] maxSize:CGSizeMake(screenWidth - titleLabelW - 2 * DRMargin, CGFLOAT_MAX)];
    _countSize = size;
    return _countSize;
}

- (CGSize)nameSize
{
    CGSize titleLabelSize = [@"收货地址" sizeWithLabelFont:[UIFont systemFontOfSize:DRGetFontSize(24)]];
    CGFloat titleLabelW = titleLabelSize.width;
    
    CGSize size = [[NSString stringWithFormat:@"%@", _address.receiverName] sizeWithFont:[UIFont systemFontOfSize:DRGetFontSize(24)] maxSize:CGSizeMake(screenWidth - titleLabelW - 2 * DRMargin - 100, CGFLOAT_MAX)];
    _nameSize = size;
    return _nameSize;
}

- (CGSize)phoneSize
{
    CGSize titleLabelSize = [@"收货地址" sizeWithLabelFont:[UIFont systemFontOfSize:DRGetFontSize(24)]];
    CGFloat titleLabelW = titleLabelSize.width;
    
    CGSize size = [[NSString stringWithFormat:@"%@", _address.phone] sizeWithFont:[UIFont systemFontOfSize:DRGetFontSize(24)] maxSize:CGSizeMake(screenWidth - titleLabelW - 2 * DRMargin, CGFLOAT_MAX)];
    _phoneSize = size;
    return _phoneSize;
}

- (CGSize)addressSize
{
    CGSize titleLabelSize = [@"收货地址" sizeWithLabelFont:[UIFont systemFontOfSize:DRGetFontSize(24)]];
    CGFloat titleLabelW = titleLabelSize.width;
    CGSize size = [[NSString stringWithFormat:@"%@%@%@", _address.province, _address.city, _address.address] sizeWithFont:[UIFont systemFontOfSize:DRGetFontSize(24)] maxSize:CGSizeMake(screenWidth - titleLabelW - 3 * DRMargin, CGFLOAT_MAX)];
    _addressSize = size;
    return _addressSize;
}

- (CGSize)logisticsNameSize
{
    CGSize titleLabelSize = [@"收货地址" sizeWithLabelFont:[UIFont systemFontOfSize:DRGetFontSize(24)]];
    CGFloat titleLabelW = titleLabelSize.width;
    
    CGSize size = [[NSString stringWithFormat:@"%@", _logisticsName] sizeWithFont:[UIFont systemFontOfSize:DRGetFontSize(24)] maxSize:CGSizeMake(screenWidth - titleLabelW - 2 * DRMargin, CGFLOAT_MAX)];
    _logisticsNameSize = size;
    return _logisticsNameSize;
}

- (CGSize)logisticsNumSize
{
    CGSize titleLabelSize = [@"收货地址" sizeWithLabelFont:[UIFont systemFontOfSize:DRGetFontSize(24)]];
    CGFloat titleLabelW = titleLabelSize.width;
    
    CGSize size = [[NSString stringWithFormat:@"%@", _logisticsNum] sizeWithFont:[UIFont systemFontOfSize:DRGetFontSize(24)] maxSize:CGSizeMake(screenWidth - titleLabelW - 2 * DRMargin, CGFLOAT_MAX)];
    _logisticsNumSize = size;
    return _logisticsNumSize;
}

- (CGSize)typeSize
{
    CGSize titleLabelSize = [@"收货地址" sizeWithLabelFont:[UIFont systemFontOfSize:DRGetFontSize(24)]];
    CGFloat titleLabelW = titleLabelSize.width;
    
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

@end
