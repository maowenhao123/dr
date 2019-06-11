//
//  DRGoodDetailViewController.h
//  dr
//
//  Created by apple on 17/1/14.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRBaseViewController.h"

@interface DRGoodDetailViewController : DRBaseViewController

@property (nonatomic,copy) NSString *goodId;
@property (nonatomic,copy) NSString *grouponId;
@property (nonatomic,assign) BOOL isGroupon;//团购页面来的

@end
