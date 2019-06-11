//
//  DRMessageChooseGoodModel.h
//  dr
//
//  Created by 毛文豪 on 2017/12/21.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRGrouponModel.h"

@interface DRMessageChooseGoodModel : NSObject

@property (nonatomic, assign, getter=isSelected) BOOL selected;//是否被选中
@property (nonatomic,strong) DRGoodModel *goodModel;
@property (nonatomic,strong) DRGrouponModel *group;//团购详情
@property (nonatomic,assign) int type;//1普通商品 2团购商品

@end
