//
//  DRManageSpecificationViewController.m
//  dr
//
//  Created by dahe on 2019/7/24.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRManageSpecificationViewController.h"
#import "DRAddSpecificationViewController.h"
#import "DRSpecificationTableViewCell.h"

@interface DRManageSpecificationViewController ()<UITableViewDataSource, UITableViewDelegate, AddSpecificationDelegate, SpecificationTableViewCellDelegate>

@property (nonatomic, weak) UIView *noDataView;
@property (nonatomic,weak) UITableView *tableView;

@end

@implementation DRManageSpecificationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"规格管理";
    [self setupChilds];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirmBarDidClick)];
    
    //noDataView
    UIView * noDataView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH)];
    self.noDataView = noDataView;
    [self.view addSubview:noDataView];
    
    UIButton * addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(screenWidth * 0.2, self.view.height * 0.3, screenWidth * 0.6, 40);
    addBtn.backgroundColor = DRDefaultColor;
    [addBtn setTitle:@"创建商品规格" forState:UIControlStateNormal];
    [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    addBtn.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [addBtn addTarget:self action:@selector(addButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    addBtn.layer.masksToBounds = YES;
    addBtn.layer.cornerRadius = addBtn.height / 2;
    [noDataView addSubview:addBtn];
    
    UILabel * noDataLabel = [[UILabel alloc] init];
    NSMutableAttributedString * noDataAttStr = [[NSMutableAttributedString alloc] initWithString:@"您还没有商品规格，快去创建一个吧"];
    [noDataAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(28)] range:NSMakeRange(0, noDataAttStr.length)];
    [noDataAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(0, noDataAttStr.length)];
    noDataLabel.attributedText = noDataAttStr;
    CGSize noDataLabelSize = [noDataLabel.attributedText boundingRectWithSize:CGSizeMake(screenWidth - DRMargin * 2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    noDataLabel.frame = CGRectMake(0, addBtn.y - 15 - noDataLabelSize.height, screenWidth, noDataLabelSize.height);
    noDataLabel.textAlignment = NSTextAlignmentCenter;
    [noDataView addSubview:noDataLabel];
    
    //tableView
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH)];
    self.tableView = tableView;
    tableView.backgroundColor = DRBackgroundColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    [self.view addSubview:tableView];
    
    //footerView
    UIView * footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 29 + 40 + 10)];
    footerView.backgroundColor = DRBackgroundColor;
    
    //确定按钮
    UIButton * addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(DRMargin, 29, screenWidth - 2 * DRMargin, 40);
    addButton.backgroundColor = DRDefaultColor;
    [addButton setTitle:@"+添加规格" forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    addButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [addButton addTarget:self action:@selector(addButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    addButton.layer.masksToBounds = YES;
    addButton.layer.cornerRadius = addButton.height / 2;
    [footerView addSubview:addButton];
    tableView.tableFooterView = footerView;
    
    NSMutableArray * dataArray = [NSMutableArray array];
    for (DRGoodSpecificationModel *specificationModel in self.dataArray) {
        if (specificationModel.delFlag == 0) {
            [dataArray addObject:specificationModel];
        }
    }
    noDataView.hidden = dataArray.count > 0;
    tableView.hidden = dataArray.count == 0;
}

- (void)confirmBarDidClick
{
    if (_delegate && [_delegate respondsToSelector:@selector(addSpecificationWithDataArray:)]) {
        [_delegate addSpecificationWithDataArray:self.dataArray];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addButtonDidClick
{
    NSMutableArray * dataArray = [NSMutableArray array];
    for (DRGoodSpecificationModel *specificationModel in self.dataArray) {
        if (specificationModel.delFlag == 0) {
            [dataArray addObject:specificationModel];
        }
    }
    if (dataArray.count > 5) {
        [MBProgressHUD showError:@"最多添加6个规格"];
        return;
    }
    
    DRAddSpecificationViewController * addSpecificationVC = [[DRAddSpecificationViewController alloc] init];
    addSpecificationVC.delegate = self;
    [self.navigationController pushViewController:addSpecificationVC animated:YES];
}

- (void)addSpecificationWithSpecificationModel:(DRGoodSpecificationModel *)specificationModel
{
    self.tableView.hidden = NO;
    self.noDataView.hidden = YES;
    
    [self.dataArray addObject:specificationModel];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.dataArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)editSpecificationWithSpecificationModel:(DRGoodSpecificationModel *)specificationModel
{
    [self.dataArray replaceObjectAtIndex:specificationModel.index withObject:specificationModel];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:specificationModel.index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRGoodSpecificationModel *specificationModel = self.dataArray[indexPath.row];
    if (specificationModel.delFlag == 0) {
        DRSpecificationTableViewCell *cell = [DRSpecificationTableViewCell cellWithTableView:tableView];
        specificationModel.index = indexPath.row;
        NSMutableArray * dataArray = [NSMutableArray array];
        for (DRGoodSpecificationModel *specificationModel in self.dataArray) {
            if (specificationModel.delFlag == 0) {
                [dataArray addObject:specificationModel];
            }
        }
        specificationModel.index_ = [dataArray indexOfObject:specificationModel];
        cell.goodSpecificationModel = specificationModel;
        cell.delegate = self;
        return cell;
    }else
    {
        static NSString *ID = @"SpecificationTableViewDeleteCellId";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        }
        return  cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRGoodSpecificationModel *specificationModel = self.dataArray[indexPath.row];
    if (specificationModel.delFlag == 0) {
        return 9 + 40 + 100;
    }else
    {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteCellWithIndexPath:indexPath];
    }
}

- (void)deleteCellWithIndexPath:(NSIndexPath *)indexPath
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"确认删除该规格?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * alertAction1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction * alertAction2 = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        DRGoodSpecificationModel *specificationModel = self.dataArray[indexPath.row];
        specificationModel.delFlag = 1;
        [self.tableView reloadData];
        
        NSMutableArray * dataArray = [NSMutableArray array];
        for (DRGoodSpecificationModel *specificationModel in self.dataArray) {
            if (specificationModel.delFlag == 0) {
                [dataArray addObject:specificationModel];
            }
        }
        if (dataArray.count == 0) {
            self.tableView.hidden = YES;
            self.noDataView.hidden = NO;
        }else
        {
            self.tableView.hidden = NO;
            self.noDataView.hidden = YES;
        }
    }];
    [alertController addAction:alertAction1];
    [alertController addAction:alertAction2];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)specificationTableViewCell:(DRSpecificationTableViewCell *)cell editButtonDidClick:(UIButton *)button
{
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    
    DRAddSpecificationViewController * addSpecificationVC = [[DRAddSpecificationViewController alloc] init];
    addSpecificationVC.delegate = self;
    addSpecificationVC.goodSpecificationModel = self.dataArray[indexPath.row];
    [self.navigationController pushViewController:addSpecificationVC animated:YES];
}

- (void)specificationTableViewCell:(DRSpecificationTableViewCell *)cell deleteButtonDidClick:(UIButton *)button
{
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    [self deleteCellWithIndexPath:indexPath];
}

#pragma mark - 初始化
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
