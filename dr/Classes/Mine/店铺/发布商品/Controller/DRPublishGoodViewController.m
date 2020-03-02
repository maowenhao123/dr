//
//  DRPublishGoodViewController.m
//  dr
//
//  Created by 毛文豪 on 2018/4/8.
//  Copyright © 2018年 JG. All rights reserved.
//
#import "DRPublishGoodViewController.h"
#import "DRPublishGoodMessageView.h"
#import "DRPublishWholesaleGoodView.h"
#import "DRPublishSingleGoodView.h"
#import "DRBottomPickerView.h"
#import "EaseEmoji.h"

@interface DRPublishGoodViewController ()<PublishGoodMessageViewDelegate>

@property (nonatomic, weak) UIScrollView * scrollView;
@property (nonatomic, weak) DRPublishGoodMessageView * goodMessageView;
@property (nonatomic, weak) DRPublishSingleGoodView * singleView;
@property (nonatomic, weak) DRPublishWholesaleGoodView * wholesaleView;
@property (nonatomic, weak) UIButton * confirmBtn;
@property (nonatomic,strong) DRGoodModel *goodModel;
@property (nonatomic, strong) NSMutableArray *uploadImageUrlArray;
@property (nonatomic, copy) NSString *uploadVideoUrl;

@end

@implementation DRPublishGoodViewController

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
    self.title = @"发布商品";
    [self setupChilds];
    [self getData];
}

