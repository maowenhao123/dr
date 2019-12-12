//
//  DRGoodCommentCollectionViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/11/29.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRGoodCommentCollectionViewCell.h"
#import "DRGoodCommentView.h"

@interface DRGoodCommentCollectionViewCell ()

@property (nonatomic, weak) DRGoodCommentView * goodCommentView;

@end

@implementation DRGoodCommentCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupChildViews];
    }
    return self;
}

- (void)setupChildViews
{
    DRGoodCommentView * goodCommentView = [[DRGoodCommentView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0)];
    self.goodCommentView = goodCommentView;
    [self addSubview:goodCommentView];
}

- (void)setModel:(DRGoodCommentModel *)model
{
    _model = model;
    
    self.goodCommentView.height = _model.cellH;
    self.goodCommentView.model = _model;
}

@end
