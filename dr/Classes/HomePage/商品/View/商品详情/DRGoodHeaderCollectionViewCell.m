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
#import "DRDateTool.h"

@interface DRGoodHeaderCollectionViewCell ()<SDCycleScrollViewDelegate, XLPhotoBrowserDelegate, XLPhotoBrowserDatasource>

@property (nonatomic, weak) SDCycleScrollView *cycleScrollView;
@property (nonatomic,weak) UILabel * goodMailTypeLabel;
@property (nonatomic,weak) UILabel * goodSaleCountLabel;
@property (nonatomic, weak) UIImageView *videoIconImageView;
@property (nonatomic,weak) UILabel * videoLabel;
@property (nonatomic,weak) UIView * activityRemindView;
@property (nonatomic,weak) UILabel * activityTimeLabel;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, weak) UIView * specificationView;
@property (nonatomic, weak) UIScrollView * specificationScrollView;
@property (nonatomic, weak) UILabel * specificationCountLabel;
@property (nonatomic, strong) NSMutableArray * specificationImageViews;

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
    goodNameLabel.font = [UIFont boldSystemFontOfSize:DRGetFontSize(32)];
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
    
    //活动提示
    CGFloat activityRemindViewH = 110;
    UIView * activityRemindView = [[UIView alloc] initWithFrame:CGRectMake(0, cycleScrollView.height - activityRemindViewH, screenWidth, activityRemindViewH)];
    self.activityRemindView = activityRemindView;
    activityRemindView.backgroundColor = DRColor(10, 178, 137, 0.5);
    activityRemindView.hidden = YES;
    [self addSubview:activityRemindView];

    UILabel * activityRemindLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 0, screenWidth * 0.7 - DRMargin, activityRemindViewH)];
    activityRemindLabel.textColor = [UIColor whiteColor];
    activityRemindLabel.numberOfLines = 0;
    NSMutableAttributedString *activityRemindAttStr = [[NSMutableAttributedString alloc] initWithString:@"十点秒杀活动进行中\n每天10:00-12:00，特价商品先到先得"];
    [activityRemindAttStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:DRGetFontSize(55)] range:NSMakeRange(0, 9)];
    [activityRemindAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(30)] range:NSMakeRange(9, activityRemindAttStr.length - 9)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;
    [activityRemindAttStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, activityRemindAttStr.length)];
    activityRemindLabel.attributedText = activityRemindAttStr;
    [activityRemindView addSubview:activityRemindLabel];
    
    UILabel * activityTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth * 0.7, 0, screenWidth * 0.3, activityRemindViewH)];
    self.activityTimeLabel = activityTimeLabel;
    activityTimeLabel.backgroundColor = DRColor(10, 178, 137, 0.5);
    activityTimeLabel.textColor = [UIColor whiteColor];
    activityTimeLabel.numberOfLines = 0;
    activityTimeLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [activityRemindView addSubview:activityTimeLabel];
    
    //规格
    UIView * specificationView = [[UILabel alloc] init];
    self.specificationView = specificationView;
    specificationView.backgroundColor = [UIColor whiteColor];
    specificationView.hidden = YES;
    [self addSubview:specificationView];
    
    //分割线
    UIView * specificationLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    specificationLine.backgroundColor = DRWhiteLineColor;
    [specificationView addSubview:specificationLine];
    
    UITapGestureRecognizer *specificationTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(specificationDidTap)];
    specificationView.userInteractionEnabled = YES;
    [specificationView addGestureRecognizer:specificationTap];
    
    UILabel * specificationTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 7, screenWidth - 2 * DRMargin, 20)];
    NSMutableAttributedString *specificationTitleAttStr = [[NSMutableAttributedString alloc] initWithString:@"选择 请选择商品规格"];
    [specificationTitleAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(0, 3)];
    [specificationTitleAttStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(3, specificationTitleAttStr.length - 3)];
    [specificationTitleAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(24)] range:NSMakeRange(0, specificationTitleAttStr.length)];
    specificationTitleLabel.attributedText = specificationTitleAttStr;
    [specificationView addSubview:specificationTitleLabel];
    
    CGFloat specificationScrollViewX = 42;
    CGFloat specificationScrollViewW = screenWidth - specificationScrollViewX - 120 - DRMargin - 20;
    UIScrollView * specificationScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(specificationScrollViewX, 35, specificationScrollViewW, 30)];
    self.specificationScrollView = specificationScrollView;
    specificationScrollView.showsHorizontalScrollIndicator = NO;
    [specificationView addSubview:specificationScrollView];
    
    CGFloat specificationImageViewWH = 30;
    for (int i = 0; i < 20; i++) {
        UIImageView *specificationImageView = [[UIImageView alloc] initWithFrame:CGRectMake((specificationImageViewWH + DRMargin) * i, 0, specificationImageViewWH, specificationImageViewWH)];
        specificationImageView.image = [UIImage imageNamed:@"placeholder"];
        specificationImageView.hidden = YES;
        specificationImageView.contentMode = UIViewContentModeScaleAspectFill;
        specificationImageView.layer.masksToBounds = YES;
        specificationImageView.layer.cornerRadius = 3;
        [specificationScrollView addSubview:specificationImageView];
        [self.specificationImageViews addObject:specificationImageView];
    }
    
    UILabel * specificationCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth - 120 - 20, 35, 120, 30)];
    self.specificationCountLabel = specificationCountLabel;
    specificationCountLabel.backgroundColor = DRColor(240, 240, 240, 1);
    specificationCountLabel.textColor = DRGrayTextColor;
    specificationCountLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    specificationCountLabel.textAlignment = NSTextAlignmentCenter;
    specificationCountLabel.layer.masksToBounds = YES;
    specificationCountLabel.layer.cornerRadius = 5;
    [specificationView addSubview:specificationCountLabel];
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
    
    BOOL inActive = [self inActiveDuration];
    if (inActive) {
        self.activityRemindView.hidden = NO;
        [self addSetDeadlineTimer];
    }else
    {
        self.activityRemindView.hidden = YES;
        [self removeSetDeadlineTimer];
    }
    
    //frame
    self.goodNameLabel.frame = _goodHeaderFrameModel.goodNameLabelF;
    self.goodDetailLabel.frame = _goodHeaderFrameModel.goodDetailLabelF;
    self.goodPriceLabel.frame = _goodHeaderFrameModel.goodPriceLabelF;
    self.goodMailTypeLabel.frame = _goodHeaderFrameModel.goodMailTypeLabelF;
    self.goodSaleCountLabel.frame = _goodHeaderFrameModel.goodSaleCountLabelF;
    if (_goodHeaderFrameModel.goodModel.specifications.count > 0) {
        self.specificationView.frame = _goodHeaderFrameModel.specificationViewF;
        self.specificationView.hidden = NO;
        self.specificationCountLabel.text = [NSString stringWithFormat:@"共%ld种分类可选", _goodHeaderFrameModel.goodModel.specifications.count];
        for (int i = 0; i < self.specificationImageViews.count; i++) {
            UIImageView * specificationImageView = self.specificationImageViews[i];
            specificationImageView.hidden = YES;
            if (i < _goodHeaderFrameModel.goodModel.specifications.count) {
                specificationImageView.hidden = NO;
                DRGoodSpecificationModel * specificationModel = _goodHeaderFrameModel.goodModel.specifications[i];
                NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, specificationModel.picUrl,smallPicUrl];
                [specificationImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                if (i == _goodHeaderFrameModel.goodModel.specifications.count - 1) {
                    self.specificationScrollView.contentSize = CGSizeMake(CGRectGetMaxX(specificationImageView.frame) + DRMargin, self.specificationScrollView.height);
                }
            }
        }
    }else
    {
        self.specificationView.hidden = YES;
    }
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

