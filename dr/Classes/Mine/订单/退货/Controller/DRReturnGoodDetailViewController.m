//
//  DRReturnGoodDetailViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/6/25.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRReturnGoodDetailViewController.h"
#import "DRShipmentDetailViewController.h"
#import "DRChatViewController.h"
#import "DRShowMultipleImageView.h"
#import "DRTextView.h"
#import "DRReturnGoodModel.h"
#import "XLPhotoBrowser.h"
#import "DRIMTool.h"

@interface DRReturnGoodDetailViewController ()<ShowMultipleImageViewDelegate, XLPhotoBrowserDatasource>

@property (nonatomic,weak) UIScrollView * scrollView;
@property (nonatomic,weak) UIView * contentView;
@property (nonatomic,weak) UILabel * statusLabel;
@property (nonatomic,weak) UIImageView * goodImageView;
@property (nonatomic,weak) UILabel * goodNameLabel;
@property (nonatomic, weak) UILabel *goodSpecificationLabel;//商品规格
@property (nonatomic,weak) UILabel * goodPriceLabel;
@property (nonatomic,weak) UIButton *orderButton;
@property (nonatomic, weak) UILabel * countLabel;
@property (nonatomic, weak) UILabel * moneyLabel;
@property (nonatomic, weak) DRTextView *detailTV;
@property (nonatomic,weak) DRShowMultipleImageView * showImageView;
@property (nonatomic,weak) UIView *memoView;
@property (nonatomic,weak) DRTextView *memoTV;
@property (nonatomic,strong) DRReturnGoodModel * returnGoodModel;

@end

