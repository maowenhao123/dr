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
@property (nonatomic, weak) UILabel *descriptionLabel;//描述
@property (nonatomic, weak) UIButton * getButton;

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
    CGFloat backImageViewH = 67;
    CGFloat backImageViewY = (85 - backImageViewH) / 2;
    UIImageView * backImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"give_voucher_item_bg"]];
    self.backImageView = backImageView;
    backImageView.userInteractionEnabled = YES;
    backImageView.frame = CGRectMake(backImageViewX, backImageViewY, backImageViewW, backImageViewH);
    [self addSubview:backImageView];

    //金额
    UILabel *balanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 70 * screenWidth / 375, backImageViewH)];
    self.balanceLabel = balanceLabel;
    balanceLabel.textColor = UIColorFromRGB(0xfd3736);
    balanceLabel.textAlignment = NSTextAlignmentCenter;
    [backImageView addSubview:balanceLabel];

    CGFloat labelX = scaleScreenWidth(70);
    CGFloat labelW = scaleScreenWidth(110);
    //标题
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(labelX, 10, labelW, 25)];
    self.titleLabel = titleLabel;
    titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    titleLabel.textColor = UIColorFromRGB(0x2b2b2b);
    [backImageView addSubview:titleLabel];

    //描述
    UILabel * descriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(labelX, 35, labelW, 20)];
    self.descriptionLabel = descriptionLabel;
    descriptionLabel.font = [UIFont systemFontOfSize:DRGetFontSize(22)];
    descriptionLabel.textColor = UIColorFromRGB(0xb4b4b4);
    [backImageView addSubview:descriptionLabel];

    UIButton * getButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.getButton = getButton;
    [getButton setTitle:@"领取" forState:UIControlStateNormal];
    [getButton setTitleColor:UIColorFromRGB(0xfd3736) forState:UIControlStateNormal];
    getButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    getButton.titleLabel.numberOfLines = 0;
    getButton.frame = CGRectMake(180 * screenWidth / 375, 0, 89 * screenWidth / 375, backImageViewH);
    [getButton addTarget:self action:@selector(getVoucherButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [backImageView addSubview:getButton];
}

- (void)getVoucherButtonDidClick:(UIButton *)button
{
    if ([_coupon.status isEqualToString:@"1"])//已领取
    {
        if (_delegate && [_delegate respondsToSelector:@selector(useVoucher)]) {
            [_delegate useVoucher];
        }
    }else if ([_coupon.status isEqualToString:@"0"])//待领取
    {
        [self getVoucher:button];
    }
}

- (void)getVoucher:(UIButton *)button
{
    if (!UserId) return;
    NSDictionary * bodyDic = @{
                               @"couponId": _coupon.id
                               };
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"L17",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            [MBProgressHUD showSuccess:@"领取成功"];
            if (_delegate && [_delegate respondsToSelector:@selector(giveVoucherTableViewCell:giveButtonDidClick:)]) {
                [_delegate giveVoucherTableViewCell:self giveButtonDidClick:button];
            }
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

- (void)setCoupon:(Coupon *)coupon
{
    _coupon = coupon;

    //面值
    NSString * moneyStr = [NSString stringWithFormat:@"%@", [DRTool formatFloat:[_coupon.couponValue doubleValue] / 100]];
    NSMutableAttributedString * moneyAttStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"￥%@",moneyStr]];
    [moneyAttStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:DRGetFontSize(28)] range:NSMakeRange(0, 1)];
    [moneyAttStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:DRGetFontSize(58)] range:NSMakeRange(1, moneyAttStr.length - 1)];
    self.balanceLabel.attributedText = moneyAttStr;
    self.titleLabel.text = _coupon.couponName;
    self.descriptionLabel.text = [NSString stringWithFormat:@"满%@可用", [DRTool formatFloat:[_coupon.minAmount doubleValue] / 100]];

    if ([_coupon.status isEqualToString:@"1"])//已领取
    {
        NSMutableAttributedString * attStr = [[NSMutableAttributedString alloc] initWithString:@"已领取\n去使用"];
        [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(24)] range:NSMakeRange(0, 3)];
        [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(30)] range:NSMakeRange(3, attStr.length - 3)];
        [attStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xb4b4b4) range:NSMakeRange(0, 3)];
        [attStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xfd3736) range:NSMakeRange(3, attStr.length - 3)];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:3];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        [attStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attStr.length)];
        [self.getButton setAttributedTitle:attStr forState:UIControlStateNormal];
    }else if ([_coupon.status isEqualToString:@"0"])//待领取
    {
        [self.getButton setTitle:@"领取" forState:UIControlStateNormal];
        [self.getButton setTitleColor:UIColorFromRGB(0xfd3736) forState:UIControlStateNormal];
        self.getButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    }
}

@end
