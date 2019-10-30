//
//  DROrderMultipTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/5/26.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DROrderMultipTableViewCell.h"

@interface DROrderMultipTableViewCell ()

@property (nonatomic,weak) UIScrollView * goodScrollView;

@end

@implementation DROrderMultipTableViewCell

+ (DROrderMultipTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"OrderMultipTableViewCellId";
    DROrderMultipTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DROrderMultipTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    return  cell;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupChildViews];
    }
    return self;
}
- (void)setupChildViews
{
    //分割线
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    line.backgroundColor = DRWhiteLineColor;
    [self addSubview:line];
    
    //scrollview
    UIScrollView * goodScrollView = [[UIScrollView alloc] init];
    self.goodScrollView = goodScrollView;
    [self addSubview:goodScrollView];
    //解决UIScrollView把UITableViewCell的点击事件屏蔽
    self.goodScrollView.userInteractionEnabled = NO;
    [self addGestureRecognizer:self.goodScrollView.panGestureRecognizer];
}
#pragma mark - 设置数据
- (void)setOrderModel:(DROrderModel *)orderModel
{
    _orderModel = orderModel;
    
    for (UIView * subView in self.goodScrollView.subviews) {
        [subView removeFromSuperview];
    }
    CGFloat padding = 5;
    CGFloat goodImageViewWH = 76;
    
    NSMutableArray * detailArray = [NSMutableArray array];
    for (DRStoreOrderModel *storeOrders in orderModel.storeOrders) {
        for (DROrderItemDetailModel *detail in storeOrders.detail) {
            [detailArray addObject:detail];
        }
    }
    
    for (int i = 0; i < detailArray.count; i++) {
        DROrderItemDetailModel * orderItemDetailModel = detailArray[i];
        UIImageView * goodImageView = [[UIImageView alloc] init];
        goodImageView.frame = CGRectMake((goodImageViewWH + padding) * i, 12, goodImageViewWH, goodImageViewWH);
        goodImageView.contentMode = UIViewContentModeScaleAspectFill;
        goodImageView.layer.masksToBounds = YES;
        if (DRObjectIsEmpty(orderItemDetailModel.specification)) {
            NSString * urlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, orderItemDetailModel.goods.spreadPics, smallPicUrl];
            [goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        }else
        {
            NSString * urlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, orderItemDetailModel.specification.picUrl, smallPicUrl];
            [goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        }
        [self.goodScrollView addSubview:goodImageView];
    }
    self.goodScrollView.contentSize = CGSizeMake((goodImageViewWH + padding) * detailArray.count, 100);
    
    self.goodScrollView.frame = CGRectMake(DRMargin, 0, screenWidth - DRMargin * 2, 100);
    
}

@end
