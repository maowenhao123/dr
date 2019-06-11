//
//  DRShoppingCarShopModel.m
//  dr
//
//  Created by 毛文豪 on 2017/5/19.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShoppingCarShopModel.h"

@implementation DRShoppingCarShopModel

MJCodingImplementation

- (NSMutableDictionary *)goodDic
{
    if (!_goodDic) {
        _goodDic = [NSMutableDictionary dictionary];
    }
    return _goodDic;
}
- (NSMutableArray *)goodArr
{
    if (!_goodArr) {
        _goodArr = [NSMutableArray array];
    }
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"creatTime" ascending:NO];
    _goodArr = [NSMutableArray arrayWithArray:[self.goodDic.allValues sortedArrayUsingDescriptors:@[sortDescriptor]]];
    return _goodArr;
}
@end
