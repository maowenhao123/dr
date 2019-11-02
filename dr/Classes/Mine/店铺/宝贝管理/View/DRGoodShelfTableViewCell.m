//
//  DRGoodShelfTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/4/6.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRGoodShelfTableViewCell.h"
#import "DRDateTool.h"

@interface DRGoodShelfTableViewCell ()

@property (nonatomic, weak) UILabel * timeLabel;
@property (nonatomic,weak) UILabel *wholesaleLabel;
@property (nonatomic, weak) UIImageView *goodImageView;//商品图片
@property (nonatomic, weak) UILabel *goodNameLabel;//商品名称
@property (nonatomic, weak) UILabel *goodNumberLabel;//商品编号
@property (nonatomic, weak) UILabel *goodPriceLabel;//商品价格
@property (nonatomic,weak) UIImageView * accessoryImageView;
@property (nonatomic, weak) UIButton * button1;
@property (nonatomic, weak) UIButton * button2;
@property (nonatomic,weak) UILabel *rejectLabel;

@end

@implementation DRGoodShelfTableViewCell

+ (DRGoodShelfTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"GoodShelfTableViewCellId";
    DRGoodShelfTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRGoodShelfTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    return  cell;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupChildViews];
    }
    return self;
}
- (void)setupChildViews
{
    //分割线
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 9)];
    lineView.backgroundColor = DRBackgroundColor;
    [self addSubview:lineView];
    
    //时间
    UILabel * timeLabel = [[UILabel alloc] init];
    self.timeLabel = timeLabel;
    timeLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    timeLabel.textColor = DRGrayTextColor;
    [self addSubview:timeLabel];
    
    //批发
    CGFloat wholesaleLabelW = 50;
    CGFloat wholesaleLabelH = 25;
    UILabel * wholesaleLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth - DRMargin - wholesaleLabelW, CGRectGetMaxY(lineView.frame) + (35 - wholesaleLabelH) / 2, wholesaleLabelW, wholesaleLabelH)];
    self.wholesaleLabel = wholesaleLabel;
    wholesaleLabel.backgroundColor = DRDefaultColor;
    wholesaleLabel.text = @"批发";
    wholesaleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    wholesaleLabel.textColor = [UIColor whiteColor];
    wholesaleLabel.textAlignment = NSTextAlignmentCenter;
    wholesaleLabel.layer.masksToBounds = YES;
    wholesaleLabel.layer.cornerRadius = 3;
    [self addSubview:wholesaleLabel];
    
    //分割线
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 9 + 35, screenWidth, 1)];
    line1.backgroundColor = DRWhiteLineColor;
    [self addSubview:line1];
    
    //商品图片
    UIImageView * goodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, CGRectGetMaxY(line1.frame) + 12, 76, 76)];
    self.goodImageView = goodImageView;
    goodImageView.contentMode = UIViewContentModeScaleAspectFill;
    goodImageView.layer.masksToBounds = YES;
    [self addSubview:goodImageView];
    
    //商品名称
    UILabel * goodNameLabel = [[UILabel alloc] init];
    self.goodNameLabel = goodNameLabel;
    goodNameLabel.textColor = DRBlackTextColor;
    goodNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [self addSubview:goodNameLabel];

    //商品数量
    UILabel * goodNumberLabel = [[UILabel alloc] init];
    self.goodNumberLabel = goodNumberLabel;
    goodNumberLabel.textColor = DRBlackTextColor;
    goodNumberLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [self addSubview:goodNumberLabel];
    
    //商品价格
    UILabel * goodPriceLabel = [[UILabel alloc] init];
    self.goodPriceLabel = goodPriceLabel;
    goodPriceLabel.textColor = DRRedTextColor;
    goodPriceLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    [self addSubview:goodPriceLabel];
    
    //角标
    CGFloat accessoryImageViewWH = 15;
    UIImageView * accessoryImageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth - DRMargin - accessoryImageViewWH, 0, accessoryImageViewWH, accessoryImageViewWH)];
    self.accessoryImageView = accessoryImageView;
    accessoryImageView.centerY = goodImageView.centerY;
    accessoryImageView.image = [UIImage imageNamed:@"big_black_accessory_icon"];
    [self addSubview:accessoryImageView];
    
    //底部视图
    UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(goodImageView.frame) + 10, screenWidth, 40)];
    self.bottomView = bottomView;
    bottomView.backgroundColor = [UIColor whiteColor];
    [self addSubview:bottomView];
    
    //分割线
    UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    line2.backgroundColor = DRWhiteLineColor;
    [bottomView addSubview:line2];
    
    //按钮
    CGFloat buttonW = 79;
    CGFloat buttonH = 30;
    for (int i = 0; i < 2; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i == 0) {
            self.button1 = button;
        }else if (i == 1)
        {
            self.button2 = button;
        }
        button.frame = CGRectMake(screenWidth - (buttonW + DRMargin) * (i + 1), CGRectGetMaxY(line2.frame) + (40 - buttonH) / 2, buttonW, buttonH);
        button.hidden = YES;
        [button setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = button.height / 2;
        button.layer.borderColor = DRGrayTextColor.CGColor;
        button.layer.borderWidth = 1;
        [button addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:button];
    }
    
    //驳回原因
    UILabel * rejectLabel = [[UILabel alloc] init];
    self.rejectLabel = rejectLabel;
    rejectLabel.textColor = DRGrayTextColor;
    rejectLabel.font = [UIFont systemFontOfSize:DRGetFontSize(22)];
    rejectLabel.numberOfLines = 0;
    [bottomView addSubview:rejectLabel];
}

