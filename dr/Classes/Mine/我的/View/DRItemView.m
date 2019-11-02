//
//  DRItemView.m
//  dr
//
//  Created by 毛文豪 on 2017/6/19.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRItemView.h"
#import "UIImage+GIF.h"

@interface DRItemView ()

@property (nonatomic,weak) UIImageView * imageView;
@property (nonatomic,weak) UILabel * label;
@property (nonatomic,weak) UILabel * bageLabel;

@end

@implementation DRItemView

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
    UIImageView * imageView = [[UIImageView alloc] init];
    self.imageView = imageView;
    [self addSubview:imageView];
    
    UILabel * label = [[UILabel alloc] init];
    self.label = label;
    label.textColor = DRBlackTextColor;
    label.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    
    CGFloat labelH = label.font.lineHeight;
    CGFloat padding = 5;//文字与图片的间距
    CGFloat imageViewWH = 25;
    CGFloat imageViewY = (self.height - imageViewWH - labelH - padding) / 2;
    CGFloat imageViewX = (self.width - imageViewWH) / 2;
    imageView.frame = CGRectMake(imageViewX, imageViewY, imageViewWH, imageViewWH);
    label.frame = CGRectMake(0, CGRectGetMaxY(imageView.frame) + padding, self.width, labelH);
    
    CGFloat bageLabelWH = 13;
    UILabel * bageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, bageLabelWH, bageLabelWH)];
    self.bageLabel = bageLabel;
    bageLabel.backgroundColor = [UIColor whiteColor];
    bageLabel.textColor = DRViceColor;
    bageLabel.font = [UIFont systemFontOfSize:DRGetFontSize(18)];
    bageLabel.textAlignment = NSTextAlignmentCenter;
    bageLabel.layer.masksToBounds = YES;
    bageLabel.layer.cornerRadius = bageLabel.width / 2;
    bageLabel.layer.borderColor = DRViceColor.CGColor;
    bageLabel.layer.borderWidth = 1;
    bageLabel.center = CGPointMake(CGRectGetMaxX(imageView.frame) - 5, imageView.y + 5);
    bageLabel.hidden = YES;
    [self addSubview:bageLabel];
}
- (void)setImageName:(NSString *)imageName
{
    _imageName = imageName;
    if ([imageName isEqualToString:@"shop"]) {
        NSMutableArray * images = [NSMutableArray array];
        for (int i = 0; i < 5; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"shop_%d", i + 1]];
            [images addObject:image];
        }
        self.imageView.animationImages = images;
        self.imageView.animationDuration = 0.5;
        [self.imageView startAnimating];
    }else
    {
        self.imageView.image = [UIImage imageNamed:_imageName];
        [self.imageView stopAnimating];
    }
}
- (void)setText:(NSString *)text
{
    _text = text;
    
    self.label.text = _text;
}
- (void)setBage:(int)bage
{
    _bage = bage;
    
    if (_bage <= 0) {
        self.bageLabel.hidden = YES;
    }else{
        self.bageLabel.hidden = NO;
        
        self.bageLabel.text = [NSString stringWithFormat:@"%d", _bage];
    }
}
@end
