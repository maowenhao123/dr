//
//  DRBillingScreeningViewController.m
//  dr
//
//  Created by 毛文豪 on 2018/5/21.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRBillingScreeningViewController.h"
#import "PGDatePickManager.h"
#import "NSDate+DR.h"
#import "DRDateTool.h"

@interface DRBillingScreeningViewController ()<PGDatePickerDelegate>

@property (nonatomic, weak) UITextField *monthTF;
@property (nonatomic, weak) UITextField *startDayTF;
@property (nonatomic, weak) UITextField *endDayTF;

@end

@implementation DRBillingScreeningViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"选择时间";
    [self setupChilds];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    if (!DRStringIsEmpty(self.monthStr)) {
        self.currentIndex = 0;
    }else if (!DRStringIsEmpty(self.beginTimeStr) && !DRStringIsEmpty(self.endTimeStr))
    {
        self.currentIndex = 1;
    }
    //添加btnTitle
    self.btnTitles = @[@"按月", @"按日"];
    //添加tableview
    CGFloat scrollViewH = screenHeight - statusBarH - navBarH - topBtnH;
    for(int i = 0; i < self.btnTitles.count; i++)
    {
        UIView * backView = [[UIView alloc] initWithFrame:CGRectMake(screenWidth * i, 0, screenWidth, scrollViewH)];
        backView.backgroundColor = DRBackgroundColor;
        [self.views addObject:backView];
        
        UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 9, screenWidth, DRCellH)];
        contentView.backgroundColor = [UIColor whiteColor];
        [backView addSubview:contentView];
        
        int count = 1;
        if (i == 1) {//按日
            count = 2;
            contentView.height = count * DRCellH;
        }
        
        for (int j = 0; j < count; j++) {
            UILabel * titleLabel = [[UILabel alloc] init];
            if (i == 0) {
                titleLabel.text = @"月份";
            }else
            {
                if (j == 0) {
                    titleLabel.text = @"开始时间";
                }else
                {
                    titleLabel.text = @"结束时间";
                }
            }
            titleLabel.textColor = DRBlackTextColor;
            titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
            CGSize titleLabelSize = [titleLabel.text sizeWithLabelFont:titleLabel.font];
            titleLabel.frame = CGRectMake(DRMargin, DRCellH * j, titleLabelSize.width, DRCellH);
            [contentView addSubview:titleLabel];
            
            UITextField * timeTF = [[UITextField alloc] init];
            if (i == 0) {
                self.monthTF = timeTF;
                if (!DRStringIsEmpty(self.monthStr)) {
                    self.monthTF.text = self.monthStr;
                }
            }else
            {
                if (j == 0) {
                    self.startDayTF = timeTF;
                    if (!DRStringIsEmpty(self.beginTimeStr)) {
                        self.startDayTF.text = self.beginTimeStr;
                    }
                }else
                {
                    self.endDayTF = timeTF;
                    if (!DRStringIsEmpty(self.endTimeStr)) {
                        self.endDayTF.text = self.endTimeStr;
                    }
                }
            }
            CGFloat timeTFX = CGRectGetMaxX(titleLabel.frame) + DRMargin;
            timeTF.frame = CGRectMake(timeTFX, DRCellH * j, screenWidth - timeTFX - DRMargin - 7, DRCellH);
            timeTF.textColor = DRBlackTextColor;
            timeTF.textAlignment = NSTextAlignmentRight;
            timeTF.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
            timeTF.tintColor = DRDefaultColor;
            timeTF.placeholder = @"请选择时间";
            timeTF.userInteractionEnabled = NO;
            [contentView addSubview:timeTF];
            
            UIButton *timeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            timeBtn.tag = j;
            timeBtn.frame = CGRectMake(timeTFX, DRCellH * j, screenWidth - timeTFX, DRCellH);
            [timeBtn setImageEdgeInsets:UIEdgeInsetsMake(0, timeBtn.width - DRMargin - 10, 0, 0)];
            [timeBtn setImage:[UIImage imageNamed:@"small_black_accessory_icon"] forState:UIControlStateNormal];
            [timeBtn addTarget:self action:@selector(timeButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:timeBtn];
            
            if (j == 1) {
                UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, DRCellH, screenWidth, 1)];
                line.backgroundColor = DRWhiteLineColor;
                [contentView addSubview:line];
            }
        }
        
        //确定按钮
        UIButton * confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat confirmBtnX = 15;
        CGFloat confirmBtnY = CGRectGetMaxY(contentView.frame) + 50;
        CGFloat confirmW = screenWidth - 2 * confirmBtnX;
        CGFloat confirmBtnH = 40;
        confirmBtn.frame = CGRectMake(confirmBtnX, confirmBtnY, confirmW, confirmBtnH);
        confirmBtn.backgroundColor = DRDefaultColor;
        [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        confirmBtn.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
        confirmBtn.layer.masksToBounds = YES;
        confirmBtn.layer.cornerRadius = confirmBtnH / 2;
        [confirmBtn addTarget:self action:@selector(confirmBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:confirmBtn];
    }
    
    //完成配置
    [super configurationComplete];
    [super topBtnClick:self.topBtns[self.currentIndex]];
}

