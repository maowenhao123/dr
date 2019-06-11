//
//  DRSubmitOrderAddressView.m
//  dr
//
//  Created by 毛文豪 on 2018/3/28.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRSubmitOrderAddressView.h"

@interface DRSubmitOrderAddressView ()

@property (nonatomic, weak) UILabel *nameLabel;//名字
@property (nonatomic, weak) UILabel *phoneLabel;//电话
@property (nonatomic, weak) UILabel *addressLabel;//地址
@property (nonatomic, weak) UIImageView * addressImageView;
@property (nonatomic,weak) UIImageView * accessoryImageView;
@property (nonatomic,weak) UILabel *noAddressLabel;
@property (nonatomic,weak) DRAddressLine * line;

@end

@implementation DRSubmitOrderAddressView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupChildViews];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupChildViews];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)setupChildViews
{
    self.backgroundColor = [UIColor whiteColor];
    //名字
    UILabel * nameLabel = [[UILabel alloc] init];
    self.nameLabel = nameLabel;
    nameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(32)];
    nameLabel.textColor = DRBlackTextColor;
    nameLabel.hidden = YES;
    [self addSubview:nameLabel];
    
    //电话
    UILabel * phoneLabel = [[UILabel alloc] init];
    self.phoneLabel = phoneLabel;
    phoneLabel.font = [UIFont systemFontOfSize:DRGetFontSize(32)];
    phoneLabel.textColor = DRBlackTextColor;
    phoneLabel.hidden = YES;
    [self addSubview:phoneLabel];
    
    //角标
    CGFloat accessoryImageViewWH = 13;
    CGFloat accessoryImageViewY = (84 - accessoryImageViewWH) / 2;
    UIImageView * accessoryImageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth - DRMargin - accessoryImageViewWH, accessoryImageViewY, accessoryImageViewWH, accessoryImageViewWH)];
    self.accessoryImageView = accessoryImageView;
    accessoryImageView.image = [UIImage imageNamed:@"big_black_accessory_icon"];
    [self addSubview:accessoryImageView];
    
    //地址
    UIImageView * addressImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pay_address_icon"]];
    self.addressImageView = addressImageView;
    addressImageView.frame = CGRectMake(DRMargin, 0, 18, 18);
    addressImageView.hidden = YES;
    [self addSubview:addressImageView];
    
    UILabel * addressLabel = [[UILabel alloc]init];
    self.addressLabel = addressLabel;
    addressLabel.numberOfLines = 0;
    addressLabel.textColor = DRBlackTextColor;
    addressLabel.hidden = YES;
    [self addSubview:addressLabel];
    
    //未选择地址
    UILabel * noAddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 0, screenWidth - 2 * DRMargin - 7, self.height)];
    self.noAddressLabel = noAddressLabel;
    noAddressLabel.text = @"您还未选择地址";
    noAddressLabel.font = [UIFont systemFontOfSize:DRGetFontSize(32)];
    noAddressLabel.textColor = DRBlackTextColor;
    noAddressLabel.hidden = NO;
    [self addSubview:noAddressLabel];
    
    //条纹
    DRAddressLine * line = [[DRAddressLine alloc] initWithFrame:CGRectMake(0, 85, screenWidth, 7)];
    self.line = line;
    line.backgroundColor = [UIColor whiteColor];
    [self addSubview:line];
}

- (void)setAddressModel:(DRAddressModel *)addressModel
{
    _addressModel = addressModel;
    
    self.nameLabel.hidden = NO;
    self.phoneLabel.hidden = NO;
    self.addressImageView.hidden = NO;
    self.addressLabel.hidden = NO;
    self.noAddressLabel.hidden = YES;
    
    //设置数据
    self.nameLabel.text = _addressModel.name;
    self.phoneLabel.text = _addressModel.phone;
    NSMutableAttributedString * attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@",_addressModel.province, _addressModel.city, _addressModel.address]];
    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(26)] range:NSMakeRange(0, attStr.length)];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;//行间距
    [attStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attStr.length)];
    self.addressLabel.attributedText = attStr;
    
    //设置frame
    CGFloat addressLabelX = DRMargin + 18 + 5;
    CGFloat addressLabelW = screenWidth - addressLabelX - DRMargin - 15 - 5;
    CGSize nameLabelSize = [self.nameLabel.text sizeWithLabelFont:self.nameLabel.font];
    self.nameLabel.frame = CGRectMake(addressLabelX, DRMargin, nameLabelSize.width, nameLabelSize.height);
    
    CGSize phoneLabelSize = [self.phoneLabel.text sizeWithLabelFont:self.phoneLabel.font];
    self.phoneLabel.frame = CGRectMake(CGRectGetMaxX(self.nameLabel.frame) + DRMargin, DRMargin, phoneLabelSize.width, phoneLabelSize.height);
    
    CGSize addressLabelSize = [self.addressLabel.attributedText boundingRectWithSize:CGSizeMake(addressLabelW, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    self.addressLabel.frame = CGRectMake(addressLabelX, CGRectGetMaxY(self.nameLabel.frame) + DRMargin, addressLabelSize.width, addressLabelSize.height);
    
    self.addressImageView.centerY = self.addressLabel.centerY;
    
    self.line.y = CGRectGetMaxY(self.addressLabel.frame) + DRMargin;
    
    self.height = CGRectGetMaxY(self.line.frame) - 1;
    self.accessoryImageView.centerY = self.centerY;
}

@end

@implementation DRAddressLine

- (void)drawRect:(CGRect)rect {
    [[UIImage imageNamed:@"address_ stripe"] drawAsPatternInRect:CGRectMake(0, 0, screenWidth, 7)];
}

@end

