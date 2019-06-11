//
//  DRBankCardTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/4/20.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRBankCardModel.h"

@interface DRBankCardTableViewCell : UITableViewCell

+ (DRBankCardTableViewCell *)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, strong) DRBankCardModel *model;

@end
