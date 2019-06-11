//
//  DRSubmitOrderGoodTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2018/3/27.
//  Copyright © 2018年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DROrderItemDetailModel.h"

@interface DRSubmitOrderGoodTableViewCell : UITableViewCell

+ (DRSubmitOrderGoodTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic,strong) DROrderItemDetailModel *model;

@end
