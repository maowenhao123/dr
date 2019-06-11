//
//  YZSortButton.m
//  dr
//
//  Created by 毛文豪 on 2018/11/1.
//  Copyright © 2018 JG. All rights reserved.
//

#import "YZSortButton.h"
#import "UIButton+DR.h"

@interface YZSortButton ()

@property (nonatomic, assign) BOOL showImage;

@end

@implementation YZSortButton

- (instancetype)initWithShowImage:(BOOL)showImage
{
    self = [super init];
    if (self) {
        self.showImage = showImage;
        [self setupChilds];
    }
    return self;
}

- (void)setupChilds
{
    //按钮
    self.adjustsImageWhenHighlighted = NO;
    self.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [self setTitleColor:DRDefaultColor forState:UIControlStateNormal];
    if (self.showImage) {
        [self setImage:[UIImage imageNamed:@"sort_gray_gray"] forState:UIControlStateNormal];
    }
}

- (void)setText:(NSString *)text
{
    _text = text;
    [self setTitle:_text forState:UIControlStateNormal];
    if (self.showImage) {
        [self setButtonTitleWithImageAlignment:UIButtonTitleWithImageAlignmentRight imgTextDistance:1.5];
    }
}

- (void)setSortMode:(SortMode)sortMode
{
    _sortMode = sortMode;
    if (self.showImage) {
        if (_sortMode == SortModeAscending) {
            [self setImage:[UIImage imageNamed:@"sort_green_gray"] forState:UIControlStateNormal];
        }else if (_sortMode == SortModeDescending)
        {
            [self setImage:[UIImage imageNamed:@"sort_gray_green"] forState:UIControlStateNormal];
        }else if (_sortMode == SortModeNormal)
        {
            [self setImage:[UIImage imageNamed:@"sort_gray_gray"] forState:UIControlStateNormal];
        }
    }
}

@end
