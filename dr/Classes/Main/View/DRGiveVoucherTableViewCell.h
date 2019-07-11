//
//  DRGiveVoucherTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2018/9/25.
//  Copyright © 2018年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRVoucherModel.h"

@interface DRGiveVoucherTableViewCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) DRVoucherModel *voucherModel;

@end