@implementation DRReturnGoodDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"退款详情";
    [self getData];
    [self setupChilds];
}
- (void)getData
{
    NSDictionary *bodyDic = [NSDictionary dictionary];
    if (!DRStringIsEmpty(self.goodsId) && !DRStringIsEmpty(self.orderId)) {
        bodyDic = @{
            @"goodsId":self.goodsId,
            @"orderId":self.orderId,
        };
    }else if (!DRStringIsEmpty(self.returnGoodId))
    {
        bodyDic = @{
            @"id":self.returnGoodId,
        };
    }else
    {
        return;
    }
    NSMutableDictionary *bodyDic_mu = [NSMutableDictionary dictionaryWithDictionary:bodyDic];
    if (!DRStringIsEmpty(self.specificationId)) {
        [bodyDic_mu setObject:self.specificationId forKey:@"specificationId"];
    }
    if (!DRStringIsEmpty(self.id)) {
        [bodyDic_mu setObject:self.id forKey:@"id"];
    }
    
    NSDictionary *headDic = @{
        @"digest":[DRTool getDigestByBodyDic:bodyDic_mu],
        @"cmd":@"S28",
        @"userId":UserId,
    };
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic_mu success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            DRReturnGoodModel *returnGoodModel = [DRReturnGoodModel mj_objectWithKeyValues:json[@"orderGoodsRefund"]];
            self.returnGoodModel = returnGoodModel;
            [self setData];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
- (void)setupChilds
{
    if (self.isSeller) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"联系买家" style:UIBarButtonItemStylePlain target:self action:@selector(chat)];
    }
    //scrollView
    UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH)];
    self.scrollView = scrollView;
    scrollView.backgroundColor = DRBackgroundColor;
    [self.view addSubview:scrollView];
    
    //contentView
    UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0)];
    self.contentView = contentView;
    contentView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:contentView];
    
    //订单状态
    UIView * statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 67)];
    statusView.backgroundColor = DRDefaultColor;
    [contentView addSubview:statusView];
    
    UILabel * statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 0, screenWidth - 2 * DRMargin, statusView.height)];
    self.statusLabel = statusLabel;
    statusLabel.textColor = [UIColor whiteColor];
    statusLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [statusView addSubview:statusLabel];
    
    //商品图片
    UIImageView * goodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, CGRectGetMaxY(statusView.frame) + 7, 76, 76)];
    self.goodImageView = goodImageView;
    goodImageView.contentMode = UIViewContentModeScaleAspectFill;
    goodImageView.layer.masksToBounds = YES;
    [contentView addSubview:goodImageView];
    
    //商品名称
    UILabel * goodNameLabel = [[UILabel alloc] init];
    self.goodNameLabel = goodNameLabel;
    goodNameLabel.textColor = DRBlackTextColor;
    goodNameLabel.numberOfLines = 0;
    goodNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [contentView addSubview:goodNameLabel];
    
    //商品规格
    UILabel * goodSpecificationLabel = [[UILabel alloc] init];
    self.goodSpecificationLabel = goodSpecificationLabel;
    goodSpecificationLabel.backgroundColor = DRWhiteLineColor;
    goodSpecificationLabel.textColor = DRGrayTextColor;
    goodSpecificationLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    goodSpecificationLabel.textAlignment = NSTextAlignmentCenter;
    goodSpecificationLabel.layer.masksToBounds = YES;
    [contentView addSubview:goodSpecificationLabel];
    
    //商品价格
    UILabel * goodPriceLabel = [[UILabel alloc] init];
    self.goodPriceLabel = goodPriceLabel;
    goodPriceLabel.textColor = DRBlackTextColor;
    goodPriceLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [contentView addSubview:goodPriceLabel];
    
    //查看订单
    if (self.isSeller) {
        UIButton *orderButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.orderButton = orderButton;
        [orderButton setTitle:@"订单详情" forState:UIControlStateNormal];
        [orderButton setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
        orderButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
        [orderButton addTarget:self action:@selector(orderButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
        orderButton.layer.masksToBounds = YES;
        orderButton.layer.cornerRadius = 4;
        orderButton.layer.borderColor = DRGrayTextColor.CGColor;
        orderButton.layer.borderWidth = 1;
        [contentView addSubview:orderButton];
    }
    
    //分割线
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(goodImageView.frame) + 7, screenWidth, 1)];
    line1.backgroundColor = DRWhiteLineColor;
    [contentView addSubview:line1];
    
    NSArray * labelTitles = @[@"退款数量", @"退款总额"];
    for (int i = 0; i < labelTitles.count; i++) {
        //选择退款原因
        UILabel * label = [[UILabel alloc] init];
        label.text = labelTitles[i];
        label.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        label.textColor = DRBlackTextColor;
        CGSize labelSize = [label.text sizeWithLabelFont:label.font];
        label.frame = CGRectMake(DRMargin, CGRectGetMaxY(line1.frame) + DRCellH * i, labelSize.width, DRCellH);
        [contentView addSubview:label];
        
        UILabel * conetntLabel = [[UILabel alloc] init];
        if (i == 0) {
            self.countLabel = conetntLabel;
        }else
        {
            self.moneyLabel = conetntLabel;
        }
        CGFloat conetntLabelX = CGRectGetMaxX(label.frame) + DRMargin;
        conetntLabel.frame = CGRectMake(conetntLabelX, CGRectGetMaxY(line1.frame) + DRCellH * i, screenWidth - conetntLabelX - DRMargin, DRCellH);
        conetntLabel.textAlignment = NSTextAlignmentRight;
        conetntLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        conetntLabel.textColor = DRBlackTextColor;
        [contentView addSubview:conetntLabel];
        
        //分割线
        UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(line1.frame) + (DRCellH - 1) * (i + 1), screenWidth, 1)];
        line2.backgroundColor = DRWhiteLineColor;
        [contentView addSubview:line2];
    }
    
    //退款说明
    UILabel * detailLabel = [[UILabel alloc] init];
    detailLabel.text = @"退款说明";
    detailLabel.textColor = DRBlackTextColor;
    detailLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    CGSize detailLabelSize = [detailLabel.text sizeWithLabelFont:detailLabel.font];
    detailLabel.frame = CGRectMake(DRMargin, 9 + CGRectGetMaxY(line1.frame) + 2 * DRCellH, detailLabelSize.width, detailLabelSize.height);
    [contentView addSubview:detailLabel];
    
    //退款描述
    DRTextView *detailTV = [[DRTextView alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(detailLabel.frame) + 1, screenWidth - 2 * 5, 100)];
    self.detailTV = detailTV;
    detailTV.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    detailTV.textColor = DRBlackTextColor;
    detailTV.tintColor = DRDefaultColor;
    detailTV.userInteractionEnabled = NO;
    [contentView addSubview:detailTV];
    
    //添加图片
    DRShowMultipleImageView * showImageView = [[DRShowMultipleImageView alloc] init];
    self.showImageView = showImageView;
    showImageView.frame = CGRectMake(0, CGRectGetMaxY(detailTV.frame), screenWidth, [showImageView getViewHeight]);
    showImageView.titleLabel.text = @"退款截图";
    showImageView.delegate = self;
    showImageView.height = [showImageView getViewHeight];
    [contentView addSubview:showImageView];
    
    //分割线
    UIView * line3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    line3.backgroundColor = DRWhiteLineColor;
    [showImageView addSubview:line3];
    
    //备注
    UIView *memoView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(showImageView.frame), screenWidth, 0)];
    self.memoView = memoView;
    memoView.backgroundColor = [UIColor whiteColor];
    [contentView addSubview:memoView];
    
    UIView * line4 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    line4.backgroundColor = DRWhiteLineColor;
    [memoView addSubview:line4];
    
    UILabel * memoLabel = [[UILabel alloc] init];
    memoLabel.text = @"备注";
    memoLabel.textColor = DRBlackTextColor;
    memoLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    CGSize memoLabelSize = [memoLabel.text sizeWithLabelFont:memoLabel.font];
    memoLabel.frame = CGRectMake(DRMargin, 9, memoLabelSize.width, memoLabelSize.height);
    [memoView addSubview:memoLabel];
    
    DRTextView *memoTV = [[DRTextView alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(memoLabel.frame) + 1, screenWidth - 2 * 5, 100)];
    self.memoTV = memoTV;
    memoTV.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    memoTV.textColor = DRBlackTextColor;
    memoTV.tintColor = DRDefaultColor;
    memoTV.userInteractionEnabled = NO;
    [memoView addSubview:memoTV];
    
    memoView.height = CGRectGetMaxY(memoTV.frame);
    
    contentView.height = CGRectGetMaxY(memoView.frame);
    scrollView.contentSize = CGSizeMake(screenWidth, CGRectGetMaxY(contentView.frame));
}

