//
//  DRHomePageSortItemCollectionViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/10/9.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRHomePageSortItemCollectionViewCell.h"

@interface DRHomePageSortItemCollectionViewCell ()

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UILabel *label;

@end

@implementation DRHomePageSortItemCollectionViewCell

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
    //图片
    CGFloat imageViewWH = 40;
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.width - imageViewWH) / 2, 9, imageViewWH, imageViewWH)];
    self.imageView = imageView;
    [self addSubview:imageView];
    
    //标题
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame), self.width, self.height - CGRectGetMaxY(imageView.frame))];
    self.label = label;
    label.font = [UIFont systemFontOfSize:DRGetFontSize(22)];
    label.textColor = DRBlackTextColor;
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
}
- (void)setStatus:(DRHomePageSortStatus *)status
{
    _status = status;
    
    NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@",baseUrl,_status.image];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
    
    self.label.text = _status.name;
}


@end
