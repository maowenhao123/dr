//
//  DRGoodHtmlCollectionViewCell.m
//  dr
//
//  Created by dahe on 2020/1/13.
//  Copyright © 2020 JG. All rights reserved.
//

#import "DRGoodHtmlCollectionViewCell.h"

@interface DRGoodHtmlCollectionViewCell ()

@property (nonatomic, strong) UILabel *htmlLabel;

@end

@implementation DRGoodHtmlCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupChildViews];
    }
    return self;
}

- (void)setupChildViews
{
    [self addSubview:self.htmlLabel];
}

- (UILabel *)htmlLabel
{
    if (!_htmlLabel) {
        _htmlLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 0, screenWidth - DRMargin, 1)];
        _htmlLabel.numberOfLines = 0;
    }
    return _htmlLabel;
}

- (void)setGoodModel:(DRGoodModel *)goodModel
{
    _goodModel = goodModel;
    
    self.htmlLabel.attributedText = _goodModel.htmlAttStr;
    self.htmlLabel.height = _goodModel.htmlLabelH;
}


@end
