//
//  DRIconTextTableViewCell.h
//  dr
//
//  Created by apple on 17/1/16.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRFunctionStatus.h"

@interface DRIconTextTableViewCell : UITableViewCell

@property (nonatomic, weak) UIImageView *iconImageView;//icon的imageView
@property (nonatomic, weak) UILabel *functionNameLabel;//名字label
@property (nonatomic, weak) UILabel *functionDetailLabel;//Detail label
@property (nonatomic, weak) UIView * line;//分割线
@property (nonatomic,weak) UIImageView * accessoryImageView;

@property (nonatomic, copy) NSString *icon;//icon名字
@property (nonatomic, copy) NSString *functionName;//名字
@property (nonatomic, copy) NSString *functionDetail;//Detail

+(DRIconTextTableViewCell *)cellWithTableView:(UITableView *)tableView;

@end
