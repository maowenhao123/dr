//
//  DRChangeShopAddressViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/5/24.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRChangeShopAddressViewController.h"
#import "DRTextView.h"

@interface DRChangeShopAddressViewController ()

@property (nonatomic, weak) DRTextView *shopAddressTV;

@end

@implementation DRChangeShopAddressViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"修改店铺地址";
    [self setupChilds];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveBarDidClick)];
    
    DRTextView *shopAddressTV = [[DRTextView alloc] initWithFrame:CGRectMake(5, 9, screenWidth - 2 * 5, 100)];
    self.shopAddressTV = shopAddressTV;
    shopAddressTV.backgroundColor = [UIColor whiteColor];
    shopAddressTV.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    shopAddressTV.textColor = DRBlackTextColor;
    DRMyShopModel * myShopModel = [DRUserDefaultTool myShopModel];
    NSString * addressStr = myShopModel.deliverAddress;
    shopAddressTV.text = addressStr;
    shopAddressTV.myPlaceholder = @"请输入店铺地址，不能有特殊符号";
    shopAddressTV.maxLimitNums = 50;
    shopAddressTV.tintColor = DRDefaultColor;
    [self.view addSubview:shopAddressTV];
}
- (void)saveBarDidClick
{
    [self.view endEditing:YES];
    
    NSString * addressStr = self.shopAddressTV.text;
    if (DRStringIsEmpty(addressStr))
    {
        [MBProgressHUD showError:@"您还未输入店铺地址"];
        return;
    }
    
    if ([DRTool stringContainsEmoji:addressStr]) {
        [MBProgressHUD showError:@"请删掉特殊符号或表情后，再提交哦~"];
        return;
    }
    
    NSDictionary *bodyDic = @{
                              @"address":addressStr
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U51",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            DRMyShopModel * myShopModel = [DRUserDefaultTool myShopModel];
            myShopModel.deliverAddress = addressStr;
            [DRUserDefaultTool saveMyShopModel:myShopModel];
            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"upDataMyShopAddress" object:nil];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        DRLog(@"error:%@",error);
    }];
}

@end