#pragma mark - 请求数据
- (void)getData
{
    if (!Token || !UserId || !self.goodId) {
        return;
    }
    NSDictionary *bodyDic = @{
                              @"id":self.goodId,
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"B08",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            DRGoodModel * goodModel = [DRGoodModel mj_objectWithKeyValues:json[@"goods"]];
            NSArray * specifications = [DRGoodSpecificationModel mj_objectArrayWithKeyValuesArray:json[@"goods"][@"specifications"]];
            for (DRGoodSpecificationModel * specificationModel in specifications) {
                specificationModel.price = [NSString stringWithFormat:@"%@", [DRTool formatFloat:[specificationModel.price doubleValue] / 100]];
            }
            goodModel.specifications = specifications;
            self.goodModel = goodModel;
            [self setData];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];;
        DRLog(@"error:%@",error);
    }];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    //scrollView
    UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH)];
    self.scrollView = scrollView;
    scrollView.backgroundColor = DRBackgroundColor;
    [self.view addSubview:scrollView];
    
    //商品信息
    DRPublishGoodMessageView * goodMessageView = [[DRPublishGoodMessageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0)];
    self.goodMessageView = goodMessageView;
    goodMessageView.delegate = self;
    [scrollView addSubview:goodMessageView];
    
    //一物一拍/零售
    DRPublishSingleGoodView * singleView = [[DRPublishSingleGoodView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.goodMessageView.frame), screenWidth, 0)];
    self.singleView = singleView;
    singleView.hidden = YES;
    __weak typeof(self) wself = self;
    singleView.hightChangeBlock = ^{
        wself.confirmBtn.y = CGRectGetMaxY(singleView.frame) + 29;
        wself.scrollView.contentSize = CGSizeMake(screenWidth, CGRectGetMaxY(self.confirmBtn.frame) + 10);
    };
    [scrollView addSubview:singleView];
    
    //批发
    DRPublishWholesaleGoodView * wholesaleView = [[DRPublishWholesaleGoodView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.goodMessageView.frame), screenWidth, 0)];
    self.wholesaleView = wholesaleView;
    wholesaleView.hightChangeBlock = ^{
        wself.confirmBtn.y = CGRectGetMaxY(wholesaleView.frame) + 29;
        wself.scrollView.contentSize = CGSizeMake(screenWidth, CGRectGetMaxY(self.confirmBtn.frame) + 10);
    };
    [scrollView addSubview:wholesaleView];
    
    //确定按钮
    UIButton * confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.confirmBtn = confirmBtn;
    confirmBtn.frame = CGRectMake(DRMargin, CGRectGetMaxY(wholesaleView.frame) + 29, screenWidth - 2 * DRMargin, 40);
    confirmBtn.backgroundColor = DRDefaultColor;
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [confirmBtn addTarget:self action:@selector(confirmBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    confirmBtn.layer.masksToBounds = YES;
    confirmBtn.layer.cornerRadius = confirmBtn.height / 2;
    [scrollView addSubview:confirmBtn];
    
    scrollView.contentSize = CGSizeMake(screenWidth, CGRectGetMaxY(confirmBtn.frame) + 10);
}

- (void)viewHeightchange
{
    self.singleView.y = CGRectGetMaxY(self.goodMessageView.frame) + 9;
    self.wholesaleView.y = CGRectGetMaxY(self.goodMessageView.frame) + 9;
    if ([self.goodMessageView.sellTypeLabel.text isEqualToString:@"一物一拍/零售"]) {//一物一拍/零售
        self.confirmBtn.y = CGRectGetMaxY(self.singleView.frame) + 29;
    }else
    {
        self.confirmBtn.y = CGRectGetMaxY(self.wholesaleView.frame) + 29;
    }
    self.scrollView.contentSize = CGSizeMake(screenWidth, CGRectGetMaxY(self.confirmBtn.frame) + 10);
}

#pragma mark - 按钮点击
- (void)sellTypeSelectPicker
{
    [self.view endEditing:YES];//取消其他键盘
    //选择销售类型
    NSArray * sellTypes = @[@"一物一拍/零售", @"批发"];
    NSInteger index = [sellTypes indexOfObject:self.goodMessageView.sellTypeLabel.text];
    if (DRStringIsEmpty(self.goodMessageView.sellTypeLabel.text)) {
        index = 0;
    }
    DRBottomPickerView * sellTypeChooseView = [[DRBottomPickerView alloc] initWithArray:sellTypes index:index];
    __weak typeof(self) wself = self;
    sellTypeChooseView.block = ^(NSInteger selectedIndex){
        wself.goodMessageView.sellTypeLabel.text = sellTypes[selectedIndex];
        if (selectedIndex == 0) {//一物一拍/零售
            wself.singleView.hidden = NO;
            wself.wholesaleView.hidden = YES;
            wself.confirmBtn.y = CGRectGetMaxY(self.singleView.frame) + 29;
            wself.scrollView.contentSize = CGSizeMake(screenWidth, CGRectGetMaxY(self.confirmBtn.frame) + 10);
        }else//批发
        {
            for (DRGoodSpecificationModel *specificationModel in self.goodModel.specifications) {
                specificationModel.delFlag = 1;
            }
            wself.singleView.hidden = YES;
            wself.wholesaleView.hidden = NO;
            wself.confirmBtn.y = CGRectGetMaxY(self.wholesaleView.frame) + 29;
            wself.scrollView.contentSize = CGSizeMake(screenWidth, CGRectGetMaxY(self.confirmBtn.frame) + 10);
        }
    };
    [sellTypeChooseView show];
}

#pragma mark - 设置数据
- (void)setData
{
    self.title = @"编辑商品";
    self.goodMessageView.nameTF.text = self.goodModel.name;
    self.goodMessageView.sortTF.text = [NSString stringWithFormat:@"%@ %@", self.goodModel.categoryName, self.goodModel.subjectName];
    self.goodMessageView.descriptionTV.text = self.goodModel.description_;
    
    if (!DRStringIsEmpty(self.goodModel.categoryId) && !DRStringIsEmpty(self.goodModel.categoryName)) {
        NSDictionary *categoryDic = @{
                                      @"name":self.goodModel.categoryName,
                                      @"id":self.goodModel.categoryId
                                      };
        self.goodMessageView.categoryDic = categoryDic;
    }
    
    if (!DRStringIsEmpty(self.goodModel.subjectId) && !DRStringIsEmpty(self.goodModel.subjectName)) {
        NSDictionary *subjectDic = @{
                                     @"name":self.goodModel.subjectName,
                                     @"id":self.goodModel.subjectId
                                     };
        self.goodMessageView.subjectDic = subjectDic;
    }
    
    //图文
    if (self.goodModel.richTexts.count > 0) {
        self.goodMessageView.detailTF.placeholder = @"已编辑";
        NSMutableAttributedString *detailAttStr = [[NSMutableAttributedString alloc] init];
        BOOL firstPic = YES;
        for (NSDictionary * richText in self.goodModel.richTexts) {
            if ([richText[@"type"] intValue] == 1) {//图片
                if (firstPic) {
                    [detailAttStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
                }
                NSURL * imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl, richText[@"content"]]];
                NSData * imageData = [NSData dataWithContentsOfURL:imageUrl];
                UIImage * image = [UIImage imageWithData:imageData];
                NSTextAttachment *textAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
                CGFloat textAttachmentW = screenWidth - 2 * 5;
                CGFloat textAttachmentH = textAttachmentW * (image.size.height / image.size.width);
                textAttachment.bounds = CGRectMake(5, 0, textAttachmentW , textAttachmentH);
                textAttachment.image = image;
                NSAttributedString *textAttachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
                [detailAttStr appendAttributedString:textAttachmentString];
                [detailAttStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
                firstPic = NO;
            }else//文字
            {
                NSMutableAttributedString *textAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", richText[@"content"]]];
                [textAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(28)] range:NSMakeRange(0, textAttStr.length)];
                [textAttStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, textAttStr.length)];
                [detailAttStr appendAttributedString:textAttStr];
            }
        }
        self.goodMessageView.detailAttStr = detailAttStr;
    }
    [MBProgressHUD hideHUDForView:self.view];
    
    if ([self.goodModel.sellType intValue] == 1)//一物一拍/零售
    {
        self.goodMessageView.sellTypeLabel.text = @"一物一拍/零售";
        self.singleView.hidden = NO;
        self.wholesaleView.hidden = YES;
        
        self.confirmBtn.y = CGRectGetMaxY(self.singleView.frame) + 29;
        self.scrollView.contentSize = CGSizeMake(screenWidth, CGRectGetMaxY(self.confirmBtn.frame) + 10);
        
        if (self.goodModel.specifications.count > 0) {
            self.singleView.specificationDataArray = [NSMutableArray arrayWithArray:self.goodModel.specifications];
            [self.singleView specificationButtonDidClick];
        }else
        {
            self.singleView.specificationButton.selected = NO;
            self.singleView.priceTF.text = [NSString stringWithFormat:@"%@", [DRTool formatFloat:[self.goodModel.price doubleValue] / 100]];
            self.singleView.countTF.text = [NSString stringWithFormat:@"%@", self.goodModel.plusCount];
        }
    }else//批发
    {
        self.goodMessageView.sellTypeLabel.text = @"批发";
        self.singleView.hidden = YES;
        self.wholesaleView.hidden = NO;
        
        self.confirmBtn.y = CGRectGetMaxY(self.wholesaleView.frame) + 29;
        self.scrollView.contentSize = CGSizeMake(screenWidth, CGRectGetMaxY(self.confirmBtn.frame) + 10);
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO];
        NSArray *wholesaleRule = [self.goodModel.wholesaleRule sortedArrayUsingDescriptors:@[sortDescriptor]];//排序
        for (int i = 0; i < wholesaleRule.count; i++) {
            NSDictionary * wholesaleRuleDic = wholesaleRule[i];
            if (i == 0) {
                self.wholesaleView.priceTF1.text = [NSString stringWithFormat:@"%@",[DRTool formatFloat:[wholesaleRuleDic[@"price"] doubleValue] / 100]];
                self.wholesaleView.numberTF1.text = [NSString stringWithFormat:@"%@",wholesaleRuleDic[@"count"]];
            }else if (i == 1)
            {
                self.wholesaleView.priceTF2.text = [NSString stringWithFormat:@"%@",[DRTool formatFloat:[wholesaleRuleDic[@"price"] doubleValue] / 100]];
                self.wholesaleView.numberTF2.text = [NSString stringWithFormat:@"%@",wholesaleRuleDic[@"count"]];
            }else if (i == 2)
            {
                self.wholesaleView.priceTF3.text = [NSString stringWithFormat:@"%@",[DRTool formatFloat:[wholesaleRuleDic[@"price"] doubleValue] / 100]];
                self.wholesaleView.numberTF3.text = [NSString stringWithFormat:@"%@",wholesaleRuleDic[@"count"]];
            }
        }
        self.wholesaleView.priceTF.text = [NSString stringWithFormat:@"%@", [DRTool formatFloat:[self.goodModel.agentPrice doubleValue] / 100]];
        self.wholesaleView.countTF.text = [NSString stringWithFormat:@"%@", self.goodModel.plusCount];
 
        self.wholesaleView.isGroup = self.goodModel.isGroup;
    }
    
    NSMutableArray * imageUrlStrs = [NSMutableArray array];
    if (!DRStringIsEmpty(self.goodModel.spreadPics)) {
        [imageUrlStrs addObject:self.goodModel.spreadPics];
    }
    
    if (!DRStringIsEmpty(self.goodModel.morePics)) {
        NSArray * morePics = [self.goodModel.morePics componentsSeparatedByString:@"|"];
        if (!DRArrayIsEmpty(morePics)) {
            [imageUrlStrs addObjectsFromArray:morePics];
        }
    }
    if (!DRArrayIsEmpty(imageUrlStrs)) {
        [self.goodMessageView.addImageView setImagesWithImageUrlStrs:imageUrlStrs];
    }
    if (!DRStringIsEmpty(self.goodModel.video)) {
        self.goodMessageView.addImageView.videoURL = [NSURL URLWithString:self.goodModel.video];
    }
}

