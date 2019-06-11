//
//  DRGoodSortPickerView.m
//  dr
//
//  Created by 毛文豪 on 2017/4/11.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRGoodSortPickerView.h"

@interface DRGoodSortPickerView ()<UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UIPickerView * pickView;
@property (nonatomic, strong) NSArray *sortArray1;
@property (nonatomic, strong) NSArray *sortArray2;
@property (nonatomic, assign) NSInteger selectedIndex1;
@property (nonatomic, assign) NSInteger selectedIndex2;
@property (nonatomic, strong) id json;

@end

@implementation DRGoodSortPickerView

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
                              @"cmd":@"B02",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            self.json = json;
            [self setSortArray1];
            [self setSortArray2WithRow1:0];
            [self.pickView reloadAllComponents];
            
            //默认选择多肉 景天科
            if ([self.sortArray1 containsObject:@"多肉植物"]) {
                self.selectedIndex1 = [self.sortArray1 indexOfObject:@"多肉植物"];
                NSArray * sortArr = self.json[@"list"];
                NSDictionary * sortDic_child = sortArr[self.selectedIndex1];
                NSArray * sortArr_child = sortDic_child[@"child"];
                NSMutableArray *sortMuArr = [NSMutableArray array];
                for (NSDictionary * sortDic in sortArr_child) {
                    [sortMuArr addObject:sortDic[@"name"]];
                }
                if ([sortMuArr containsObject:@"景天科"]) {
                    self.selectedIndex2 = [sortMuArr indexOfObject:@"景天科"];
                    if (self.block) {
                        self.block(sortArr[self.selectedIndex1], sortArr_child[self.selectedIndex2]);
                    }
                }
            }
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self];
        DRLog(@"error:%@",error);
    }];
}
//设置数据
- (void)setSortArray1
{
    NSArray * sortArr = self.json[@"list"];
    NSMutableArray *sortMuArr = [NSMutableArray array];
    for (NSDictionary * sortDic in sortArr) {
        [sortMuArr addObject:sortDic[@"name"]];
    }
    self.sortArray1 = [NSArray arrayWithArray:sortMuArr];
}
- (void)setSortArray2WithRow1:(NSInteger)row1
{
    NSArray * sortArr = self.json[@"list"];
    
    NSDictionary * sortDic_child = sortArr[row1];
    NSArray * sortArr_child = sortDic_child[@"child"];
    
    NSMutableArray *sortMuArr = [NSMutableArray array];
    for (NSDictionary * sortDic in sortArr_child) {
        [sortMuArr addObject:sortDic[@"name"]];
    }
    self.sortArray2 = [NSArray arrayWithArray:sortMuArr];
}
#pragma  mark - function
- (void)selectBarClicked
{
    NSArray * sortArr = self.json[@"list"];
    
    NSDictionary * sortDic_child = sortArr[self.selectedIndex1];
    NSArray * sortArr_child = sortDic_child[@"child"];
    
    if (self.block) {
        self.block(sortArr[self.selectedIndex1], sortArr_child[self.selectedIndex2]);
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
    return 2;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component == 0) {
        return self.sortArray1.count;
    }
    return self.sortArray2.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (component == 0) {
        return self.sortArray1[row];
    }
    return self.sortArray2[row];
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
    pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    //刷新数据
    if (component == 0) {
        [self setSortArray2WithRow1:row];
        self.selectedIndex2 = 0;
        [pickerView selectRow:0 inComponent:1 animated:NO];
        [pickerView reloadComponent:1];
        
        self.selectedIndex1 = row;
    }else if (component == 1)
    {
        self.selectedIndex2 = row;
    }
}
#pragma mark - 初始化
- (NSArray *)sortArray1
{
    if (!_sortArray1)
    {
        _sortArray1 = [NSArray array];
    }
    return _sortArray1;
}
- (NSArray *)sortArray2
{
    if (!_sortArray2)
    {
        _sortArray2 = [NSArray array];
    }
    return _sortArray2;
}

@end
