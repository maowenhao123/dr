//
//  DRPublishWholesaleGoodView.h
//  dr
//
//  Created by 毛文豪 on 2018/4/10.
//  Copyright © 2018年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRDecimalTextField.h"

typedef void (^WholesaleGoodHightChangeBlock)(void);

@interface DRPublishWholesaleGoodView : UIView

@property (nonatomic, weak) UITextField * numberTF1;
@property (nonatomic, weak) DRDecimalTextField * priceTF1;
@property (nonatomic, weak) UITextField * numberTF2;
@property (nonatomic, weak) DRDecimalTextField * priceTF2;
@property (nonatomic, weak) UITextField * numberTF3;
@property (nonatomic, weak) DRDecimalTextField * priceTF3;
@property (nonatomic, weak) DRDecimalTextField * priceTF;
@property (nonatomic,weak) UITextField *countTF;
@property (nonatomic, weak) UISwitch *grouponSwitch;
@property (nonatomic, assign) int isGroup;
@property (copy, nonatomic) WholesaleGoodHightChangeBlock hightChangeBlock;

@end
