//
//  DRGoodCommentCollectionViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/11/29.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRGoodCommentModel.h"

@interface DRGoodCommentCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) DRGoodCommentModel * model;

@property (nonatomic, weak) UIView * line;

@end
