//
//  DRBankCardTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/4/20.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRBankCardTableViewCell.h"

@interface DRBankCardTableViewCell ()

@property (nonatomic, weak) UIView * backView;
@property (nonatomic, weak) UIImageView *logoImageView;
@property (nonatomic, weak) UILabel *bankLabel;
@property (nonatomic, weak) UILabel *cardTypeLabel;
@property (nonatomic, weak) UILabel *cardLabel;

@end

@implementation DRBankCardTableViewCell

+ (DRBankCardTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"BankCardTableViewCellId";
    DRBankCardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRBankCardTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    return  cell;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = DRBackgroundColor;
        [self setupChildViews];
    }
    return self;
}
- (void)setupChildViews
{
    //背景
    UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(10, 0, screenWidth - 20, 70)];
    self.backView = backView;
    backView.layer.masksToBounds = YES;
    backView.layer.cornerRadius = 4;
    [self.contentView addSubview:backView];
    
    //logo
    CGFloat logoWH = 30;
    UIImageView * logoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(DRMargin, 15, logoWH, logoWH)];
    self.logoImageView = logoImageView;
    [backView addSubview:logoImageView];
    
    //银行
    UILabel * bankLabel = [[UILabel alloc]initWithFrame:CGRectMake(67, 5, backView.width - 67, 20)];
    self.bankLabel = bankLabel;
    bankLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    bankLabel.textColor = [UIColor whiteColor];
    [backView addSubview: bankLabel];
    
    //银行卡类型
    UILabel * cardTypeLabel = [[UILabel alloc]initWithFrame:CGRectMake(bankLabel.x, 25,bankLabel.width, 15)];
    self.cardTypeLabel = cardTypeLabel;
    cardTypeLabel.text = @"储蓄卡";
    cardTypeLabel.font = [UIFont systemFontOfSize:DRGetFontSize(20)];
    cardTypeLabel.textColor = [UIColor whiteColor];
    [backView addSubview: cardTypeLabel];
    
    //银行卡号
    UILabel * cardLabel = [[UILabel alloc]initWithFrame:CGRectMake(bankLabel.x, 40, bankLabel.width, 25)];
    self.cardLabel = cardLabel;
    cardLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    cardLabel.textColor = [UIColor whiteColor];
    [backView addSubview:cardLabel];
}
- (void)setModel:(DRBankCardModel *)model
{
    _model = model;
    if ([UIImage imageNamed:_model.bankName]) {
        self.logoImageView.image = [UIImage imageNamed:_model.bankName];
    }else
    {
        self.logoImageView.image = [UIImage imageNamed:@"其他银行"];
    }
    self.bankLabel.text = _model.bankName;
    self.cardLabel.text = _model.cardNo;
    
    //设置背景颜色
    if ([_model.bankName isEqualToString:@"中国建设银行"]) {
        self.backView.backgroundColor = DRColor(85, 132, 222, 1);
    }else if ([_model.bankName isEqualToString:@"中国工商银行"])
    {
        self.backView.backgroundColor = DRColor(251, 100, 151, 1);
    }else if ([_model.bankName isEqualToString:@"招商银行"])
    {
        self.backView.backgroundColor = DRColor(236, 75, 65, 1);
    }else if ([_model.bankName isEqualToString:@"中国银行"])
    {
        self.backView.backgroundColor = DRColor(208, 48, 42, 1);
    }else if ([_model.bankName isEqualToString:@"中国农业银行"])
    {
        self.backView.backgroundColor = DRColor(23, 166, 146, 1);
    }else//其他银行
    {
        self.backView.backgroundColor = DRColor(166, 202, 228, 1);
    }
}

@end
