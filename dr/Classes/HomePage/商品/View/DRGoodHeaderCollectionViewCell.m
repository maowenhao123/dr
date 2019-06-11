//
//  DRGoodHeaderCollectionViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/11/29.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRGoodHeaderCollectionViewCell.h"
#import "SDCycleScrollView.h"
#import "XLPhotoBrowser.h"

@interface DRGoodHeaderCollectionViewCell ()<SDCycleScrollViewDelegate, XLPhotoBrowserDelegate, XLPhotoBrowserDatasource>

@property (nonatomic, weak) SDCycleScrollView *cycleScrollView;
@property (nonatomic,weak) UILabel * goodMailTypeLabel;
@property (nonatomic,weak) UILabel * goodSaleCountLabel;
@property (nonatomic, weak) UIImageView *videoIconImageView;
@property (nonatomic,weak) UILabel * videoLabel;

@end

@implementation DRGoodHeaderCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupChildViews];
    }
    return self;
}
- (void)setupChildViews
{
    self.backgroundColor = [UIColor whiteColor];
    //轮播图
    SDCycleScrollView * cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, screenWidth, 390) delegate:self placeholderImage:[UIImage imageNamed:@"banner_placeholder"]];
    self.cycleScrollView = cycleScrollView;
    cycleScrollView.autoScroll = NO;
    cycleScrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
    cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    cycleScrollView.currentPageDotColor = [UIColor whiteColor]; // 自定义分页控件小圆标颜色
    cycleScrollView.pageDotColor = [UIColor colorWithWhite:1 alpha:0.44];
    [self addSubview:cycleScrollView];
    
    //视频
    CGFloat videoIconImageViewW = 90;
    CGFloat videoIconImageViewH = 40;
    UIImageView *videoIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake((cycleScrollView.width - videoIconImageViewW) / 2, cycleScrollView.height - 15 - videoIconImageViewH, videoIconImageViewW, videoIconImageViewH)];
    self.videoIconImageView = videoIconImageView;
    videoIconImageView.image = [UIImage imageNamed:@"good_detail_video_icon"];
    videoIconImageView.userInteractionEnabled = YES;
    videoIconImageView.hidden = YES;
    [cycleScrollView addSubview:videoIconImageView];
    
    UITapGestureRecognizer *videoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoPlayDidTap)];
    [videoIconImageView addGestureRecognizer:videoTap];
    //视频时间
    UILabel * videoLabel = [[UILabel alloc] initWithFrame:CGRectMake(videoIconImageViewH, 0, videoIconImageViewW - videoIconImageViewH - 5, videoIconImageViewH)];
    self.videoLabel = videoLabel;
    videoLabel.textColor = [UIColor whiteColor];
    videoLabel.font = [UIFont systemFontOfSize:DRGetFontSize(29)];
    videoLabel.adjustsFontSizeToFitWidth = YES;
    videoLabel.text = @"00:00";
    [videoIconImageView addSubview:videoLabel];
    
    //商品名
    UILabel * goodNameLabel = [[UILabel alloc] init];
    self.goodNameLabel = goodNameLabel;
    goodNameLabel.textColor = DRBlackTextColor;
    goodNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    goodNameLabel.numberOfLines = 0;
    [self addSubview:goodNameLabel];
    
    //详情
    UILabel * goodDetailLabel = [[UILabel alloc] init];
    self.goodDetailLabel = goodDetailLabel;
    goodDetailLabel.textColor = DRGrayTextColor;
    goodDetailLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    goodDetailLabel.numberOfLines = 0;
    [self addSubview:goodDetailLabel];
    
    //商品价格
    UILabel * goodPriceLabel = [[UILabel alloc] init];
    self.goodPriceLabel = goodPriceLabel;
    [self addSubview:goodPriceLabel];
    
    //配送方式
    UILabel * goodMailTypeLabel = [[UILabel alloc] init];
    self.goodMailTypeLabel = goodMailTypeLabel;
    goodMailTypeLabel.textColor = DRGrayTextColor;
    goodMailTypeLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [self addSubview:goodMailTypeLabel];
    
    //销量
    UILabel * goodSaleCountLabel = [[UILabel alloc] init];
    self.goodSaleCountLabel = goodSaleCountLabel;
    goodSaleCountLabel.textColor = DRGrayTextColor;
    goodSaleCountLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [self addSubview:goodSaleCountLabel];
}