#pragma mark - 发布商品
- (void)confirmBtnDidClick
{
    [self.view endEditing:YES];
    
    if ([DRTool stringContainsEmoji:self.goodMessageView.nameTF.text] || [DRTool stringContainsEmoji:self.goodMessageView.descriptionTV.text]) {
        [MBProgressHUD showError:@"请删掉特殊符号或表情后，再提交哦~"];
        return;
    }
    
    //判空
    if (DRStringIsEmpty(self.goodMessageView.sortTF.text)) {
        [MBProgressHUD showError:@"未输入商品分类"];
        return;
    }
    
    if (DRStringIsEmpty(self.goodMessageView.nameTF.text)) {
        [MBProgressHUD showError:@"未输入商品名称"];
        return;
    }
    
    if (DRStringIsEmpty(self.goodMessageView.descriptionTV.text)) {
        [MBProgressHUD showError:@"未输入商品简介"];
        return;
    }
    
    if (DRArrayIsEmpty(self.goodMessageView.addImageView.images)) {
        [MBProgressHUD showError:@"请至少上传一张图片"];
        return;
    }
    
    if ([self.goodMessageView.sellTypeLabel.text isEqualToString:@"一物一拍/零售"]) {//一物一拍/零售
        if (self.singleView.specificationButton.selected) {
            if (DRArrayIsEmpty(self.singleView.specificationDataArray)) {
                [MBProgressHUD showError:@"请添加商品规格"];
                return;
            }
        }else if (!self.singleView.specificationButton.selected)
        {
            if (DRStringIsEmpty(self.singleView.priceTF.text)) {
                [MBProgressHUD showError:@"未输入商品价格"];
                return;
            }
            if ([self.singleView.priceTF.text intValue] == 0) {
                [MBProgressHUD showError:@"价格不可为0"];
                return;
            }
            if (DRStringIsEmpty(self.singleView.countTF.text)) {
                [MBProgressHUD showError:@"未输入商品库存"];
                return;
            }
            if ([self.singleView.countTF.text intValue] == 0) {
                [MBProgressHUD showError:@"库存数不可为0"];
                return;
            }
        }
    }else
    {
        double priceFloat1 = [self.wholesaleView.priceTF1.text doubleValue];
        double priceFloat2 = [self.wholesaleView.priceTF2.text doubleValue];
        double priceFloat3 = [self.wholesaleView.priceTF3.text doubleValue];
        
        int numberInt1 = [self.wholesaleView.numberTF1.text intValue];
        int numberInt2 = [self.wholesaleView.numberTF2.text intValue];
        int numberInt3 = [self.wholesaleView.numberTF3.text intValue];
        
        if ((priceFloat1 == 0 && numberInt1 == 0) && (priceFloat2 == 0 && numberInt2 == 0) && (priceFloat3 == 0 && numberInt3 == 0)) {
            [MBProgressHUD showError:@"不符合批发模式价格设置，请重新选择售卖类型。"];
            return;
        }
        if ((priceFloat1 > 0 && numberInt1 == 0) || (priceFloat1 == 0 && numberInt1 > 0)) {
            [MBProgressHUD showError:@"不符合批发模式价格设置，请重新选择售卖类型。"];
            return;
        }
        if ((priceFloat2 > 0 && numberInt2 == 0) || (priceFloat2 == 0 && numberInt2 > 0)) {
            [MBProgressHUD showError:@"不符合批发模式价格设置，请重新选择售卖类型。"];
            return;
        }
        if ((priceFloat3 > 0 && numberInt3 == 0) || (priceFloat3 == 0 && numberInt3 > 0)) {
            [MBProgressHUD showError:@"不符合批发模式价格设置，请重新选择售卖类型。"];
            return;
        }
        if (numberInt1 == 1 && ((priceFloat2 == 0 && numberInt2 == 0) && (priceFloat3 == 0 && numberInt3 == 0))) {
            [MBProgressHUD showError:@"不符合批发模式价格设置，请重新选择售卖类型。"];
            return;
        }
        if (numberInt2 == 1 && ((priceFloat1 == 0 && numberInt1 == 0) && (priceFloat3 == 0 && numberInt3 == 0))) {
            [MBProgressHUD showError:@"不符合批发模式价格设置，请重新选择售卖类型。"];
            return;
        }
        if (numberInt3 == 1 && ((priceFloat1 == 0 && numberInt1 == 0) && (priceFloat2 == 0 && numberInt2 == 0))) {
            [MBProgressHUD showError:@"不符合批发模式价格设置，请重新选择售卖类型。"];
            return;
        }
        if (priceFloat1 > 0 && priceFloat2 > 0 && numberInt1 > 0 && numberInt2 > 0){
            if (priceFloat2 > priceFloat1 && numberInt2 > numberInt1) {
                [MBProgressHUD showError:@"不符合批发模式价格设置，请重新选择售卖类型。"];
                return;
            }
            if (priceFloat2 < priceFloat1 && numberInt2 < numberInt1) {
                [MBProgressHUD showError:@"不符合批发模式价格设置，请重新选择售卖类型。"];
                return;
            }
        }
        if (priceFloat3 > 0 && priceFloat2 > 0 && numberInt3 > 0 && numberInt2 > 0){
            if (priceFloat2 > priceFloat3 && numberInt2 > numberInt3) {
                [MBProgressHUD showError:@"不符合批发模式价格设置，请重新选择售卖类型。"];
                return;
            }
            if (priceFloat2 < priceFloat3 && numberInt2 < numberInt3) {
                [MBProgressHUD showError:@"不符合批发模式价格设置，请重新选择售卖类型。"];
                return;
            }
        }
        if (priceFloat3 > 0 && priceFloat1 > 0 && numberInt3 > 0 && numberInt1 > 0){
            if (priceFloat1 > priceFloat3 && numberInt1 > numberInt3) {
                [MBProgressHUD showError:@"不符合批发模式价格设置，请重新选择售卖类型。"];
                return;
            }
            if (priceFloat1 < priceFloat3 && numberInt1 < numberInt3) {
                [MBProgressHUD showError:@"不符合批发模式价格设置，请重新选择售卖类型。"];
                return;
            }
        }
        
        if (DRStringIsEmpty(self.wholesaleView.countTF.text)) {
            [MBProgressHUD showError:@"未输入商品库存"];
            return;
        }
        
        int maxNumber = numberInt1;
        if (numberInt2 > maxNumber) {
            maxNumber = numberInt2;
        }
        if (numberInt3 > maxNumber) {
            maxNumber = numberInt3;
        }
        if (maxNumber > [self.wholesaleView.countTF.text intValue]) {
            [MBProgressHUD showError:@"库存数必须大于等于批发中的最大数量"];
            return;
        }
    }
    
    if (self.goodMessageView.addImageView.videoURL && ![self.goodMessageView.addImageView.videoURL.absoluteString containsString:@"http"]) {
        [self uploadVideo];
    }else
    {
        if (!self.goodMessageView.addImageView.videoURL) {
            self.uploadVideoUrl = @"-1";
        }
        self.uploadImageUrlArray = [NSMutableArray array];
        [self uploadGoodImageWithImage:self.goodMessageView.addImageView.images[0]];
    }
}

