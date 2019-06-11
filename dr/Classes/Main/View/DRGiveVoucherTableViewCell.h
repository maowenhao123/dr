//
//  DRGiveVoucherTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2018/9/25.
//  Copyright © 2018年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRRedPacketModel.h"

@class DRGiveVoucherTableViewCell;
@protocol DRGiveVoucherTableViewCellDelegate <NSObject>

- (void)giveVoucherTableViewCell:(DRGiveVoucherTableViewCell *)cell giveButtonDidClick:(UIButton *)button;
- (void)useVoucher;

@end

@interface DRGiveVoucherTableViewCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, weak) id <DRGiveVoucherTableViewCellDelegate> delegate;

@property (nonatomic, strong) Coupon *coupon;

@end