- (void)timeButtonDidClick:(UIButton *)button
{
    PGDatePickManager *datePickManager = [[PGDatePickManager alloc]init];
    PGDatePicker *datePicker = datePickManager.datePicker;
    datePicker.tag = button.tag;
    datePicker.datePickerType = PGPickerViewType2;
    datePicker.maximumDate = [NSDate date];
    if (self.currentIndex == 0) {
        datePicker.minimumDate = [NSDate dateWithString:@"2017-01" format:@"yyyy-MM"];
        datePicker.datePickerMode = PGDatePickerModeYearAndMonth;
        if (!DRStringIsEmpty(self.monthStr)) {
            NSDate * date = [NSDate dateWithString:self.monthStr format:@"yyyy-MM"];
            [datePicker setDate:date];
        }
    }else
    {
        datePicker.minimumDate = [NSDate dateWithString:@"2017-01-01" format:@"yyyy-MM-dd"];
        datePicker.datePickerMode = PGDatePickerModeDate;
        if (button.tag == 0) {
            if (!DRStringIsEmpty(self.beginTimeStr)) {
                NSDate * date = [NSDate dateWithString:self.beginTimeStr format:@"yyyy-MM-dd"];
                [datePicker setDate:date];
            }
        }else if (button.tag == 1)
        {
            if (!DRStringIsEmpty(self.endTimeStr)) {
                NSDate * date = [NSDate dateWithString:self.endTimeStr format:@"yyyy-MM-dd"];
                [datePicker setDate:date];
            }
        }
    }
    datePicker.delegate = self;
    [self presentViewController:datePickManager animated:false completion:nil];
    
}

- (void)datePicker:(PGDatePicker *)datePicker didSelectDate:(NSDateComponents *)dateComponents
{
    if (self.currentIndex == 0) {
        NSString * timeStr = [NSString stringWithFormat:@"%ld-%02ld", dateComponents.year, dateComponents.month];
        self.monthTF.text = timeStr;
    }else
    {
        NSString * timeStr = [NSString stringWithFormat:@"%ld-%02ld-%02ld", dateComponents.year, dateComponents.month, dateComponents.day];
        if (datePicker.tag == 0) {
            self.startDayTF.text = timeStr;
        }else
        {
            self.endDayTF.text = timeStr;
        }
    }
}

- (void)confirmBtnDidClick
{
    if (self.currentIndex == 0) {
        if (DRStringIsEmpty(self.monthTF.text)) {
            [MBProgressHUD showError:@"您还未选择月份"];
            return;
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(billingScreeningByMonth:)]) {
            [_delegate billingScreeningByMonth:self.monthTF.text];
        }
    }else
    {
        if (DRStringIsEmpty(self.startDayTF.text)) {
            [MBProgressHUD showError:@"您还未选择开始时间"];
            return;
        }
        if (DRStringIsEmpty(self.endDayTF.text)) {
            [MBProgressHUD showError:@"您还未选择结束时间"];
            return;
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(billingScreeningByBeginTimeStr:endTimeStr:)]) {
            [_delegate billingScreeningByBeginTimeStr:self.startDayTF.text endTimeStr:self.endDayTF.text];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
