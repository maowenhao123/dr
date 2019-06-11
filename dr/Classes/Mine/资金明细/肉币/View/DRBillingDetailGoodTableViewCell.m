//
//  DRBillingDetailGoodTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2018/6/6.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRBillingDetailGoodTableViewCell.h"

@interface DRBillingDetailGoodTableViewCell ()

@property (nonatomic, strong) NSMutableArray *titlelabelArray;
@property (nonatomic, strong) NSMutableArray *contentlabelArray;

@end

@implementation DRBillingDetailGoodTableViewCell

+ (DRBillingDetailGoodTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"BillingDetailGoodTableViewCellId";
    DRBillingDetailGoodTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRBillingDetailGoodTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
    
    CGFloat labelH = 15;
    CGFloat labelPadding = 10;
    NSArray * titles = @[@"名称：", @"单价：", @"代理价：", @"数量：", @"实收："];
    for (int i = 0; i < titles.count; i++) {
        UILabel * titleLabel = [[UILabel alloc] init];
        titleLabel.text = titles[i];
        titleLabel.textColor = DRBlackTextColor;
        titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
        CGSize titleLabelSize = [titleLabel.text sizeWithLabelFont:titleLabel.font];
        titleLabel.frame = CGRectMake(15, 15 + (labelH + labelPadding) * i, titleLabelSize.width, labelH);
        [self addSubview:titleLabel];
        
        UILabel * contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame), 15 + (labelH + labelPadding) * i, screenWidth - CGRectGetMaxX(titleLabel.frame) - 15, labelH)];
        contentLabel.textColor = DRBlackTextColor;
        contentLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
        contentLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:contentLabel];
        [self.contentlabelArray addObject:contentLabel];
    }
}

- (void)setDetailModel:(DROrderItemDetailModel *)detailModel
{
    _detailModel = detailModel;
  
    for (int i = 0; i < self.contentlabelArray.count; i++) {
        UILabel * contentLabel = self.contentlabelArray[i];
        NSString * labelText;
        if (i == 0) {
            labelText = [NSString stringWithFormat:@"%@", _detailModel.goods.name];
        }else if (i == 1) {
            labelText = [NSString stringWithFormat:@"%@元", [DRTool formatFloat:[_detailModel.goods.price doubleValue] / 100]];
        }else if (i == 2) {
             labelText = [NSString stringWithFormat:@"%@元", [DRTool formatFloat:[_detailModel.goods.agentPrice doubleValue] / 100]];
        }else if (i == 3) {
            labelText = [NSString stringWithFormat:@"%@件", _detailModel.purchaseCount];
        }else if (i == 4) {
           labelText = [NSString stringWithFormat:@"%@元", [DRTool formatFloat:[_detailModel.goods.agentPrice doubleValue] * [_detailModel.purchaseCount intValue] / 100]];
        }
        contentLabel.text = labelText;
    }
}

#pragma mark - 初始化
- (NSMutableArray *)titlelabelArray
{
    if (!_titlelabelArray) {
        _titlelabelArray = [NSMutableArray array];
    }
    return _titlelabelArray;
}
- (NSMutableArray *)contentlabelArray
{
    if (!_contentlabelArray) {
        _contentlabelArray = [NSMutableArray array];
    }
    return _contentlabelArray;
}

@end
