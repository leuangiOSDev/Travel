//
//  SearchViewController.h
//  banlv
//
//  Created by lcy on 16/5/6.
//  Copyright © 2016年 llz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController

@property (nonatomic,copy)NSString *cityId;

@property (nonatomic,copy)NSString *cityName;

@property(nonatomic,strong)NSMutableArray *selectDateArr;

@property(nonatomic,strong) NSMutableArray *tempChooseDateArr;

@end
