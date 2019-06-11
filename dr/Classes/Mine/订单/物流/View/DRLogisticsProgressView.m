//
//  DRLogisticsProgressView.m
//  dr
//
//  Created by 毛文豪 on 2017/6/2.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRLogisticsProgressView.h"

@interface DRLogisticsProgressView ()

@property (nonatomic,weak) UIImageView *imageView1;
@property (nonatomic,weak) UILabel *label1;
@property (nonatomic,weak) UIView *line;
@property (nonatomic,weak) UIImageView *imageView2;
@property (nonatomic,weak) UILabel *label2;

@end

@implementation DRLogisticsProgressView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupChildViews];
    }
    return self;
}
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
    NSArray * texts = @[@"1.卖家发往平台", @"2.平台分发给买家"];
    CGFloat imageViewWH = 48;
    CGFloat imageViewY = 24;
    CGFloat lineW = 120;
    CGFloat padding = 10;
    CGFloat imageViewX1 = (screenWidth - 2 * imageViewWH - lineW) / 2;
    for (int i = 0; i < 2; i++) {
        UIImageView * imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(imageViewX1 + (lineW + imageViewWH) * i, imageViewY, imageViewWH, imageViewWH);
        [self addSubview:imageView];
        
        UILabel * label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
        label.text = texts[i];
        label.textColor = DRBlackTextColor;
        CGSize labelSize = [label.text sizeWithLabelFont:label.font];
        label.frame = CGRectMake(0, CGRectGetMaxY(imageView.frame) + padding, labelSize.width, labelSize.height);
        label.centerX = imageView.centerX;
        [self addSubview:label];
        
        UIView * line = [[UIView alloc] init];
        line.frame = CGRectMake(imageViewX1 + imageViewWH, 0, lineW, 1);
        line.centerY = imageView.centerY;
        [self addSubview:line];
        
        if (i == 0) {
            self.imageView1 = imageView;
            self.label1 = label;
        }else
        {
            self.imageView2 = imageView;
            self.label2 = label;
        }
        self.line = line;
    }
}
- (void)setProgressType:(int)progressType
{
    _progressType = progressType;
    
    if (_progressType == 2) {
        self.imageView1.image = [UIImage imageNamed:@"logistics_progress_green_1"];
        self.label1.textColor = DRDefaultColor;
        self.line.backgroundColor = DRDefaultColor;
        self.imageView2.image = [UIImage imageNamed:@"logistics_progress_green_2"];
        self.label2.textColor = DRDefaultColor;
    }else
    {
        self.imageView1.image = [UIImage imageNamed:@"logistics_progress_green_1"];
        self.label1.textColor = DRDefaultColor;
        self.line.backgroundColor = DRDefaultColor;
        self.imageView2.image = [UIImage imageNamed:@"logistics_progress_gray_2"];
        self.label2.textColor = DRGrayTextColor;
    }
}
@end
