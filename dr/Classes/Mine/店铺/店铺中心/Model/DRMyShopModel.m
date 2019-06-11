//
//  DRMyShopModel.m
//  dr
//
//  Created by 毛文豪 on 2017/4/20.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRMyShopModel.h"

@implementation DRMyShopModel

MJCodingImplementation

+ (void)initialize
{
    [DRMyShopModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        
        return @{
                 @"description_":@"description"
                 };
    }];
}

@end