- (void)buttonDidClick:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(goodShelfTableViewCell:buttonDidClick:)]) {
        [_delegate goodShelfTableViewCell:self buttonDidClick:button];
    }
}

- (void)setModel:(DRGoodModel *)model
{
    _model = model;
   
    if (_model.type == 1) {
        self.bottomView.hidden = NO;
        self.button1.hidden = NO;
        [self.button1 setTitle:@"下架" forState:UIControlStateNormal];
        self.button2.hidden = NO;
        [self.button2 setTitle:@"编辑" forState:UIControlStateNormal];
        self.rejectLabel.hidden = YES;
        self.accessoryImageView.hidden = NO;
    }else if (_model.type == 2)
    {
        self.bottomView.hidden = YES;
        self.button1.hidden = YES;
        self.button2.hidden = YES;
        self.rejectLabel.hidden = YES;
        self.accessoryImageView.hidden = YES;
    }else if (_model.type == 3)
    {
        self.bottomView.hidden = NO;
        self.button1.hidden = NO;
        [self.button1 setTitle:@"删除" forState:UIControlStateNormal];
        self.button2.hidden = NO;
        [self.button2 setTitle:@"编辑" forState:UIControlStateNormal];
        self.rejectLabel.hidden = NO;
        self.accessoryImageView.hidden = NO;
    }else if (_model.type == 4)
    {
        self.bottomView.hidden = NO;
        self.button1.hidden = NO;
        [self.button1 setTitle:@"删除" forState:UIControlStateNormal];
        self.button2.hidden = NO;
        [self.button2 setTitle:@"编辑" forState:UIControlStateNormal];
        self.rejectLabel.hidden = YES;
        self.accessoryImageView.hidden = YES;
    }
    
    if ([_model.sellType intValue] == 1) {//一物一拍/零售
        self.wholesaleLabel.hidden = YES;
    } else {//批发
        self.wholesaleLabel.hidden = NO;
    }
    
    //赋值
    NSString * urlStr = [NSString stringWithFormat:@"%@%@%@",baseUrl,_model.spreadPics,smallPicUrl];
    [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    self.timeLabel.text = [NSString stringWithFormat:@"发布时间：%@",[DRDateTool getTimeByTimestamp:_model.createTime format:@"yyyy-MM-dd HH:mm:ss"]];
    
    self.goodNameLabel.text = [NSString stringWithFormat:@"名称：%@",_model.name];
    //plusCount
    if ([DRTool showDiscountPriceWithGoodModel:_model]) {
        self.goodNumberLabel.text = [NSString stringWithFormat:@"库存：%@",_model.activityStock];
    }else
    {
        self.goodNumberLabel.text = [NSString stringWithFormat:@"库存：%@",_model.plusCount];
    }
    
    if ([_model.sellType intValue] == 1) {//一物一拍/零售
        if ([DRTool showDiscountPriceWithGoodModel:_model]) {
            NSString * newPriceStr = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[_model.discountPrice doubleValue] / 100]];
            NSString * oldPriceStr = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[_model.price doubleValue] / 100]];
            NSString * priceStr = [NSString stringWithFormat:@"%@ %@", newPriceStr, oldPriceStr];
            NSMutableAttributedString * priceAttStr = [[NSMutableAttributedString alloc]initWithString:priceStr];
            [priceAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(26)] range:NSMakeRange(0, newPriceStr.length)];
            [priceAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(22)] range:NSMakeRange(priceStr.length - oldPriceStr.length, oldPriceStr.length)];
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
            self.goodPriceLabel.text = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:maxPrice / 100]];
        }else
        {
            self.goodPriceLabel.text = [NSString stringWithFormat:@"¥%@ ~ ¥%@", [DRTool formatFloat:maxPrice / 100], [DRTool formatFloat:minPrice / 100]];
        }
    }
    
    self.rejectLabel.text = _model.remark;
    CGSize rejectLabelSize = [self.rejectLabel.text sizeWithLabelFont:self.rejectLabel.font];
    CGFloat rejectLabelH = (rejectLabelSize.height + 15) < 35 ? 35 : (rejectLabelSize.height + 15);
    self.rejectLabel.frame = CGRectMake(DRMargin, 0, rejectLabelSize.width, rejectLabelH);
    
    //frame
    CGSize timeLabelSize = [self.timeLabel.text sizeWithLabelFont:self.timeLabel.font];
    self.timeLabel.frame = CGRectMake(DRMargin, 9, timeLabelSize.width, 35);

    CGFloat labelX = CGRectGetMaxX(self.goodImageView.frame) + 10;
    CGFloat labelW = screenWidth - labelX - DRMargin;
    CGSize goodNameLabelSize = [self.goodNameLabel.text sizeWithFont:self.goodNameLabel.font maxSize:CGSizeMake(labelW, 40)];
    self.goodNameLabel.frame = CGRectMake(labelX, self.goodImageView.y, labelW, goodNameLabelSize.height);
    
    CGSize goodNumberLabelSize = [self.goodNumberLabel.text sizeWithLabelFont:self.goodNumberLabel.font];
    self.goodNumberLabel.frame = CGRectMake(labelX, CGRectGetMaxY(self.goodNameLabel.frame) + 13, labelW, goodNumberLabelSize.height);
    self.goodNumberLabel.centerY = self.goodImageView.centerY;

    CGSize goodPriceLabelSize = [self.goodPriceLabel.text sizeWithLabelFont:self.goodPriceLabel.font];
    CGFloat goodPriceLabelY = CGRectGetMaxY(self.goodImageView.frame) - goodPriceLabelSize.height;
    self.goodPriceLabel.frame = CGRectMake(labelX, goodPriceLabelY, labelW, goodPriceLabelSize.height);
}


@end
