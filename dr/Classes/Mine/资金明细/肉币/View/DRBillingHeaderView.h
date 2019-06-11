//
//  DRBillingHeaderView.h
//  dr
//
//  Created by 毛文豪 on 2018/6/4.
//  Copyright © 2018年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRMoneyDetailSectionModel.h"

@interface DRBillingHeaderView : UITableViewHeaderFooterView

+ (DRBillingHeaderView *)headerFooterViewWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) DRMoneyDetailSectionModel *sectionModel;

@end
