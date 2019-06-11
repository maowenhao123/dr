//
//  DRShopNewsView.h
//  dr
//
//  Created by 毛文豪 on 2018/4/26.
//  Copyright © 2018年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ConfirmButtonDidClickBlock)();

@interface DRShopNewsView : UIView

@property (copy, nonatomic)ConfirmButtonDidClickBlock block;

@end
