//
//  DRMaintainTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/4/7.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DRMaintainTableViewCell : UITableViewCell

+ (DRMaintainTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) NSDictionary * dic;

@end
