//
//  DRChooseRegionPickerView.m
//  dr
//
//  Created by 毛文豪 on 2017/4/18.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRChooseRegionPickerView.h"

#define AddressPickerViewHeight 216

@interface DRChooseRegionPickerView () <UIPickerViewDataSource,UIPickerViewDelegate>

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIPickerView *pickView;
@property (strong,nonatomic) NSArray *firstAry;//一级数据源
@property (strong,nonatomic) NSArray *secondAry;//二级数据源
@property (nonatomic,assign) NSInteger firstCurrentIndex;//第一行当前位置
@property (nonatomic,assign) NSInteger secondCurrentIndex;//第二行当前位置

@end


@implementation DRChooseRegionPickerView
- (instancetype)initWithFrame:(CGRect)frame {
    self =  [super initWithFrame:frame];
    if (self) {
        [self internalConfig];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self internalConfig];
    }
    return self;
}

- (void)internalConfig {

    self.backgroundColor = DRColor(0, 0, 0, 0.4);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [self addGestureRecognizer:tap];
    
    self.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.pickView];
    
    //工具栏取消和选择
    UIButton * cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(10, 0, 40, 39);
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(32)];
    [cancelButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:cancelButton];
    
    UIButton * selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    selectButton.frame = CGRectMake(screenWidth - 50, 0, 40, 39);
    [selectButton setTitle:@"选择" forState:UIControlStateNormal];
    [selectButton setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
    selectButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(32)];
    [selectButton addTarget:self action:@selector(completionButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:selectButton];
}

- (void)showPickerWithProvinceName:(NSString *)provinceName cityName:(NSString *)cityName
{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"address" ofType:@"plist"];
    _firstAry = [[NSArray alloc] initWithContentsOfFile:path];;
    
    if (provinceName.length > 0) {
        [_firstAry enumerateObjectsUsingBlock:^(NSDictionary *provinceDic, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([provinceDic[@"state"] isEqualToString:provinceName]) {
                _firstCurrentIndex = idx+1;
                _secondAry = provinceDic[@"cities"];
            }
        }];
    } else {
        _firstCurrentIndex = 0;
        _secondCurrentIndex = 0;
    }
    
    [_secondAry enumerateObjectsUsingBlock:^(NSDictionary *cityDic, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([cityDic[@"city"] isEqualToString:cityName]) {
            _secondCurrentIndex = idx+1;
        }
    }];
    
    [self.pickView reloadAllComponents];
    [self.pickView selectRow:_firstCurrentIndex inComponent:0 animated:NO];
    if (_secondAry.count > 0) {
        [self.pickView selectRow:_secondCurrentIndex inComponent:1 animated:NO];
    }
    
    [self show];
}

- (void)show {
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

#pragma mark - UIPickerViewDataSource,UIPickerViewDelegate

//选项默认值
- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated {
    return;
}

//设置列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    if (_secondAry.count > 0) {
        return 2;
    }
    
    _secondCurrentIndex = 0;
    return 1;
}

//返回数组总数
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return _firstAry.count + 1;
    }
    return _secondAry.count + 1;

}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        if (row > 0) {
            if (row - 1 < _firstAry.count) {
                NSDictionary *data = _firstAry[row - 1];
                //获取省
                NSString *str = data[@"state"];
                return str;
            }
        }
    } else if (component == 1) {
        if (row > 0) {
            if (row - 1 < _secondAry.count) {
                NSDictionary *data = _secondAry[row - 1];
                //获取市
                NSString *str = data[@"city"];
                return str;
            }
        }
    }
    return @"请选择";
}

//触发事件
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        _firstCurrentIndex = row;
        
        if (row > 0) {
            NSDictionary *dic = _firstAry[row - 1];
            _secondAry = dic[@"cities"];
            _secondCurrentIndex = 0;
            
        } else {
            _secondAry = nil;
            _secondCurrentIndex = 0;
        }
        
        [self.pickView reloadAllComponents];
        if (_secondAry.count > 0) {
            [self.pickView selectRow:_secondCurrentIndex inComponent:1 animated:NO];
        }
    } else if (component == 1) {
        _secondCurrentIndex = row;
    }
}

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

- (void)completionButtonAction {
    
    NSString *provinceName = @"";
    NSString *cityName = @"";
    
    if (_firstAry.count > 0) {
        if (_firstCurrentIndex > 0) {
            if (_firstCurrentIndex - 1 < _firstAry.count) {
                NSDictionary *data = _firstAry[_firstCurrentIndex - 1];
                //获取省
                provinceName = data[@"state"];
            }
        }
    }
    
    if (_secondAry.count > 0) {
        if (_secondCurrentIndex > 0) {
            if (_secondCurrentIndex - 1 < _secondAry.count) {
                NSDictionary *data = _secondAry[_secondCurrentIndex - 1];
                //获取市
                cityName = data[@"city"];
            }
        }
    }
    
    if (_completion) {
        _completion(provinceName,cityName);
    }
    [self hide];
}

- (void)cancleButtonAction {
    [self hide];
}

#pragma mark - 懒加载
- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, screenHeight, screenWidth, 255)];
        _contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_contentView];
    }
    return _contentView;
}
- (UIPickerView*)pickView {
    if (!_pickView) {
        _pickView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 39, self.frame.size.width, AddressPickerViewHeight)];
        _pickView.delegate = self;
        _pickView.dataSource = self;
        _pickView.backgroundColor = [UIColor whiteColor];
        [_pickView selectRow:0 inComponent:0 animated:NO];
    }
    return _pickView;
}

@end

