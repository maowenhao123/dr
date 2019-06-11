//
//  DRSubmitOrderGoodHeaderView.h
//  dr
//
//  Created by 毛文豪 on 2018/3/27.
//  Copyright © 2018年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRStoreOrderModel.h"

@interface DRSubmitOrderGoodHeaderView : UITableViewHeaderFooterView

+ (DRSubmitOrderGoodHeaderView *)headerFooterViewWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) DRStoreOrderModel * storeOrderModel;

@end
