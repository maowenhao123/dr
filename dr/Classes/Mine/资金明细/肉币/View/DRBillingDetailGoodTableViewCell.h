//
//  DRBillingDetailGoodTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2018/6/6.
//  Copyright © 2018年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DROrderItemDetailModel.h"

@interface DRBillingDetailGoodTableViewCell : UITableViewCell

+ (DRBillingDetailGoodTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) DROrderItemDetailModel *detailModel;

@end