- (void)specificationDidTap
{
    if (_delegate && [_delegate respondsToSelector:@selector(goodHeaderCollectionViewSpecificationDidClickWithCell:)]) {
        [_delegate goodHeaderCollectionViewSpecificationDidClickWithCell:self];
    }
}
#pragma mark - 倒计时
- (void)addSetDeadlineTimer
{
    if(self.timer == nil && self.goodHeaderFrameModel.goodModel)//空才创建
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(setTimeLabelText) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        [self.timer fire];
    }
}

- (void)setTimeLabelText
{
    //倒计时
    DRGoodModel * goodModel = self.goodHeaderFrameModel.goodModel;
    NSDateComponents * components = [DRDateTool getDeltaDateFromTimestamp: goodModel.systemTime fromFormat:@"yyyyy-MM-dd HH:mm:ss" toTimestamp: goodModel.dayEndTime ToFormat:@"yyyy-MM-dd HH:mm:ss"];
    if (components.hour > 0 || components.minute > 0 || components.second > 0) {
        NSString * activityTimeStr = [NSString stringWithFormat:@"距特价结束\n仅剩\n%02ld:%02ld:%02ld", components.hour, components.minute, components.second];
        NSMutableAttributedString *activityTimeAttStr = [[NSMutableAttributedString alloc] initWithString:activityTimeStr];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        [activityTimeAttStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, activityTimeAttStr.length)];
        self.activityTimeLabel.attributedText = activityTimeAttStr;
        goodModel.systemTime = goodModel.systemTime + 1000;
    }else
    {
        self.activityRemindView.hidden = YES;
        [self removeSetDeadlineTimer];
    }
}

#pragma mark - 工具
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

- (BOOL)inActiveDuration
{
    DRGoodModel * goodModel = self.goodHeaderFrameModel.goodModel;
    if (goodModel.systemTime == 0 || goodModel.beginTime == 0 || goodModel.endTime == 0 || goodModel.dayBeginTime == 0 || goodModel.dayEndTime == 0 || goodModel.discountPrice == 0) {
        return NO;
    }
    long long systemTime = goodModel.systemTime;
    return systemTime > goodModel.beginTime && systemTime < goodModel.endTime && systemTime > goodModel.dayBeginTime && systemTime < goodModel.dayEndTime;
}

#pragma  mark - 销毁对象
- (void)removeSetDeadlineTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)dealloc
{
    [self removeSetDeadlineTimer];
}

#pragma mark - 初始化
- (NSMutableArray *)specificationImageViews
{
    if (!_specificationImageViews) {
        _specificationImageViews = [NSMutableArray array];
    }
    return _specificationImageViews;
}

@end
