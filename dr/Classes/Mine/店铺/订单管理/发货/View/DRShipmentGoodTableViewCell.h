//
//  DRShipmentGoodTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/6/1.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DROrderItemDetailModel.h"

@interface DRShipmentGoodTableViewCell : UITableViewCell

+ (DRShipmentGoodTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic,strong) NSNumber *successCount;//成团数量
@property (nonatomic,strong) NSNumber *payCount;//已团数
@property (nonatomic,strong) NSNumber *orderType;
@property (nonatomic,strong) DROrderItemDetailModel * orderItemDetailModel;

@end
