//
//  DRShipmentGrouponConfirmViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/6/1.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShipmentGrouponConfirmViewController.h"
#import "DRShipmentGrouponDeliveryTableViewCell.h"

@interface DRShipmentGrouponConfirmViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,weak) UITableView *tableView;

@end

@implementation DRShipmentGrouponConfirmViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"物流单号";
    [self setupChilds];
}
- (void)setupChilds {
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirmBarDidClick)];
    
    //tableView
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH)];
    self.tableView = tableView;
    tableView.backgroundColor = DRBackgroundColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    [self.view addSubview:tableView];
}
- (void)confirmBarDidClick
{
    [self.view endEditing:YES];
    
    //遍历 添加数据
    NSMutableArray * deliverys = [NSMutableArray array];
    for (DRDeliveryAddressModel * model in self.deliveryList) {
        if (DRDictIsEmpty(model.deliveryDic)) {
            [MBProgressHUD showError:@"请选择物流公司"];
            return;
        }
        if (DRStringIsEmpty(model.logisticsNum)) {
            [MBProgressHUD showError:@"请输入物流单号"];
            return;
        }
        
        NSDictionary * delivery_ = @{
                                     @"logisticsId":model.deliveryDic[@"id"],
                                     @"logisticsNum":model.logisticsNum,
                                     };
        NSMutableDictionary *delivery = [NSMutableDictionary dictionaryWithDictionary:delivery_];
        if (!DRStringIsEmpty(model.orderDetailId)) {
            [delivery setObject:model.orderDetailId forKey:@"orderDetailId"];
        }
        [deliverys addObject:delivery];
    }
    
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
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deliveryList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRShipmentGrouponDeliveryTableViewCell *cell = [DRShipmentGrouponDeliveryTableViewCell cellWithTableView:tableView];
    cell.deliveryModel = self.deliveryList[indexPath.row];
    return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRDeliveryAddressModel * deliveryModel = self.deliveryList[indexPath.row];
    return 9 + DRMargin + deliveryModel.nameSize.height + DRMargin + deliveryModel.phoneSize.height + DRMargin + deliveryModel.addressSize.height + DRMargin + 80;
}

@end
