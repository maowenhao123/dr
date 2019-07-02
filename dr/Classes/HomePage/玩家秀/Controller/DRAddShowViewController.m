//
//  DRAddShowViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/4/5.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRAddShowViewController.h"
#import "DRLoginViewController.h"
#import "DRAddShowSuccessViewController.h"
#import "DRTextView.h"
#import "DRAddMultipleImageView.h"

@interface DRAddShowViewController ()<AddMultipleImageViewDelegate>

@property (nonatomic, weak) UITextField * titleTF;
@property (nonatomic, weak) DRTextView * detailTV;
@property (nonatomic, weak) DRAddMultipleImageView * addImageView;
@property (nonatomic, weak) UILabel * promptLabel;
@property (nonatomic, strong) NSMutableArray *uploadImageUrlArray;

@end

@implementation DRAddShowViewController

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    UINavigationBar *navBar = [UINavigationBar appearance];
    // 设置背景
    [navBar setBackgroundImage:[UIImage ImageFromColor:[UIColor whiteColor] WithRect:CGRectMake(0, 0, screenWidth, statusBarH + navBarH)] forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"发表文章";
    [self setupChilds];
}

- (void)setupChilds
{
    //rightBarButtonItem
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(publishShowBarDidClick)];
    
    //白色背景
    UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 9, screenWidth, 134)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];
    
    //标题
    UITextField * titleTF = [[UITextField alloc] initWithFrame:CGRectMake(DRMargin, 0, screenWidth - 2 * DRMargin, 45)];
    self.titleTF = titleTF;
    titleTF.placeholder = @"文章标题，不要超过20个字符哦";
    titleTF.textColor = DRBlackTextColor;
    titleTF.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    titleTF.tintColor = DRDefaultColor;
    [contentView addSubview:titleTF];
    
    //分割线
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleTF.frame), screenWidth, 1)];
    line.backgroundColor = DRWhiteLineColor;
    [contentView addSubview:line];
    
    //描述
    DRTextView * detailTV = [[DRTextView alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(line.frame), screenWidth - 2 * 5, 88)];
    self.detailTV = detailTV;
    detailTV.textColor = DRBlackTextColor;
    detailTV.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    detailTV.myPlaceholder = @"文章内容，介绍一下吧，好的文章上头条哦";
    detailTV.tintColor = DRDefaultColor;
    [contentView addSubview:detailTV];
    
    //添加图片
    DRAddMultipleImageView * addImageView = [[DRAddMultipleImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(contentView.frame) + 9, screenWidth, 0)];
    self.addImageView = addImageView;
    addImageView.titleLabel.text = @"添加图片(最多9张)";
    addImageView.maxImageCount = 9;
    addImageView.height = [addImageView getViewHeight];
    addImageView.delegate = self;
    [self.view addSubview:addImageView];
    
    //温馨提示
    UILabel * promptLabel = [[UILabel alloc] init];
    self.promptLabel = promptLabel;
    promptLabel.numberOfLines = 0;
    NSString * promptStr = @"注意：玩家秀场仅供玩家分享关于多肉植物的图片、感想等，任何有广告意图的帖子都将被删除，特此提醒，谢谢配合！";
    NSMutableAttributedString * promptAttStr = [[NSMutableAttributedString alloc]initWithString:promptStr];
    [promptAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(24)] range:NSMakeRange(0, promptAttStr.length)];
    [promptAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(0, promptAttStr.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5];
    [promptAttStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, promptAttStr.length)];
    promptLabel.attributedText = promptAttStr;
    CGSize promptSize = [promptLabel.attributedText boundingRectWithSize:CGSizeMake(screenWidth - DRMargin * 2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    promptLabel.frame = CGRectMake(DRMargin, CGRectGetMaxY(addImageView.frame) + 10, screenWidth - DRMargin * 2, promptSize.height);
    [self.view addSubview:promptLabel];
}

- (void)viewHeightchange
{
    self.promptLabel.y = CGRectGetMaxY(self.addImageView.frame) + 10;
}

- (void)publishShowBarDidClick
{
    if((!UserId || !Token))//未登录
    {
        DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
        [self presentViewController:loginVC animated:YES completion:nil];
        return;
    }
    
    if (DRStringIsEmpty(self.titleTF.text))//未输入标题
    {
        [MBProgressHUD showError:@"请输入文章标题"];
        return;
    }
    if (DRStringIsEmpty(self.detailTV.text))//未输入标题
    {
        [MBProgressHUD showError:@"请输入文章内容"];
        return;
    }
    
    if (DRArrayIsEmpty(self.addImageView.images))//未添加图片
    {
        [MBProgressHUD showError:@"请添加图片"];
        return;
    }
    self.uploadImageUrlArray = [NSMutableArray array];
    [self uploadImageWithImage:self.addImageView.images[0]];
}

- (void)uploadImageWithImage:(UIImage *)image
{
    [DRHttpTool uploadWithImage:image currentIndex:[self.addImageView.images indexOfObject:image] + 1 totalCount:self.addImageView.images.count Success:^(id json) {
        if (SUCCESS) {
            [self.uploadImageUrlArray addObject:json[@"picUrl"]];
        }else
        {
            [self.uploadImageUrlArray addObject:@""];
        }
        if (self.uploadImageUrlArray.count == self.addImageView.images.count)
        {
            [self uploadShow];
        }else
        {
            [self uploadImageWithImage:self.addImageView.images[self.uploadImageUrlArray.count]];
        }
    } Failure:^(NSError *error) {
        [self.uploadImageUrlArray addObject:@""];
        if (self.uploadImageUrlArray.count == self.addImageView.images.count)
        {
            [self uploadShow];
        }else
        {
            [self uploadImageWithImage:self.addImageView.images[self.uploadImageUrlArray.count]];
        }
    }  Progress:^(float percent) {
        
    }];
}

- (void)uploadShow
{
    NSDictionary *bodyDic = @{
                              @"subject":self.titleTF.text,
                              @"content":self.detailTV.text,
                              @"picUrls":self.uploadImageUrlArray,
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"A01",
                              @"userId":UserId,
                              };
    [MBProgressHUD showMessage:@"发布中..." toView:self.view];
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            if (_delegate && [_delegate respondsToSelector:@selector(addShowSuccess)]) {
                [_delegate addShowSuccess];
            }
            DRAddShowSuccessViewController * addShowVC = [[DRAddShowSuccessViewController alloc] init];
            addShowVC.showId = json[@"id"];
            [self.navigationController pushViewController:addShowVC animated:YES];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        DRLog(@"error:%@",error);
    }];
}

#pragma mark - 初始化
- (NSMutableArray *)uploadImageUrlArray
{
    if (!_uploadImageUrlArray) {
        _uploadImageUrlArray = [NSMutableArray array];
    }
    return _uploadImageUrlArray;
}

@end
