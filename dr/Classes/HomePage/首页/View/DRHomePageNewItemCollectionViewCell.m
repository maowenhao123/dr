//
//  DRHomePageNewItemCollectionViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/10/9.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRHomePageNewItemCollectionViewCell.h"

@interface DRHomePageNewItemCollectionViewCell ()

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UILabel *goodNameLabel;
@property (nonatomic, weak) UILabel *priceLabel;

@end

@implementation DRHomePageNewItemCollectionViewCell

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
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.width)];
    self.imageView = imageView;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.masksToBounds = YES;
    [self addSubview:imageView];
    
    //标题
    UILabel * goodNameLabel = [[UILabel alloc]init];
    self.goodNameLabel = goodNameLabel;
    goodNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [self addSubview:goodNameLabel];
    
    UILabel * priceLabel = [[UILabel alloc]init];
    self.priceLabel = priceLabel;
    priceLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    priceLabel.textColor = DRRedTextColor;
    priceLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:priceLabel];
}
- (void)setModel:(DRGoodModel *)model
{
    _model = model;
    
    NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@%@",baseUrl,_model.spreadPics,smallPicUrl];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    //_model.description_
    if (DRStringIsEmpty(_model.description_)) {
        self.goodNameLabel.text = _model.name;
    }else
    {
        if (iOS10) {
            NSMutableAttributedString * attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",_model.name, _model.description_]];
            [attStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, _model.name.length)];
            [attStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(_model.name.length, attStr.length - _model.name.length)];
            
            NSAttributedString * spaceAtttr = [[NSAttributedString alloc] initWithString:@" "];
            //团购图标
            if (_model.isGroup) {
                NSTextAttachment *grouponTextAttachment = [[NSTextAttachment alloc]initWithData:nil ofType:nil];
                grouponTextAttachment.bounds = CGRectMake(0, -3, 17, 14);
                grouponTextAttachment.image = [UIImage imageNamed:@"good_groupon_icon"];
                NSAttributedString *grouponTextAttStr = [NSAttributedString attributedStringWithAttachment:grouponTextAttachment];
                [attStr insertAttributedString:grouponTextAttStr atIndex:0];
                [attStr insertAttributedString:spaceAtttr atIndex:1];
            }
            
            //批发图标
            if ([_model.sellType intValue] == 2) {
                NSTextAttachment *wholeasleTextAttachment = [[NSTextAttachment alloc]initWithData:nil ofType:nil];
                wholeasleTextAttachment.bounds = CGRectMake(0, -3, 17, 14);
                wholeasleTextAttachment.image = [UIImage imageNamed:@"good_wholesale_icon"];
                NSAttributedString *wholeasleTextAttStr = [NSAttributedString attributedStringWithAttachment:wholeasleTextAttachment];
                [attStr insertAttributedString:wholeasleTextAttStr atIndex:0];
                [attStr insertAttributedString:spaceAtttr atIndex:1];
            }
            
            self.goodNameLabel.attributedText = attStr;
        }else
        {
            self.goodNameLabel.text = [NSString stringWithFormat:@"%@ %@",_model.name, _model.description_];
        }
    }
    
    if ([_model.sellType intValue] == 1) {//一物一拍/零售
        self.priceLabel.text = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[_model.price doubleValue] / 100]];
    } else {//批发
        double minPrice = 0;
        double maxPrice = 0;
        for (NSDictionary * wholesaleRuleDic in _model.wholesaleRule) {
            NSInteger index = [ _model.wholesaleRule indexOfObject:wholesaleRuleDic];
            int price = [wholesaleRuleDic[@"price"] intValue];
            if (index == 0) {
                minPrice = price;
            }else
            {
                minPrice = price < minPrice ? price : minPrice;
            }
            maxPrice = price < maxPrice ? maxPrice : price;
        }
        
        if (maxPrice == minPrice) {
            self.priceLabel.text = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:maxPrice / 100]];
        }else
        {
            self.priceLabel.text = [NSString stringWithFormat:@"¥%@ ~ ¥%@", [DRTool formatFloat:maxPrice / 100], [DRTool formatFloat:minPrice / 100]];
        }
    }
    self.goodNameLabel.frame = CGRectMake(0, CGRectGetMaxY(self.imageView.frame) + 7.5, self.width, 14);
    self.priceLabel.frame = CGRectMake(0, CGRectGetMaxY(self.goodNameLabel.frame) + 5, self.width, 12.5);
}


@end
