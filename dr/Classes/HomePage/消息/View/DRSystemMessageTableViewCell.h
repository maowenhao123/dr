//
//  DRSystemMessageTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/10/20.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HyphenateLite/HyphenateLite.h>

@interface DRSystemMessageTableViewCell : UITableViewCell

+ (DRSystemMessageTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, assign) BOOL isSystem;

@property (nonatomic,strong) EMMessage *messageModel;

@end
