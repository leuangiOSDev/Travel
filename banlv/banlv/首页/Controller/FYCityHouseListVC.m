//
//  FYCityHouseList.m
//  banlv
//
//  Created by lifeiyang on 16/5/13.
//  Copyright © 2016年 llz. All rights reserved.
//

#import "FYCityHouseListVC.h"

//城市房间数据模型
#import "FYCityHouseListData.h"

//城市房间cell
#import "FYCityHouseListCell.h"

//更多筛选条件
#import "FYMoreChoose.h"

//筛选条件控制器
#import "FYMoreChooseVC.h"

//地图模式控制器
#import "FYCityHouseMapVC.h"

//选择日期
#import "FYChooseDateView.h"

@interface FYCityHouseListVC () <UITableViewDelegate ,UITableViewDataSource ,UIScrollViewDelegate>

@property(nonatomic,strong) UITableView *tableView;

@property(nonatomic,strong) FYChooseDateView *chooseDateView;

@property(nonatomic,strong) FYMoreChoose *moreChoose;

@property(nonatomic,strong)UIView *bothView;

//存放城市房间的数组
@property(nonatomic,strong) NSMutableArray<FYCityHouseListData *> *cityHouseArr;

@property(nonatomic,strong) FYAFNetworkingManager *manager;

@property(nonatomic,assign)NSInteger page;

@property(nonatomic,assign)NSInteger hasNext;

@property(nonatomic,strong)ZFChooseTimeViewController *chooseDateVC;

@end

@implementation FYCityHouseListVC

- (NSInteger)page
{
    if (!_page) {
        
        _page = 1;
    }
    
    return _page;
}

- (NSMutableArray *)selectDateArr
{
    if (!_selectDateArr) {
        
        _selectDateArr = [NSMutableArray arrayWithObjects:[NSNumber numberWithInteger:0],[NSNumber numberWithInteger:0], nil];
    }
    
    return _selectDateArr;
}

- (NSDate *)getDateFromString:(NSString *)dateStr
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    
    return [format dateFromString:dateStr];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //设置标题文字样式
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#666666"]}];
    
    self.title = self.cityName;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"dizhi"] style:UIBarButtonItemStyleDone target:self action:@selector(swithToMapStyle)];
    
    [self initTableView];
    
    self.chooseDateVC = [[ZFChooseTimeViewController alloc] initWithFrame:CGRectMake(0, self.view.height, self.view.width, self.view.height)];
    
    __weak typeof(self) mySelf = self;
    
    self.chooseDateVC.returnDateBlock = ^(NSMutableArray *selectedDateArr)
    {
        mySelf.selectDateArr = selectedDateArr;
        
        NSString *dateInStr = [NSString stringWithFormat:@"%@-%@-%@",mySelf.selectDateArr[0][0],mySelf.selectDateArr[0][1],mySelf.selectDateArr[0][2]];
        NSDate *dateIn = [mySelf getDateFromString:dateInStr];
        
        NSInteger liveIn = (NSInteger)[dateIn timeIntervalSince1970];
        
        NSString *dateOutStr = [NSString stringWithFormat:@"%@-%@-%@",mySelf.selectDateArr[1][0],mySelf.selectDateArr[1][1],mySelf.selectDateArr[1][2]];
        NSDate *dateOut = [mySelf getDateFromString:dateOutStr];
        
        NSInteger liveOut = (NSInteger)[dateOut timeIntervalSince1970];
        
        [mySelf.selectDateArr removeAllObjects];
        
        [mySelf.selectDateArr addObject:[NSString stringWithFormat:@"%ld",liveIn]];
        [mySelf.selectDateArr addObject:[NSString stringWithFormat:@"%ld",liveOut]];
        
        [mySelf.tableView.mj_header beginRefreshing];
        
    };
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.chooseDateVC];
    
    self.manager = [FYAFNetworkingManager manager];
    
    [self requestData];
    
    }

