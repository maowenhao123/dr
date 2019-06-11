//
//  DRShopDetailTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/8/25.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DRShopDetailTableViewCell : UITableViewCell

+ (DRShopDetailTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic,copy) NSString *detailTitleStr;
@property (nonatomic,copy) NSString * shopDetailStr;

@end
