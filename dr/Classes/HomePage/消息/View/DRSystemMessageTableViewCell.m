//
//  DRSystemMessageTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/10/20.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRSystemMessageTableViewCell.h"
#import "DRDateTool.h"

@interface DRSystemMessageTableViewCell ()

@property (nonatomic, weak) UILabel * timeLabel;
@property (nonatomic, weak) UIView * customContentView;
@property (nonatomic, weak) UIImageView *goodImageView;//商品图片
@property (nonatomic, weak) UILabel * titleLabel;
@property (nonatomic, weak) UILabel * detailLabel;
@property (nonatomic, strong) NSDictionary *typeDic;

@end

@implementation DRSystemMessageTableViewCell

+ (DRSystemMessageTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"MessageTableViewCellId";
    DRSystemMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRSystemMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = DRBackgroundColor;
    }
    return  cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self setupChildViews];
    }
    return self;
}

- (void)setupChildViews
{
    //时间
    UILabel * timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 0, screenWidth - 2 * DRMargin, 30)];
    self.timeLabel = timeLabel;
    timeLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    timeLabel.textColor = DRGrayTextColor;
    timeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:timeLabel];
    
    //内容
    UIView * customContentView = [[UIView alloc] initWithFrame:CGRectMake(DRMargin, 30, screenWidth - 2 * DRMargin, 0)];
    self.customContentView = customContentView;
    customContentView.backgroundColor = [UIColor whiteColor];
    customContentView.layer.masksToBounds = YES;
    customContentView.layer.cornerRadius = 3;
    [self addSubview:customContentView];
    
    //商品图片
    UIImageView * goodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, DRMargin, 80, 80)];
    self.goodImageView = goodImageView;
    goodImageView.contentMode = UIViewContentModeScaleAspectFill;
    goodImageView.layer.masksToBounds = YES;
    [customContentView addSubview:goodImageView];
    
    //标题
    UILabel * titleLabel = [[UILabel alloc] init];
    self.titleLabel = titleLabel;
    titleLabel.textColor = DRBlackTextColor;
    titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    titleLabel.numberOfLines = 0;
    [customContentView addSubview:titleLabel];

    //描述
    UILabel * detailLabel = [[UILabel alloc] init];
    self.detailLabel = detailLabel;
    detailLabel.textColor = DRBlackTextColor;
    detailLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    detailLabel.numberOfLines = 0;
    [customContentView addSubview:detailLabel];
}