- (void)initTableView
{
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    self.chooseDateView = [[FYChooseDateView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 55)];
    
    __weak typeof(self) mySelf = self;
    
    self.chooseDateView.chooseDateBlock = ^{
        
        [UIView animateWithDuration:0.2f animations:^{
            
            mySelf.chooseDateVC.frame = CGRectMake(0, 0, mySelf.view.width, mySelf.view.height);
        }];
        
    };
    
    self.moreChoose = [[FYMoreChoose alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.chooseDateView.frame), self.view.width, 40)];
    
    self.bothView = [[UIView alloc] initWithFrame:CGRectMake(0, NavH, self.view.width, self.chooseDateView.height + self.moreChoose.height)];
    self.bothView.backgroundColor = [UIColor whiteColor];
    
    [self.bothView addSubview:self.chooseDateView];
    
    [self.bothView addSubview:self.moreChoose];
    
    self.moreChoose.moreChooseBlock = ^(){
        
        FYMoreChooseVC *moreChooseVC = [[FYMoreChooseVC alloc] initWithNibName:@"FYMoreChooseVC" bundle:nil];
        
        moreChooseVC.view.frame = mySelf.view.bounds;
        
        [mySelf.navigationController pushViewController:moreChooseVC animated:YES];
        
    };
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavH, self.view.width, self.view.height - NavH) style:UITableViewStylePlain];
    
    self.tableView.contentInset = UIEdgeInsetsMake(self.bothView.height, 0, 0, 0);
    
    self.tableView.showsVerticalScrollIndicator = NO;
    
    self.tableView.delegate = self;
    
    self.tableView.dataSource = self;
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(downRefresh)];
    header.stateLabel.textColor = [UIColor colorWithHexString:@"#676767"];
    header.lastUpdatedTimeLabel.textColor = [UIColor colorWithHexString:@"##676767"];
    
    
    self.tableView.mj_header = header;
    
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(upRefresh)];
    footer.stateLabel.textColor = [UIColor colorWithHexString:@"##676767"];
    [footer setTitle:@"正在加载 ..." forState:MJRefreshStateRefreshing];
    footer.automaticallyHidden = NO;
    
    self.tableView.mj_footer = footer;
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FYCityHouseListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"houseCell"];
    
    [self.view addSubview:self.tableView];
    
    [self.view addSubview:self.bothView];
    
    [self.tableView.mj_header beginRefreshing];
    
}

- (void)downRefresh
{
    
    self.page = 1;
    
    [self.manager GET:[self getURLStrWithPage:self.page DateIn:self.selectDateArr[0] DateOut:self.selectDateArr[1]] parameters:nil success:^(id responseObject) {
        
        [self.tableView.mj_footer resetNoMoreData];
        self.tableView.mj_footer.hidden = NO;
        
        self.hasNext = [self getHasNext:responseObject];
        
        NSArray *cityHouseArr = [[responseObject objectForKey:@"data"] objectForKey:@"result"];
        
        self.cityHouseArr = [FYCityHouseListData mj_objectArrayWithKeyValuesArray:cityHouseArr];
        
        [self isHiddenFooter];
        
        [self.tableView reloadData];
        
        [self.tableView.mj_header endRefreshing];
        
    } failur:^(NSError *error) {
        
        CYLog(@"error : %@",error);
        
    }];
    
}

- (void)upRefresh
{
    
    if (!self.hasNext) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
        
        __weak typeof(self) mySelf = self;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5f animations:^{
                
                mySelf.tableView.mj_footer.hidden = YES;
            }];
            
        });
        
        return;
    }
    
    self.page++;
    
    [self.manager GET:[self getURLStrWithPage:self.page DateIn:self.selectDateArr[0] DateOut:self.selectDateArr[1]] parameters:nil success:^(id responseObject) {
        
        self.hasNext = [self getHasNext:responseObject];;
        
        NSArray *cityHouseArr = [[responseObject objectForKey:@"data"] objectForKey:@"result"];
        
        NSArray *newCityHouseArr = [FYCityHouseListData mj_objectArrayWithKeyValuesArray:cityHouseArr];
        
        [self.cityHouseArr addObjectsFromArray:newCityHouseArr];
        
        [self.tableView reloadData];
        
        [self.tableView.mj_footer endRefreshing];
        
        
    } failur:^(NSError *error) {
        
        CYLog(@"error : %@",error);
        
    }];
}

