//
//  DRShoppingCarRecommendTableViewCell.h
//  dr
//
//  Created by dahe on 2019/8/7.
//  Copyright © 2019 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DRShoppingCarRecommendTableViewCell : UITableViewCell

+ (DRShoppingCarRecommendTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic,strong) DRGoodModel *leftModel;
@property (nonatomic, strong, nullable) DRGoodModel *rightModel;

@end

NS_ASSUME_NONNULL_END
