//
//  DRShipmentDetailViewController.h
//  dr
//
//  Created by 毛文豪 on 2017/4/6.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRBaseViewController.h"

@interface DRShipmentDetailViewController : DRBaseViewController

@property (nonatomic,copy) NSString *orderId;
@property (nonatomic, strong) NSNumber *orderType;
@property (nonatomic, assign) BOOL isWaitPending;

@end
