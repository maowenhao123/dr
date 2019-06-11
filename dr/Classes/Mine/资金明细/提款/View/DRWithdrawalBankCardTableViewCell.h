//
//  DRWithdrawalBankCardTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/7/26.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRBankCardModel.h"

@interface DRWithdrawalBankCardTableViewCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) DRBankCardModel *bankCardModel;

@end
