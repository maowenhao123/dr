//
//  DRGoodScreeningCollectionViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/5/24.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRGoodScreeningCollectionViewCell.h"

@interface DRGoodScreeningCollectionViewCell ()

@property (nonatomic, weak) UILabel *label;

@end

@implementation DRGoodScreeningCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupChildViews];
    }
    return self;
}
- (void)setupChildViews
{
    //标题
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 84, 32.5)];
    self.label = label;
    label.backgroundColor = DRColor(240, 240, 240, 1);
    label.font = [UIFont systemFontOfSize:DRGetFontSize(22)];
    label.textColor = DRBlackTextColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.masksToBounds = YES;
    label.layer.cornerRadius = 4;
    [self.contentView addSubview:label];
}
- (void)setModel:(DRSortModel *)model
{
    _model = model;
    self.label.text = _model.name;
    if (_model.isSelected) {
        self.label.backgroundColor = DRDefaultColor;
        self.label.textColor = [UIColor whiteColor];
    }else
    {
        self.label.backgroundColor = DRColor(240, 240, 240, 1);
        self.label.textColor = DRBlackTextColor;
    }
}

@end
