//
//  DRSystemMessageViewController.h
//  dr
//
//  Created by 毛文豪 on 2017/10/20.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRBaseViewController.h"
#import <HyphenateLite/HyphenateLite.h>
#import "DRSystemMessageTableViewCell.h"

@interface DRSystemMessageViewController : DRBaseViewController

@property (assign, nonatomic) SystemMessageType systemMessageType;
@property (strong, nonatomic) EMConversation *conversation;

@end
