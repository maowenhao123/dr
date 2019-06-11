//
//  DRMoneyDetailTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/4/5.
//  Copyright © 2017年 JG. All rights reserved.
//
#define cellH 35

#import "DRMoneyDetailTableViewCell.h"
#import "DRDateTool.h"
#import "NSDate+DR.h"

@interface DRMoneyDetailTableViewCell ()

@property (nonatomic, weak) UILabel * timeLabel;
@property (nonatomic, weak) UIImageView * iconImageView;
@property (nonatomic, weak) UILabel * typeLabel;
@property (nonatomic, weak) UILabel * moneyLabel;
@property (nonatomic, weak) UILabel * detailLabel;

@end

@implementation DRMoneyDetailTableViewCell

+ (DRMoneyDetailTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"MoneyDetailTableViewCellId";
    DRMoneyDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRMoneyDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    line.backgroundColor = DRWhiteLineColor;
    [self addSubview:line];
    
    //icon
    UIImageView * iconImageView = [[UIImageView alloc] init];
    self.iconImageView = iconImageView;
    [self addSubview:iconImageView];
    
    //类型
    UILabel * typeLabel = [[UILabel alloc] init];
    self.typeLabel = typeLabel;
    typeLabel.textColor = DRBlackTextColor;
    typeLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [self addSubview:typeLabel];
   
    //日期
    UILabel * timeLabel = [[UILabel alloc] init];
    self.timeLabel = timeLabel;
    timeLabel.textColor = DRGrayTextColor;
    timeLabel.font = [UIFont systemFontOfSize:DRGetFontSize(22)];
    [self addSubview:timeLabel];
    
    //金额
    UILabel * moneyLabel = [[UILabel alloc] init];
    self.moneyLabel = moneyLabel;
    moneyLabel.textColor = DRBlackTextColor;
    moneyLabel.font = [UIFont systemFontOfSize:DRGetFontSize(34)];
    [self addSubview:moneyLabel];
    
    //详情
    UILabel * detailLabel = [[UILabel alloc] init];
    self.detailLabel = detailLabel;
    detailLabel.text = @"详情>";
    detailLabel.textColor = DRGrayTextColor;
    detailLabel.font = [UIFont systemFontOfSize:DRGetFontSize(20)];
    CGSize detailLabellSize = [detailLabel.text sizeWithLabelFont:detailLabel.font];
    detailLabel.frame = CGRectMake(screenWidth - DRMargin - detailLabellSize.width, 55 - detailLabellSize.height - 7, detailLabellSize.width, detailLabellSize.height);
    [self addSubview:detailLabel];
}

- (void)setModel:(DRMoneyDetailModel *)model
{
    _model = model;
    
    self.timeLabel.text = [DRDateTool getTimeByTimestamp:_model.createTime format:@"MM-dd HH:mm"];

    //1 充值， 2 退款 ，3 卖货    11 消费， 12 提现， 13 退货
    self.detailLabel.hidden = YES;
    if ([_model.type intValue] == 1) {
        self.typeLabel.text = @"充值";
        self.iconImageView.image = [UIImage imageNamed:@"money_detail_recharge"];
    }else if ([_model.type intValue] == 2)
    {
        self.typeLabel.text = @"退款";
        self.iconImageView.image = [UIImage imageNamed:@"money_detail_drawback"];
    }else if ([_model.type intValue] == 3)
    {
        self.typeLabel.text = @"结算";
        self.iconImageView.image = [UIImage imageNamed:@"money_detail_account"];
        if (!DRObjectIsEmpty(_model.detail)) {
            self.detailLabel.hidden = NO;
        }
    }else if ([_model.type intValue] == 4)
    {
        self.typeLabel.text = @"无货撤单";
        self.iconImageView.image = [UIImage imageNamed:@"money_detail_revoke"];
    }else if ([_model.type intValue] == 5)
    {
        self.typeLabel.text = @"拼团失败撤单";
        self.iconImageView.image = [UIImage imageNamed:@"money_detail_revoke"];
    }else if ([_model.type intValue] == 10)
    {
        self.typeLabel.text = @"系统加款";
        self.iconImageView.image = [UIImage imageNamed:@"money_detail_system_add"];
    }else if ([_model.type intValue] == 11)
    {
        self.typeLabel.text = @"消费";
        self.iconImageView.image = [UIImage imageNamed:@"money_detail_buy"];
    }else if ([_model.type intValue] == 12)
    {
        self.typeLabel.text = @"提现";
        self.iconImageView.image = [UIImage imageNamed:@"money_detail_withdraw"];
    }else if ([_model.type intValue] == 13)
    {
        self.typeLabel.text = @"支付运费";
        self.iconImageView.image = [UIImage imageNamed:@"money_detail_freight"];
    }else if ([_model.type intValue] == 20)
    {
        self.typeLabel.text = @"系统扣款";
        self.iconImageView.image = [UIImage imageNamed:@"money_detail_system_minus"];
    }
    
    double moneyF = [_model.money doubleValue] / 100;
    if (moneyF > 0) {
        self.moneyLabel.textColor = DRDefaultColor;
        self.moneyLabel.text = [NSString stringWithFormat:@"+%@元", [DRTool formatFloat:moneyF]];
    }else
    {
        self.moneyLabel.textColor = DRBlackTextColor;
        self.moneyLabel.text = [NSString stringWithFormat:@"%@元", [DRTool formatFloat:moneyF]];
    }
    
    CGFloat iconImageViewWH = 35;
    self.iconImageView.frame = CGRectMake(18, (55 - iconImageViewWH) / 2, iconImageViewWH, iconImageViewWH);
    
    CGSize typeLabelSize = [self.typeLabel.text sizeWithLabelFont:self.typeLabel.font];
    self.typeLabel.frame = CGRectMake(CGRectGetMaxX(self.iconImageView.frame) + 15, 13, typeLabelSize.width, 17);
    
    CGSize timeLabelSize = [self.timeLabel.attributedText boundingRectWithSize:CGSizeMake(screenWidth, screenHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    self.timeLabel.frame = CGRectMake(CGRectGetMaxX(self.iconImageView.frame) + 15, 33, timeLabelSize.width, 15);
    
    CGSize moneyLabelSize = [self.moneyLabel.text sizeWithLabelFont:self.moneyLabel.font];
    if ([_model.type intValue] == 3 && !DRObjectIsEmpty(_model.detail))
    {
        self.moneyLabel.frame = CGRectMake(screenWidth - DRMargin - moneyLabelSize.width, (55 - moneyLabelSize.height) / 2 - 4, moneyLabelSize.width, moneyLabelSize.height);
    }else
    {
        self.moneyLabel.frame = CGRectMake(screenWidth - DRMargin - moneyLabelSize.width, 0, moneyLabelSize.width, 55);
    }
}

@end
