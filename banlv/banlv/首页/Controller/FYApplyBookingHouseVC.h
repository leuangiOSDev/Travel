//
//  FYApplyBookingHouseVC.h
//  banlv
//
//  Created by lifeiyang on 16/5/29.
//  Copyright © 2016年 llz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FYApplyBookingHouseVC : BLBackViewController

@property(nonatomic,strong)NSMutableDictionary *publishDic;

@property(nonatomic,copy) NSString *ownerName;

@property(nonatomic,strong)NSMutableArray *selectDateArr;

@property(nonatomic,strong) NSMutableArray *tempChooseDateArr;

@property(nonatomic,assign) NSInteger limitGuestsNum;

@end
