//
//  DRAttentionShopTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/5/17.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AttentionShopTableViewCellDelegate <NSObject>

- (void)attentionShopTableViewCell:(UITableViewCell *)cell cancelAttentionButtonDidClick:(UIButton *)button;
- (void)attentionShopTableViewCell:(UITableViewCell *)cell goshopButtonDidClick:(UIButton *)button;
- (void)attentionShopTableViewCell:(UITableViewCell *)cell goGoodWithGoodId:(NSString *)goodId;

@end

@interface DRAttentionShopTableViewCell : UITableViewCell

+ (DRAttentionShopTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, assign) id <AttentionShopTableViewCellDelegate> delegate;

@property (nonatomic,strong) id json;

@end
