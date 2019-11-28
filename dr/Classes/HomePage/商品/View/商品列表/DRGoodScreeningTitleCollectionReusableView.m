//
//  DRGoodScreeningTitleCollectionReusableView.m
//  dr
//
//  Created by 毛文豪 on 2018/2/28.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRGoodScreeningTitleCollectionReusableView.h"

@interface DRGoodScreeningTitleCollectionReusableView ()

@property (nonatomic, weak) UILabel *typeLabel;

@end

@implementation DRGoodScreeningTitleCollectionReusableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        //售卖方式
        UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 1)];
        line.backgroundColor = DRWhiteLineColor;
        [self addSubview:line];
        
        UILabel * typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 0, self.width - 2 * DRMargin, 50)];
        self.typeLabel = typeLabel;
        [self addSubview:typeLabel];
    }
    return self;
}

- (void)setTypeStr:(NSString *)typeStr
{
    _typeStr = typeStr;
    
    NSMutableAttributedString * typeAttStr = [[NSMutableAttributedString alloc] initWithString:typeStr];
    [typeAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(26)] range:NSMakeRange(0, typeAttStr.length)];
    [typeAttStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, typeAttStr.length)];
    [typeAttStr addAttribute:NSForegroundColorAttributeName value:DRColor(9, 99, 200, 1) range:[typeStr rangeOfString:@"（单选）"]];
    self.typeLabel.attributedText = typeAttStr;
    CGSize typeLabel1Size = [self.typeLabel.attributedText boundingRectWithSize:self.bounds.size options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    self.typeLabel.frame = CGRectMake(DRMargin, 0, typeLabel1Size.width, 50);
}

@end
