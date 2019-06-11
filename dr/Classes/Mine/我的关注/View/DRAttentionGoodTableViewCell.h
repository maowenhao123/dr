//
//  DRAttentionGoodTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/4/1.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DRAttentionGoodTableViewCell : UITableViewCell

+ (DRAttentionGoodTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic,strong) id json;

@end
