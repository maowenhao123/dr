//
//  DRShipmentDeliveryPickerView.m
//  dr
//
//  Created by 毛文豪 on 2017/5/31.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShipmentDeliveryPickerView.h"

@interface DRShipmentDeliveryPickerView ()<UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UIPickerView * pickView;
@property (nonatomic, strong) NSArray *deliveryArray;
@property (nonatomic, strong) NSDictionary * deliveryDic;

@end

@implementation DRShipmentDeliveryPickerView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidden = YES;
        self.frame = [UIScreen mainScreen].bounds;
        UIView *topView = [KEY_WINDOW.subviews firstObject];
        [topView addSubview:self];
        
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
        self.pickView = pickView;
        pickView.backgroundColor = [UIColor whiteColor];
        pickView.delegate = self;
        pickView.dataSource = self;
        [pickView selectRow:0 inComponent:0 animated:NO];
        [contentView addSubview:pickView];
        
        [self getData];
    }
    return self;
}
- (void)getData
{
    NSDictionary *bodyDic = @{
    };
    
    NSDictionary *headDic = @{
        @"digest":[DRTool getDigestByBodyDic:bodyDic],
        @"cmd":@"P15",
        @"userId":UserId,
    };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            self.deliveryArray = json[@"list"];
            self.deliveryDic = self.deliveryArray.firstObject;
            [self.pickView reloadAllComponents];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self];
        DRLog(@"error:%@",error);
    }];
}
#pragma  mark - function
- (void)selectBarClicked
{
    if (self.block) {
        self.block(self.deliveryDic);
    }
    [self hide];
}

- (void)show{
    self.hidden = NO;
    [UIView animateWithDuration:DRAnimateDuration animations:^{
        self.contentView.y = screenHeight - 255;
        self.backgroundColor = DRColor(0, 0, 0, 0.4);
    }];
}
- (void)hide{
    [UIView animateWithDuration:DRAnimateDuration animations:^{
        self.contentView.y = screenHeight;
        self.backgroundColor = DRColor(0, 0, 0, 0);
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

#pragma mark - UIPickerViewDataSource,UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.deliveryArray.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSDictionary * dic = self.deliveryArray[row];
    return [NSString stringWithFormat:@"%@", dic[@"name"]];
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
    //刷新数据
    self.deliveryDic = self.deliveryArray[row];
}
#pragma mark - 初始化
- (NSArray *)deliveryArray
{
    if (!_deliveryArray)
    {
        _deliveryArray = [NSArray array];
    }
    return _deliveryArray;
}
- (NSDictionary *)deliveryDic
{
    if (!_deliveryDic)
    {
        _deliveryDic = [NSDictionary dictionary];
    }
    return _deliveryDic;
}


@end
