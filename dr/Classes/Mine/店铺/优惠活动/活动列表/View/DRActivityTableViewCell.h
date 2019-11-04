//
//  DRActivityTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2019/1/18.
//  Copyright © 2019 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRShopActivityModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DRActivityTableViewCell : UITableViewCell

+ (DRActivityTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) DRShopActivityModel *activityModel;

@end

NS_ASSUME_NONNULL_END
