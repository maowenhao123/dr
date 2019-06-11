//
//  DRAddressModel.m
//  dr
//
//  Created by 毛文豪 on 2017/4/17.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRAddressModel.h"

@implementation DRAddressModel

- (CGFloat)addressCellH
{
    //姓名
    _nameStr = [NSString stringWithFormat:@"收货人：%@", _name];
    CGSize nameLabelSize = [_nameStr sizeWithLabelFont:[UIFont systemFontOfSize:DRGetFontSize(30)]];
    _nameLabelF = CGRectMake(DRMargin, 9 + 13, nameLabelSize.width, nameLabelSize.height);
    
    //电话
    _phoneStr = [NSString stringWithFormat:@"联系电话：%@", _phone];
    CGSize phoneLabelSize = [_phoneStr sizeWithLabelFont:[UIFont systemFontOfSize:DRGetFontSize(30)]];
    _phoneLabelF = CGRectMake(screenWidth - DRMargin - phoneLabelSize.width, 9 + 13, phoneLabelSize.width, phoneLabelSize.height);
    
    //地址
    NSMutableAttributedString * addressAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"收货地址：%@%@%@", _province, _city, _address]];
    [addressAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(26)] range:NSMakeRange(0, addressAttStr.length)];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;//行间距
    [addressAttStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, addressAttStr.length)];
    _addressAttStr = addressAttStr;
    CGSize addressLabelSize = [addressAttStr boundingRectWithSize:CGSizeMake(screenWidth - 2 * DRMargin, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    _addressLabelF = CGRectMake(DRMargin, CGRectGetMaxY(_nameLabelF) + DRMargin, addressLabelSize.width, addressLabelSize.height);
    
    _lineF = CGRectMake(0, CGRectGetMaxY(_addressLabelF) + DRMargin, screenWidth, 1);
    
    _defaultButtonF = CGRectMake(DRMargin, CGRectGetMaxY(_lineF), 100, 35);
    
    CGSize deleteButtonSize = [@"删除" sizeWithLabelFont:[UIFont systemFontOfSize:DRGetFontSize(28)]];
    _deleteButtonF = CGRectMake(screenWidth - DRMargin - deleteButtonSize.width, CGRectGetMaxY(_lineF), deleteButtonSize.width, 35);
    
    CGSize editButtonSize = [@"编辑" sizeWithLabelFont:[UIFont systemFontOfSize:DRGetFontSize(28)]];
    _editButtonF = CGRectMake(_deleteButtonF.origin.x - DRMargin - editButtonSize.width, CGRectGetMaxY(_lineF), editButtonSize.width, 35);
    
    _addressCellH = CGRectGetMaxY(_defaultButtonF);
    
    return _addressCellH;
}

@end
