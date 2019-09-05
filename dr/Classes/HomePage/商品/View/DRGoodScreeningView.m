//
//  DRGoodScreeningView.m
//  dr
//
//  Created by 毛文豪 on 2017/5/12.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRGoodScreeningView.h"
#import "DRGoodScreeningTitleCollectionReusableView.h"
#import "DRGoodScreeningCollectionViewCell.h"
#import "DRGoodScreeningPriceCollectionViewCell.h"

NSString * const GoodScreeningCollectionViewCellId = @"GoodScreeningCollectionViewCellId";
NSString * const GoodScreeningPriceCollectionViewCellId = @"GoodScreeningPriceCollectionViewCellId";
NSString * const GoodScreeningCollectionViewHeaderId = @"GoodScreeningCollectionViewHeaderId";

@interface DRGoodScreeningView ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GoodScreeningPriceCollectionViewCellDelegate>

@property (nonatomic,weak) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *categoryArray;
@property (nonatomic,strong) NSMutableArray *sellTypeArray;

@end

@implementation DRGoodScreeningView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupChildViews];
        [self getCategoryData];
    }
    return self;
}

- (void)getCategoryData
{
    NSDictionary *bodyDic = @{
                              };
    
    NSDictionary *headDic = @{
                              @"cmd":@"B02",
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            self.categoryArray = [DRSortModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            for (DRSortModel * model in self.categoryArray) {
                model.selected = [self.categoryId isEqualToString:model.id];
            }
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self];
        DRLog(@"error:%@",error);
    }];
}

