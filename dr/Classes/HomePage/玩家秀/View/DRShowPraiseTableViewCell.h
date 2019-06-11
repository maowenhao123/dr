//
//  DRShowPraiseTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/7/16.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRShowPraiseModel.h"

@interface DRShowPraiseTableViewCell : UITableViewCell

+ (DRShowPraiseTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) DRShowPraiseModel * showPraiseModel;

@property (nonatomic,assign) BOOL isList;

@end
