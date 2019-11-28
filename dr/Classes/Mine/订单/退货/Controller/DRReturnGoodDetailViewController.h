//
//  DRReturnGoodDetailViewController.h
//  dr
//
//  Created by 毛文豪 on 2017/6/25.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRBaseViewController.h"

@interface DRReturnGoodDetailViewController : DRBaseViewController

@property (nonatomic,copy) NSString *orderId;
@property (nonatomic,copy) NSString *goodsId;
@property (nonatomic,copy) NSString *returnGoodId;
@property (nonatomic,copy) NSString *id;
@property (nonatomic,copy) NSString *specificationId;
@property (nonatomic,assign) BOOL isSeller;

@end
