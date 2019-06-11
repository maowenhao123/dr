//
//  DRSubmitOrderViewController.h
//  dr
//
//  Created by 毛文豪 on 2018/3/27.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRBaseViewController.h"

@interface DRSubmitOrderViewController : DRBaseViewController

@property (nonatomic,assign) int grouponType;//团购类型 0:正常商品 1:跟团商品 2:发起团购商品
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic,strong) NSArray *dataArray;

@end