- (NSString *)getURLStrWithPage:(NSInteger)page DateIn:(NSNumber *)dateIn DateOut:(NSNumber *)dateOut
{
    NSString *params = [NSString stringWithFormat:@"bizParams={\n\"cityId\":%ld,\n\"limitGuestsNum\":0,\n\"checkOutDate\":%ld,\n\"page\":%ld,\n\"userToken\":\"NDRjYmJiZWJlZWJjMmE1NjQ2NmVhNzUxMjY2YzRhMWQ4NDE0MjBhMjMyNjEyZTQ3\",\n\"sex\":0,\n\"districtId\":0,\n\"checkInDate\":%ld}",self.cityId.integerValue,dateOut.integerValue,page,(long)dateIn.integerValue];
    
    NSString *urlStr = @"http://www.shafalvxing.com/space/getSharedSpaceByCity.do?";
    
//    NSLog(@"url : %@",[urlStr encodeURLWithParams:params]);
    
    return [urlStr encodeURLWithParams:params];
}


- (void)requestData
{

    [self.manager GET:[self getURLStrWithPage:self.page DateIn:self.selectDateArr[0] DateOut:self.selectDateArr[1]] parameters:nil success:^(id responseObject) {
        
        self.hasNext = [self getHasNext:responseObject];
        
        NSArray *cityHouseArr = [[responseObject objectForKey:@"data"] objectForKey:@"result"];
        
        self.cityHouseArr = [FYCityHouseListData mj_objectArrayWithKeyValuesArray:cityHouseArr];
        
        [self isHiddenFooter];
        
        [self.tableView reloadData];
        
        
    } failur:^(NSError *error) {
        
        CYLog(@"error : %@",error);
        
    }];
    
    
}

- (NSInteger)getHasNext:(id)responseObject
{
    NSString *hasNext = [[responseObject objectForKey:@"data"] objectForKey:@"hasNext"];
    
    return hasNext.integerValue;
}

- (void)isHiddenFooter
{
    if (self.cityHouseArr.count < 2) {
        
        if (!self.hasNext) {
            
            self.tableView.mj_footer.hidden = YES;
        }
    }
}

//切换到地图模式
- (void)swithToMapStyle
{
    FYCityHouseMapVC *mapVC = [[FYCityHouseMapVC alloc] init];
    
    mapVC.cityId = self.cityId;
    mapVC.cityName = self.cityName;
    
    [self.navigationController pushViewController:mapVC animated:YES];
}

#pragma mark -- UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 340.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //设为不选中（不变灰色）
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSLog(@"点击的房间ID:%@",self.cityHouseArr[indexPath.row].spaceId);
}

#pragma mark -- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cityHouseArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FYCityHouseListCell *houseCell = [tableView dequeueReusableCellWithIdentifier:@"houseCell" forIndexPath:indexPath];
    
    houseCell.cityHouseData = self.cityHouseArr[indexPath.row];
    
    return houseCell;
}

#pragma mark -- UIScrollViewDelegate


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if (self.tableView.contentOffset.y > -self.bothView.height) {
        
        [self.bothView removeFromSuperview];
        self.bothView.y = -self.bothView.height;
        [self.tableView addSubview:self.bothView];
        
    }
    
    if (self.tableView.contentOffset.y > -self.moreChoose.height)
    {
        [self.moreChoose removeFromSuperview];
        self.moreChoose.y = NavH;
        [self.view addSubview:self.moreChoose];
    }
    
    if (self.tableView.contentOffset.y < -self.bothView.height) {
        
        [self.bothView removeFromSuperview];
        self.bothView.y = NavH;
        [self.view addSubview:self.bothView];
        
    }
    
    if (self.tableView.contentOffset.y < -self.moreChoose.height) {
        
        [self.moreChoose removeFromSuperview];
        self.moreChoose.y = self.chooseDateView.height;
        [self.bothView addSubview:self.moreChoose];
    }
 

}

//cityId的setter方法
- (void)setCityId:(NSString *)cityId
{
    _cityId = cityId;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    NSLog(@"你的内存快爆了!");
    
}

- (void)setCityName:(NSString *)cityName
{
    _cityName = cityName;
}


@end
