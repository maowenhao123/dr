//
//  DRGoodScreeningPriceCollectionViewCell.m
//  dr
//
//  Created by 毛文豪 on 2018/11/1.
//  Copyright © 2018 JG. All rights reserved.
//

#import "DRGoodScreeningPriceCollectionViewCell.h"

@interface DRGoodScreeningPriceCollectionViewCell ()<UITextFieldDelegate>

@end

@implementation DRGoodScreeningPriceCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupChildViews];
    }
    return self;
}

- (void)setupChildViews
{
    CGFloat textFieldH = 35;
    CGFloat textFieldPadding1 = 15;
    CGFloat textFieldPadding2 = 45;
    CGFloat textFieldW = (self.width - 2 * textFieldPadding1 -  textFieldPadding2) / 2;
    NSArray *placeholders = @[@"最低价", @"最高价"];
    for (int i = 0; i < 2; i++) {
        UITextField * textField = [[UITextField alloc] init];
        if (i == 0) {
            self.minTF = textField;
        }else
        {
            self.maxTF = textField;
        }
        textField.frame = CGRectMake(textFieldPadding1 + (textFieldW + textFieldPadding2) * i, 0, textFieldW, textFieldH);
        textField.tag = i;
        textField.backgroundColor = DRBackgroundColor;
        textField.tintColor = DRDefaultColor;
        textField.textColor = DRBlackTextColor;
        textField.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
        textField.placeholder = placeholders[i];
        textField.delegate = self;
        textField.textAlignment = NSTextAlignmentCenter;
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.borderStyle = UITextBorderStyleNone;
        textField.layer.masksToBounds = YES;
        textField.layer.cornerRadius = 5;
        [self addSubview:textField];
    }
    
    UIView * line = [[UIView alloc] init];
    line.frame = CGRectMake(textFieldPadding1 + textFieldW + 8, 17, textFieldPadding2 - 2 * 8, 1);
    line.backgroundColor = DRWhiteLineColor;
    [self addSubview:line];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (_delegate && [_delegate respondsToSelector:@selector(goodScreeningPriceCollectionViewCell:textFieldDidEndEditing:)]) {
        [_delegate goodScreeningPriceCollectionViewCell:self textFieldDidEndEditing:textField];
    }
}

#pragma mark- UITextFieldDelegate
//限制金额输入框只能输入整数
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL isHaveDian = YES;
    if (textField.keyboardType == UIKeyboardTypeDecimalPad) {
        if ([textField.text rangeOfString:@"."].location==NSNotFound) {
            isHaveDian=NO;
        }
        if ([string length]>0)
        {
            unichar single=[string characterAtIndex:0];//当前输入的字符
            if ((single >='0' && single<='9') || single=='.')//数据格式正确
            {
                //首字母不能为0和小数点
                if([textField.text length]==0){
                    if(single == '.'){
                        //  [self alertView:@"亲，第一个数字不能为小数点"];
                        [textField.text stringByReplacingCharactersInRange:range withString:@""];
                        return NO;
                        
                    }
                }else if (textField.text.length == 1 && [textField.text isEqualToString:@"0"]){
                    if (single != '.') {
                        //     [self alertView:@"亲，第一个数字不能为0"];
                        [textField.text stringByReplacingCharactersInRange:range withString:@""];
                        return NO;
                        
                    }
                }
                if (single=='.')
                {
                    if(!isHaveDian)//text中还没有小数点
                    {
                        isHaveDian=YES;
                        return YES;
                    }else
                    {
                        //   [self alertView:@"亲，您已经输入过小数点了"];
                        [textField.text stringByReplacingCharactersInRange:range withString:@""];
                        return NO;
                    }
                }
                else
                {
                    if (isHaveDian)//存在小数点
                    {
                        //判断小数点的位数
                        NSRange ran=[textField.text rangeOfString:@"."];
                        NSInteger tt=range.location-ran.location;
                        if (tt <= 2){
                            return YES;
                        }else{
                            // [self alertView:@"亲，您最多输入两位小数"];
                            return NO;
                        }
                    }
                    else
                    {
                        return YES;
                    }
                }
            }else{//输入的数据格式不正确
                // [self alertView:@"亲，您输入的格式不正确"];
                [textField.text stringByReplacingCharactersInRange:range withString:@""];
                return NO;
            }
        }
        else
        {
            return YES;
        }
    }
    return YES;
}


@end
