//
//  DRChangeRealNameViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/4/17.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRChangeRealNameViewController.h"
#import "DRCardNoTextField.h"
#import "DRAddImageManage.h"
#import "DRValidateTool.h"

@interface DRChangeRealNameViewController ()<AddImageManageDelegate>

@property (nonatomic, weak) UITextField * realNameTF;
@property (nonatomic, weak) UITextField * personalIdTF;
@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) DRAddImageManage * addImageManage;
@property (nonatomic, strong) NSMutableArray *uploadImageUrlArray;

@end

@implementation DRChangeRealNameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"实名认证";
    [self setupChilds];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveBarDidClick)];
    
    UIView * contentView = [[UIView alloc] init];
    contentView.frame = CGRectMake(0, 9, screenWidth, 0);
    contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];

    NSArray * titles = @[@"真实姓名", @"身份证号"];
    for (int i = 0; i < 2; i++) {
        UILabel * titleLabel = [[UILabel alloc]init];
        titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        titleLabel.textColor = DRBlackTextColor;
        titleLabel.text = titles[i];
        CGSize titleLabelSize = [titleLabel.text sizeWithLabelFont:titleLabel.font];
        titleLabel.frame = CGRectMake(DRMargin,i * DRCellH, titleLabelSize.width, DRCellH);
        [contentView addSubview:titleLabel];
        
        UITextField * textField;
        if (i == 0) {
            textField = [[UITextField alloc] init];
        }else
        {
            textField = [[DRCardNoTextField alloc] init];
        }
        textField.frame = CGRectMake(CGRectGetMaxX(titleLabel.frame) + DRMargin, i * DRCellH, screenWidth - 2 * DRMargin - CGRectGetMaxX(titleLabel.frame), DRCellH);
        textField.textAlignment = NSTextAlignmentRight;
        textField.borderStyle = UITextBorderStyleNone;
        textField.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        textField.tintColor = DRDefaultColor;
        [self.view addSubview:textField];
        if (i == 0) {
            textField.placeholder = @"请输入真实姓名";
            self.realNameTF = textField;
        }else if (i == 1)
        {
            textField.placeholder = @"请输入身份证号码";
            self.personalIdTF = textField;
        }
        [contentView addSubview:textField];
        //分割线
        UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, (DRCellH - 1) * i + DRCellH, screenWidth, 1)];
        line.backgroundColor = DRWhiteLineColor;
        [contentView addSubview:line];
    }
    
    UILabel * pictureLabel = [[UILabel alloc]init];
    pictureLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    pictureLabel.textColor = DRBlackTextColor;
    pictureLabel.text = @"上传身份证照片";
    CGSize titleLabelSize = [pictureLabel.text sizeWithLabelFont:pictureLabel.font];
    pictureLabel.frame = CGRectMake(DRMargin, 2 * DRCellH + 5, titleLabelSize.width, 25);
    [contentView addSubview:pictureLabel];
    
    CGFloat maxY = CGRectGetMaxY(pictureLabel.frame) + 10;
    CGFloat imageViewHW = 100;
    CGFloat padding = (screenWidth - 2 * imageViewHW) / 3;
    NSArray * pictureTitles = @[@"身份证正面", @"身份证反面", @"本人手持身份照照片（需露出身份照正面照及本人清晰五官）"];
    for (int i = 0; i < 3; i++) {
        UIImageView * imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(padding + (imageViewHW + padding) * (i % 2), maxY + (imageViewHW + 40) * (i / 2), imageViewHW, imageViewHW);
        imageView.tag = i;
        imageView.image = [UIImage imageNamed:@"addImage"];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [contentView addSubview:imageView];
        [self.imageViews addObject:imageView];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDidClick:)];
        [imageView addGestureRecognizer:tap];
        
        UILabel * titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
        titleLabel.textColor = DRGrayTextColor;
        titleLabel.text = pictureTitles[i];
        titleLabel.numberOfLines = 0;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        CGSize titleLabelSize = [titleLabel.text sizeWithFont:titleLabel.font maxSize:CGSizeMake(imageViewHW + 100, MAXFLOAT)];
        CGFloat titleLabelH = titleLabelSize.height;
        if (titleLabelH < 25) {
            titleLabelH = 25;
        }
        titleLabel.frame = CGRectMake(0, CGRectGetMaxY(imageView.frame) + 5, imageViewHW + 100, titleLabelH);
        titleLabel.centerX = imageView.centerX;
        [contentView addSubview:titleLabel];
        
        if (i == 2) {
            contentView.height = CGRectGetMaxY(titleLabel.frame) + 10;
        }
    }
    
    //温馨提示
    UILabel * promptLabel = [[UILabel alloc] init];
    promptLabel.numberOfLines = 0;
    NSString * promptStr = @"*实名信息不允许修改，请认真填写";
    NSMutableAttributedString * promptAttStr = [[NSMutableAttributedString alloc]initWithString:promptStr];
    [promptAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(22)] range:NSMakeRange(0, promptAttStr.length)];
    [promptAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(0, promptAttStr.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5];
    [promptAttStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, promptAttStr.length)];
    promptLabel.attributedText = promptAttStr;
    CGSize promptSize = [promptLabel.attributedText boundingRectWithSize:CGSizeMake(screenWidth - DRMargin * 2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    promptLabel.frame = CGRectMake(DRMargin, CGRectGetMaxY(contentView.frame) + 10, screenWidth - DRMargin * 2, promptSize.height);
    [self.view addSubview:promptLabel];
}

- (void)imageViewDidClick:(UIGestureRecognizer *)ges
{
    [self.view endEditing:YES];
    
    self.addImageManage = [[DRAddImageManage alloc] init];
    self.addImageManage.viewController = self;
    self.addImageManage.delegate = self;
    self.addImageManage.type = 0;
    self.addImageManage.tag = ges.view.tag;
    [self.addImageManage addImage];
}

- (void)imageManageCropImage:(UIImage *)image
{
    UIImageView * imageView = self.imageViews[self.addImageManage.tag];
    imageView.image = image;
}

- (void)saveBarDidClick
{
    [self.view endEditing:YES];
    
    if (self.realNameTF.text.length == 0)//不是姓名
    {
        [MBProgressHUD showError:@"请输入真实姓名"];
        return;
    }

    if (![DRValidateTool validateIdentityCard:self.personalIdTF.text])//不是手机号码
    {
        [MBProgressHUD showError:@"您输入的身份证号格式不对"];
        return;
    }
    
    for (UIImageView * imageView in self.imageViews) {
        NSInteger index = [self.imageViews indexOfObject:imageView];
        if (imageView.image == [UIImage imageNamed:@"addImage"]) {
            if (index == 0) {
                [MBProgressHUD showError:@"请输入身份证正面"];
                return;
            }else if (index == 1)
            {
                [MBProgressHUD showError:@"请输入身份证反面"];
                return;
            }else if (index == 2)
            {
                [MBProgressHUD showError:@"本人手持身份照照片"];
                return;
            }
        }
    }

    [self uploadImageWithImageView:self.imageViews.firstObject];
}

- (void)uploadImageWithImageView:(UIImageView *)imageView
{
    [DRHttpTool uploadWithImage:imageView.image currentIndex:[self.imageViews indexOfObject:imageView] + 1 totalCount:self.imageViews.count Success:^(id json) {
        if (SUCCESS) {
            [self.uploadImageUrlArray addObject:json[@"picUrl"]];
        }else
        {
            [self.uploadImageUrlArray addObject:@""];
        }
        if (self.uploadImageUrlArray.count == self.imageViews.count)
        {
            [self upData];
        }else
        {
            [self uploadImageWithImageView:self.imageViews[self.uploadImageUrlArray.count]];
        }
    } Failure:^(NSError *error) {
        [self.uploadImageUrlArray addObject:@""];
        if (self.uploadImageUrlArray.count == self.imageViews.count)
        {
            [self upData];
        }else
        {
            [self uploadImageWithImageView:self.imageViews[self.uploadImageUrlArray.count]];
        }
    }  Progress:^(float percent) {
        
    }];
}

- (void)upData
{
    NSString * idCardImgURL = self.uploadImageUrlArray[0];
    NSString * idCardBackImgURL = self.uploadImageUrlArray[1];
    NSString * idCardHoldImg = self.uploadImageUrlArray[2];
   
    NSDictionary *bodyDic = @{
                              @"idCardImg":idCardImgURL,
                              @"idCardBackImg":idCardBackImgURL,
                              @"idCardHoldImg":idCardHoldImg,
                              @"realName":self.realNameTF.text,
                              @"personalId":self.personalIdTF.text
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U06",
                              @"userId":UserId,
                              };
    [MBProgressHUD showMessage:@"上传中" toView:self.view];
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            DRUser *user = [DRUserDefaultTool user];
            user.realName = self.realNameTF.text;
            user.personalId = self.personalIdTF.text;
            [DRUserDefaultTool saveUser:user];
            [self.navigationController popViewControllerAnimated:YES];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        DRLog(@"error:%@",error);
    }];
}

- (NSMutableArray *)imageViews
{
    if (!_imageViews) {
        _imageViews = [NSMutableArray array];
    }
    return _imageViews;
}


- (NSMutableArray *)uploadImageUrlArray
{
    if (!_uploadImageUrlArray) {
        _uploadImageUrlArray = [NSMutableArray array];
    }
    return _uploadImageUrlArray;
}

@end
