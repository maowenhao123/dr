//
//  DRAttentionShowTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/7/18.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AttentionShowTableViewCellDelegate <NSObject>

- (void)attentionShowTableViewCell:(UITableViewCell *)cell cancelAttentionButtonDidClick:(UIButton *)button;

@end

@interface DRAttentionShowTableViewCell : UITableViewCell

+ (DRAttentionShowTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, assign) id <AttentionShowTableViewCellDelegate> delegate;

@property (nonatomic,strong) id json;

@end
