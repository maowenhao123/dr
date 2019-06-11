//
//  DRShipmentUserInfoTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/6/28.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShipmentUserInfoTableViewCell.h"

@interface DRShipmentUserInfoTableViewCell ()

@property (nonatomic,weak) UILabel * nickNameLabel;
@property (nonatomic,weak) UIImageView * avatarImageView;
@property (nonatomic,weak) UILabel * goodCountLabel;//商品数量
@property (nonatomic, weak) UILabel *statusLabel;

@end

@implementation DRShipmentUserInfoTableViewCell

+ (DRShipmentUserInfoTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"ShipmentUserInfoTableViewCellId";
    DRShipmentUserInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRShipmentUserInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    line.backgroundColor = DRWhiteLineColor;
    [self addSubview:line];
    
    //头像
    UIImageView * avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, 7.5, 35, 35)];
    self.avatarImageView = avatarImageView;
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.layer.cornerRadius = avatarImageView.width / 2;
    [self addSubview:avatarImageView];
    
    //昵称
    UILabel * nickNameLabel = [[UILabel alloc] init];
    self.nickNameLabel = nickNameLabel;
    nickNameLabel.textColor = DRBlackTextColor;
    nickNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    [self addSubview:nickNameLabel];
    
    //商品数量
    UILabel * goodCountLabel = [[UILabel alloc] init];
    self.goodCountLabel = goodCountLabel;
    goodCountLabel.textColor = DRDefaultColor;
    goodCountLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [self addSubview:goodCountLabel];
    
    //状态
    UILabel * statusLabel = [[UILabel alloc] init];
    self.statusLabel = statusLabel;
    statusLabel.textColor = DRGrayTextColor;
    statusLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    [self addSubview:statusLabel];
    
    //提示
    UIView *promptView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, screenWidth, 30)];
    self.promptView = promptView;
    promptView.backgroundColor = DRBackgroundColor;
    [self addSubview:promptView];
    
    UILabel * promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 3, promptView.width - 2 * DRMargin, promptView.height - 3)];
    promptLabel.text = @"*点击头像发起聊天";
    promptLabel.font = [UIFont systemFontOfSize:DRGetFontSize(22)];
    promptLabel.textColor = DRRedTextColor;
    [promptView addSubview:promptLabel];
    
}
- (void)setShipmentGroupon:(DRShipmentGroupon *)shipmentGroupon
{
    _shipmentGroupon = shipmentGroupon;
    
    //赋值
    if (DRStringIsEmpty(_shipmentGroupon.user.nickName)) {
        self.nickNameLabel.text = _shipmentGroupon.user.loginName;
    }else
    {
        self.nickNameLabel.text = _shipmentGroupon.user.nickName;
    }
    
    self.goodCountLabel.text = [NSString stringWithFormat:@"x%@", [DRTool getNumber:_shipmentGroupon.count]];
    
    NSString * avatarUrlStr = [NSString stringWithFormat:@"%@%@",baseUrl, _shipmentGroupon.user.headImg];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrlStr] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
    
    int statusInt = [_shipmentGroupon.status intValue];
    if (statusInt == 30) {
        self.statusLabel.text = @"已完成";
    }else if (statusInt == 0) {
        self.statusLabel.text = @"待付款";
    }else if (statusInt == 5) {
        self.statusLabel.text = @"待成团";
    }else if (statusInt == 10) {
        self.statusLabel.text = @"待发货";
    }else if (statusInt == 20) {
        self.statusLabel.text = @"待收货";
    }else if (statusInt == -1) {
        self.statusLabel.text = @"已取消";
    }
    
    //frame
    CGSize nickNameLabelSize = [self.nickNameLabel.text sizeWithLabelFont:self.nickNameLabel.font];
    self.nickNameLabel.frame = CGRectMake(CGRectGetMaxX(self.avatarImageView.frame) + 5, 0, nickNameLabelSize.width, 50);
    
    CGSize goodCountLabelSize = [self.goodCountLabel.text sizeWithLabelFont:self.goodCountLabel.font];
    self.goodCountLabel.frame = CGRectMake(CGRectGetMaxX(self.nickNameLabel.frame) + 10, 0, goodCountLabelSize.width, 50);
    
    CGSize statusLabelSize = [self.statusLabel.text sizeWithLabelFont:self.statusLabel.font];
    self.statusLabel.frame = CGRectMake(screenWidth - DRMargin - statusLabelSize.width, 0, statusLabelSize.width, 50);
}


@end
