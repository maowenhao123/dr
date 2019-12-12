//
//  DRAttentionShopTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/5/17.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRAttentionShopTableViewCell.h"

@interface DRAttentionShopTableViewCell ()

@property (nonatomic, weak) UIImageView *avatarImageView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *fansLabel;
@property (nonatomic, weak) UIImageView * bigImageView;
@property (nonatomic, weak) UIImageView * smallImageView1;
@property (nonatomic, weak) UIImageView * smallImageView2;
@property (nonatomic,strong) NSMutableArray *goodDataArray;

@end

@implementation DRAttentionShopTableViewCell

+ (DRAttentionShopTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"AttentionShopTableViewCellId";
    DRAttentionShopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRAttentionShopTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 9)];
    lineView.backgroundColor = DRBackgroundColor;
    [self addSubview:lineView];
    
    //头像
    UIImageView * avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, CGRectGetMaxY(lineView.frame) + 9, 36, 36)];
    self.avatarImageView = avatarImageView;
    avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.layer.cornerRadius = avatarImageView.width / 2;
    [self addSubview:avatarImageView];
    
    //店名
    UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(avatarImageView.frame) + 5, CGRectGetMaxY(lineView.frame) + 7, 200, 20)];
    self.nameLabel = nameLabel;
    nameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    nameLabel.textColor = DRBlackTextColor;
    [self addSubview:nameLabel];
    
    //粉丝
    UIImageView * favoriteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(nameLabel.x, CGRectGetMaxY(nameLabel.frame), 11, 11)];
    favoriteImageView.image = [UIImage imageNamed:@"favorite_icon"];
    [self addSubview:favoriteImageView];
    
    UILabel * fansLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(favoriteImageView.frame) + 2, CGRectGetMaxY(nameLabel.frame), 100, 20)];
    self.fansLabel = fansLabel;
    fansLabel.textColor = DRGrayTextColor;
    fansLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [self addSubview:fansLabel];
    favoriteImageView.centerY = fansLabel.centerY;
    
    //进店看看
    UIButton * goShopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [goShopButton setTitle:@"进店看看>" forState:UIControlStateNormal];
    [goShopButton setTitleColor:DRGrayTextColor forState:UIControlStateNormal];
    goShopButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(22)];
    CGSize goShopButtonSize = [goShopButton.currentTitle sizeWithLabelFont:goShopButton.titleLabel.font];
    goShopButton.frame = CGRectMake(screenWidth - DRMargin - goShopButtonSize.width, CGRectGetMaxY(lineView.frame), goShopButtonSize.width, 53);
    [goShopButton addTarget:self action:@selector(goShopButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:goShopButton];
    
    //图片
    CGFloat padding = 5;
    CGFloat smallImageViewWH = (screenWidth -  4 * padding) / 3;
    CGFloat bigImageViewWH = 2 * smallImageViewWH + padding;
    
    for (int i = 0; i < 3; i++) {
        UIImageView * imageView = [[UIImageView alloc] init];
        if (i == 0) {
            self.bigImageView = imageView;
            imageView.frame = CGRectMake(padding, 9 + 53, bigImageViewWH, bigImageViewWH);
        }else if (i == 1)
        {
            self.smallImageView1 = imageView;
            imageView.frame = CGRectMake(CGRectGetMaxX(self.bigImageView.frame) + padding, 9 + 53, smallImageViewWH, smallImageViewWH);
        }else if (i == 2)
        {
            self.smallImageView2 = imageView;
            imageView.frame = CGRectMake(self.smallImageView1.x, CGRectGetMaxY(self.smallImageView1.frame) + padding, smallImageViewWH, smallImageViewWH);
        }
        imageView.tag = i;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.masksToBounds = YES;
        imageView.userInteractionEnabled = YES;
        imageView.image = [UIImage imageNamed:@"shop_no_good"];
        [self addSubview:imageView];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goodDidClick:)];
        [imageView addGestureRecognizer:tap];
    }
    
    //取消关注
    UIButton * cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(screenWidth - DRMargin - 65, CGRectGetMaxY(self.bigImageView.frame) + 7, 70, 27);
    [cancelButton setTitle:@"取消关注" forState:UIControlStateNormal];
    [cancelButton setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    cancelButton.layer.masksToBounds = YES;
    cancelButton.layer.cornerRadius = cancelButton.height / 2;
    cancelButton.layer.borderColor = DRGrayLineColor.CGColor;
    cancelButton.layer.borderWidth = 1;
    [cancelButton addTarget:self action:@selector(cancelButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelButton];
}
- (void)goShopButtonDidClick:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(attentionShopTableViewCell:goshopButtonDidClick:)]) {
        [_delegate attentionShopTableViewCell:self goshopButtonDidClick:button];
    }
}
- (void)goodDidClick:(UITapGestureRecognizer *)tap
{
    NSInteger tag = tap.view.tag;
    if (tag + 1 > self.goodDataArray.count) {
        return;
    }
    DRGoodModel * goodModel = self.goodDataArray[tag];
    if (_delegate && [_delegate respondsToSelector:@selector(attentionShopTableViewCell:goGoodWithGoodId:)]) {
        [_delegate attentionShopTableViewCell:self goGoodWithGoodId:goodModel.id];
    }
    
}
- (void)cancelButtonDidClick:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(attentionShopTableViewCell:cancelAttentionButtonDidClick:)]) {
        [_delegate attentionShopTableViewCell:self cancelAttentionButtonDidClick:button];
    }

}
- (void)setJson:(id)json
{
    _json = json;
    NSDictionary * dic = _json[@"store"];
    NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@",baseUrl, dic[@"storeImg"]];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
    
    self.nameLabel.text = dic[@"storeName"];
    self.fansLabel.text = [NSString stringWithFormat:@"%@",dic[@"fansCount"]];
    [self getGoodDataWithShopId:dic[@"id"]];
}
- (void)getGoodDataWithShopId:(NSString *)shopId
{
    if (!shopId) {
        return;
    }
    NSDictionary *bodyDic = @{
                              @"pageIndex":@(1),
                              @"pageSize":@(3),
                              @"storeId":shopId,
                              };
    
    NSDictionary *headDic = @{
                              @"cmd":@"B07",
                              };
    
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            self.goodDataArray = [DRGoodModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            [self setGoodData];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

- (void)setGoodData
{
    self.bigImageView.image = [UIImage imageNamed:@"shop_no_good"];
    self.smallImageView1.image = [UIImage imageNamed:@"shop_no_good"];
    self.smallImageView2.image = [UIImage imageNamed:@"shop_no_good"];
    for (int i = 0; i < self.goodDataArray.count; i++) {
        DRGoodModel * goodModel = self.goodDataArray[i];
        NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@%@",baseUrl,goodModel.spreadPics,smallPicUrl];
        if (i == 0) {
            [self.bigImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"shop_no_good"]];
        }else if (i == 1)
        {
            [self.smallImageView1 sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"shop_no_good"]];
        }else if (i == 2)
        {
            [self.smallImageView2 sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"shop_no_good"]];
        }
    }
}

#pragma mark - 初始化
- (NSMutableArray *)goodDataArray
{
    if (!_goodDataArray) {
        _goodDataArray = [NSMutableArray array];
    }
    return _goodDataArray;
}

@end
