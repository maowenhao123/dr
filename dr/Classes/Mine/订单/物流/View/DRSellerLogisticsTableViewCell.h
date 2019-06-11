//
//  DRSellerLogisticsTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/6/13.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRLogisticsTraceModel.h"

@interface DRSellerLogisticsTableViewCell : UITableViewCell

+ (DRSellerLogisticsTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic,strong) DRLogisticsTraceModel *logisticsTraceModel;

@end
