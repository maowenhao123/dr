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
@property (nonatomic,weak) UIImageView * imageView1;
@property (nonatomic,weak) UIImageView * imageView2;
@property (nonatomic, strong) DRAddImageManage * addImageManage;
@property (nonatomic,assign) BOOL haveImage1;
@property (nonatomic,assign) BOOL haveImage2;
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
    contentView.frame = CGRectMake(0, 9, screenWidth, 2 * DRCellH + 170);
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
    
    CGFloat imageViewY = CGRectGetMaxY(pictureLabel.frame) + 5;
    CGFloat imageViewHW = 100;
    CGFloat padding = (screenWidth - 2 * imageViewHW) / 3;
    NSArray * pictureTitles = @[@"身份证正面",@"身份证反面"];
    for (int i = 0; i < 2; i++) {
        UIImageView * imageView = [[UIImageView alloc] init];
        if (i == 0) {
            self.imageView1 = imageView;
        }else
        {
            self.imageView2 = imageView;
        }
        imageView.frame = CGRectMake(padding + (imageViewHW + padding) * i, imageViewY, imageViewHW, imageViewHW);
        imageView.tag = i;
        imageView.image = [UIImage imageNamed:@"addImage"];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [contentView addSubview:imageView];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDidClick:)];
        [imageView addGestureRecognizer:tap];
        
        UILabel * pictureTitleLabel = [[UILabel alloc]init];
        pictureTitleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
        pictureTitleLabel.textColor = DRGrayTextColor;
        pictureTitleLabel.text = pictureTitles[i];
        CGSize titleLabelSize = [pictureTitleLabel.text sizeWithLabelFont:pictureTitleLabel.font];
        pictureTitleLabel.frame = CGRectMake(0, CGRectGetMaxY(imageView.frame) + 5, titleLabelSize.width, 25);
        pictureTitleLabel.centerX = imageView.centerX;
        [contentView addSubview:pictureTitleLabel];
    }
    
    //温馨提示
    UILabel * promptLabel = [[UILabel alloc]init];
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
    if (self.addImageManage.tag == 0) {
        self.imageView1.image = image;
        self.haveImage1 = YES;
    }else
    {
        self.imageView2.image = image;
        self.haveImage2 = YES;
    }
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
    
    if (!self.haveImage1) {
        [MBProgressHUD showError:@"请输入身份证正面"];
        return;
    }
    
    if (!self.haveImage2) {
        [MBProgressHUD showError:@"请输入身份证反面"];
        return;
    }
    
    [self uploadImageWithImage:self.imageView1.image back:NO];
}

- (void)uploadImageWithImage:(UIImage *)image back:(BOOL)back
{
    NSInteger currentIndex = 0;
    if (back == NO) {
        currentIndex = 1;
    }else
    {
        currentIndex = 2;
    }
    [DRHttpTool uploadWithImage:image currentIndex:currentIndex totalCount:2 Success:^(id json) {
        if (SUCCESS) {
            NSDictionary * dic = @{
                                   @"back":@(back),
                                   @"picUrl":json[@"picUrl"]
                                   };
            [self.uploadImageUrlArray addObject:dic];
        }
        if (currentIndex == 1)
        {
            [self uploadImageWithImage:self.imageView2.image back:YES];
        }else
        {
            [self upData];
        }
    } Failure:^(NSError *error) {
        [self.uploadImageUrlArray addObject:@""];
        if (currentIndex == 1)
        {
            [self uploadImageWithImage:self.imageView2.image back:YES];
        }else
        {
            [self upData];
        }
    }  Progress:^(float percent) {
        
    }];
}

- (void)upData
{
    NSString * idCardImgURL;
    NSString * idCardBackImgURL;
    for (NSDictionary * dic in self.uploadImageUrlArray) {
        if ([dic[@"back"] boolValue] == YES) {
            idCardBackImgURL = dic[@"picUrl"];
        }else
        {
            idCardImgURL = dic[@"picUrl"];
        }
    }
    
    NSDictionary *bodyDic = @{
                              @"idCardImg":idCardImgURL,
                              @"idCardBackImg":idCardBackImgURL,
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

- (NSMutableArray *)uploadImageUrlArray
{
    if (!_uploadImageUrlArray) {
        _uploadImageUrlArray = [NSMutableArray array];
    }
    return _uploadImageUrlArray;
}

@end
