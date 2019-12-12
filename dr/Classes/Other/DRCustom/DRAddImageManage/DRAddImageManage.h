//
//  DRAddImageManage.h
//  dr
//
//  Created by 毛文豪 on 2017/4/17.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AddImageManageDelegate <NSObject>

@optional
- (void)imageManageCropImage:(UIImage *)image;

@end

@interface DRAddImageManage : NSObject

@property (nonatomic, strong) UIViewController * viewController;
@property (nonatomic, assign) NSInteger type;//0不编辑 1圆形 2方形
@property (nonatomic, assign) NSInteger tag;

- (void)addImage;

@property (nonatomic, weak) id <AddImageManageDelegate> delegate;

@end
