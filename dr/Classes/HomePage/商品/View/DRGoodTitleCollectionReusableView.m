//
//  DRGoodTitleCollectionReusableView.m
//  dr
//
//  Created by 毛文豪 on 2018/2/28.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRGoodTitleCollectionReusableView.h"

@interface DRGoodTitleCollectionReusableView ()

@property (nonatomic, weak) UILabel * titleLabel;

@end

@implementation DRGoodTitleCollectionReusableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 9)];
        lineView.backgroundColor = DRBackgroundColor;
        [self addSubview:lineView];
        
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 9, screenWidth, 80)];
        self.titleLabel = titleLabel;
        titleLabel.backgroundColor = [UIColor whiteColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:DRGetFontSize(34)];
        titleLabel.textColor = DRBlackTextColor;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}

@end
