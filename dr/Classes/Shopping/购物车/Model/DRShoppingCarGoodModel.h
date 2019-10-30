//
//  DRShoppingCarGoodModel.h
//  dr
//
//  Created by 毛文豪 on 2017/5/19.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRShoppingCarGoodModel : NSObject

@property (nonatomic, assign, getter=isSelected) BOOL selected;//是否被选中
@property (nonatomic,assign) long long creatTime;//添加进购物车的时间
@property (nonatomic,assign) int count;//购物车中该商品的数量
@property (nonatomic,strong) DRGoodModel *goodModel;
@property (nonatomic,strong) DRGoodSpecificationModel *specificationModel;
@property (nonatomic,copy) NSString * carGoodId;

@end
