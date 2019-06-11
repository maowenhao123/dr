//
//  DRChooseRedPacketView.m
//  dr
//
//  Created by 毛文豪 on 2018/1/31.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRChooseRedPacketView.h"

@implementation DRChooseRedPacketView

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
    self.backgroundColor = [UIColor whiteColor];

    //分割线
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 9)];
    lineView.backgroundColor = DRBackgroundColor;
    [self addSubview:lineView];
    
    //使用红包
    UILabel * redPacketLabel = [[UILabel alloc] init];
    redPacketLabel.textColor = DRBlackTextColor;
    redPacketLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    redPacketLabel.text = @"使用红包";
    CGSize redPacketLabelSize = [redPacketLabel.text sizeWithLabelFont:redPacketLabel.font];
    redPacketLabel.frame = CGRectMake(DRMargin, CGRectGetMaxY(lineView.frame), redPacketLabelSize.width, self.height - CGRectGetMaxY(lineView.frame));
    [self addSubview:redPacketLabel];
    
    //角标
    CGFloat accessoryImageViewWH = 10;
    CGFloat accessoryImageViewY = CGRectGetMaxY(lineView.frame) + (self.height - CGRectGetMaxY(lineView.frame) - accessoryImageViewWH) / 2;
    UIImageView * accessoryImageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth - 5 - accessoryImageViewWH, accessoryImageViewY, accessoryImageViewWH, accessoryImageViewWH)];
    accessoryImageView.image = [UIImage imageNamed:@"big_black_accessory_icon"];
    [self addSubview:accessoryImageView];
    
    //可用红包
    UILabel * usableRedPacketLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(redPacketLabel.frame) + 10, CGRectGetMaxY(lineView.frame), accessoryImageView.x - CGRectGetMaxX(redPacketLabel.frame) - 10, self.height - CGRectGetMaxY(lineView.frame))];
    self.usableRedPacketLabel = usableRedPacketLabel;
    usableRedPacketLabel.text = @"0个红包可用";
    usableRedPacketLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    usableRedPacketLabel.textColor = DRDefaultColor;
    usableRedPacketLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:usableRedPacketLabel];
}

- (void)setCouponNumber:(NSInteger)couponNumber
{
    _couponNumber = couponNumber;
    self.usableRedPacketLabel.text = [NSString stringWithFormat:@"%ld个红包可用", _couponNumber];
}
@end
