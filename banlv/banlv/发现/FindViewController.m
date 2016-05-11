//
//  FindViewController.m
//  banlv
//
//  Created by lcy on 16/5/6.
//  Copyright © 2016年 llz. All rights reserved.
//

#define kSegmentH 30

#define kTableViewY 64

#import "FindViewController.h"



#import "CYDizhuTableView.h"
#import "CYPartyTableView.h"

@interface FindViewController ()<UIScrollViewDelegate>



@property(nonatomic,strong)UISegmentedControl *seg;

@property(nonatomic, strong)UIScrollView *mainScrollView;

@property(nonatomic, strong)CYDizhuTableView *dizhuTableView;
@property(nonatomic, strong)CYPartyTableView *partyTableView;

@end

@implementation FindViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self creatSegment];
    
    [self creatScrollView];
    
    [self creatDizhuTableView];
    
    [self creaPartyTableView];
    

   
    
    
    
    
    
    
    
}
//contentOffset:滑动视图里面的内容的相对位置
//contentInset:滑动视图在外面的相对位置
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger pageNum = scrollView.contentOffset.x/kScreenFrameW + 0.5;
    
    self.seg.selectedSegmentIndex = pageNum;
}

- (void)creatScrollView{
    UIScrollView *mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenFrameW, kScreenFrameH)];
    mainScrollView.showsHorizontalScrollIndicator = NO;
    self.mainScrollView = mainScrollView;
    mainScrollView.delegate = self;
    
    mainScrollView.pagingEnabled = YES;
    
    mainScrollView.contentSize = CGSizeMake(kScreenFrameW *2, kScreenFrameH - self.tabBarController.tabBar.height - kTableViewY - 100 );
    
    mainScrollView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:mainScrollView];
    
   
    
}

- (void)creatSegment{
    
    NSArray *arrItems = @[@"叫地主",@"聚会&派对"];
    
  
    UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:arrItems];
    seg.size = CGSizeMake(50, 10);
    seg.center = CGPointMake(kScreenFrameW/2, 44/2);
    seg.backgroundColor = [UIColor whiteColor];
    
  
    [seg addTarget:self action:@selector(segAction:) forControlEvents:UIControlEventValueChanged];
   
    
    
    
    seg.selectedSegmentIndex = 0;

    self.navigationItem.titleView = seg;
    self.seg = seg;
    
    
    

    
}

- (void)segAction:(id)sender{
    
   
    
    [UIView animateWithDuration:0.5 animations:^{
        self.mainScrollView.contentOffset = CGPointMake(kScreenFrameW * self.seg.selectedSegmentIndex, - 64);
    }];

  
    
    
}


- (void)creatDizhuTableView{
    
    CYDizhuTableView *dizhuTableView = [[CYDizhuTableView alloc] init];
    
    dizhuTableView.frame = CGRectMake(0, 0, kScreenFrameW, kScreenFrameH - self.tabBarController.tabBar.height - kTableViewY );
    [self.mainScrollView addSubview:dizhuTableView];
    
    

    
    self.dizhuTableView = dizhuTableView;
    

    
    
    
//    return dizhuTableView;
    
}


- (void)creaPartyTableView{
    
    CYPartyTableView *partyTableView = [[CYPartyTableView alloc] init];
    partyTableView.frame = CGRectMake(kScreenFrameW, 0, kScreenFrameW, kScreenFrameH - self.tabBarController.tabBar.height - kTableViewY );
    
    partyTableView.backgroundColor = [UIColor yellowColor];
    
    [self.mainScrollView addSubview:partyTableView];
    
    self.partyTableView = partyTableView;
    
    
    
    
    
//    return partyTableView;
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
