//
//  DRChangeShopNameViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/4/20.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRChangeShopNameViewController.h"

@interface DRChangeShopNameViewController ()

@property (nonatomic, weak) UITextField * shopNameTF;

@end

@implementation DRChangeShopNameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"修改店铺名称";
    [self setupChilds];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveBarDidClick)];
    
    UIView * shopNameView = [[UIView alloc] initWithFrame:CGRectMake(0, 9, screenWidth, DRCellH)];
    shopNameView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:shopNameView];
    
    UITextField * shopNameTF = [[UITextField alloc] init];
    self.shopNameTF = shopNameTF;
    DRMyShopModel * myShopModel = [DRUserDefaultTool myShopModel];
    shopNameTF.text = myShopModel.storeName;
    shopNameTF.frame = CGRectMake(DRMargin, 0, screenWidth - 2 * DRMargin, DRCellH);
    shopNameTF.tintColor = DRDefaultColor;
    shopNameTF.textColor = DRBlackTextColor;
    shopNameTF.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    shopNameTF.placeholder = @"请输入店铺名称";
    shopNameTF.clearButtonMode = UITextFieldViewModeAlways;
    [shopNameView addSubview:shopNameTF];
}

- (void)saveBarDidClick
{
    [self.view endEditing:YES];
    
    if (DRStringIsEmpty(self.shopNameTF.text))
    {
        [MBProgressHUD showError:@"您还输入店铺名称"];
        return;
    }
    
    if ([DRTool stringContainsEmoji:self.shopNameTF.text]) {
        [MBProgressHUD showError:@"请删掉特殊符号或表情后，再提交哦~"];
        return;
    }
    
    NSDictionary *bodyDic = @{
                              @"name":self.shopNameTF.text
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
            myShopModel.storeName = self.shopNameTF.text;
            [DRUserDefaultTool saveMyShopModel:myShopModel];
            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"upDataMyShopName" object:nil];
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
