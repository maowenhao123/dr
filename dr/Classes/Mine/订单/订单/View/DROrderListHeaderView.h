//
//  DROrderListHeaderView.h
//  dr
//
//  Created by 毛文豪 on 2018/3/6.
//  Copyright © 2018年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DROrderModel.h"

@interface DROrderListHeaderView : UITableViewHeaderFooterView

+ (DROrderListHeaderView *)headerFooterViewWithTableView:(UITableView *)tableView;

@property (nonatomic,weak) UIImageView * shopLogoImageView;
@property (nonatomic,weak) UILabel * shopNameLabel;
@property (nonatomic,weak) UILabel * statusLabel;

@property (nonatomic,assign) BOOL isGroup;

@property (nonatomic, strong) DROrderModel * orderModel;

@end
