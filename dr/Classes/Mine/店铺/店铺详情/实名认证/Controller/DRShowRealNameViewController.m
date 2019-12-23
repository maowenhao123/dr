//
//  DRShowRealNameViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/4/18.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShowRealNameViewController.h"
#import "XLPhotoBrowser.h"

@interface DRShowRealNameViewController ()<XLPhotoBrowserDatasource>

@property (nonatomic, strong) NSMutableArray * imageViews;

@end

@implementation DRShowRealNameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"实名认证";
    [self setupChilds];
}
- (void)setupChilds
{
    UIView * contentView = [[UIView alloc] init];
    contentView.frame = CGRectMake(0, 9, screenWidth, 2 * DRCellH + 120);
    contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];
    
    NSArray * titles = @[@"真实姓名",@"身份证号"];
    for (int i = 0; i < 2; i++) {
        UILabel * titleLabel = [[UILabel alloc]init];
        titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        titleLabel.textColor = DRBlackTextColor;
        titleLabel.text = titles[i];
        CGSize titleLabelSize = [titleLabel.text sizeWithLabelFont:titleLabel.font];
        titleLabel.frame = CGRectMake(DRMargin,i * DRCellH, titleLabelSize.width, DRCellH);
        [contentView addSubview:titleLabel];
        
        UILabel * detailLabel = [[UILabel alloc]init];
        detailLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
        detailLabel.textColor = DRGrayTextColor;
        DRUser *user = [DRUserDefaultTool user];
        if (i == 0) {//真实姓名
            NSMutableString *replaceString =  replaceString = [NSMutableString string];
            for(int i = 0; i < user.realName.length-1; i++)
            {
                [replaceString appendString:@"*"];
            }
            detailLabel.text = [user.realName stringByReplacingCharactersInRange:NSMakeRange(1, user.realName.length - 1) withString:replaceString];
        }else//身份证号
        {
            NSString * cardNo = user.personalId;
            if (cardNo.length == 18) {//是身份证号
                cardNo = [cardNo stringByReplacingCharactersInRange:NSMakeRange(3, 12) withString:@"************"];
            }
            detailLabel.text = cardNo;
        }
        CGSize detailLabelSize = [detailLabel.text sizeWithLabelFont:detailLabel.font];
        detailLabel.frame = CGRectMake(screenWidth - DRMargin - detailLabelSize.width, i * DRCellH, detailLabelSize.width, DRCellH);
        [contentView addSubview:detailLabel];
        
        //分割线
        UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, (DRCellH - 1) * i + DRCellH, screenWidth, 1)];
        line.backgroundColor = DRWhiteLineColor;
        [contentView addSubview:line];
    }
    
    DRUser *user = [DRUserDefaultTool user];
    CGFloat imageViewY = 2 * DRCellH + 10;
    CGFloat imageViewHW = 100;
    CGFloat padding = (screenWidth - 3 * imageViewHW) / 4;
    for (int i = 0; i < 3; i++) {
        UIImageView * imageView = [[UIImageView alloc] init];
        imageView.tag = i;
        imageView.frame = CGRectMake(padding + (imageViewHW + padding) * i, imageViewY, imageViewHW, imageViewHW);
        if (i == 0) {
            NSString * idCardImgUrlStr = [NSString stringWithFormat:@"%@%@",baseUrl,user.idCardImg];
            [imageView sd_setImageWithURL:[NSURL URLWithString:idCardImgUrlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        }else if (i == 1)
        {
            NSString * idCardBackImgUrlStr = [NSString stringWithFormat:@"%@%@",baseUrl,user.idCardBackImg];
            [imageView sd_setImageWithURL:[NSURL URLWithString:idCardBackImgUrlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        }else if (i == 2)
        {
            NSString * idCardBackImgUrlStr = [NSString stringWithFormat:@"%@%@",baseUrl,user.idCardHoldImg];
            [imageView sd_setImageWithURL:[NSURL URLWithString:idCardBackImgUrlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        }
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [contentView addSubview:imageView];
        [self.imageViews addObject:imageView];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDidClick:)];
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:tap];
    }
}

- (void)imageViewDidClick:(UIGestureRecognizer *)ges
{
    XLPhotoBrowser * photoBrowser = [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:ges.view.tag imageCount:3 datasource:self];
    photoBrowser.browserStyle = XLPhotoBrowserStyleSimple;
}

#pragma mark - XLPhotoBrowserDatasource
- (UIImage *)photoBrowser:(XLPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    UIImageView * imageView = self.imageViews[index];
    return imageView.image;
}

- (NSURL *)photoBrowser:(XLPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    DRUser *user = [DRUserDefaultTool user];
    NSMutableArray *URLArray = [NSMutableArray array];
    [URLArray addObject:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl, user.idCardImg]]];
    [URLArray addObject:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl, user.idCardBackImg]]];
    if (DRObjectIsEmpty(user.idCardHoldImg)) {
        [URLArray addObject:@""];
    }else
    {
        [URLArray addObject:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl, user.idCardHoldImg]]];
    }
    return URLArray[index];
}
- (UIView *)photoBrowser:(XLPhotoBrowser *)browser sourceImageViewForIndex:(NSInteger)index
{
    return self.imageViews[index];
}

#pragma mark - 初始化
- (NSMutableArray *)imageViews
{
    if (!_imageViews) {
        _imageViews = [NSMutableArray array];
    }
    return _imageViews;
}

@end