- (void)uploadVideo
{
    [DRHttpTool upFileWithVideo:self.goodMessageView.addImageView.videoURL Success:^(id json) {
        if (SUCCESS) {
            self.uploadVideoUrl = json[@"picUrl"];
        }
        
        self.uploadImageUrlArray = [NSMutableArray array];
        [self uploadGoodImageWithImage:self.goodMessageView.addImageView.images[0]];
    } Failure:^(NSError *error) {
        
        self.uploadImageUrlArray = [NSMutableArray array];
        [self uploadGoodImageWithImage:self.goodMessageView.addImageView.images[0]];
    } Progress:^(float percent) {
        
    }];
}

//上传商品图片
- (void)uploadGoodImageWithImage:(UIImage *)image
{
    if ([image isKindOfClass:[NSString class]]) {
        NSString * imageStr = (NSString *)image;
        [self.uploadImageUrlArray addObject:imageStr];
        if (self.uploadImageUrlArray.count == self.goodMessageView.addImageView.images.count)
        {
            if (DRArrayIsEmpty(self.singleView.specificationDataArray)) {
                [self uploadGood];
            }else
            {
                [self uploadSpecificationImageWithSpecificationModel:self.singleView.specificationDataArray.firstObject];
            }
        }else
        {
            [self uploadGoodImageWithImage:self.goodMessageView.addImageView.images[self.uploadImageUrlArray.count]];
        }
        return;
    }
    [DRHttpTool uploadWithImage:image currentIndex:[self.goodMessageView.addImageView.images indexOfObject:image] + 1 totalCount:self.goodMessageView.addImageView.images.count Success:^(id json) {
        if (SUCCESS) {
            [self.uploadImageUrlArray addObject:json[@"picUrl"]];
        }else
        {
            [self.uploadImageUrlArray addObject:@""];
        }
        if (self.uploadImageUrlArray.count == self.goodMessageView.addImageView.images.count)
        {
            if (DRArrayIsEmpty(self.singleView.specificationDataArray)) {
                [self uploadGood];
            }else
            {
                [self uploadSpecificationImageWithSpecificationModel:self.singleView.specificationDataArray.firstObject];
            }
        }else
        {
            [self uploadGoodImageWithImage:self.goodMessageView.addImageView.images[self.uploadImageUrlArray.count]];
        }
    } Failure:^(NSError *error) {
        [self.uploadImageUrlArray addObject:@""];
        if (self.uploadImageUrlArray.count == self.goodMessageView.addImageView.images.count)
        {
            if (DRArrayIsEmpty(self.singleView.specificationDataArray)) {
                [self uploadGood];
            }else
            {
                [self uploadSpecificationImageWithSpecificationModel:self.singleView.specificationDataArray.firstObject];
            }
        }else
        {
            [self uploadGoodImageWithImage:self.goodMessageView.addImageView.images[self.uploadImageUrlArray.count]];
        }
    } Progress:^(float percent) {
        
    }];
}

