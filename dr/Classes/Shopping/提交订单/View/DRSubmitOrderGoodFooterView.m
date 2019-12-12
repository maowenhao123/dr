//
//  DRSubmitOrderGoodFooterView.m
//  dr
//
//  Created by 毛文豪 on 2018/3/27.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRSubmitOrderGoodFooterView.h"
#import "UITextField+DRTextFieldSelected.h"

@interface DRSubmitOrderGoodFooterView ()<UITextFieldDelegate>

@property (nonatomic,weak) UILabel * mailTypeLabel;
@property (nonatomic,weak) UILabel * moneyLabel;
@property (nonatomic, weak) UITextField * remarkTF;

@end

@implementation DRSubmitOrderGoodFooterView

+ (DRSubmitOrderGoodFooterView *)headerFooterViewWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"SubmitOrderGoodFooterViewId";
    DRSubmitOrderGoodFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:ID];
    if(headerView == nil)
    {
        headerView = [[DRSubmitOrderGoodFooterView alloc] initWithReuseIdentifier:ID];
    }
    return headerView;
}
//初始化子控件
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithReuseIdentifier:reuseIdentifier])
    {
        [self setupChildViews];
    }
    return self;
}

- (void)setupChildViews
{
    UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 37 * 3)];
    footerView.backgroundColor = [UIColor whiteColor];
    [self addSubview:footerView];
    
    //商品价格
    UILabel * moneyTitleLabel = [[UILabel alloc] init];
    moneyTitleLabel.textColor = DRBlackTextColor;
    moneyTitleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    moneyTitleLabel.text = @"商品价格";
    CGSize moneyTitleLabelSize = [moneyTitleLabel.text sizeWithLabelFont:moneyTitleLabel.font];
    moneyTitleLabel.frame = CGRectMake(DRMargin, 0, moneyTitleLabelSize.width, 37);
    [footerView addSubview:moneyTitleLabel];
    
    UILabel * moneyLabel = [[UILabel alloc] init];
    self.moneyLabel = moneyLabel;
    moneyLabel.textColor = DRBlackTextColor;
    moneyLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    moneyLabel.textAlignment = NSTextAlignmentRight;
    [footerView addSubview:moneyLabel];
    
    //分割线
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 37, screenWidth, 1)];
    line1.backgroundColor = DRWhiteLineColor;
    [footerView addSubview:line1];
    
    //配送方式
    UILabel * mailTypeTitleLabel = [[UILabel alloc] init];
    mailTypeTitleLabel.textColor = DRBlackTextColor;
    mailTypeTitleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    mailTypeTitleLabel.text = @"邮费：";
    CGSize mailTypeTitleLabelSize = [mailTypeTitleLabel.text sizeWithLabelFont:mailTypeTitleLabel.font];
    mailTypeTitleLabel.frame = CGRectMake(DRMargin, 37, mailTypeTitleLabelSize.width, 37);
    [footerView addSubview:mailTypeTitleLabel];
    
    UILabel * mailTypeLabel = [[UILabel alloc] init];
    self.mailTypeLabel = mailTypeLabel;
    mailTypeLabel.textColor = DRBlackTextColor;
    mailTypeLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    [footerView addSubview:mailTypeLabel];
    
    //分割线
    UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 37 * 2, screenWidth, 1)];
    line2.backgroundColor = DRWhiteLineColor;
    [footerView addSubview:line2];
    
    UILabel * remarkLabel = [[UILabel alloc] init];
    remarkLabel.text = @"备注";
    remarkLabel.textColor = DRBlackTextColor;
    remarkLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    CGSize remarkLabelSize = [remarkLabel.text sizeWithLabelFont:remarkLabel.font];
    remarkLabel.frame = CGRectMake(DRMargin, 37 * 2, remarkLabelSize.width, 37);
    [footerView addSubview:remarkLabel];
    
    UITextField * remarkTF = [[UITextField alloc] init];
    self.remarkTF = remarkTF;
    CGFloat remarkTFX = CGRectGetMaxX(remarkLabel.frame) + DRMargin;
    remarkTF.frame = CGRectMake(remarkTFX, 37 * 2, screenWidth - remarkTFX - DRMargin - 7, 37);
    remarkTF.textColor = DRBlackTextColor;
    remarkTF.textAlignment = NSTextAlignmentRight;
    remarkTF.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    remarkTF.tintColor = DRDefaultColor;
    remarkTF.placeholder = @"请输入备注";
    remarkTF.delegate = self;
    [footerView addSubview:remarkTF];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:remarkTF];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.remarkTF == textField) {
        self.storeOrderModel.remarks = textField.text;
    }
}