#pragma mark - SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    XLPhotoBrowser * photoBrowser = [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:index imageCount:[self getPicUrlStrArr].count datasource:self];
    photoBrowser.delegate = self;
    photoBrowser.browserStyle = XLPhotoBrowserStyleSimple;
}

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index
{
    if (index == 0 && !DRStringIsEmpty(_goodHeaderFrameModel.goodModel.video)) {
        self.videoIconImageView.hidden = NO;
    }else
    {
        self.videoIconImageView.hidden = YES;
    }
}

#pragma mark - XLPhotoBrowserDatasource
- (NSURL *)photoBrowser:(XLPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    return [self getPicUrlStrArr][index];
}

#pragma mark - 设置数据
- (void)setGoodHeaderFrameModel:(DRGoodHeaderFrameModel *)goodHeaderFrameModel
{
    _goodHeaderFrameModel = goodHeaderFrameModel;
    
    self.cycleScrollView.imageURLStringsGroup = [self getPicUrlStrArr];
    if (!DRStringIsEmpty(_goodHeaderFrameModel.goodModel.video)) {
        self.videoIconImageView.hidden = NO;
        int videoTime = [_goodHeaderFrameModel.goodModel.videoTime intValue] / 1000;
        self.videoLabel.text = [NSString stringWithFormat:@"%02d:%02d", videoTime / 60, videoTime % 60];
    }
    self.goodNameLabel.text = _goodHeaderFrameModel.goodModel.name;
    if (_goodHeaderFrameModel.detailAttStr.length > 0) {
        self.goodDetailLabel.attributedText = _goodHeaderFrameModel.detailAttStr;
    }
    self.goodPriceLabel.attributedText = _goodHeaderFrameModel.goodPriceAttStr;
    
    self.goodMailTypeLabel.text = _goodHeaderFrameModel.mailTypeStr;
    self.goodSaleCountLabel.text = [NSString stringWithFormat:@"销量：%@", [DRTool getNumber:_goodHeaderFrameModel.goodModel.sellCount]];
    
    //frame
    self.goodNameLabel.frame = _goodHeaderFrameModel.goodNameLabelF;
    self.goodDetailLabel.frame = _goodHeaderFrameModel.goodDetailLabelF;
    self.goodPriceLabel.frame = _goodHeaderFrameModel.goodPriceLabelF;
    self.goodMailTypeLabel.frame = _goodHeaderFrameModel.goodMailTypeLabelF;
    self.goodSaleCountLabel.frame = _goodHeaderFrameModel.goodSaleCountLabelF;
}

- (void)videoPlayDidTap
{
    for (UIView * subView in self.barView.subviews) {
        subView.hidden = YES;
        if (subView.tag == 1) {
            subView.hidden = NO;
        }
    }
    if (_delegate && [_delegate respondsToSelector:@selector(goodHeaderCollectionViewPlayDidClickWithCell:)]) {
        [_delegate goodHeaderCollectionViewPlayDidClickWithCell:self];
    }
}

- (NSArray *)getPicUrlStrArr
{
    NSMutableArray * morePicUrlStrArr = [NSMutableArray array];
    NSString * spreadPicsUrlStr = [NSString stringWithFormat:@"%@%@", baseUrl, _goodHeaderFrameModel.goodModel.spreadPics];
    [morePicUrlStrArr addObject:spreadPicsUrlStr];
    if (!DRStringIsEmpty(_goodHeaderFrameModel.goodModel.morePics)) {
        NSArray * morePicArr = [_goodHeaderFrameModel.goodModel.morePics componentsSeparatedByString:@"|"];
        for (NSString * str in morePicArr) {
            NSString * morePicUrlStr = [NSString stringWithFormat:@"%@%@",baseUrl,str];
            [morePicUrlStrArr addObject:morePicUrlStr];
        }
    }
    return morePicUrlStrArr;
}



@end
