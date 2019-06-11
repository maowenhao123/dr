//
//  DRGrouponSearchView.h
//  dr
//
//  Created by 毛文豪 on 2017/10/24.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DRGrouponSearchView : UIView

@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic,weak) UITableView *tableView;
- (void)searchGrouponWithKeyword:(NSString *)keyWord;

@end
