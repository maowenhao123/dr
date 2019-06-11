//
//  DRGoodSortPickerView.h
//  dr
//
//  Created by 毛文豪 on 2017/4/11.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^GoodSortChoicePickerViewBlock)(NSDictionary * categoryDic, NSDictionary * subjectDic);

@interface DRGoodSortPickerView : UIView

@property (copy, nonatomic)GoodSortChoicePickerViewBlock block;

- (void)show;

@end
