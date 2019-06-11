//
//  DRChooseRegionPickerView.h
//  dr
//
//  Created by 毛文豪 on 2017/4/18.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DRChooseRegionPickerView : UIView


@property (nonatomic,copy) void (^completion)(NSString *provinceName,NSString *cityName);

- (void)showPickerWithProvinceName:(NSString *)provinceName cityName:(NSString *)cityName;//显示 省 市 县名

@end
