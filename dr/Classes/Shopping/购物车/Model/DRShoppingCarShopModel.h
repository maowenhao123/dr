//
//  DRShoppingCarShopModel.h
//  dr
//
//  Created by 毛文豪 on 2017/5/19.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRShoppingCarGoodModel.h"

@interface DRShoppingCarShopModel : NSObject

@property (nonatomic, assign, getter=isSelected) BOOL selected;//是否被选中
@property (nonatomic,assign) long long creatTime;//添加进购物车的时间
@property (nonatomic, strong) NSMutableDictionary *goodDic;
@property (nonatomic, strong) NSMutableArray *goodArr;

@property (nonatomic,strong) DRShopModel *shopModel;

@end
