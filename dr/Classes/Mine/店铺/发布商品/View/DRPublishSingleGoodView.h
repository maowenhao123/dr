//
//  DRPublishSingleGoodView.h
//  dr
//
//  Created by 毛文豪 on 2018/4/10.
//  Copyright © 2018年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRDecimalTextField.h"
#import "DRGoodSpecificationModel.h"

typedef void (^SingleGoodHightChangeBlock)(void);

@interface DRPublishSingleGoodView : UIView

@property (nonatomic, weak) UIButton * specificationButton;
@property (nonatomic, weak) DRDecimalTextField * priceTF;
@property (nonatomic, weak) UITextField * countTF;
@property (nonatomic, strong) NSMutableArray *specificationDataArray;

@property (copy, nonatomic) SingleGoodHightChangeBlock hightChangeBlock;

- (void)specificationButtonDidClick;

@end
