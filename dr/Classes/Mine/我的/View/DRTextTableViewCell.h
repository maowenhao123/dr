//
//  DRTextTableViewCell.h
//  dr
//
//  Created by apple on 17/1/16.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DRTextTableViewCell : UITableViewCell

@property (nonatomic, weak) UILabel *functionNameLabel;//名字label

@property (nonatomic, weak) UILabel *functionDetailLabel;//Detail label

@property (nonatomic, weak) UIImageView *avatarImageView;//头像

@property (nonatomic,weak) UIImageView * accessoryImageView;

@property (nonatomic, weak) UIView * line;//分割线

@property (nonatomic, copy) NSString *functionName;//名字

@property (nonatomic, copy) NSString *functionDetail;//Detail

+ (DRTextTableViewCell *)cellWithTableView:(UITableView *)tableView;

@end
