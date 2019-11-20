//
//  DRRecommendGoodCollectionViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/10/11.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRRecommendGoodCollectionViewCell.h"

@interface DRRecommendGoodCollectionViewCell ()

@property (nonatomic, weak) UIImageView * goodImageView;
@property (nonatomic, weak) UILabel * goodNameLabel;
@property (nonatomic, weak) UILabel * goodPriceLabel;
@property (nonatomic,weak) UIImageView * videoImageView;
@property (nonatomic, weak) UILabel * mailLabel;

@end

@implementation DRRecommendGoodCollectionViewCell

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
    CGFloat width = (screenWidth - 5) / 2;
    //图片
    UIImageView * goodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    self.goodImageView = goodImageView;
    goodImageView.contentMode = UIViewContentModeScaleAspectFill;
    goodImageView.layer.masksToBounds = YES;
    [self addSubview:goodImageView];
    
    //视频图片
    CGFloat videoImageViewWH = 37;
    UIImageView * videoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, goodImageView.height - 10 - videoImageViewWH, videoImageViewWH, videoImageViewWH)];
    self.videoImageView = videoImageView;
    videoImageView.image = [UIImage imageNamed:@"good_list_video_icon"];
    videoImageView.hidden = YES;
    [goodImageView addSubview:videoImageView];
    
    //名字
    UILabel * goodNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(goodImageView.frame) + 5, width - 2 * 10, 40)];
    self.goodNameLabel = goodNameLabel;
    goodNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    goodNameLabel.textColor = DRBlackTextColor;
    goodNameLabel.numberOfLines = 0;
    [self addSubview:goodNameLabel];
    
    //价格
    UILabel * goodPriceLabel = [[UILabel alloc] init];
    self.goodPriceLabel = goodPriceLabel;
    goodPriceLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    goodPriceLabel.textColor = DRRedTextColor;
    [self addSubview:goodPriceLabel];

    //邮费
    UILabel * mailLabel = [[UILabel alloc] init];
    self.mailLabel = mailLabel;
    mailLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    mailLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:mailLabel];
    
}
- (void)setModel:(DRGoodModel *)model
{
    _model = model;
    self.backgroundColor = [UIColor whiteColor];
    
    NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, _model.spreadPics, smallPicUrl];
    self.goodImageView.image = [UIImage imageNamed:@"placeholder"];
    [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    if (!DRStringIsEmpty(_model.video)) {
        self.videoImageView.hidden = NO;
    }else
    {
        self.videoImageView.hidden = YES;
    }
    //_model.description_
    NSMutableAttributedString * attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",_model.name, _model.description_]];
    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(28)] range:NSMakeRange(0, _model.name.length)];
    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(22)] range:NSMakeRange(_model.name.length, attStr.length - _model.name.length)];
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
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 3;//行间距
    [attStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attStr.length)];
    self.goodNameLabel.attributedText = attStr;
    
    if ([_model.sellType intValue] == 1) {//一物一拍/零售
        if ([DRTool showDiscountPriceWithGoodModel:_model]) {
            NSString * newPriceStr = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[_model.discountPrice doubleValue] / 100]];
            NSString * oldPriceStr = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[_model.price doubleValue] / 100]];
            NSString * priceStr = [NSString stringWithFormat:@"%@ %@", newPriceStr, oldPriceStr];
            NSMutableAttributedString * priceAttStr = [[NSMutableAttributedString alloc]initWithString:priceStr];
            [priceAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(30)] range:NSMakeRange(0, newPriceStr.length)];
            [priceAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(26)] range:NSMakeRange(priceStr.length - oldPriceStr.length, oldPriceStr.length)];
            [priceAttStr addAttribute:NSForegroundColorAttributeName value:DRRedTextColor range:NSMakeRange(0, newPriceStr.length)];
            [priceAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(priceStr.length - oldPriceStr.length, oldPriceStr.length)];
            [priceAttStr addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(priceStr.length - oldPriceStr.length, oldPriceStr.length)];
            self.goodPriceLabel.attributedText = priceAttStr;
        }else
        {
            if (_model.specifications.count > 0) {
                double minPrice = 0;
                double maxPrice = 0;
                for (DRGoodSpecificationModel * specificationModel in _model.specifications) {
                    NSInteger index = [_model.specifications indexOfObject:specificationModel];
                    int price = [specificationModel.price intValue];
                    if (index == 0) {
                        minPrice = price;
                    }else
                    {
                        minPrice = price < minPrice ? price : minPrice;
                    }
                    maxPrice = price < maxPrice ? maxPrice : price;
                }
                
                if (maxPrice == minPrice) {
                    self.goodPriceLabel.text = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:maxPrice / 100]];
                }else
                {
                    self.goodPriceLabel.text = [NSString stringWithFormat:@"¥%@ ~ ¥%@", [DRTool formatFloat:maxPrice / 100], [DRTool formatFloat:minPrice / 100]];
                }
            }else
            {
                self.goodPriceLabel.text = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[_model.price doubleValue] / 100]];
            }
        }
    }else//批发
    {
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
            self.goodPriceLabel.text = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:maxPrice / 100]];
        }else
        {
            self.goodPriceLabel.text = [NSString stringWithFormat:@"¥%@ ~ ¥%@", [DRTool formatFloat:maxPrice / 100], [DRTool formatFloat:minPrice / 100]];
        }
    }
    
    if ([_model.store.ruleMoney intValue] > 0) {
        self.mailLabel.text = [NSString stringWithFormat:@"满%@包邮", [DRTool formatFloat:[_model.store.ruleMoney doubleValue] / 100]];
        CGSize mailLabelSize = [self.mailLabel.text sizeWithLabelFont:self.mailLabel.font];
        self.mailLabel.frame = CGRectMake(self.width - 10 - mailLabelSize.width, CGRectGetMaxY(self.goodNameLabel.frame), mailLabelSize.width, 25);
    }else if ([_model.store.ruleMoney intValue] == 0 && [_model.store.ruleMoney intValue] == 0 && [_model.mailType intValue] == 0)
    {
        self.mailLabel.text = @"包邮";
        CGSize mailLabelSize = [self.mailLabel.text sizeWithLabelFont:self.mailLabel.font];
        self.mailLabel.frame = CGRectMake(self.width - 10 - mailLabelSize.width, CGRectGetMaxY(self.goodNameLabel.frame), mailLabelSize.width, 25);
    }else
    {
        self.mailLabel.text = @"";
        self.mailLabel.frame = CGRectZero;
    }
    
    if (!DRObjectIsEmpty(self.mailLabel.text)) {
        self.goodPriceLabel.frame = CGRectMake(10, CGRectGetMaxY(self.goodNameLabel.frame), self.mailLabel.x - 10, 25);
    }else
    {
        self.goodPriceLabel.frame = CGRectMake(10, CGRectGetMaxY(self.goodNameLabel.frame), self.width - 10 * 2, 25);
    }
}


@end
