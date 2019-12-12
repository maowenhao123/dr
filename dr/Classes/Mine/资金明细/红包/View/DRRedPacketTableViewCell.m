//
//  DRRedPacketTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2018/1/25.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRRedPacketTableViewCell.h"
#import "DRDateTool.h"
#import "NSDate+DR.h"

@interface DRRedPacketTableViewCell ()

@property (nonatomic, weak) UIImageView *backImageView;
@property (nonatomic, weak) UILabel *balanceLabel;//余额
@property (nonatomic, weak) UILabel *titleLabel;//标题
@property (nonatomic, weak) UILabel *descriptionLabel;//描述
@property (nonatomic, weak) UILabel *timeLabel;//有效期
@property (nonatomic,weak) UIImageView * selectedImageView;//选中图标

@end

@implementation DRRedPacketTableViewCell

+ (DRRedPacketTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"RedPacketTableViewCellId";
    DRRedPacketTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRRedPacketTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = DRBackgroundColor;
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
    //背景
    UIImageView * backImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"voucher_backImage"]];
    self.backImageView = backImageView;
    backImageView.frame = CGRectMake(10, 0, screenWidth - 20, 75);
    [self addSubview:backImageView];
    
    //金额
    UILabel *balanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 10, 85, 35)];
    self.balanceLabel = balanceLabel;
    balanceLabel.centerY = backImageView.centerY;
    balanceLabel.textColor = UIColorFromRGB(0xde352f);
    balanceLabel.textAlignment = NSTextAlignmentCenter;
    [backImageView addSubview:balanceLabel];
    
    //标题
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 9, backImageView.width - 100 - 20 - 30, 18)];
    self.titleLabel = titleLabel;
    titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    titleLabel.textColor = UIColorFromRGB(0xb8aaaa);
    [backImageView addSubview:titleLabel];
    
    //描述
    UILabel * descriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 29, backImageView.width - 100 - 20 - 30, 18)];
    self.descriptionLabel = descriptionLabel;
    descriptionLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    descriptionLabel.textColor = UIColorFromRGB(0x696767);
    [backImageView addSubview:descriptionLabel];
    
    //有效期
    UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 49, backImageView.width - 100 - 20 - 30, 18)];
    self.timeLabel = timeLabel;
    timeLabel.font = [UIFont systemFontOfSize:DRGetFontSize(22)];
    timeLabel.textColor = UIColorFromRGB(0xd3d3d3);
    [backImageView addSubview:timeLabel];
    
    //选中图标
    CGFloat selectedImageViewWH = 20;
    UIImageView * selectedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shoppingcar_selected"]];
    self.selectedImageView = selectedImageView;
    selectedImageView.frame = CGRectMake(backImageView.width - 10 - selectedImageViewWH, (backImageView.height - selectedImageViewWH) / 2, selectedImageViewWH, selectedImageViewWH);
    selectedImageView.hidden = YES;
    [self addSubview:selectedImageView];
}

- (void)setCustomSelected:(BOOL)customSelected
{
    _customSelected = customSelected;
    
    self.selectedImageView.hidden = !_customSelected;
}

- (void)setIndex:(int)index
{
    _index = index;
    if (self.index == 1) {//可用
        self.balanceLabel.textColor = UIColorFromRGB(0xde352f);
        self.titleLabel.textColor = UIColorFromRGB(0xb8aaaa);
        self.descriptionLabel.textColor = UIColorFromRGB(0x696767);
        self.timeLabel.textColor = UIColorFromRGB(0xd3d3d3);
    }else
    {
        self.balanceLabel.textColor = DRGrayTextColor;
        self.titleLabel.textColor = DRGrayTextColor;
        self.descriptionLabel.textColor = DRGrayTextColor;
        self.timeLabel.textColor = DRGrayTextColor;
    }
}

- (void)setRedPacketModel:(DRRedPacketModel *)redPacketModel
{
    _redPacketModel = redPacketModel;
    
    //面值
    NSString * moneyStr = [NSString stringWithFormat:@"%@", [DRTool formatFloat:[_redPacketModel.coupon.couponValue doubleValue] / 100]];
    NSMutableAttributedString * moneyAttStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"￥%@",moneyStr]];
    [moneyAttStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:DRGetFontSize(50)] range:NSMakeRange(0, 1)];
    [moneyAttStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:DRGetFontSize(54)] range:NSMakeRange(1, moneyStr.length)];
    self.balanceLabel.attributedText = moneyAttStr;
    
    //标题
    self.titleLabel.text = _redPacketModel.coupon.couponName;
    
    //简介
    self.descriptionLabel.text = [NSString stringWithFormat:@"满%@元可用", [DRTool formatFloat:[_redPacketModel.coupon.minAmount doubleValue] / 100]];
    
    //时间
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: _redPacketModel.couponUser.useEndTime / 1000];
    NSString * endTimekStr = [date stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    self.timeLabel.text = [NSString stringWithFormat:@"有效期:%@", endTimekStr];
}


@end
