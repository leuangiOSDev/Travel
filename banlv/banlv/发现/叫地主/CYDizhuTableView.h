//
//  CYDizhuTableView.h
//  banlv
//
//  Created by lcy on 16/5/8.
//  Copyright © 2016年 llz. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^xuanfu)(UIButton *xuanfuBtn);

@interface CYDizhuTableView : UITableView
@property(nonatomic, copy)xuanfu xuanfuBtn;

@end
