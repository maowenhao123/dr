//
//  DRAddressTableViewCell.m
//  dr
//
//  Created by apple on 17/1/16.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRAddressTableViewCell.h"
#import "UIButton+DR.h"

@interface DRAddressTableViewCell ()

@property (nonatomic, weak) UILabel *nameLabel;//名字
@property (nonatomic, weak) UILabel *phoneLabel;//电话
@property (nonatomic, weak) UILabel *addressLabel;//地址
@property (nonatomic,weak) UIView * line;
@property (nonatomic, weak) UIButton * defaultButton;
@property (nonatomic,weak) UIButton * deleteButton;
@property (nonatomic,weak) UIButton * editButton;

@end

@implementation DRAddressTableViewCell

+ (DRAddressTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"AddressTableViewCell";
    DRAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRAddressTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    
    //名字
    UILabel * nameLabel = [[UILabel alloc]init];
    self.nameLabel = nameLabel;
    nameLabel.textColor = DRBlackTextColor;
    nameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [self addSubview:nameLabel];
    
    //电话
    UILabel * phoneLabel = [[UILabel alloc]init];
    self.phoneLabel = phoneLabel;
    phoneLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    phoneLabel.textColor = DRBlackTextColor;
    [self addSubview:phoneLabel];
    
    //地址
    UILabel * addressLabel = [[UILabel alloc]init];
    self.addressLabel = addressLabel;
    addressLabel.textColor = DRBlackTextColor;
    addressLabel.numberOfLines = 0;
    [self addSubview:addressLabel];
    
    //分割线
    UIView * line = [[UIView alloc] init];
    self.line = line;
    line.backgroundColor = DRWhiteLineColor;
    [self addSubview:line];
    
    //设为默认
    UIButton * defaultButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.defaultButton = defaultButton;
    [defaultButton setImage:[UIImage imageNamed:@"shoppingcar_not_selected"] forState:UIControlStateNormal];
    [defaultButton setImage:[UIImage imageNamed:@"shoppingcar_selected"] forState:UIControlStateSelected];
    [defaultButton setTitle:@"默认地址" forState:UIControlStateNormal];
    [defaultButton setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
    [defaultButton setTitleColor:DRDefaultColor forState:UIControlStateSelected];
    defaultButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    [defaultButton addTarget:self action:@selector(defaultButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:defaultButton];
    
    //删除
    UIButton * deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.deleteButton = deleteButton;
    [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    [deleteButton setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
    deleteButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    [deleteButton addTarget:self action:@selector(deleteButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:deleteButton];
    
    //编辑
    UIButton * editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.editButton = editButton;
    [editButton setTitle:@"编辑" forState:UIControlStateNormal];
    [editButton setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
    editButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    [editButton addTarget:self action:@selector(editButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:editButton];
}

- (void)defaultButtonDidClick:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(AddressTableViewCellDefaultButtonDidClick:withCell:)]) {
        [_delegate AddressTableViewCellDefaultButtonDidClick:button withCell:self];
    }
}

- (void)editButtonDidClick
{
    if (_delegate && [_delegate respondsToSelector:@selector(AddressTableViewCellEditButtonDidClickWithCell:)]) {
        [_delegate AddressTableViewCellEditButtonDidClickWithCell:self];
    }
}

- (void)deleteButtonDidClick
{
    if (_delegate && [_delegate respondsToSelector:@selector(AddressTableViewCellDeleteButtonDidClickWithCell:)]) {
        [_delegate AddressTableViewCellDeleteButtonDidClickWithCell:self];
    }
}

- (void)setAddressModel:(DRAddressModel *)addressModel
{
    _addressModel = addressModel;
    
    self.nameLabel.text = _addressModel.nameStr;
    self.phoneLabel.text = _addressModel.phoneStr;
    self.addressLabel.attributedText = _addressModel.addressAttStr;
    self.defaultButton.selected = [_addressModel.defaultv boolValue];
    
    //设置frame
    self.nameLabel.frame = _addressModel.nameLabelF;
    self.phoneLabel.frame = _addressModel.phoneLabelF;
    self.addressLabel.frame = _addressModel.addressLabelF;
    self.line.frame = _addressModel.lineF;
    self.defaultButton.frame = _addressModel.defaultButtonF;
    [self.defaultButton setButtonTitleWithImageAlignment:UIButtonTitleWithImageAlignmentLeft imgTextDistance:5];
    self.deleteButton.frame = _addressModel.deleteButtonF;
    self.editButton.frame = _addressModel.editButtonF;
    
}


@end
