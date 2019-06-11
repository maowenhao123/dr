//
//  DRMoneyDetailTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/4/5.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRMoneyDetailSectionModel.h"

@interface DRMoneyDetailTableViewCell : UITableViewCell

+ (DRMoneyDetailTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) DRMoneyDetailModel * model;

@end
