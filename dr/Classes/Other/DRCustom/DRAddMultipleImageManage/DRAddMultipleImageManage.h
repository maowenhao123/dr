//
//  DRAddMultipleImageManage.h
//  dr
//
//  Created by 毛文豪 on 2017/7/27.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AddMultipleImageManageDelegate <NSObject>

- (void)imageManageAddImages:(NSArray *)images;

@end

@interface DRAddMultipleImageManage : NSObject

@property (nonatomic, strong) UIViewController * viewController;

@property (nonatomic,assign) NSInteger maxImageCount;

@property (nonatomic, strong) NSMutableArray * images;

- (void)addImage;

@property (nonatomic, weak) id <AddMultipleImageManageDelegate> delegate;

@end
