//
//  DRShopSearchView.h
//  dr
//
//  Created by 毛文豪 on 2017/5/25.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DRShopSearchView : UIView

@property (nonatomic, strong) NSMutableArray * dataArray;
- (void)searchShopWithKeyword:(NSString *)keyWord;

@end
