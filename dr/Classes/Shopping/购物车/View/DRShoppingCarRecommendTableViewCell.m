//
//  DRShoppingCarRecommendTableViewCell.m
//  dr
//
//  Created by dahe on 2019/8/7.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRShoppingCarRecommendTableViewCell.h"
#import "DRGoodItemView.h"

@interface DRShoppingCarRecommendTableViewCell ()

@property (nonatomic, strong) DRGoodItemView * leftGoodItemView;
@property (nonatomic, strong) DRGoodItemView * rightGoodItemView;

@end

@implementation DRShoppingCarRecommendTableViewCell

+ (DRShoppingCarRecommendTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"ShoppingCarRecommendTableViewCellId";
    DRShoppingCarRecommendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRShoppingCarRecommendTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = DRBackgroundColor;
    }
    return  cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupChildViews];
    }
    return self;
}

- (void)setupChildViews
{
    CGFloat goodItemViewW = (screenWidth - 3 * DRMargin) / 2;
    CGFloat goodItemViewH = goodItemViewW + 75;
    for (int i = 0; i < 2; i++) {
        DRGoodItemView * goodItemView = [[DRGoodItemView alloc] initWithFrame:CGRectMake(DRMargin + (goodItemViewW + DRMargin) * i, 0, goodItemViewW, goodItemViewH)];
        if (i == 0) {
            self.leftGoodItemView = goodItemView;
        }else if (i == 1)
        {
            self.rightGoodItemView = goodItemView;
        }
        [self addSubview:goodItemView];
    }
}

- (void)setLeftModel:(DRGoodModel *)leftModel
{
    _leftModel = leftModel;
    
    self.leftGoodItemView.model = _leftModel;
}

- (void)setRightModel:(DRGoodModel *)rightModel
{
    _rightModel = rightModel;
    
    if (DRObjectIsEmpty(_rightModel)) {
        self.rightGoodItemView.hidden = YES;
    }else
    {
        self.rightGoodItemView.hidden = NO;
        self.rightGoodItemView.model = _rightModel;
    }
}

@end
