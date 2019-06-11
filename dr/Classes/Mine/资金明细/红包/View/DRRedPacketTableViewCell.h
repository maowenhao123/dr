//
//  DRRedPacketTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2018/1/25.
//  Copyright © 2018年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRRedPacketModel.h"

@interface DRRedPacketTableViewCell : UITableViewCell

+ (DRRedPacketTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic,strong) DRRedPacketModel *redPacketModel;

@property (nonatomic,assign) BOOL customSelected;

@property (nonatomic, assign) int index;//1 未使用 2 已使用 3 已过期

@end
