//
//  DRMaintainTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/4/7.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRMaintainTableViewCell.h"
#import "DRDateTool.h"

@interface DRMaintainTableViewCell ()

@property (nonatomic, weak) UIImageView * maintainImageView;
@property (nonatomic, weak) UILabel * titleLabel;
@property (nonatomic, weak) UILabel * detailLabel;
@property (nonatomic, weak) UILabel * readCountLabel;

@end

@implementation DRMaintainTableViewCell

+ (DRMaintainTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"MaintainTableViewCellId";
    DRMaintainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRMaintainTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    line.backgroundColor = DRWhiteLineColor;
    [self addSubview:line];
    
    //图片
    UIImageView * maintainImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, 12, 76, 76)];
    self.maintainImageView = maintainImageView;
    maintainImageView.contentMode = UIViewContentModeScaleAspectFill;
    maintainImageView.layer.masksToBounds = YES;
    [self addSubview:maintainImageView];
    
    //名称
    CGFloat titleLabelX = CGRectGetMaxX(self.maintainImageView.frame) + 10;
    CGFloat titleLabelW = screenWidth - titleLabelX - DRMargin;
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, maintainImageView.y, titleLabelW, 20)];
    self.titleLabel = titleLabel;
    titleLabel.textColor = DRBlackTextColor;
    titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    [self addSubview:titleLabel];
    
    //详情
    UILabel * detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, CGRectGetMaxY(titleLabel.frame), titleLabelW, 40)];
    self.detailLabel = detailLabel;
    detailLabel.numberOfLines = 0;
    [self addSubview:detailLabel];
    
    //阅读数量
    UILabel * readCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, CGRectGetMaxY(detailLabel.frame) + 3, titleLabelW, 15)];
    self.readCountLabel = readCountLabel;
    readCountLabel.textColor = DRGrayTextColor;
    readCountLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [self addSubview:readCountLabel];
}

- (void)setDic:(NSDictionary *)dic
{
    _dic = dic;
    NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@%@",baseUrl,dic[@"image"],smallPicUrl];
    [self.maintainImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];

    self.titleLabel.text = dic[@"title"];
    
    NSString * detailStr = dic[@"description"];
    NSMutableAttributedString * detailAttStr = [[NSMutableAttributedString alloc] initWithString:detailStr];
    [detailAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(26)] range:NSMakeRange(0, detailStr.length)];
    [detailAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(0, detailStr.length)];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;//行间距
    [detailAttStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, detailStr.length)];
    self.detailLabel.attributedText = detailAttStr;
    
    self.readCountLabel.text = [NSString stringWithFormat:@"%@人阅读", dic[@"hits"]];

}

@end