- (void)setupChildViews
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, DRMargin, DRMargin, DRMargin);
    layout.minimumInteritemSpacing = DRMargin;//列间距
    layout.minimumLineSpacing = DRMargin;//行间距
    
    CGFloat collectionViewH = self.height - 45 - [DRTool getSafeAreaBottom];
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.width, collectionViewH) collectionViewLayout:layout];
    self.collectionView = collectionView;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.contentInset = UIEdgeInsetsMake(43, 0, 0, 0);
    //注册
    [collectionView registerClass:[DRGoodScreeningTitleCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:GoodScreeningCollectionViewHeaderId];
    [collectionView registerClass:[DRGoodScreeningCollectionViewCell class] forCellWithReuseIdentifier:GoodScreeningCollectionViewCellId];
    [collectionView registerClass:[DRGoodScreeningPriceCollectionViewCell class] forCellWithReuseIdentifier:GoodScreeningPriceCollectionViewCellId];
    
    [self addSubview:collectionView];
    
    //底部按钮
    NSArray * buttonTitles = @[@"重置", @"确定"];
    CGFloat buttonH = 37;
    CGFloat buttonPadding = 20;
    CGFloat buttonW = (self.width - 3 * buttonPadding) / 2;
    for (int i = 0; i < buttonTitles.count; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.frame = CGRectMake(buttonPadding + (buttonPadding + buttonW) * i, CGRectGetMaxY(collectionView.frame), buttonW, buttonH);
        button.adjustsImageWhenHighlighted = NO;
        if (i == 0) {
            button.backgroundColor = DRWhiteLineColor;
            [button setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
        }else
        {
            button.backgroundColor = DRDefaultColor;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        [button setTitle:buttonTitles[i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = buttonH / 2;
        [button addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.categoryArray.count;
    }else if (section == 1)
    {
        return self.sellTypeArray.count;
    }
    return 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 1) {
        DRGoodScreeningCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GoodScreeningCollectionViewCellId forIndexPath:indexPath];
        if (indexPath.section == 0) {
            cell.model = self.categoryArray[indexPath.row];
        }else if (indexPath.section == 1)
        {
            cell.model = self.sellTypeArray[indexPath.row];
        }
        return cell;
    }else if (indexPath.section == 2)
    {
        DRGoodScreeningPriceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GoodScreeningPriceCollectionViewCellId forIndexPath:indexPath];
        cell.delegate = self;
        if ([self.minPrice doubleValue] > 0) {
            cell.minTF.text = self.minPrice;
        }
        if ([self.maxPrice doubleValue] > 0) {
            cell.maxTF.text = self.maxPrice;
        }
        return cell;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 1) {
        return CGSizeMake(84, 32.5);
    }else if (indexPath.section == 2)
    {
        return CGSizeMake(collectionView.width, 35);
    }
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(collectionView.width, 50);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        DRGoodScreeningTitleCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:GoodScreeningCollectionViewHeaderId forIndexPath:indexPath];
        if (indexPath.section == 0) {
            headerView.typeStr = @"分类（单选）";
        }else if (indexPath.section == 1)
        {
            headerView.typeStr = @"售卖方式（单选）";
        }else if (indexPath.section == 2)
        {
            headerView.typeStr = @"价格区间";
        }
        return headerView;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray * indexPaths = [NSMutableArray array];
    
    if (indexPath.section == 0) {
        DRSortModel * model = self.categoryArray[indexPath.row];
        self.categoryId = model.id;
        
        for (int i = 0; i < self.categoryArray.count; i++) {
            DRSortModel * model = self.categoryArray[i];
            if (model.isSelected) {
                model.selected = NO;
                NSIndexPath * openIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [indexPaths addObject:openIndexPath];
            }
        }
        //点击的indexPath
        model.selected = YES;//选中
        if (![indexPaths containsObject:indexPath]) {
            [indexPaths addObject:indexPath];
        }
    }else if (indexPath.section == 1) {
        DRSortModel * model = self.sellTypeArray[indexPath.row];
        self.isGroup = nil;
        if (indexPath.row == 3) {
            self.isGroup = @"1";
        }else
        {
            self.sellType = model.id;
        }
        
        for (int i = 0; i < self.sellTypeArray.count; i++) {
            DRSortModel * model = self.sellTypeArray[i];
            if (model.isSelected) {
                model.selected = NO;
                NSIndexPath * openIndexPath = [NSIndexPath indexPathForRow:i inSection:1];
                [indexPaths addObject:openIndexPath];
            }
        }
        //点击的indexPath
        model.selected = YES;//选中
        if (![indexPaths containsObject:indexPath]) {
            [indexPaths addObject:indexPath];
        }
    }
    
    [self.collectionView reloadItemsAtIndexPaths:indexPaths];
}

- (void)buttonDidClick:(UIButton *)button
{
    [self endEditing:YES];
    
    if (button.tag == 0) {
        self.categoryId = nil;
        self.sellType = nil;
        self.isGroup = nil;
        self.minPrice = nil;
        self.maxPrice = nil;
        NSMutableArray * indexPaths = [NSMutableArray array];
        
        for (int i = 0; i < self.categoryArray.count; i++) {
            DRSortModel * model = self.categoryArray[i];
            if (model.isSelected) {
                model.selected = NO;
                NSIndexPath * openIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [indexPaths addObject:openIndexPath];
            }
        }

        for (int i = 0; i < self.sellTypeArray.count; i++) {
            DRSortModel * model = self.sellTypeArray[i];
            if (model.isSelected) {
                model.selected = NO;
                NSIndexPath * openIndexPath = [NSIndexPath indexPathForRow:i inSection:1];
                [indexPaths addObject:openIndexPath];
            }
        }
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
        [indexPaths addObject:indexPath];
        [self.collectionView reloadItemsAtIndexPaths:indexPaths];
    }else if (button.tag == 1)
    {
        double minPrice = [self.minPrice doubleValue];
        double maxPrice = [self.maxPrice doubleValue];
        if (minPrice >= maxPrice && maxPrice > 0 && minPrice > 0) {
            [MBProgressHUD showError:@"请输入正确的价格"];
            return;
        }
        if (_delegate && [_delegate respondsToSelector:@selector(goodScreeningView:confirmButtonDidClick:)]) {
            [_delegate goodScreeningView:self confirmButtonDidClick:button];
        }
    }
}

- (void)goodScreeningPriceCollectionViewCell:(DRGoodScreeningPriceCollectionViewCell *)goodScreeningPriceCollectionViewCell textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == 0) {
        self.minPrice = textField.text;
    }else if (textField.tag == 1)
    {
        self.maxPrice = textField.text;
    }
}

#pragma mark - 初始化
- (NSMutableArray *)categoryArray
{
    if (!_categoryArray) {
        _categoryArray = [NSMutableArray array];
    }
    return _categoryArray;
}

- (NSMutableArray *)sellTypeArray
{
    if (!_sellTypeArray) {
        _sellTypeArray = [NSMutableArray array];
        NSArray * names = @[@"全部", @"一物一拍/零售", @"批发", @"团购"];
        NSArray * sellTypes = @[@"", @"1", @"2", @"isGroup"];
        
        for (int i = 0; i < names.count; i++) {
            DRSortModel * model = [[DRSortModel alloc] init];
            model.name = names[i];
            model.id = sellTypes[i];
            if (i == 3) {
                model.selected = [self.isGroup isEqualToString:@"1"];
            }else
            {
                model.selected = [self.sellType isEqualToString:model.id];
            }
            [_sellTypeArray addObject:model];
        }
    }
    return _sellTypeArray;
}

@end
