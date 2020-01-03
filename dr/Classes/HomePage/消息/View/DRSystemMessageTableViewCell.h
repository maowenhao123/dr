//
//  DRSystemMessageTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/10/20.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HyphenateLite/HyphenateLite.h>

typedef NS_ENUM(NSUInteger, SystemMessageType) {
    OrderMessage = 0,
    SystemMessage,
    InteractiveMessage,
};

@interface DRSystemMessageTableViewCell : UITableViewCell

+ (DRSystemMessageTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (assign, nonatomic) SystemMessageType systemMessageType;
@property (nonatomic,strong) EMMessage *messageModel;

@end
