//
//  DRMyShopDetailViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/4/6.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRMyShopDetailViewController.h"
#import "DRChangeShopNameViewController.h"
#import "DRChangeShopAddressViewController.h"
#import "DRChangeShopDescriptionViewController.h"
#import "DRChangeRealNameViewController.h"
#import "DRShowRealNameViewController.h"
#import "DRIdentityAuditViewController.h"
#import "DRChangeFunPassWordViewController.h"
#import "DRSetFunPasswordViewController.h"
#import "DRBankCardViewController.h"
#import "DRTextTableViewCell.h"
#import "DRShopDetailTableViewCell.h"
#import "DRAddImageManage.h"

@interface DRMyShopDetailViewController ()<UITableViewDelegate, UITableViewDataSource, AddImageManageDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *functionNames;
@property (nonatomic, strong) DRAddImageManage * addImageManage;

@end

@implementation DRMyShopDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"店铺管理";
    [self setupChilds];

    //通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upDataShopName) name:@"upDataMyShopName" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upDataShopAddress) name:@"upDataMyShopAddress" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upDataMyShopDescription) name:@"upDataMyShopDescription" object:nil];
}

#pragma mark - 接收通知
- (void)upDataShopName
{
    //刷新
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}
- (void)upDataShopAddress
{
    //刷新
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}
- (void)upDataMyShopDescription
{
    //刷新
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - 布局试图
- (void)setupChilds
{
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH) style:UITableViewStyleGrouped];
    self.tableView = tableView;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    tableView.backgroundColor = DRBackgroundColor;
    [self.view addSubview:tableView];
}
#pragma mark - cell delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.functionNames.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * functionNames = self.functionNames[section];
    if (section == 0) {
        return functionNames.count + 2;
    }
    return functionNames.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRMyShopModel * myShopModel = [DRUserDefaultTool myShopModel];
    if (indexPath.section == 0 && (indexPath.row == 2 || indexPath.row == 3))
    {
        DRShopDetailTableViewCell * cell = [DRShopDetailTableViewCell cellWithTableView:tableView];
        if (indexPath.row == 2) {
            cell.detailTitleStr = @"店铺地址";
            cell.shopDetailStr = myShopModel.deliverAddress;
        }else
        {
            cell.detailTitleStr = @"店铺简介";
            cell.shopDetailStr = myShopModel.description_;
        }
    
        return cell;
    }
    
    DRTextTableViewCell * cell = [DRTextTableViewCell cellWithTableView:tableView];
    NSArray * functionNames = self.functionNames[indexPath.section];
    cell.functionName = functionNames[indexPath.row];
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.avatarImageView.hidden = NO;
    }else
    {
        cell.avatarImageView.hidden = YES;
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {//头像
            cell.functionDetail = nil;
            [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%@%@",baseUrl,myShopModel.storeImg]] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
        }else if (indexPath.row == 1)//名字
        {
            cell.functionDetail = myShopModel.storeName;
        }
    }
    
    if (indexPath.row == 0) {
        cell.line.hidden = YES;
    }else
    {
        cell.line.hidden = NO;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRMyShopModel * myShopModel = [DRUserDefaultTool myShopModel];
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 70;
    }else if (indexPath.section == 0 && indexPath.row == 2)
    {
        CGSize size = [myShopModel.deliverAddress sizeWithFont:[UIFont systemFontOfSize:DRGetFontSize(26)] maxSize:CGSizeMake(screenWidth - 2 * 10, MAXFLOAT)];
        CGFloat height = size.height < 20 ? 20 : size.height;
        return 35 + height + 15;
    }else if (indexPath.section == 0 && indexPath.row == 3)
    {
        CGSize size = [myShopModel.description_ sizeWithFont:[UIFont systemFontOfSize:DRGetFontSize(26)] maxSize:CGSizeMake(screenWidth - 2 * 10, MAXFLOAT)];
        CGFloat height = size.height < 20 ? 20 : size.height;
        return 35 + height + 15;
    }
    return DRCellH;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            self.addImageManage = [[DRAddImageManage alloc] init];
            self.addImageManage.viewController = self;
            self.addImageManage.delegate = self;
            self.addImageManage.type = 1;
            [self.addImageManage addImage];
        }else if (indexPath.row == 1)//昵称
        {
//            DRIdentityAuditViewController * shopNameVC = [[DRIdentityAuditViewController alloc] init];
//            [self.navigationController pushViewController:shopNameVC animated:YES];
            DRChangeShopNameViewController * shopNameVC = [[DRChangeShopNameViewController alloc] init];
            [self.navigationController pushViewController:shopNameVC animated:YES];
        }else if (indexPath.row == 2)
        {
            DRChangeShopAddressViewController * shopAddressVC = [[DRChangeShopAddressViewController alloc] init];
            [self.navigationController pushViewController:shopAddressVC animated:YES];
        }else if (indexPath.row == 3)
        {
            DRChangeShopDescriptionViewController * shopDescriptionVC = [[DRChangeShopDescriptionViewController alloc] init];
            [self.navigationController pushViewController:shopDescriptionVC animated:YES];
        }
    }else if (indexPath.section == 1)
    {
        DRUser *user = [DRUserDefaultTool user];
        if (indexPath.row == 0) {//实名认证
            if (DRStringIsEmpty(user.realName) || DRStringIsEmpty(user.personalId)) {
                DRChangeRealNameViewController * realNameVC = [[DRChangeRealNameViewController alloc] init];
                [self.navigationController pushViewController: realNameVC animated:YES];
            }else
            {
                DRShowRealNameViewController * realNameVC = [[DRShowRealNameViewController alloc] init];
                [self.navigationController pushViewController: realNameVC animated:YES];
            }
        }else if (indexPath.row == 1)//提款密码
        {
            DRUser *user = [DRUserDefaultTool user];
            if (user.hasFundPassword) {//已经设置提款密码
                DRChangeFunPassWordViewController * changeFunPwdVC = [[DRChangeFunPassWordViewController alloc] init];
                [self.navigationController pushViewController:changeFunPwdVC animated:YES];
            }else
            {
                DRSetFunPasswordViewController * setFunPwdVC = [[DRSetFunPasswordViewController alloc] init];
                [self.navigationController pushViewController:setFunPwdVC animated:YES];
            }
        }else if (indexPath.row == 2)
        {
            DRBankCardViewController * bankVC = [[DRBankCardViewController alloc] init];
            [self.navigationController pushViewController: bankVC animated:YES];
        }
    }
}
#pragma mark - 修改头像
- (void)imageManageCropImage:(UIImage *)image
{
    NSString * image64 = [DRTool stringByimageBase64WithImage:image];
    NSDictionary *bodyDic = @{
                              @"logo":image64,
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U51",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            //刷新
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self upDataMyShopSuccess:^{
                //刷新
                NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                //更新数据发送通知
                [[NSNotificationCenter defaultCenter] postNotificationName:@"upDataMyShopAvatar" object:nil];
            }];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
- (void)upDataMyShopSuccess:(void (^)(void))success
{
    NSDictionary *bodyDic = @{
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"B01",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            DRMyShopModel *shopModel = [DRMyShopModel mj_objectWithKeyValues:json];
            [DRUserDefaultTool saveMyShopModel:shopModel];
            success();
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

#pragma mark - 初始化
- (NSArray *)functionNames
{
    if (!_functionNames) {
        _functionNames = @[@[@"店铺logo", @"店铺名称"],
                           @[@"实名认证", @"提款密码", @"我的银行卡"]
                           ];
    }
    return _functionNames;
}

@end
