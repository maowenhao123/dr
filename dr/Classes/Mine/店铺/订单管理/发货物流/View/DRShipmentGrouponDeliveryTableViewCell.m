//
//  DRShipmentGrouponDeliveryTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/6/1.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShipmentGrouponDeliveryTableViewCell.h"
#import "DRShipmentDeliveryPickerView.h"

@interface DRShipmentGrouponDeliveryTableViewCell ()<UITextFieldDelegate>

@property (nonatomic, weak) UILabel *nameLabel;//名字
@property (nonatomic, weak) UILabel *phoneLabel;//电话
@property (nonatomic, weak) UILabel *addressLabel;//地址
@property (nonatomic,weak) UIView *logisticsView;
@property (nonatomic,weak) UITextField *companyTF;
@property (nonatomic,weak) UITextField *numberTF;
@property (nonatomic, weak) DRShipmentDeliveryPickerView * deliveryPickerView;
@property (nonatomic,strong) NSDictionary *deliveryDic;
@property (nonatomic,strong) NSMutableArray *titleLabelArray;

@end

@implementation DRShipmentGrouponDeliveryTableViewCell

+ (DRShipmentGrouponDeliveryTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"ShipmentGrouponDeliveryTableViewCellId";
    DRShipmentGrouponDeliveryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRShipmentGrouponDeliveryTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 9)];
    lineView.backgroundColor = DRBackgroundColor;
    [self addSubview:lineView];
    
    NSArray * titles = @[@"联系人：", @"联系电话：", @"收货地址："];
    for (int i = 0; i < 3; i++) {
        UILabel * titleLabel = [[UILabel alloc] init];
        titleLabel.text = titles[i];
        titleLabel.textColor = DRGrayTextColor;
        titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
        titleLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:titleLabel];
        [self.titleLabelArray addObject:titleLabel];
        
        UILabel * label = [[UILabel alloc] init];
        if (i == 0) {
            self.nameLabel = label;
        }else if (i == 1)
        {
            self.phoneLabel = label;
        }else if (i == 2)
        {
            self.addressLabel = label;
        }
        label.textColor = DRBlackTextColor;
        label.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
        label.numberOfLines = 0;
        [self addSubview:label];
    }
    
    UIView *logisticsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 80)];
    self.logisticsView = logisticsView;
    [self addSubview:logisticsView];
    
    NSArray * titles_ = @[@"物流公司",@"物流单号"];
    NSArray * placeholders = @[@"选择",@"输入物流单号"];
    for (int i = 0; i < 2; i++) {
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, i * 40, 70, 40)];
        titleLabel.text = titles_[i];
        titleLabel.textColor = DRBlackTextColor;
        titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
        [logisticsView addSubview:titleLabel];
        
        UITextField * textField = [[UITextField alloc] init];
        textField.frame = CGRectMake(CGRectGetMaxX(titleLabel.frame), i * 40, screenWidth - DRMargin - CGRectGetMaxX(titleLabel.frame), 40);
        textField.tintColor = DRDefaultColor;
        textField.textColor = DRBlackTextColor;
        textField.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
        textField.placeholder = placeholders[i];
        textField.delegate = self;
        textField.textAlignment = NSTextAlignmentRight;
        [logisticsView addSubview:textField];
        
        if (i == 0) {
            self.companyTF = textField;
            textField.userInteractionEnabled = NO;
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = textField.frame;
            [button addTarget:self action:@selector(selectPickerView) forControlEvents:UIControlEventTouchUpInside];
            [logisticsView addSubview:button];
            
            //选择物流公司
            DRShipmentDeliveryPickerView * deliveryPickerView = [[DRShipmentDeliveryPickerView alloc] init];
            self.deliveryPickerView = deliveryPickerView;
            __weak typeof(self) wself = self;
            deliveryPickerView.block = ^(NSDictionary * deliveryDic){
                wself.deliveryDic = deliveryDic;
                wself.companyTF.text = deliveryDic[@"name"];
                wself.deliveryModel.deliveryDic = deliveryDic;
            };
        }else if (i == 1)
        {
            self.numberTF = textField;
        }
        //分割线
        UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, i * 40, screenWidth, 1)];
        line.backgroundColor = DRWhiteLineColor;
        [logisticsView addSubview:line];
    }
}
- (void)selectPickerView
{
    [self endEditing:YES];
    [self.deliveryPickerView show];
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.numberTF == textField) {
        self.deliveryModel.logisticsNum = textField.text;
    }
}
- (void)setDeliveryModel:(DRDeliveryAddressModel *)deliveryModel
{
    _deliveryModel = deliveryModel;
    self.nameLabel.text = [NSString stringWithFormat:@"%@", _deliveryModel.address.receiverName];
    self.phoneLabel.text = [NSString stringWithFormat:@"%@",_deliveryModel.address.phone];
    self.addressLabel.text = [NSString stringWithFormat:@"%@%@%@",_deliveryModel.address.province, _deliveryModel.address.city, _deliveryModel.address.address];
    self.companyTF.text = _deliveryModel.deliveryDic[@"name"];
    self.numberTF.text = _deliveryModel.logisticsNum;
    
    //frame
    CGSize titleLabelSize = [@"收货地址：" sizeWithLabelFont:[UIFont systemFontOfSize:DRGetFontSize(24)]];
    CGFloat titleLabelW = titleLabelSize.width;
    
    self.nameLabel.frame = CGRectMake(DRMargin + titleLabelW, 9 + DRMargin, _deliveryModel.nameSize.width, _deliveryModel.nameSize.height);
    self.phoneLabel.frame = CGRectMake(DRMargin + titleLabelW, CGRectGetMaxY(self.nameLabel.frame) + DRMargin, _deliveryModel.phoneSize.width, _deliveryModel.phoneSize.height);
    self.addressLabel.frame = CGRectMake(DRMargin + titleLabelW , CGRectGetMaxY(self.phoneLabel.frame) + DRMargin, _deliveryModel.addressSize.width, _deliveryModel.addressSize.height);
    
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
        }
    }
    
    self.logisticsView.y = CGRectGetMaxY(self.addressLabel.frame) + DRMargin;
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
