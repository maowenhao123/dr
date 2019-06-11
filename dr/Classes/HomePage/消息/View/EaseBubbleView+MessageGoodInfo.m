//
//  EaseBubbleView+MessageGoodInfo.m
//  dr
//
//  Created by 毛文豪 on 2017/12/18.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "EaseBubbleView+MessageGoodInfo.h"

@implementation EaseBubbleView (MessageGoodInfo)

-(void)_setUpShareBubbleMarginConstraints
{
    [self.marginConstraints removeAllObjects];
    
    NSLayoutConstraint *titleWithMarginTopConstraint =
    [NSLayoutConstraint constraintWithItem:self.titleLabel
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeTop
                                multiplier:1.0
                                  constant:10];
    
    NSLayoutConstraint *titleWithMarginRightConstraint =
    [NSLayoutConstraint constraintWithItem:self.titleLabel
                                 attribute:NSLayoutAttributeTrailing
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeTrailing
                                multiplier:1.0
                                  constant:-self.margin.right - 80 - 10];
    
    NSLayoutConstraint *titleWithMarginLeftConstraint =
    [NSLayoutConstraint constraintWithItem:self.titleLabel
                                 attribute:NSLayoutAttributeLeading
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeLeading
                                multiplier:1.0
                                  constant:self.margin.left];
    NSLayoutConstraint *titleBottomConstraint = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-70];
    
    [self.marginConstraints addObject:titleWithMarginTopConstraint];
    [self.marginConstraints addObject:titleWithMarginRightConstraint];
    [self.marginConstraints addObject:titleWithMarginLeftConstraint];
    [self.marginConstraints addObject:titleBottomConstraint];
    
    
    NSLayoutConstraint *contentTopConstraint =
    [NSLayoutConstraint constraintWithItem:self.content
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeTop
                                multiplier:1.0
                                  constant:35];
    
    NSLayoutConstraint *contentlLeftConstraint =
    [NSLayoutConstraint constraintWithItem:self.content
                                 attribute:NSLayoutAttributeLeading
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeLeading
                                multiplier:1.0
                                  constant:self.margin.left];
    NSLayoutConstraint *contentlRightConstraint =
    [NSLayoutConstraint constraintWithItem:self.content
                                 attribute:NSLayoutAttributeTrailing
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeTrailing
                                multiplier:1.0
                                  constant:-self.margin.right - 80 - 10];
    
    NSLayoutConstraint *contentlBottomConstraint =
    [NSLayoutConstraint constraintWithItem:self.content
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1.0
                                  constant:-35];
    
    [self.marginConstraints addObject:contentTopConstraint];
    [self.marginConstraints addObject:contentlLeftConstraint];
    [self.marginConstraints addObject:contentlRightConstraint];
    [self.marginConstraints addObject:contentlBottomConstraint];
    
    NSLayoutConstraint *priceTopConstraint =
    [NSLayoutConstraint constraintWithItem:self.priceLabel
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.content
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1.0
                                  constant:5];
    
    NSLayoutConstraint *priceLeftConstraint =
    [NSLayoutConstraint constraintWithItem:self.priceLabel
                                 attribute:NSLayoutAttributeLeading
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeLeading
                                multiplier:1.0
                                  constant:self.margin.left];
    NSLayoutConstraint *priceRightConstraint =
    [NSLayoutConstraint constraintWithItem:self.priceLabel
                                 attribute:NSLayoutAttributeTrailing
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeTrailing
                                multiplier:1.0
                                  constant:-self.margin.right - 80 - 10];
    
    NSLayoutConstraint *priceBottomConstraint =
    [NSLayoutConstraint constraintWithItem:self.priceLabel
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1.0
                                  constant:-5];
    
    [self.marginConstraints addObject:priceTopConstraint];
    [self.marginConstraints addObject:priceLeftConstraint];
    [self.marginConstraints addObject:priceRightConstraint];
    [self.marginConstraints addObject:priceBottomConstraint];
    
    NSLayoutConstraint *imageViewTopConstraint =
    [NSLayoutConstraint constraintWithItem:self.imageViewShare
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeTop
                                multiplier:1.0
                                  constant:10];
    
    NSLayoutConstraint *imageViewLeadingConstraint =
    [NSLayoutConstraint constraintWithItem:self.imageViewShare
                                 attribute:NSLayoutAttributeLeading
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.titleLabel
                                 attribute:NSLayoutAttributeTrailing
                                multiplier:1.0
                                  constant:10];
    NSLayoutConstraint *imageViewRightConstraint =
    [NSLayoutConstraint constraintWithItem:self.imageViewShare
                                 attribute:NSLayoutAttributeTrailing
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeTrailing
                                multiplier:1.0
                                  constant:-self.margin.right];
    NSLayoutConstraint *imageViewBottomConstraint =
    [NSLayoutConstraint constraintWithItem:self.imageViewShare
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1.0
                                  constant:-10];
    
    [self.marginConstraints addObject:imageViewTopConstraint];
    [self.marginConstraints addObject:imageViewLeadingConstraint];
    [self.marginConstraints addObject:imageViewRightConstraint];
    [self.marginConstraints addObject:imageViewBottomConstraint];
    
    [self addConstraints:self.marginConstraints];
    
    NSLayoutConstraint *backImageConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0f constant:260];
    
    [self.superview addConstraint:backImageConstraint];
    
}

- (void)_setupShareBubbleConstraints
{
    [self _setUpShareBubbleMarginConstraints];
}

-(void)setUpShareBubbleView{
    
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textColor = DRBlackTextColor;
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.backgroundImageView addSubview:self.titleLabel];
    
    self.content = [[UILabel alloc]init];
    self.content.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    self.content.numberOfLines = 0;
    self.content.textColor = DRGrayTextColor;
    self.content.translatesAutoresizingMaskIntoConstraints = NO;
    self.content.textAlignment = NSTextAlignmentLeft;
    [self.backgroundImageView addSubview:self.content];
    
    self.priceLabel = [[UILabel alloc]init];
    self.priceLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    self.priceLabel.textColor = [UIColor redColor];
    self.priceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.priceLabel.textAlignment = NSTextAlignmentLeft;
    [self.backgroundImageView addSubview:self.priceLabel];
    
    self.imageViewShare = [[UIImageView alloc]init];
    self.imageViewShare.contentMode = UIViewContentModeScaleAspectFill;
    self.imageViewShare.layer.masksToBounds = YES;
    self.imageViewShare.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backgroundImageView addSubview:self.imageViewShare];
    [self _setUpShareBubbleMarginConstraints];
    
}

- (void)updateShareMargin:(UIEdgeInsets)margin
{
    if (_margin.top == margin.top && _margin.bottom == margin.bottom && _margin.left == margin.left && _margin.right == margin.right) {
        return;
    }
    _margin = margin;
    
    [self removeConstraints:self.marginConstraints];
    [self _setUpShareBubbleMarginConstraints];
}


@end
