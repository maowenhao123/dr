//
//  DRAddressModel.h
//  dr
//
//  Created by 毛文豪 on 2017/4/17.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRAddressModel : NSObject

@property (nonatomic, copy) NSString * id;//id
@property (nonatomic,copy) NSString *province;
@property (nonatomic,copy) NSString *city;
@property (nonatomic, copy) NSString * address;//地址
@property (nonatomic, copy) NSString * name;//名字
@property (nonatomic, copy) NSString * phone;//电话
@property (nonatomic, strong) NSNumber * defaultv;//是否是默认地址
@property (nonatomic,copy) NSString *receiverName;//收货人名字

//自定义
@property (nonatomic,copy) NSString *nameStr;
@property (nonatomic,assign) CGRect nameLabelF;
@property (nonatomic,copy) NSString *phoneStr;
@property (nonatomic,assign) CGRect phoneLabelF;
@property (nonatomic,copy) NSMutableAttributedString * addressAttStr;
@property (nonatomic,assign) CGRect addressLabelF;
@property (nonatomic,assign) CGRect lineF;
@property (nonatomic,assign) CGRect defaultButtonF;
@property (nonatomic,assign) CGRect deleteButtonF;
@property (nonatomic,assign) CGRect editButtonF;
@property (nonatomic,assign) CGFloat addressCellH;

@end
