//
//  DRAddressTableViewCell.h
//  dr
//
//  Created by apple on 17/1/16.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRAddressModel.h"

@class DRAddressTableViewCell;
@protocol AddressTableViewCellDelegate <NSObject>

- (void)AddressTableViewCellDefaultButtonDidClick:(UIButton *)buton withCell:(DRAddressTableViewCell *)cell;
- (void)AddressTableViewCellDeleteButtonDidClickWithCell:(DRAddressTableViewCell *)cell;
- (void)AddressTableViewCellEditButtonDidClickWithCell:(DRAddressTableViewCell *)cell;

@end

@interface DRAddressTableViewCell : UITableViewCell

+ (DRAddressTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) DRAddressModel * addressModel;

@property (nonatomic, weak) id <AddressTableViewCellDelegate> delegate;

@end
