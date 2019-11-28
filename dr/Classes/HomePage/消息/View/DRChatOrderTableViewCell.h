//
//  DRChatOrderTableViewCell.h
//  dr
//
//  Created by dahe on 2019/11/25.
//  Copyright © 2019 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DROrderModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DRChatOrderTableViewCell : UITableViewCell

+ (DRChatOrderTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic,strong) DROrderModel * orderModel;

@end

NS_ASSUME_NONNULL_END
