//
//  DRGoodScreeningPriceCollectionViewCell.h
//  dr
//
//  Created by 毛文豪 on 2018/11/1.
//  Copyright © 2018 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DRGoodScreeningPriceCollectionViewCell;
@protocol GoodScreeningPriceCollectionViewCellDelegate <NSObject>

- (void)goodScreeningPriceCollectionViewCell:(DRGoodScreeningPriceCollectionViewCell *)goodScreeningPriceCollectionViewCell textFieldDidEndEditing:(UITextField *)textField;

@end

@interface DRGoodScreeningPriceCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UITextField *minTF;
@property (nonatomic, strong) UITextField *maxTF;

/**
 协议
 */
@property (nonatomic, weak) id <GoodScreeningPriceCollectionViewCellDelegate> delegate;

@end

