//
//  DRPaySuccessViewController.h
//  dr
//
//  Created by 毛文豪 on 2017/3/30.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRBaseViewController.h"

@interface DRPaySuccessViewController : DRBaseViewController

@property (nonatomic,copy) NSString *orderId;
@property (nonatomic,assign) int grouponType;//团购类型 0:正常商品 1:跟团商品 2:发起团购商品
@property (nonatomic,assign) double price;
@property (nonatomic, copy) NSString *grouponId;
@property (nonatomic,assign) BOOL grouponFull;

@end
