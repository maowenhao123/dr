//
//  DRGiveVoucherTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2018/9/25.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRGiveVoucherTableViewCell.h"

@interface DRGiveVoucherTableViewCell ()

@property (nonatomic, weak) UIImageView *backImageView;
@property (nonatomic, weak) UILabel *balanceLabel;//余额
@property (nonatomic, weak) UILabel *titleLabel;//标题
@property (nonatomic, weak) UILabel * timeLabel;
@property (nonatomic, weak) UILabel *descriptionLabel;//描述

@end

@implementation DRGiveVoucherTableViewCell

//初始化一个cell
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"GiveVoucherTableViewCellId";
    DRGiveVoucherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRGiveVoucherTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
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
    //背景
    CGFloat bgImageViewW = scaleScreenWidth(320);
    CGFloat backImageViewW = scaleScreenWidth(269);
    CGFloat backImageViewX = (bgImageViewW - backImageViewW) / 2;
    CGFloat backImageViewH = 70;
    CGFloat backImageViewY = (85 - backImageViewH) / 2;
    UIImageView * backImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"give_voucher_item_bg"]];
    self.backImageView = backImageView;
    backImageView.userInteractionEnabled = YES;
    backImageView.frame = CGRectMake(backImageViewX, backImageViewY, backImageViewW, backImageViewH);
    [self addSubview:backImageView];

    //金额
    UILabel *balanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, scaleScreenWidth(60), backImageViewH)];
    self.balanceLabel = balanceLabel;
    balanceLabel.textColor = UIColorFromRGB(0xfd3736);
    balanceLabel.textAlignment = NSTextAlignmentCenter;
    [backImageView addSubview:balanceLabel];

    CGFloat labelX = scaleScreenWidth(60);
    CGFloat labelW = scaleScreenWidth(120);
    //标题
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(labelX, 5, labelW, 20)];
    self.titleLabel = titleLabel;
    titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    titleLabel.textColor = UIColorFromRGB(0x2b2b2b);
    [backImageView addSubview:titleLabel];

    //描述
    UILabel * descriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(labelX, 25, labelW, 15)];
    self.descriptionLabel = descriptionLabel;
    descriptionLabel.font = [UIFont systemFontOfSize:DRGetFontSize(20)];
    descriptionLabel.textColor = UIColorFromRGB(0xb4b4b4);
    [backImageView addSubview:descriptionLabel];

    //描述
    UILabel * timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, 40, labelW, 28)];
    self.timeLabel = timeLabel;
    timeLabel.font = [UIFont systemFontOfSize:DRGetFontSize(20)];
    timeLabel.textColor = UIColorFromRGB(0xb4b4b4);
    timeLabel.numberOfLines = 0;
    [backImageView addSubview:timeLabel];
    
    UIButton * getButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [getButton setTitle:@"已到账" forState:UIControlStateNormal];
    [getButton setTitleColor:UIColorFromRGB(0xfd3736) forState:UIControlStateNormal];
    getButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    getButton.titleLabel.numberOfLines = 0;
    getButton.frame = CGRectMake(180 * screenWidth / 375, 0, 89 * screenWidth / 375, backImageViewH);
    [backImageView addSubview:getButton];
}

- (void)setVoucherModel:(DRVoucherModel *)voucherModel
{
    _voucherModel = voucherModel;

    //面值
    NSString * moneyStr = [NSString stringWithFormat:@"%@", [DRTool formatFloat:[_voucherModel.money doubleValue]]];
    NSMutableAttributedString * moneyAttStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"￥%@",moneyStr]];
    [moneyAttStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:DRGetFontSize(28)] range:NSMakeRange(0, 1)];
    [moneyAttStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:DRGetFontSize(58)] range:NSMakeRange(1, moneyAttStr.length - 1)];
    self.balanceLabel.attributedText = moneyAttStr;
    self.titleLabel.text = _voucherModel.name;
    self.descriptionLabel.text = _voucherModel.ruleDesc;
    self.timeLabel.text = _voucherModel.expiredTimeDesc;
}

@end
