//
//  DRSortGoodCollectionViewCell.m
//  dr
//
//  Created by apple on 2017/3/14.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRSortGoodCollectionViewCell.h"
#import "UIView+WebCache.h"

@interface DRSortGoodCollectionViewCell ()

@end

@implementation DRSortGoodCollectionViewCell

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
    CGFloat width = self.width;
    self.imageView = [[UIImageView alloc] init];
    self.imageView.frame = CGRectMake(0, 0, width, width);
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.image = [UIImage imageNamed:@"placeholder"];
    [self addSubview:self.imageView];
    
    UILabel * nameLabel = [[UILabel alloc] init];
    self.nameLabel = nameLabel;
    nameLabel.frame = CGRectMake(0, width, width, self.height - width);
    nameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    nameLabel.textColor = DRBlackTextColor;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:nameLabel];
}

- (void)setDic:(NSDictionary *)dic
{
    _dic = dic;
    self.nameLabel.text = dic[@"name"];
    NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@",baseUrl,dic[@"logo"]];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
}

@end
