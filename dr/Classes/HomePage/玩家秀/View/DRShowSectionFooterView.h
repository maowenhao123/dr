//
//  DRShowSectionFooterView.h
//  dr
//
//  Created by 毛文豪 on 2018/3/14.
//  Copyright © 2018年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRShowModel.h"

@interface DRShowSectionFooterView : UITableViewHeaderFooterView

+ (DRShowSectionFooterView *)headerFooterViewWithTableView:(UITableView *)talbeView;

@property (nonatomic,strong) DRShowModel * model;

@end