- (void)setMessageModel:(EMMessage *)messageModel
{
    _messageModel = messageModel;
    
    /*
     //给卖家发消息
     Store_Delivery(101,"提醒卖家发货"),
     Store_Receipt(102,"提醒卖家买家已收货"),
     Store_Refund(103,"提醒卖家有退款申请"),
     Store_Group_Failed(105,"拼团失败撤单"),        //7天到期自动撤单
     
     //给买家发消息
     Buyer_Delivered(201,"提醒买家卖家已发货"),
     Buyer_Refund(202,"提醒买家退款已处理"),
     Buyer_Group_Finish(203,"提醒买家团购已成团"),
     Buyer_Group_Cancel(204,"提醒买家无货撤单"),        //无货撤单
     Buyer_Group_Failed(205,"提醒买家拼团失败撤单"); //7天到期自动撤单
    */
    
    //时间
    NSDictionary *ext = messageModel.ext;
    NSDictionary * data = [DRTool dictionaryWithJsonString:ext[@"data"]];
    if (self.systemMessageType == SystemMessage || self.systemMessageType == InteractiveMessage) {
        self.timeLabel.text = [NSString stringWithFormat:@"%@",[DRDateTool getTimeByTimestamp:[data[@"time"] longLongValue] format:@"yyyy-MM-dd HH:mm:ss"]];
    }else
    {
        self.timeLabel.text = [NSString stringWithFormat:@"%@",[DRDateTool getTimeByTimestamp:[messageModel.ext[@"time"] longLongValue] format:@"yyyy-MM-dd HH:mm:ss"]];
    }
    
    //图片
    NSString * urlStr;
    if (self.systemMessageType == SystemMessage) {
        urlStr = [NSString stringWithFormat:@"%@%@%@",baseUrl, data[@"picture"], smallPicUrl];
        [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }else if (self.systemMessageType == InteractiveMessage)
    {
        if ([ext[@"type"] isEqualToString:@"INTERACT_STORE_FOCUS"]) {
            self.goodImageView.image = [UIImage imageNamed:@"shop_attention"];
        }else if ([ext[@"type"] isEqualToString:@"INTERACT_USER_FOCUS"])
        {
            self.goodImageView.image = [UIImage imageNamed:@"user_attention"];
        }else
        {
            urlStr = [NSString stringWithFormat:@"%@%@%@",baseUrl, data[@"pic"], smallPicUrl];
            [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        }
    }else
    {
        urlStr = [NSString stringWithFormat:@"%@%@%@",baseUrl, messageModel.ext[@"goodsPic"], smallPicUrl];
        [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }
    
    //标题
    if (self.systemMessageType == SystemMessage) {
        self.titleLabel.text = data[@"name"];
    }else if (self.systemMessageType == InteractiveMessage)
    {
        self.titleLabel.text = data[@"title"];
    }else
    {
        NSString * type = [NSString stringWithFormat:@"%@", messageModel.ext[@"type"]];
        self.titleLabel.text = self.typeDic[type];
    }
    CGFloat titleLabelX = CGRectGetMaxX(self.goodImageView.frame) + DRMargin;
    CGSize titleLabelSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font maxSize:CGSizeMake(screenWidth - 2 * DRMargin - titleLabelX - DRMargin, CGFLOAT_MAX)];
    self.titleLabel.frame = CGRectMake(titleLabelX, self.goodImageView.y + 5, titleLabelSize.width, titleLabelSize.height);
    
    //内容
    EMMessageBody *messageBody = _messageModel.body;
    NSString *messageStr = ((EMTextMessageBody *)messageBody).text;
    NSMutableAttributedString *messageAttStr = [[NSMutableAttributedString alloc] initWithString:messageStr];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 3;//行间距
    [messageAttStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, messageAttStr.length)];
    [messageAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(26)] range:NSMakeRange(0, messageAttStr.length)];
    self.detailLabel.attributedText = messageAttStr;
    CGSize detailLabelize = [messageAttStr boundingRectWithSize:CGSizeMake(screenWidth - 2 * DRMargin - titleLabelX - DRMargin, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    CGFloat detailLabelH = detailLabelize.height;
    CGFloat detailLabelMinH = CGRectGetMaxY(self.goodImageView.frame) - CGRectGetMaxY(self.titleLabel.frame) - DRMargin;
    detailLabelH = detailLabelH < detailLabelMinH ?  detailLabelMinH : detailLabelH;
    self.detailLabel.frame = CGRectMake(titleLabelX, CGRectGetMaxY(self.titleLabel.frame) + DRMargin, detailLabelize.width, detailLabelH);
    
    CGFloat customContentViewH = CGRectGetMaxY(self.detailLabel.frame) + DRMargin;
    customContentViewH = customContentViewH < 100 ? 100 : customContentViewH;
    self.customContentView.height = customContentViewH;

}

- (NSDictionary *)typeDic
{
    if (!_typeDic) {
        _typeDic = @{
                     @"101":@"发货提醒",
                     @"102":@"收货通知",
                     @"103":@"退款申请",
                     @"105":@"团购撤单",
                     @"201":@"发货通知",
                     @"202":@"退款结果",
                     @"203":@"拼团成功",
                     @"204":@"无货撤单",
                     @"205":@"团购过期",
                     };
    }
    return _typeDic;
}
@end
