//
//  DRShipmentConfirmViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/5/31.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShipmentConfirmViewController.h"
#import "DRShipmentDeliveryPickerView.h"

@interface DRShipmentConfirmViewController ()

@property (nonatomic,weak) UIView * contentView;
@property (nonatomic,weak) UITextField *companyTF;
@property (nonatomic,weak) UITextField *numberTF;
@property (nonatomic, weak) DRShipmentDeliveryPickerView * deliveryPickerView;
@property (nonatomic,strong) NSDictionary *deliveryDic;

@end

@implementation DRShipmentConfirmViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"物流单号";
    [self setupChilds];
}
- (void)setupChilds
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirmBarDidClick)];
    
    UIView * contentView = [[UIView alloc] init];
    self.contentView = contentView;
    contentView.frame = CGRectMake(0, 9, screenWidth, 2 * DRCellH);
    contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];
    
    NSArray * titles = @[@"物流公司",@"物流单号"];
    NSArray * placeholders = @[@"选择",@"输入物流单号"];
    for (int i = 0; i < 2; i++) {
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, i * DRCellH, 70, DRCellH)];
        titleLabel.text = titles[i];
        titleLabel.textColor = DRBlackTextColor;
        titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
        [contentView addSubview:titleLabel];
        
        UITextField * textField = [[UITextField alloc] init];
        textField.frame = CGRectMake(CGRectGetMaxX(titleLabel.frame), i * DRCellH, screenWidth - DRMargin - CGRectGetMaxX(titleLabel.frame), DRCellH);
        textField.tintColor = DRDefaultColor;
        textField.textColor = DRBlackTextColor;
        textField.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
        textField.placeholder = placeholders[i];
        textField.textAlignment = NSTextAlignmentRight;
        [contentView addSubview:textField];
        if (i == 0) {
            self.companyTF = textField;
            textField.userInteractionEnabled = NO;
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = textField.frame;
            [button addTarget:self action:@selector(selectPickerView) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:button];
            
            //选择形态特点
            DRShipmentDeliveryPickerView * deliveryPickerView = [[DRShipmentDeliveryPickerView alloc] init];
            self.deliveryPickerView = deliveryPickerView;
            __weak typeof(self) wself = self;
            deliveryPickerView.block = ^(NSDictionary * deliveryDic){
                wself.deliveryDic = deliveryDic;
                wself.companyTF.text = deliveryDic[@"name"];
            };
        }else if (i == 1)
        {
            self.numberTF = textField;
        }
    }
    
    //分割线
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, DRCellH, screenWidth, 1)];
    line.backgroundColor = DRWhiteLineColor;
    [contentView addSubview:line];
}
- (void)selectPickerView
{
    [self.view endEditing:YES];
    [self.deliveryPickerView show];
}
- (void)confirmBarDidClick
{
    [self.view endEditing:YES];
    
    if (DRDictIsEmpty(self.deliveryDic)) {
        [MBProgressHUD showError:@"请选择物流公司"];
        return;
    }
    if (DRStringIsEmpty(self.numberTF.text)) {
        [MBProgressHUD showError:@"请输入物流单号"];
        return;
    }
    NSDictionary * delivery = @{
                                @"logisticsId":self.deliveryDic[@"id"],
                                @"logisticsNum":self.numberTF.text,
                                };
    
    NSArray * deliverys = @[delivery];
    NSDictionary *bodyDic = @{
                              @"deliverys":deliverys,
                              @"orderId":self.orderId
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"S22",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            [MBProgressHUD showSuccess:@"发货成功"];
            [self.navigationController popToViewController:self.navigationController.viewControllers[2] animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"shipmentSuccess" object:nil];
        }else
        {
            ShowErrorView;
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

@end
