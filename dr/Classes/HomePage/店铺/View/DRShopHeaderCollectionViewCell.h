//
//  DRShopHeaderCollectionViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/10/9.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DRShopHeaderCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) DRShopModel * shopModel;

@property (nonatomic,weak) UIButton *attentionButton;

@property (nonatomic,weak) UIButton *chatButton;

@end