//上传规格图片
- (void)uploadSpecificationImageWithSpecificationModel:(DRGoodSpecificationModel *)specificationModel
{
    if (!DRStringIsEmpty(specificationModel.picUrl)) {
        if (specificationModel == self.singleView.specificationDataArray.lastObject)
        {
            [self uploadGood];
        }else
        {
            [self uploadSpecificationImageWithSpecificationModel:self.singleView.specificationDataArray[[self.singleView.specificationDataArray indexOfObject:specificationModel] + 1]];
        }
        return;
    }
    [DRHttpTool uploadWithImage:specificationModel.pic currentIndex:[self.singleView.specificationDataArray indexOfObject:specificationModel] + 1 totalCount:self.singleView.specificationDataArray.count Success:^(id json) {
        if (SUCCESS) {
            specificationModel.picUrl = json[@"picUrl"];
        }else
        {
            specificationModel.picUrl = @"";
        }
        if (specificationModel == self.singleView.specificationDataArray.lastObject)
        {
            [self uploadGood];
        }else
        {
            [self uploadSpecificationImageWithSpecificationModel:self.singleView.specificationDataArray[[self.singleView.specificationDataArray indexOfObject:specificationModel] + 1]];
        }
    } Failure:^(NSError *error) {
        specificationModel.picUrl = @"";
        if (specificationModel == self.singleView.specificationDataArray.lastObject)
        {
            [self uploadGood];
        }else
        {
            [self uploadSpecificationImageWithSpecificationModel:self.singleView.specificationDataArray[[self.singleView.specificationDataArray indexOfObject:specificationModel] + 1]];
        }
    } Progress:^(float percent) {
        
    }];
}

