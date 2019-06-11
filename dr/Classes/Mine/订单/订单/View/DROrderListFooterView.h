//
//  DROrderListFooterView.h
//  dr
//
//  Created by 毛文豪 on 2018/3/6.
//  Copyright © 2018年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DROrderModel.h"

@protocol DROrderListFooterViewDelegate <NSObject>

- (void)buttonDidClick:(UIButton *)button;

@end

@interface DROrderListFooterView : UITableViewHeaderFooterView

+ (DROrderListFooterView *)headerFooterViewWithTableView:(UITableView *)tableView;

@property (nonatomic,assign) NSInteger index;

@property (nonatomic,assign) BOOL isGroup;

@property (nonatomic, strong) DROrderModel * orderModel;

@property (nonatomic, weak) id<DROrderListFooterViewDelegate>delegate;

@end
