//
//  DROrderSingleTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/5/26.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DROrderModel.h"

@interface DROrderSingleTableViewCell : UITableViewCell

+ (DROrderSingleTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic,strong) DRStoreOrderModel *storeOrderModel;

@end
