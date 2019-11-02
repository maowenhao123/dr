//
//  DRAddPictureAndWordViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/7/27.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRAddPictureAndWordViewController.h"
#import "DRAddMultipleImageManage.h"
#import "IQKeyboardManager.h"
#import "DRTextView.h"

@interface DRAddPictureAndWordViewController ()<UITextViewDelegate ,AddMultipleImageManageDelegate>

@property (nonatomic,weak) DRTextView *textView;
@property (nonatomic,weak) UIButton * addButton;
@property (nonatomic,weak) UIButton * completeButton;
@property (nonatomic, strong) DRAddMultipleImageManage * addMultipleImageManage;
@property (nonatomic, strong) NSMutableArray *uploadImageUrlArray;

@end

@implementation DRAddPictureAndWordViewController

#pragma mark - 控制器的生命周期
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager];
    keyboardManager.enable = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager];
    keyboardManager.enable = YES;
}

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
    self.title = @"添加商品详情";
    [self setupChilds];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark Removing toolbar
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary* info = [notification userInfo];
    CGSize keyBoardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    self.textView.height = screenHeight - statusBarH - navBarH - keyBoardSize.height;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.textView.height = screenHeight - statusBarH - navBarH - 45;
}

#pragma mark - 布局视图
- (void)setupChilds
{
    CGFloat bottomButtonH = 45;
    CGFloat textViewH = screenHeight - statusBarH - navBarH - bottomButtonH - [DRTool getSafeAreaBottom];
    DRTextView * textView = [[DRTextView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, textViewH)];
    self.textView = textView;
    textView.attributedText = self.attStr;
    textView.delegate = self;
    textView.backgroundColor = [UIColor whiteColor];
    textView.tintColor = DRDefaultColor;
    textView.textColor = DRBlackTextColor;
    textView.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    textView.myPlaceholder = @"添加图片和文字让商品看起来更诱人";
    textView.delegate = self;
    [self.view addSubview:textView];
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 10;// 字体的行间距
    NSDictionary *attributes = @{
                                 NSFontAttributeName:textView.font,
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    textView.typingAttributes = attributes;
    
    //底部按钮
    for (int i = 0; i < 2; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i == 0) {
            self.addButton = button;
        }else
        {
            self.completeButton = button;
        }
        button.tag = i;
        button.frame = CGRectMake(screenWidth / 2 * i, CGRectGetMaxY(textView.frame), screenWidth / 2, 45);
        if (i == 0) {
            button.backgroundColor = DRColor(20, 215, 167, 1);
            [button setTitle:@"添加图片" forState:UIControlStateNormal];
        }else
        {
            button.backgroundColor = DRDefaultColor;
            [button setTitle:@"完成" forState:UIControlStateNormal];
        }
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
        [button addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}

- (void)buttonDidClick:(UIButton *)button
{
    [self.view endEditing:YES];
    
    if (button.tag == 0) {
        self.addMultipleImageManage = [[DRAddMultipleImageManage alloc] init];
        self.addMultipleImageManage.viewController = self;
        self.addMultipleImageManage.delegate = self;
        [self.addMultipleImageManage addImage];
    }else
    {
        [self complete];
    }
}
- (void)imageManageAddImages:(NSArray *)images
{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    for (UIImage * image in images) {
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
        CGFloat textAttachmentW = screenWidth - 2 * 5;
        CGFloat textAttachmentH = textAttachmentW * (image.size.height / image.size.width);
        textAttachment.bounds = CGRectMake(5, 0, textAttachmentW , textAttachmentH);
        textAttachment.image = image;
        NSAttributedString *textAttachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [string appendAttributedString:textAttachmentString];
        if (image == images.lastObject) {
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }else
        {
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n"]];
        }
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 10;// 字体的行间距
    [string addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, string.length)];
    [string addAttribute:NSFontAttributeName value:self.textView.font range:NSMakeRange(0, string.length)];
    self.textView.attributedText = string;
    [self.textView becomeFirstResponder];
}
- (void)complete
{
    NSAttributedString * attributedText = self.textView.attributedText;
    if (attributedText.length == 0) {//没有图片文字
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    NSMutableArray * images = [NSMutableArray array];
    [attributedText enumerateAttributesInRange:NSMakeRange(0, attributedText.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSTextAttachment * textAtt = attrs[@"NSAttachment"];//从字典中取得那一个图片
        if (textAtt)
        {
            [images addObject:textAtt.image];
        }
    }];
    
    // 异步提交数据
    if (images.count > 0) {//有图片
        [self uploadImageWithImage:images[0] images:images];
    }else
    {
        [MBProgressHUD hideHUDForView:self.view];
        [self uploadRichText];
    }
}

- (void)uploadImageWithImage:(UIImage *)image images:(NSArray *)images
{
    [DRHttpTool uploadWithImage:image currentIndex:[images indexOfObject:image] + 1 totalCount:images.count Success:^(id json) {
        if (SUCCESS) {
            [self.uploadImageUrlArray addObject:json[@"picUrl"]];
        }else
        {
            [self.uploadImageUrlArray addObject:@""];
        }
        if (self.uploadImageUrlArray.count == images.count)
        {
            [self uploadRichText];
        }else
        {
            [self uploadImageWithImage:images[self.uploadImageUrlArray.count] images:images];
        }
    } Failure:^(NSError *error) {
        [self.uploadImageUrlArray addObject:@""];
        if (self.uploadImageUrlArray.count == images.count)
        {
            [self uploadRichText];
        }else
        {
            [self uploadImageWithImage:images[self.uploadImageUrlArray.count] images:images];
        }
    }  Progress:^(float percent) {
        
    }];
}

- (void)uploadRichText
{
    NSAttributedString * attributedText = self.textView.attributedText;
    __block NSInteger imageIndex = 0;
    //枚举出所有的字符串
    NSMutableArray * richTexts = [NSMutableArray array];
    [attributedText enumerateAttributesInRange:NSMakeRange(0, attributedText.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSTextAttachment * textAtt = attrs[@"NSAttachment"];//从字典中取得那一个图片
        NSString * content;
        if (textAtt)
        {
            NSDictionary * richText = @{
                                        @"type":@(1),
                                        @"content":self.uploadImageUrlArray[imageIndex],
                                        };
            [richTexts addObject:richText];
            imageIndex++;
        }else
        {
            NSAttributedString * subStr = [attributedText attributedSubstringFromRange:range];
            content = subStr.string;
            NSDictionary * richText = @{
                                        @"type":@(0),
                                        @"content":content
                                        };
            
            if (richTexts.count > 0) {
                NSDictionary * lastRichText = richTexts.lastObject;
                if ([lastRichText[@"type"] intValue] == 0) {
                    NSString * newContent = [NSString stringWithFormat:@"%@%@", lastRichText[@"content"], content];
                    NSDictionary * newRichText = @{
                                                   @"type":@(0),
                                                   @"content":newContent
                                                   };
                    [richTexts replaceObjectAtIndex:richTexts.count - 1 withObject:newRichText];
                }else
                {
                    [richTexts addObject:richText];
                }
            }else
            {
                [richTexts addObject:richText];
            }
        }
    }];
    
    if (_delegate && [_delegate respondsToSelector:@selector(addPictureAndWordWithRichTexts:attStr:)]) {
        [_delegate addPictureAndWordWithRichTexts:richTexts attStr:attributedText];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
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
