//
//  DRBottomPickerView.m
//  dr
//
//  Created by 毛文豪 on 2017/4/13.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRBottomPickerView.h"

@interface DRBottomPickerView ()<UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, copy) NSString *selectedString;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation DRBottomPickerView

- (instancetype)initWithArray:(NSArray *)dataArray index:(NSInteger)index
{
    self = [super init];
    if (self) {
        self.dataArray = dataArray;
        
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = DRColor(0, 0, 0, 0.4);
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hide)];
        [self addGestureRecognizer:tap];
        
        UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(0, screenHeight, screenWidth, 255)];
        self.contentView = contentView;
        contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:contentView];
        
        //工具栏取消和选择
        UIButton * cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(10, 0, 40, 39);
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(32)];
        [cancelButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:cancelButton];
        
        UIButton * selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        selectButton.frame = CGRectMake(screenWidth - 50, 0, 40, 39);
        [selectButton setTitle:@"选择" forState:UIControlStateNormal];
        [selectButton setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
        selectButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(32)];
        [selectButton addTarget:self action:@selector(selectBarClicked) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:selectButton];
 
        //PickerView
        UIPickerView * pickView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 39, screenWidth, 216)];
        pickView.backgroundColor = [UIColor whiteColor];
        pickView.delegate = self;
        pickView.dataSource = self;
        [contentView addSubview:pickView];
        
        [pickView selectRow:index inComponent:0 animated:NO];
        self.selectedString = self.dataArray[index];
    }
    return self;
}
#pragma  mark - function
- (void)selectBarClicked
{
    NSInteger selectedIndex = [self.dataArray indexOfObject:self.selectedString];
    if (self.block) {
        self.block(selectedIndex);
    }
    [self hide];
}

- (void)show{
    UIView *topView = [KEY_WINDOW.subviews firstObject];
    [topView addSubview:self];
    
    [UIView animateWithDuration:DRAnimateDuration animations:^{
        self.contentView.y = screenHeight - 255;
    }];
}
- (void)hide{
    [UIView animateWithDuration:DRAnimateDuration animations:^{
        self.alpha = 0;
        self.contentView.y = screenHeight;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.dataArray.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return self.dataArray[row];
}
#pragma mark - UIPickerViewDelegate
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.textColor = DRBlackTextColor;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont systemFontOfSize:DRGetFontSize(32)]];
    }
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.selectedString = self.dataArray[row];
}


@end
