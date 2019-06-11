//
//  DRWithdrawalBankCardTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/7/26.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRWithdrawalBankCardTableViewCell.h"

@interface DRWithdrawalBankCardTableViewCell ()

@property (nonatomic, weak) UIImageView *bankIcon;
@property (nonatomic, weak) UILabel * bankNameLabel;
@property (nonatomic, weak) UILabel *bankNumberLabel;
@property (nonatomic, weak) UIImageView *selectedIcon;

@end

@implementation DRWithdrawalBankCardTableViewCell

//初始化一个cell
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    NSString *ID = @"WithdrawalBankCardCellId";
    DRWithdrawalBankCardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRWithdrawalBankCardTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    return cell;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupChilds];
    }
    return self;
}
- (void)setupChilds
{
    //银行图标
    UIImageView * bankIcon = [[UIImageView alloc]init];
    self.bankIcon = bankIcon;
    [self addSubview:bankIcon];
    
    //银行名称
    UILabel * bankNameLabel = [[UILabel alloc]init];
    self.bankNameLabel = bankNameLabel;
    bankNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    bankNameLabel.textColor = DRGrayTextColor;
    [self addSubview:bankNameLabel];
    
    //银行卡号
    UILabel * bankNumberLabel = [[UILabel alloc]init];
    self.bankNumberLabel = bankNumberLabel;
    bankNumberLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    bankNumberLabel.textColor = DRGrayTextColor;
    bankNumberLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:bankNumberLabel];
    
    //选中图标
    UIImageView * selectedIcon = [[UIImageView alloc]init];
    self.selectedIcon = selectedIcon;
    [self addSubview:selectedIcon];
    
    //分割线
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    line.backgroundColor = DRWhiteLineColor;
    [self addSubview:line];
}
- (void)setBankCardModel:(DRBankCardModel *)bankCardModel
{
    _bankCardModel = bankCardModel;
    self.bankNameLabel.text = _bankCardModel.bankName;
    self.bankNumberLabel.text = _bankCardModel.cardNo;
    if (_bankCardModel.isSelected) {//被选中状态
        if ([UIImage imageNamed:_bankCardModel.bankName]) {
            self.bankIcon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@小", _bankCardModel.bankName]];
        }else
        {
            self.bankIcon.image = [UIImage imageNamed:@"其他银行小"];
        }
        self.bankNameLabel.textColor = DRDefaultColor;
        self.bankNumberLabel.textColor = DRDefaultColor;
        self.selectedIcon.image = [UIImage imageNamed:@"shoppingcar_selected"];
    }else
    {
        if ([UIImage imageNamed:_bankCardModel.bankName]) {
            self.bankIcon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@灰", _bankCardModel.bankName]];
        }else
        {
            self.bankIcon.image = [UIImage imageNamed:@"其他银行灰"];
        }
        self.bankNameLabel.textColor = DRGrayTextColor;
        self.bankNumberLabel.textColor = DRGrayTextColor;
        self.selectedIcon.image = [UIImage imageNamed:@"shoppingcar_not_selected"];
    }
    
    //frame
    CGFloat bankIconWH = 18;
    CGFloat bankIconY = (DRCellH - bankIconWH) / 2;
    self.bankIcon.frame = CGRectMake(DRMargin, bankIconY, bankIconWH, bankIconWH);
    
    CGSize bankNameSize = [self.bankNameLabel.text sizeWithLabelFont:self.bankNameLabel.font];
    self.bankNameLabel.frame = CGRectMake(CGRectGetMaxX(self.bankIcon.frame) + DRMargin, 0, bankNameSize.width, DRCellH);
    
    CGFloat selectedIconWH = 18;
    CGFloat selectedIconY = (DRCellH - selectedIconWH) / 2;
    self.selectedIcon.frame = CGRectMake(screenWidth - DRMargin - selectedIconWH, selectedIconY, selectedIconWH, selectedIconWH);
    
    CGSize bankNumberSize = [self.bankNumberLabel.text sizeWithLabelFont:self.bankNumberLabel.font];
    self.bankNumberLabel.frame = CGRectMake(self.selectedIcon.x - DRMargin - bankNumberSize.width, 0, bankNumberSize.width, DRCellH);
    
}

@end
