//
//  DRGoodItemView.m
//  dr
//
//  Created by dahe on 2019/8/7.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRGoodItemView.h"
#import "DRGoodDetailViewController.h"

@interface DRGoodItemView ()

@property (nonatomic, weak) UIImageView * goodImageView;
@property (nonatomic, weak) UILabel * goodNameLabel;
@property (nonatomic, weak) UILabel * goodPriceLabel;

@end

@implementation DRGoodItemView

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
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 10;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDidClick)];
    [self addGestureRecognizer:tap];
    
    CGFloat width = self.width;
    //图片
    UIImageView * goodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    self.goodImageView = goodImageView;
    goodImageView.contentMode = UIViewContentModeScaleAspectFill;
    goodImageView.layer.masksToBounds = YES;
    [self addSubview:goodImageView];
    
    //名字
    UILabel * goodNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(goodImageView.frame) + 5, width - 2 * 10, 40)];
    self.goodNameLabel = goodNameLabel;
    goodNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    goodNameLabel.textColor = DRBlackTextColor;
    goodNameLabel.numberOfLines = 0;
    [self addSubview:goodNameLabel];
    
    //价格
    UILabel * goodPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(goodNameLabel.frame), width - 2 * 10, 25)];
    self.goodPriceLabel = goodPriceLabel;
    goodPriceLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    goodPriceLabel.textColor = DRRedTextColor;
    [self addSubview:goodPriceLabel];
}

- (void)tapDidClick
{
    DRGoodDetailViewController * goodVC = [[DRGoodDetailViewController alloc] init];
    goodVC.goodId = self.model.id;
    [self.viewController.navigationController pushViewController:goodVC animated:YES];
}

- (void)setModel:(DRGoodModel *)model
{
    _model = model;
    
    NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, _model.spreadPics, smallPicUrl];
    self.goodImageView.image = [UIImage imageNamed:@"placeholder"];
    [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    //_model.description_
    NSMutableAttributedString * attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",_model.name, _model.description_]];
    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(28)] range:NSMakeRange(0, _model.name.length)];
    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(22)] range:NSMakeRange(_model.name.length, attStr.length - _model.name.length)];
    [attStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, _model.name.length)];
    [attStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(_model.name.length, attStr.length - _model.name.length)];
    
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
    } else//批发
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
}

@end
