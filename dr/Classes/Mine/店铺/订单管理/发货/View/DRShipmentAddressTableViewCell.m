//
//  DRShipmentAddressTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/6/1.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShipmentAddressTableViewCell.h"

@interface DRShipmentAddressTableViewCell ()

@property (nonatomic, weak) UILabel * mailTitleLabel;
@property (nonatomic, weak) UILabel *nameLabel;//名字
@property (nonatomic, weak) UILabel *phoneLabel;//电话
@property (nonatomic, weak) UILabel *addressLabel;//地址
@property (nonatomic, weak) UILabel *mailTypeLabel;//配送方式
@property (nonatomic, weak) UILabel *remarkLabel;//订单备注
@property (nonatomic,strong) NSMutableArray *titleLabelArray;

@end

@implementation DRShipmentAddressTableViewCell

+ (DRShipmentAddressTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"ShipmentAddressTableViewCellId";
    DRShipmentAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRShipmentAddressTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    
    NSArray * titles = @[@"联系人：", @"联系电话：", @"收货地址：", @"配送方式：", @"备注："];
    for (int i = 0; i < titles.count; i++)
    {
        UILabel * titleLabel = [[UILabel alloc] init];
        titleLabel.text = titles[i];
        titleLabel.textColor = DRGrayTextColor;
        titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
        titleLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:titleLabel];
        [self.titleLabelArray addObject:titleLabel];
        if (i == 3) {
            self.mailTitleLabel = titleLabel;
        }
        
        UILabel * label = [[UILabel alloc] init];
        if (i == 0) {
            self.nameLabel = label;
        }else if (i == 1)
        {
            self.phoneLabel = label;
        }else if (i == 2)
        {
            self.addressLabel = label;
        }else if (i == 3)
        {
            self.mailTypeLabel = label;
        }else if (i == 4)
        {
            self.remarkLabel = label;
        }
        label.textColor = DRBlackTextColor;
        label.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
        label.numberOfLines = 0;
        [self addSubview:label];
        
        if (i == 0) {
            UIButton * copyButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.numberButton = copyButton;
            [copyButton setTitle:@"复制" forState:UIControlStateNormal];
            [copyButton setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
            copyButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(22)];
            [copyButton addTarget:self action:@selector(copyButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
            copyButton.layer.masksToBounds = YES;
            copyButton.layer.cornerRadius = 3;
            copyButton.layer.borderColor = DRGrayLineColor.CGColor;
            copyButton.layer.borderWidth = 1;
            [self addSubview:copyButton];
        }
    }
}

- (void)copyButtonDidClick
{
    //复制账号
    UIPasteboard *pab = [UIPasteboard generalPasteboard];
    NSString *string = [NSString stringWithFormat:@"收货人：%@\n联系电话：%@\n收货地址：%@", _deliveryModel.address.receiverName, _deliveryModel.address.phone, [NSString stringWithFormat:@"%@%@%@",_deliveryModel.address.province, _deliveryModel.address.city, _deliveryModel.address.address]];
    [pab setString:string];
    [MBProgressHUD showSuccess:@"复制成功"];
}

- (void)setDeliveryModel:(DRDeliveryAddressModel *)deliveryModel
{
    _deliveryModel = deliveryModel;
    self.nameLabel.text = [NSString stringWithFormat:@"%@", _deliveryModel.address.receiverName];
    self.phoneLabel.text = [NSString stringWithFormat:@"%@",_deliveryModel.address.phone];
    self.addressLabel.text = [NSString stringWithFormat:@"%@%@%@",_deliveryModel.address.province, _deliveryModel.address.city, _deliveryModel.address.address];
    
    NSString * mailTypeStr = @"";
    if ([_deliveryModel.freight intValue] > 0) {
        self.mailTitleLabel.text = @"运费：";
        mailTypeStr = [NSString stringWithFormat:@"%@元", [DRTool formatFloat:[_deliveryModel.freight doubleValue] / 100]];
    }else if ([_deliveryModel.mailType intValue] == 0 && [_deliveryModel.freight intValue] == 0)
    {
        self.mailTitleLabel.text = @"运费：";
        mailTypeStr = @"包邮";
    }else if ([_deliveryModel.mailType intValue] > 0)
    {
        self.mailTitleLabel.text = @"配送方式：";
        NSArray * mailTypes = @[@"包邮", @"肉币支付", @"快递到付"];
        mailTypeStr = [NSString stringWithFormat:@"%@", mailTypes[[_deliveryModel.mailType intValue] - 1]];
    }
    self.mailTypeLabel.text = mailTypeStr;
    self.remarkLabel.text = _deliveryModel.remarks;
    
    //frame
    CGSize titleLabelSize = [@"收货地址：" sizeWithLabelFont:[UIFont systemFontOfSize:DRGetFontSize(24)]];
    CGFloat titleLabelW = titleLabelSize.width;
    
    self.nameLabel.frame = CGRectMake(DRMargin + titleLabelW, DRMargin, _deliveryModel.nameSize.width, _deliveryModel.nameSize.height);
    self.numberButton.frame = CGRectMake(screenWidth - DRMargin - 60, self.nameLabel.y, 60, 25);
    self.phoneLabel.frame = CGRectMake(DRMargin + titleLabelW, CGRectGetMaxY(self.nameLabel.frame) + DRMargin, _deliveryModel.phoneSize.width, _deliveryModel.phoneSize.height);
    self.addressLabel.frame = CGRectMake(DRMargin + titleLabelW , CGRectGetMaxY(self.phoneLabel.frame) + DRMargin, _deliveryModel.addressSize.width, _deliveryModel.addressSize.height);
    self.mailTypeLabel.frame = CGRectMake(DRMargin + titleLabelW, CGRectGetMaxY(self.addressLabel.frame) + DRMargin, _deliveryModel.typeSize.width, _deliveryModel.typeSize.height);
    self.remarkLabel.frame = CGRectMake(DRMargin + titleLabelW, CGRectGetMaxY(self.mailTypeLabel.frame) + DRMargin, _deliveryModel.remarkSize.width, _deliveryModel.remarkSize.height);

    for (int i = 0; i < self.titleLabelArray.count; i++) {
        UILabel * label = self.titleLabelArray[i];
        if (i == 0) {
            label.frame = CGRectMake(DRMargin, self.nameLabel.y, titleLabelW, titleLabelSize.height);
        }else if (i == 1)
        {
            label.frame = CGRectMake(DRMargin, self.phoneLabel.y, titleLabelW, titleLabelSize.height);
        }else if (i == 2)
        {
            label.frame = CGRectMake(DRMargin, self.addressLabel.y, titleLabelW, titleLabelSize.height);
        }else if (i == 3)
        {
            label.frame = CGRectMake(DRMargin, self.mailTypeLabel.y, titleLabelW, titleLabelSize.height);
        }else if (i == 4)
        {
            if (DRStringIsEmpty(_deliveryModel.remarks)) {
                label.hidden = YES;
            }else
            {
                label.frame = CGRectMake(DRMargin, self.remarkLabel.y, titleLabelW, titleLabelSize.height);
            }
        }
    }
}
#pragma mark - 初始化
- (NSMutableArray *)titleLabelArray
{
    if (!_titleLabelArray) {
        _titleLabelArray = [NSMutableArray array];
    }
    return _titleLabelArray;
}

@end