- (void)chat
{
    DRChatViewController *chatVC = [[DRChatViewController alloc] initWithConversationChatter:self.returnGoodModel.user.id conversationType:EMConversationTypeChat];
    chatVC.title = self.returnGoodModel.user.nickName;
    NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@", baseUrl, self.returnGoodModel.user.headImg];
    [DRIMTool saveUserProfileWithUsername:self.returnGoodModel.user.id forNickName:self.returnGoodModel.user.nickName avatarURLPath:imageUrlStr];
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (void)orderButtonDidClick
{
    DRShipmentDetailViewController * shipmentDetailVC = [[DRShipmentDetailViewController alloc] init];
    shipmentDetailVC.orderId = self.returnGoodModel.orderId;
    [self.navigationController pushViewController:shipmentDetailVC animated:YES];
}

- (void)setData
{
    if ([self.returnGoodModel.status intValue] == 0) {
        self.statusLabel.text = @"未申请退款";
    }else if ([self.returnGoodModel.status intValue] == 10) {
        self.statusLabel.text = @"待审核退款";
    }else if ([self.returnGoodModel.status intValue] == 20) {
        self.statusLabel.text = @"审核通过";
    }else if ([self.returnGoodModel.status intValue] == -1) {
        self.statusLabel.text = @"驳回";
    }else if ([self.returnGoodModel.status intValue] == 100) {
        self.statusLabel.text = @"已退款";
    }else
    {
        self.statusLabel.text = @"未知状态";
    }
    
    
    if (DRObjectIsEmpty(self.returnGoodModel.specification)) {
        NSString * urlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, self.returnGoodModel.goods.spreadPics, smallPicUrl];
        [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }else
    {
        NSString * urlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, self.returnGoodModel.specification.picUrl, smallPicUrl];
        [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        self.goodSpecificationLabel.text = self.returnGoodModel.specification.name;
    }
    
    self.goodPriceLabel.text = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[self.returnGoodModel.goods.price doubleValue] / 100]];
    self.countLabel.text = [NSString stringWithFormat:@"%@", self.returnGoodModel.count];
    NSString * actualRefund = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[self.returnGoodModel.actualRefund doubleValue] / 100]];
    NSString * couponPrice = [NSString stringWithFormat:@"(抵扣-%@)", [DRTool formatFloat:[self.returnGoodModel.couponPrice doubleValue] / 100]];
    NSMutableAttributedString * moneyAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", actualRefund, couponPrice]];
    [moneyAttStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:[moneyAttStr.string rangeOfString:actualRefund]];
    [moneyAttStr addAttribute:NSForegroundColorAttributeName value:DRRedTextColor range:[moneyAttStr.string rangeOfString:couponPrice]];
    self.moneyLabel.attributedText = moneyAttStr;
    self.detailTV.text = self.returnGoodModel.description_;
    self.memoTV.text = self.returnGoodModel.memo;
    
    if (!DRArrayIsEmpty(self.returnGoodModel.pictures)) {
        [self.showImageView setImagesWithImageUrlStrs:self.returnGoodModel.pictures];
    }else
    {
        self.showImageView.hidden = YES;
        self.showImageView.height = 0;
    }
    
    //frame
    CGFloat goodNameLabelX = CGRectGetMaxX(self.goodImageView.frame) + 10;
    if (DRStringIsEmpty(self.returnGoodModel.goods.description_)) {
        self.goodNameLabel.text = self.returnGoodModel.goods.name;
        
        CGSize goodNameLabelSize = [self.goodNameLabel.text sizeWithFont:self.goodNameLabel.font maxSize:CGSizeMake(screenWidth - goodNameLabelX - 10, 40)];
        self.goodNameLabel.frame = CGRectMake(goodNameLabelX, self.goodImageView.y + 3, goodNameLabelSize.width, goodNameLabelSize.height);
    }else
    {
        NSMutableAttributedString * nameAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", self.returnGoodModel.goods.name, self.returnGoodModel.goods.description_]];
        [nameAttStr addAttribute:NSFontAttributeName value:self.goodNameLabel.font range:NSMakeRange(0, nameAttStr.length)];
        [nameAttStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, self.returnGoodModel.goods.name.length)];
        [nameAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange( self.returnGoodModel.goods.name.length, nameAttStr.length - self.returnGoodModel.goods.name.length)];
        self.goodNameLabel.attributedText = nameAttStr;
        
        CGSize goodNameLabelSize = [self.goodNameLabel.attributedText boundingRectWithSize:CGSizeMake(screenWidth - goodNameLabelX - 10, 40) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        self.goodNameLabel.frame = CGRectMake(goodNameLabelX, self.goodImageView.y + 3, goodNameLabelSize.width, goodNameLabelSize.height);
    }
    
    if (DRObjectIsEmpty(self.returnGoodModel.specification)) {
        self.goodSpecificationLabel.hidden = YES;
    }else
    {
        self.goodSpecificationLabel.hidden = NO;
        self.goodSpecificationLabel.text = self.returnGoodModel.specification.name;
        CGSize goodSpecificationLabelSize = [self.goodSpecificationLabel.text sizeWithLabelFont:self.goodSpecificationLabel.font];
        CGFloat goodSpecificationLabelH = goodSpecificationLabelSize.height + 4;
        self.goodSpecificationLabel.frame = CGRectMake(self.goodNameLabel.x, CGRectGetMaxY(self.goodNameLabel.frame) + 10, goodSpecificationLabelSize.width + 15, goodSpecificationLabelH);
        self.goodSpecificationLabel.layer.cornerRadius = goodSpecificationLabelH / 2;
    }
    
    CGSize goodPriceLabelSize = [self.goodPriceLabel.text sizeWithLabelFont:self.goodPriceLabel.font];
    CGFloat goodPriceLabelX = goodNameLabelX;
    self.goodPriceLabel.frame = CGRectMake(goodPriceLabelX, CGRectGetMaxY(self.goodImageView.frame) - 3 - goodPriceLabelSize.height, goodPriceLabelSize.width, goodPriceLabelSize.height);
    
    self.orderButton.frame = CGRectMake(screenWidth - 70 - DRMargin, 0, 70, 25);
    self.orderButton.centerY = self.goodPriceLabel.centerY;
    
    CGSize detailTVSize = [self.detailTV.text sizeWithFont:self.detailTV.font maxSize:CGSizeMake(self.detailTV.width, MAXFLOAT)];
    self.detailTV.height = detailTVSize.height + 2 * 9;
    
    self.showImageView.y = CGRectGetMaxY(self.detailTV.frame);
    
    CGSize memoTVSize = [self.memoTV.text sizeWithFont:self.memoTV.font maxSize:CGSizeMake(self.memoTV.width, MAXFLOAT)];
    self.memoView.y = CGRectGetMaxY(self.showImageView.frame);
    self.memoTV.height = memoTVSize.height + 2 * 9;
    
    if (DRStringIsEmpty(self.returnGoodModel.memo)) {
        self.memoView.hidden = YES;
        self.contentView.height = CGRectGetMaxY(self.showImageView.frame);
        self.scrollView.contentSize = CGSizeMake(screenWidth, CGRectGetMaxY(self.contentView.frame));
    }else
    {
        self.memoView.hidden = NO;
        self.contentView.height = CGRectGetMaxY(self.showImageView.frame);
        self.scrollView.contentSize = CGSizeMake(screenWidth, CGRectGetMaxY(self.memoView.frame));
    }
}
- (void)imageViewDidClickWithIndex:(NSInteger)index
{
    XLPhotoBrowser * photoBrowser = [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:index imageCount:self.returnGoodModel.pictures.count datasource:self];
    photoBrowser.browserStyle = XLPhotoBrowserStyleSimple;
}
#pragma mark - XLPhotoBrowserDatasource
- (UIImage *)photoBrowser:(XLPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    return [UIImage imageNamed:@"placeholder"];
}
- (NSURL *)photoBrowser:(XLPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    NSMutableArray *URLArray = [NSMutableArray array];
    NSArray * imageUrls = self.returnGoodModel.pictures;
    for (NSString * imageUrl in imageUrls) {
        NSString * urlStr = [NSString stringWithFormat:@"%@%@",baseUrl, imageUrl];
        [URLArray addObject:[NSURL URLWithString:urlStr]];
    }
    return URLArray[index];
}
- (UIView *)photoBrowser:(XLPhotoBrowser *)browser sourceImageViewForIndex:(NSInteger)index
{
    return self.showImageView.imageViews[index];
}

@end
