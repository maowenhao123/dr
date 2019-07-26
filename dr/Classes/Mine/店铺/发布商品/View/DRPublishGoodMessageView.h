//
//  DRPublishGoodMessageView.h
//  dr
//
//  Created by dahe on 2019/7/24.
//  Copyright © 2019 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRAddMultipleImageView.h"
#import "DRGoodSortPickerView.h"
#import "DRTextView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PublishGoodMessageViewDelegate <NSObject>

- (void)viewHeightchange;
- (void)sellTypeSelectPicker;

@end

@interface DRPublishGoodMessageView : UIView

@property (nonatomic, weak) UITextField * sortTF;
@property (nonatomic, weak) DRGoodSortPickerView * sortChooseView;
@property (nonatomic, weak) UITextField * nameTF;
@property (nonatomic, weak) DRTextView *descriptionTV;//简介输入
@property (nonatomic, weak) DRAddMultipleImageView * addImageView;
@property (nonatomic, weak) UIView * detailView;
@property (nonatomic, weak) UIView * sellTypeView;
@property (nonatomic, weak) UILabel * sellTypeLabel;
@property (nonatomic, weak) UITextField * detailTF;
@property (nonatomic,strong) NSArray *richTexts;
@property (nonatomic,copy) NSAttributedString *detailAttStr;
@property (nonatomic, strong) NSDictionary * categoryDic;
@property (nonatomic, strong) NSDictionary * subjectDic;

@property (nonatomic, assign) id <PublishGoodMessageViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
