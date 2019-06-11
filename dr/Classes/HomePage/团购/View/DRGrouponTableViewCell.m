//
//  DRGrouponTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/4/27.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRGrouponTableViewCell.h"
#import "DRGrouponProgressView.h"
#import "DRDateTool.h"

@interface DRGrouponTableViewCell ()

@property (nonatomic, weak) UIImageView *goodImageView;//商品图片
@property (nonatomic, weak) UILabel *goodNameLabel;//商品名称
@property (nonatomic, weak) UILabel *currentPriceLabel;//现价
@property (nonatomic, weak) UILabel *timeLabel;//倒计时
@property (nonatomic, weak) DRGrouponProgressView *progressView;//进度
@property (nonatomic, weak) UIButton *buyButton;//已参团

@end

@implementation DRGrouponTableViewCell

+ (DRGrouponTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"GrouponTableViewCellId";
    DRGrouponTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRGrouponTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return  cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupChildViews];
        // 监听通知
        [[NSNotificationCenter defaultCenter] addObserver:self    selector:@selector(countDownNotification) name:@"GroupCountDownNotification" object:nil];
    }
    return self;
}

- (void)setupChildViews
{
    //分割线
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 9)];
    lineView.backgroundColor = DRBackgroundColor;
    [self addSubview:lineView];
    
    //商品图片
    UIImageView * goodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, CGRectGetMaxY(lineView.frame) + 8, 113, 113)];
    self.goodImageView = goodImageView;
    goodImageView.contentMode = UIViewContentModeScaleAspectFill;
    goodImageView.layer.masksToBounds = YES;
    [self addSubview:goodImageView];
    
    //商品名称
    UILabel * goodNameLabel = [[UILabel alloc] init];
    self.goodNameLabel = goodNameLabel;
    goodNameLabel.numberOfLines = 2;
    [self addSubview:goodNameLabel];
    
    //现价
    UILabel * currentPriceLabel = [[UILabel alloc] init];
    self.currentPriceLabel = currentPriceLabel;
    currentPriceLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    currentPriceLabel.textColor = DRDefaultColor;
    [self addSubview:currentPriceLabel];

    
    //进度条
    DRGrouponProgressView *progressView = [[DRGrouponProgressView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.goodImageView.frame) + DRMargin, CGRectGetMaxY(goodImageView.frame) - 9, 80, 9)];
    self.progressView = progressView;
    [self addSubview:progressView];

    //倒计时
    UILabel * timeLabel = [[UILabel alloc] init];
    self.timeLabel = timeLabel;
    timeLabel.textColor = DRBlackTextColor;
    timeLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    [self addSubview:timeLabel];
    
    //已参团
    UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.buyButton = buyButton;
    CGFloat buyButtonW = 74;
    CGFloat buyButtonH = 24;
    self.buyButton.frame = CGRectMake(screenWidth - DRMargin - buyButtonW, CGRectGetMaxY(self.goodImageView.frame) - buyButtonH, buyButtonW, buyButtonH);
    buyButton.backgroundColor = DRDefaultColor;
    [buyButton setTitle:@"马上参团" forState:UIControlStateNormal];
    [buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    buyButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [buyButton addTarget:self action:@selector(buyButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    buyButton.layer.masksToBounds = YES;
    buyButton.layer.cornerRadius = 4;
    [self addSubview:buyButton];
}

- (void)buyButtonDidClick:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(grouponTableViewCell:joinGrouponButtonDidClick:)]) {
        [_delegate grouponTableViewCell:self joinGrouponButtonDidClick:button];
    }
}

- (void)countDownNotification
{
    //倒计时
    NSDateComponents * components = [DRDateTool getDeltaDateToTimestampg:_model.createTime + 2 * 24 * 60 * 60 * 1000];
    if (components.day > 0 || components.hour > 0 || components.minute > 0 || components.second > 0) {
        if (components.day > 0) {
            self.timeLabel.text = [NSString stringWithFormat:@"%ld天 %02ld:%02ld:%02ld", components.day, components.hour, components.minute, components.second];
        }else if (components.hour > 0)
        {
            self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", components.hour, components.minute, components.second];
        }
    }else
    {
        self.timeLabel.text = @"00:00:00";
    }
    
    CGSize timeLabelSize = [self.timeLabel.text sizeWithLabelFont:self.timeLabel.font];
    self.timeLabel.frame = CGRectMake(self.goodNameLabel.x, self.progressView.y - 10 - timeLabelSize.height, timeLabelSize.width, timeLabelSize.height);
}

- (void)setModel:(DRGrouponModel *)model
{
    _model = model;
    
    //图片
    NSString * urlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, _model.goods.spreadPics, smallPicUrl];
    [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    //名称
    NSString * goodNameStr = _model.goods.name;
    NSString * goodDetailStr = _model.goods.description_;
    NSMutableAttributedString * goodDetailAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  %@",goodNameStr,goodDetailStr]];
    [goodDetailAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(28)] range:NSMakeRange(0, goodDetailAttStr.length)];
    [goodDetailAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(0, goodDetailAttStr.length)];
    [goodDetailAttStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, goodNameStr.length)];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 3;//行间距
    [goodDetailAttStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, goodDetailAttStr.length)];
    self.goodNameLabel.attributedText = goodDetailAttStr;
    
    CGFloat goodNameLabelX = CGRectGetMaxX(self.goodImageView.frame) + DRMargin;
    CGFloat goodNameLabelW = screenWidth - goodNameLabelX - DRMargin;
    self.goodNameLabel.frame = CGRectMake(goodNameLabelX, self.goodImageView.y, goodNameLabelW, 40);

    //进度条
    self.progressView.progress = ([_model.payCount doubleValue] / [_model.successCount doubleValue]) * 100;
    
    //价格
    self.currentPriceLabel.text = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[_model.price doubleValue] / 100]];
    CGSize currentPriceLabelSize = [self.currentPriceLabel.text sizeWithLabelFont:self.currentPriceLabel.font];
    self.currentPriceLabel.frame = CGRectMake(self.goodNameLabel.x, self.progressView.y - 10 - self.timeLabel.font.lineHeight - 10 - currentPriceLabelSize.height, currentPriceLabelSize.width, currentPriceLabelSize.height);
    
}

@end
