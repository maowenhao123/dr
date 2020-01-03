//
//  DRAddAddressViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/4/14.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRAddAddressViewController.h"
#import "DRChooseRegionPickerView.h"
#import "DRTextView.h"
#import "DRValidateTool.h"

@interface DRAddAddressViewController ()

@property (nonatomic, weak) UITextField * nameTF;
@property (nonatomic, weak) UITextField * phoneTF;
@property (nonatomic, weak) UITextField * regionTF;
@property (nonatomic, weak) DRTextView *addressDescriptionTV;
@property (nonatomic, weak) UISwitch *defaultSwitchView;
@property (nonatomic,copy) NSString *province;
@property (nonatomic,copy) NSString *city;

@end

@implementation DRAddAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.addressModel) {
        self.title = @"新增收货地址";
    }else
    {
        self.title = @"编辑收货地址";
    }
    [self setupChilds];
}

- (void)setupChilds
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveBarDidClick)];
    
    UIView * contentView = [[UIView alloc] init];
    contentView.frame = CGRectMake(0, 9, screenWidth, 3 * DRCellH + 100);
    contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];
    
    NSArray * titles = @[@"收货人",@"联系电话",@"所在地区"];
    NSArray * placeholders = @[@"请输入姓名",@"请输入电话",@"选择"];
    for (int i = 0; i < titles.count; i++) {
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, i * DRCellH, 70, DRCellH)];
        titleLabel.text = titles[i];
        titleLabel.textColor = DRBlackTextColor;
        titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        [contentView addSubview:titleLabel];
        
        UITextField * textField = [[UITextField alloc] init];
        textField.frame = CGRectMake(CGRectGetMaxX(titleLabel.frame), i * DRCellH, screenWidth - DRMargin - CGRectGetMaxX(titleLabel.frame), DRCellH);
        textField.tintColor = DRDefaultColor;
        textField.textColor = DRBlackTextColor;
        textField.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        textField.placeholder = placeholders[i];
        textField.textAlignment = NSTextAlignmentRight;
        [contentView addSubview:textField];
        if (i == 0) {
            self.nameTF = textField;
            textField.text = self.addressModel.name;
        }else if (i == 1)
        {
            self.phoneTF = textField;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.text = self.addressModel.phone;
        }else if (i == 2)
        {
            self.regionTF = textField;
            if (!DRStringIsEmpty(self.addressModel.province) && !DRStringIsEmpty(self.addressModel.city)) {
                textField.text = [NSString stringWithFormat:@"%@%@", self.addressModel.province, self.addressModel.city];
                self.province = self.addressModel.province;
                self.city = self.addressModel.city;
            }
            textField.userInteractionEnabled = NO;
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = textField.frame;
            [button addTarget:self action:@selector(selectPickerView:) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:button];
        }
        
        //分割线
        UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, (i + 1) * DRCellH, screenWidth, 1)];
        line.backgroundColor = DRWhiteLineColor;
        [contentView addSubview:line];
    }
    
    //详细地址
    DRTextView *addressDescriptionTV = [[DRTextView alloc] initWithFrame:CGRectMake(5, 3 * DRCellH, screenWidth - 2 * 5, 100)];
    self.addressDescriptionTV = addressDescriptionTV;
    if (!DRStringIsEmpty(self.addressModel.address)) {
        addressDescriptionTV.text = self.addressModel.address;
    }
    addressDescriptionTV.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    addressDescriptionTV.textColor = DRBlackTextColor;
    addressDescriptionTV.myPlaceholder = @"请输入详细地址";
    addressDescriptionTV.tintColor = DRDefaultColor;
    [contentView addSubview:addressDescriptionTV];
    
    //默认
    UIView * defaultView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(contentView.frame) + 9, screenWidth, DRCellH)];
    defaultView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:defaultView];
    
    UILabel * defaultTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 0, 100, DRCellH)];
    defaultTitleLabel.text = @"设为默认";
    defaultTitleLabel.textColor = DRBlackTextColor;
    defaultTitleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    [defaultView addSubview:defaultTitleLabel];
    
    //开关
    UISwitch *defaultSwitchView = [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    // 控件大小，不能设置frame，只能用缩放比例
    self.defaultSwitchView = defaultSwitchView;
    defaultSwitchView.on = [self.addressModel.defaultv boolValue];
    CGFloat scale = 0.8;
    defaultSwitchView.transform = CGAffineTransformMakeScale(scale, scale);
    defaultSwitchView.x = screenWidth - defaultSwitchView.width - DRMargin;
    defaultSwitchView.y = (DRCellH - defaultSwitchView.height * scale) / 2;
    defaultSwitchView.onTintColor = DRDefaultColor;
    [defaultView addSubview:defaultSwitchView];
}
- (void)selectPickerView:(UIButton *)button
{
    [self.view endEditing:YES];
    
    DRChooseRegionPickerView *regionPickerView = [[DRChooseRegionPickerView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    
    __weak typeof(self) wself = self;
    regionPickerView.completion = ^(NSString *provinceName,NSString *cityName) {
        wself.province = provinceName;
        wself.city = cityName;
        wself.regionTF.text = [NSString stringWithFormat:@"%@ %@",provinceName,cityName];
    };
  
    [regionPickerView showPickerWithProvinceName:self.province cityName:self.city];
    [self.navigationController.view addSubview:regionPickerView];
}
- (void)saveBarDidClick
{
    [self.view endEditing:YES];
    
    if (DRStringIsEmpty(self.nameTF.text))
    {
        [MBProgressHUD showError:@"您还未输入收货人"];
        return;
    }
    
    if (![DRValidateTool validateMobile:self.phoneTF.text])
    {
        [MBProgressHUD showError:@"您输入的联系电话格式不对"];
        return;
    }

    if (DRStringIsEmpty(self.regionTF.text))
    {
        [MBProgressHUD showError:@"您还未选择所在地区"];
        return;
    }
    
    if (DRStringIsEmpty(self.province) || DRStringIsEmpty(self.city))
    {
        [MBProgressHUD showError:@"请完善所在地区"];
        return;
    }

    if (DRStringIsEmpty(self.addressDescriptionTV.text))
    {
        [MBProgressHUD showError:@"您还未输入详细地址"];
        return;
    }
    if ([DRTool stringContainsEmoji:self.nameTF.text] || [DRTool stringContainsEmoji:self.addressDescriptionTV.text]) {
        [MBProgressHUD showError:@"请删掉特殊符号或表情后，再提交哦~"];
        return;
    }
    
    NSDictionary *bodyDic = [NSDictionary dictionary];
    if (self.addressModel) {
        bodyDic = @{
                    @"province":self.province,
                    @"city":self.city,
                    @"address":self.addressDescriptionTV.text,
                    @"defaultv":[NSNumber numberWithInt:self.defaultSwitchView.on],
                    @"phone":self.phoneTF.text,
                    @"name":self.nameTF.text,
                    @"id":self.addressModel.id
                    };
    }else
    {
        bodyDic = @{
                    @"province":self.province,
                    @"city":self.city,
                    @"address":self.addressDescriptionTV.text,
                    @"defaultv":[NSNumber numberWithInt:self.defaultSwitchView.on],
                    @"phone":self.phoneTF.text,
                    @"name":self.nameTF.text
                    };
    }
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U07",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            if (_delegate && [_delegate respondsToSelector:@selector(addAddressSuccess)]) {
                [_delegate addAddressSuccess];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        [MBProgressHUD hideHUDForView:self.view];
    }];
}

@end
