//
//  DRNoNetView.h
//  dr
//
//  Created by 毛文豪 on 2017/5/27.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DRNoNetViewDelegate  <NSObject>

- (void)reloadNetworkDataSource:(id)sender;

@end

@interface DRNoNetView : UIView

/**
 *  由代理控制器去执行刷新网络
 */
@property (nonatomic, strong) id<DRNoNetViewDelegate>delegate;

@end
