//
//  DRLoadHtmlFileViewController.h
//  dr
//
//  Created by 毛文豪 on 2017/5/8.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRBaseViewController.h"

@interface DRLoadHtmlFileViewController : DRBaseViewController

/*
 通过文件名请求数据
 */
- (instancetype)initWithFileName:(NSString *)fileName;
/*
 通过web请求数据
 */
- (instancetype)initWithWeb:(NSString *)web;

@property (nonatomic, assign) BOOL hiddenNav;

@end
