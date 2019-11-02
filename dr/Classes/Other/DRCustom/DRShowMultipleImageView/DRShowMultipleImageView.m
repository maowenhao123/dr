//
//  DRShowMultipleImageView.m
//  dr
//
//  Created by 毛文豪 on 2017/7/8.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShowMultipleImageView.h"

@interface DRShowMultipleImageView ()

@property (nonatomic,weak) UIImageView * lastImageView;

@end

@implementation DRShowMultipleImageView

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
    self.backgroundColor = [UIColor whiteColor];
    //标题
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 0, screenWidth -  2 * DRMargin, 35)];
    self.titleLabel = titleLabel;
    titleLabel.textColor = DRBlackTextColor;
    titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    [self addSubview:titleLabel];
}
- (void)setImagesWithImageUrlStrs:(NSArray *)imageUrlStrs
{
    //清除子试图
    for (UIView * subView in self.subviews) {
        if ([subView isKindOfClass:[UIImageView class]]) {
            [subView removeFromSuperview];
        }
    }
    
    CGFloat padding = 5;
    int maxCount = 4;
    CGFloat imageViewWH = (screenWidth - 2 * 2 * padding - (maxCount - 1) * padding) / maxCount;
    NSInteger count = imageUrlStrs.count;
    for (int i = 0; i < count; i++) {
        CGFloat imageViewX = 2 * padding + (imageViewWH + padding) * (i % maxCount);
        CGFloat imageViewY = CGRectGetMaxY(self.titleLabel.frame) + padding + (imageViewWH + padding) * (i / maxCount);
        NSString * imageUrlStr = [NSString stringWithFormat:@"%@", imageUrlStrs[i]];
        if (![imageUrlStr containsString:@"http"]) {
            imageUrlStr = [NSString stringWithFormat:@"%@%@", baseUrl, imageUrlStr];
        }
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageViewX, imageViewY, imageViewWH, imageViewWH)];
        imageView.tag = i;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.masksToBounds = YES;
        __weak typeof(self) wself = self;
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (!error) {
                [wself.images addObject:image];
            }
        }];
        [self addSubview:imageView];
        [self.imageViews addObject:imageView];
        self.lastImageView = imageView;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDidClick:)];
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:tap];
    }
    self.height = [self getViewHeight];
}
- (void)imageViewDidClick:(UIGestureRecognizer *)ges
{
    if (_delegate && [_delegate respondsToSelector:@selector(imageViewDidClickWithIndex:)]) {
        [_delegate imageViewDidClickWithIndex:ges.view.tag];
    }
}
- (CGFloat)getViewHeight
{
    return CGRectGetMaxY(self.lastImageView.frame) + 5;
}
#pragma mark - 初始化
- (NSMutableArray *)images
{
    if (!_images) {
        _images = [NSMutableArray array];
    }
    return _images;
}
- (NSMutableArray *)imageViews
{
    if (!_imageViews) {
        _imageViews = [NSMutableArray array];
    }
    return _imageViews;
}

@end
