//
//  DRAddPictureAndWordViewController.h
//  dr
//
//  Created by 毛文豪 on 2017/7/27.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRBaseViewController.h"

@protocol AddPictureAndWordViewControllerDelegate <NSObject>

- (void)addPictureAndWordWithRichTexts:(NSArray *)richTexts attStr:(NSAttributedString *)attStr;

@end

@interface DRAddPictureAndWordViewController : DRBaseViewController

@property (nonatomic,copy) NSAttributedString *attStr;

@property (nonatomic, weak) id <AddPictureAndWordViewControllerDelegate> delegate;

@end