- (void)textFieldDidChange:(NSNotification *)note
{
    UITextField *textField = note.object;
    if (DRObjectIsEmpty(textField.markedTextRange)) {
        NSMutableAttributedString * attStr = [[NSMutableAttributedString alloc] initWithString:textField.text];
        [attStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, attStr.length)];
        int maxCount = 100;
        if (attStr.length > maxCount) {
            [attStr addAttribute:NSForegroundColorAttributeName value:DRRedTextColor range:NSMakeRange(maxCount, attStr.length - maxCount)];
        }
        textField.attributedText = attStr;
    }
}

- (void)setStoreOrderModel:(DRStoreOrderModel *)storeOrderModel
{
    _storeOrderModel = storeOrderModel;
    
    int goodCount = 0;
    double ruleMoney = [_storeOrderModel.ruleMoney doubleValue] / 100;
    double priceCount = [_storeOrderModel.priceCount doubleValue] / 100;
    double freightMoney = [_storeOrderModel.freight doubleValue] / 100;
    for (DROrderItemDetailModel * orderItemDetailModel in _storeOrderModel.detail)
    {
        goodCount += [orderItemDetailModel.purchaseCount intValue];
    }
    self.moneyLabel.text = [NSString stringWithFormat:@"共%d件商品 金额：￥%@", goodCount, [DRTool formatFloat:priceCount]];
    CGSize moneyLabelSize = [self.moneyLabel.text sizeWithLabelFont:self.moneyLabel.font];
    self.moneyLabel.frame = CGRectMake(screenWidth - DRMargin - moneyLabelSize.width, 0, moneyLabelSize.width, 37);
    
    CGSize mailTypeLabelSize;
    if (ruleMoney > priceCount && freightMoney > 0) {//不包邮
        //_model.description_
        NSString *freightMoneyStr = [NSString stringWithFormat:@"￥%@", [DRTool formatFloat:freightMoney]];
        NSString *ruleMoneyStr = [NSString stringWithFormat:@"（满%@元包邮）", [DRTool formatFloat:ruleMoney]];
        NSMutableAttributedString * attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",freightMoneyStr, ruleMoneyStr]];
        [attStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:[attStr.string rangeOfString:freightMoneyStr]];
        [attStr addAttribute:NSForegroundColorAttributeName value:DRDefaultColor range:[attStr.string rangeOfString:ruleMoneyStr]];
        [attStr addAttribute:NSFontAttributeName value:self.mailTypeLabel.font range:NSMakeRange(0, attStr.string.length)];
        self.mailTypeLabel.attributedText = attStr;
        mailTypeLabelSize = [self.mailTypeLabel.attributedText boundingRectWithSize:CGSizeMake(screenWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    }else
    {
        self.mailTypeLabel.text = @"包邮";
        mailTypeLabelSize = [self.mailTypeLabel.text sizeWithLabelFont:self.mailTypeLabel.font];
    }
    self.mailTypeLabel.frame = CGRectMake(screenWidth - DRMargin - mailTypeLabelSize.width, 37, mailTypeLabelSize.width, 37);
    
    self.remarkTF.text = _storeOrderModel.remarks;
}

#pragma mark - dealloc
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.remarkTF];
}


@end