//上传商品
- (void)uploadGood
{
    NSDictionary * bodyDic_ = [NSDictionary dictionary];
    NSString *categoryId = self.goodMessageView.categoryDic[@"id"];
    NSString *subjectId = self.goodMessageView.subjectDic[@"id"];
    NSString * version = [NSString stringWithFormat:@"%@", [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"]];
    
    if ([self.goodMessageView.sellTypeLabel.text isEqualToString:@"一物一拍/零售"]) {//一物一拍/零售
        NSNumber * priceStr = [NSNumber numberWithInt:[DRTool getHighPrecisionDouble:[self.singleView.priceTF.text doubleValue]]];
        bodyDic_ = @{
                     @"price":priceStr,
                     @"count":self.singleView.countTF.text,
                     @"description":self.goodMessageView.descriptionTV.text,
                     @"goodsName":self.goodMessageView.nameTF.text,
                     @"sellType":@(1),
                     @"picUrls":self.uploadImageUrlArray,
                     @"categoryId":categoryId,
                     @"subjectId":subjectId,
                     @"version": version
                     };
    }else//批发
    {
        //批发规则
        NSMutableArray * wholesaleRule = [NSMutableArray array];
        if (!DRStringIsEmpty(self.wholesaleView.priceTF1.text) && !DRStringIsEmpty(self.wholesaleView.numberTF1.text)) {
            NSNumber * priceStr1 = [NSNumber numberWithInt:[DRTool getHighPrecisionDouble:[self.wholesaleView.priceTF1.text doubleValue]]];
            NSDictionary * dic = @{
                                   @"price":priceStr1,
                                   @"count":self.wholesaleView.numberTF1.text,
                                   };
            [wholesaleRule addObject:dic];
        }
        
        if (!DRStringIsEmpty(self.wholesaleView.priceTF2.text) && !DRStringIsEmpty(self.wholesaleView.numberTF2.text)) {
            NSNumber * priceStr2 = [NSNumber numberWithInt:[DRTool getHighPrecisionDouble:[self.wholesaleView.priceTF2.text doubleValue]]];
            NSDictionary * dic = @{
                                   @"price":priceStr2,
                                   @"count":self.wholesaleView.numberTF2.text,
                                   };
            [wholesaleRule addObject:dic];
        }
        
        if (!DRStringIsEmpty(self.wholesaleView.priceTF3.text) && !DRStringIsEmpty(self.wholesaleView.numberTF3.text)) {
            NSNumber * priceStr3 = [NSNumber numberWithInt:[DRTool getHighPrecisionDouble:[self.wholesaleView.priceTF3.text doubleValue]]];
            NSDictionary * dic = @{
                                   @"price":priceStr3,
                                   @"count":self.wholesaleView.numberTF3.text,
                                   };
            [wholesaleRule addObject:dic];
        }
        bodyDic_ = @{
                     @"wholesaleRule":wholesaleRule,
                     @"description":self.goodMessageView.descriptionTV.text,
                     @"goodsName":self.goodMessageView.nameTF.text,
                     @"sellType":@(2),
                     @"picUrls":self.uploadImageUrlArray,
                     @"categoryId":categoryId,
                     @"subjectId":subjectId,
                     @"count":self.wholesaleView.countTF.text,
                     @"version": version
                     };
        
    }
    NSMutableDictionary * bodyDic = [NSMutableDictionary dictionaryWithDictionary:bodyDic_];
    if (self.goodModel) {
        [bodyDic setObject:self.goodModel.id forKey:@"id"];
    }
    if (!DRArrayIsEmpty(self.goodMessageView.richTexts)) {
        [bodyDic setObject:self.goodMessageView.richTexts forKey:@"richTexts"];
    }
   
    if ([self.goodMessageView.sellTypeLabel.text isEqualToString:@"批发"] && self.wholesaleView.isGroup == 1) {
        NSNumber * isGroup = [NSNumber numberWithInt:self.wholesaleView.isGroup];
        [bodyDic setObject:isGroup forKey:@"isGroup"];
    }
    if (self.goodMessageView.addImageView.videoURL) {
        int videoTime = [DRTool getVideoTimeWithSourcevideoURL:self.goodMessageView.addImageView.videoURL] * 1000;
        [bodyDic setObject:@(videoTime) forKey:@"videoTime"];
    }
    if (!DRStringIsEmpty(self.uploadVideoUrl)) {
        if ([self.uploadVideoUrl isEqualToString:@"-1"]) {
            [bodyDic setObject:@"" forKey:@"video"];
            [bodyDic setObject:@"" forKey:@"videoTime"];
        }else
        {
            [bodyDic setObject:self.uploadVideoUrl forKey:@"video"];
        }
    }
    if (!DRArrayIsEmpty(self.singleView.specificationDataArray)) {
        NSMutableArray *specifications = [NSMutableArray array];
        for (DRGoodSpecificationModel *specificationModel in self.singleView.specificationDataArray) {
            NSNumber * specificationPrice = [NSNumber numberWithInt:[DRTool getHighPrecisionDouble:[specificationModel.price doubleValue]]];
            NSDictionary *specificationDic = @{
                                               @"name": specificationModel.name,
                                               @"price": specificationPrice,
                                               @"storeCount": @([specificationModel.storeCount longLongValue]),
                                               @"picUrl": specificationModel.picUrl,
                                               @"delFlag": @(specificationModel.delFlag),
                                               };
            NSMutableDictionary *specificationDic_mu = [NSMutableDictionary dictionaryWithDictionary:specificationDic];
            if (self.goodModel) {
                [specificationDic_mu setObject:self.goodModel.id forKey:@"goodsId"];
            }
            if (!DRStringIsEmpty(specificationModel.id)) {
                [specificationDic_mu setObject:specificationModel.id forKey:@"id"];
            }
            [specifications addObject:specificationDic_mu];
        }
        [bodyDic setObject:specifications forKey:@"specifications"];
    }
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"B06",
                              @"userId":UserId,
                              };
    [MBProgressHUD showMessage:@"上传商品中" toView:self.view];
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@", json);
        [self.view endEditing:YES];
        if (SUCCESS) {
            [MBProgressHUD showSuccess:@"上传成功"];
            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addGoodSuccess" object:nil];
        }else
        {
            [MBProgressHUD hideHUDForView:self.view];
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
