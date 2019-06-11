//
//  DRAddMailTemplateViewController.m
//  dr
//
//  Created by 毛文豪 on 2018/4/10.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRAddMailTemplateViewController.h"
#import "DRDecimalTextField.h"

@interface DRAddMailTemplateViewController ()

@property (nonatomic, weak) UITextField * nameTF;
@property (nonatomic, weak) UITextField * numberTF1;
@property (nonatomic, weak) DRDecimalTextField * priceTF1;
@property (nonatomic, weak) UITextField * numberTF2;
@property (nonatomic, weak) DRDecimalTextField * priceTF2;
@property (nonatomic, weak) UITextField * countTF;

@end

@implementation DRAddMailTemplateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"添加运费模板";
    [self setupChilds];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    //设置运费
    UIView * mailTemplateView = [[UIView alloc] initWithFrame:CGRectMake(0, 9, screenWidth, 3 * DRCellH + 9 + 2 * DRCellH)];
    mailTemplateView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:mailTemplateView];
    
    UITextField * nameTF = [[UITextField alloc] init];
    self.nameTF = nameTF;
    nameTF.frame = CGRectMake(DRMargin, 0, screenWidth - 2 * DRMargin, DRCellH);
    nameTF.textColor = DRBlackTextColor;
    nameTF.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    nameTF.tintColor = DRDefaultColor;
    nameTF.placeholder = @"请输入模板名称";
    [mailTemplateView addSubview:nameTF];
    
    for (int i = 0; i < 2; i++) {
        CGFloat viewY = DRCellH + DRCellH * i;
        
        UITextField * numberTF = [[UITextField alloc] init];
        if (i == 0) {
            self.numberTF1 = numberTF;
        }else if (i == 1)
        {
            self.numberTF2 = numberTF;
        }
        numberTF.textColor = DRBlackTextColor;
        numberTF.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        numberTF.tintColor = DRDefaultColor;
        numberTF.borderStyle = UITextBorderStyleRoundedRect;
        numberTF.textAlignment = NSTextAlignmentCenter;
        numberTF.keyboardType = UIKeyboardTypeNumberPad;
        numberTF.frame = CGRectMake((screenWidth / 2 - 75) / 2, viewY + 7, 75, DRCellH - 2 * 7);
        [mailTemplateView addSubview:numberTF];
        
        UILabel * wordLabel1 = [[UILabel alloc] init];
        if (i == 0) {
            wordLabel1.text = @"低于";
        }else
        {
            wordLabel1.text = @"每增加";
        }
        wordLabel1.textColor = DRBlackTextColor;
        wordLabel1.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        CGSize wordLabel1Size = [wordLabel1.text sizeWithLabelFont:wordLabel1.font];
        wordLabel1.frame = CGRectMake(numberTF.x - wordLabel1Size.width - 5, viewY, wordLabel1Size.width, DRCellH);
        [mailTemplateView addSubview:wordLabel1];
        
        UILabel * wordLabel2 = [[UILabel alloc] init];
        wordLabel2.text = @"件";
        wordLabel2.textColor = DRBlackTextColor;
        wordLabel2.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        CGSize wordLabel2Size = [wordLabel2.text sizeWithLabelFont:wordLabel2.font];
        wordLabel2.frame = CGRectMake(CGRectGetMaxX(numberTF.frame) + 5, viewY, wordLabel2Size.width, DRCellH);
        [mailTemplateView addSubview:wordLabel2];
        
        DRDecimalTextField * priceTF = [[DRDecimalTextField alloc] init];
        if (i == 0) {
            self.priceTF1 = priceTF;
        }else if (i == 1)
        {
            self.priceTF2 = priceTF;
        }
        priceTF.textColor = DRBlackTextColor;
        priceTF.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        priceTF.tintColor = DRDefaultColor;
        priceTF.borderStyle = UITextBorderStyleRoundedRect;
        priceTF.textAlignment = NSTextAlignmentCenter;
        priceTF.frame = CGRectMake(screenWidth / 2 + (screenWidth / 2 - 75) / 2, viewY + 7, 75, DRCellH - 2 * 7);
        [mailTemplateView addSubview:priceTF];
        
        UILabel * wordLabel3 = [[UILabel alloc] init];
        if (i == 0) {
            wordLabel3.text = @"运费";
        }else
        {
            wordLabel3.text = @"运费加";
        }
        wordLabel3.textColor = DRBlackTextColor;
        wordLabel3.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        CGSize wordLabel3Size = [wordLabel3.text sizeWithLabelFont:wordLabel3.font];
        wordLabel3.frame = CGRectMake(priceTF.x - wordLabel3Size.width - 5, viewY, wordLabel3Size.width, DRCellH);
        [mailTemplateView addSubview:wordLabel3];
        
        UILabel * wordLabel4 = [[UILabel alloc] init];
        wordLabel4.text = @"元";
        wordLabel4.textColor = DRBlackTextColor;
        wordLabel4.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        CGSize wordLabel4Size = [wordLabel4.text sizeWithLabelFont:wordLabel4.font];
        wordLabel4.frame = CGRectMake(CGRectGetMaxX(priceTF.frame) + 5, viewY, wordLabel4Size.width, DRCellH);
        [mailTemplateView addSubview:wordLabel4];
        
        UIView * line1 = [[UIView alloc] initWithFrame:CGRectMake(screenWidth / 2, viewY, 1, DRCellH)];
        line1.backgroundColor = DRWhiteLineColor;
        [mailTemplateView addSubview:line1];
        
        UIView * line2 = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, screenWidth, 1)];
        line2.backgroundColor = DRWhiteLineColor;
        [mailTemplateView addSubview:line2];
    }
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 3 * DRCellH, screenWidth, 9)];
    lineView.backgroundColor = DRBackgroundColor;
    [mailTemplateView addSubview:lineView];
    
    //商品包邮条件
    UILabel * pinkageLabel = [[UILabel alloc] init];
    pinkageLabel.text = @"商品包邮条件（可选）";
    pinkageLabel.textColor = DRBlackTextColor;
    pinkageLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    CGSize pinkageLabelSize = [pinkageLabel.text sizeWithLabelFont:pinkageLabel.font];
    pinkageLabel.frame = CGRectMake(DRMargin, CGRectGetMaxY(lineView.frame), pinkageLabelSize.width, DRCellH);
    [mailTemplateView addSubview:pinkageLabel];
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(pinkageLabel.frame), screenWidth, 1)];
    line.backgroundColor = DRWhiteLineColor;
    [mailTemplateView addSubview:line];
    
    UILabel * countLabel = [[UILabel alloc] init];
    countLabel.text = @"笔购买满";
    countLabel.textColor = DRBlackTextColor;
    countLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    CGSize countLabelSize = [countLabel.text sizeWithLabelFont:countLabel.font];
    countLabel.frame = CGRectMake(DRMargin, CGRectGetMaxY(line.frame), countLabelSize.width, DRCellH);
    [mailTemplateView addSubview:countLabel];
    
    UILabel * countWordLabel = [[UILabel alloc] init];
    countWordLabel.text = @"件";
    countWordLabel.textColor = DRBlackTextColor;
    countWordLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    CGSize countWordLabelSize = [countWordLabel.text sizeWithLabelFont:countWordLabel.font];
    countWordLabel.frame = CGRectMake(screenWidth - DRMargin - countWordLabelSize.width, CGRectGetMaxY(line.frame), countWordLabelSize.width, DRCellH);
    [mailTemplateView addSubview:countWordLabel];
    
    UITextField * countTF = [[UITextField alloc] init];
    self.countTF = countTF;
    countTF.frame = CGRectMake(CGRectGetMaxX(countLabel.frame) + 5, CGRectGetMaxY(line.frame), countWordLabel.x - CGRectGetMaxX(countLabel.frame) - 5 * 2, DRCellH);
    countTF.textColor = DRBlackTextColor;
    countTF.textAlignment = NSTextAlignmentRight;
    countTF.keyboardType = UIKeyboardTypeNumberPad;
    countTF.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    countTF.tintColor = DRDefaultColor;
    countTF.placeholder = @"0";
    [mailTemplateView addSubview:countTF];
    
    //确定按钮
    UIButton * confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmBtn.frame = CGRectMake(DRMargin, CGRectGetMaxY(mailTemplateView.frame) + 29, screenWidth - 2 * DRMargin, 40);
    confirmBtn.backgroundColor = DRDefaultColor;
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [confirmBtn addTarget:self action:@selector(confirmBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    confirmBtn.layer.masksToBounds = YES;
    confirmBtn.layer.cornerRadius = confirmBtn.height / 2;
    [self.view addSubview:confirmBtn];
}

#pragma mark - 点击确定按钮
- (void)confirmBtnDidClick
{
    
    
}

@end
