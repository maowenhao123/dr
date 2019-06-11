//
//  DROrderDetailSectionFooterView.h
//  dr
//
//  Created by 毛文豪 on 2018/3/13.
//  Copyright © 2018年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRStoreOrderModel.h"

@interface DROrderDetailSectionFooterView : UITableViewHeaderFooterView

+ (DROrderDetailSectionFooterView *)headerFooterViewWithTableView:(UITableView *)tableView;

@property (nonatomic,strong) DRStoreOrderModel * storeOrderModel;

@end
