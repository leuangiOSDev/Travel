//
//  FindViewController.m
//  banlv
//
//  Created by lcy on 16/5/6.
//  Copyright © 2016年 llz. All rights reserved.
//

#import "FindViewController.h"
#import "CYPartyViewController.h"
#import "CYCallViewController.h"

@interface FindViewController ()

@end

@implementation FindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationItem setTitle:@"发现"];
    
    self.view.backgroundColor = [UIColor cyanColor];
    
    
    
    
}

- (void)call:(id)sender{
    CYCallViewController *new = [[CYCallViewController alloc] init];
    
    [self.navigationController pushViewController:new animated:YES] ;
    
}

- (void)party:(id)sender{
    CYPartyViewController *new = [[CYPartyViewController alloc] init];
    
    [self.navigationController pushViewController:new animated:YES] ;
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
