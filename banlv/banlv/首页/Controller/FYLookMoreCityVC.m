//
//  FYLookMoreCityVC.m
//  banlv
//
//  Created by lifeiyang on 16/5/12.
//  Copyright © 2016年 llz. All rights reserved.
//

#import "FYLookMoreCityVC.h"

//查看更多城市cell模型
#import "FYLookMoreCityData.h"

//展示搜索结果的列表
#import "FYSearchedCityTableView.h"

@interface FYLookMoreCityVC () <UITableViewDelegate ,UITableViewDataSource ,UITextFieldDelegate>

@property(nonatomic,strong) UITextField *searchField;

@property(nonatomic,strong) UITableView *cityTableView;

@property(nonatomic,strong) FYSearchedCityTableView *searchedTableView;

@property(nonatomic,strong) UICollectionView *headerCollecView;

@property(nonatomic,strong) NSArray<FYLookMoreCityData *> *cityArr;

@end

@implementation FYLookMoreCityVC

//懒加载
- (NSArray *)cityArr
{
    if (!_cityArr) {
        
        _cityArr = [[NSArray alloc] init];
        
    }
    
    return _cityArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initNavCenterView];
    
    [self initCityTableView];
    
    [self initSearchedTableView];
    
    [self requestCityData];
    
}

//搜索框
- (void)initNavCenterView
{
    self.searchField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
    
    self.searchField.placeholder = @"搜索城市";
    
    self.searchField.delegate = self;
    
    self.navigationItem.titleView = self.searchField;
    

}

//显示的城市列表
- (void)initCityTableView
{
    self.cityTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    
    self.cityTableView.backgroundColor = [UIColor redColor];
    
    self.cityTableView.delegate = self;
    self.cityTableView.dataSource = self;
    
    [self.cityTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cityCell"];
    
    [self.view addSubview:self.cityTableView];
}

- (void)initSearchedTableView
{
    self.searchedTableView = [[FYSearchedCityTableView alloc] initWithFrame:self.view.bounds];
    
    self.searchedTableView.hidden = YES;
    
    [self.view addSubview:self.searchedTableView];
}

- (void)requestCityData
{
    FYAFNetworkingManager *manager = [FYAFNetworkingManager manager];
    
    [manager GET:@"http://www.shafalvxing.com/city/citySearchInfo.do" parameters:@{@"userToken" : @"NDRjYmJiZWJlZWJjMmE1NjQ2NmVhNzUxMjY2YzRhMWQ4NDE0MjBhMjMyNjEyZTQ3"} success:^(id responseObject) {
        
        NSArray *searchCityArr = [[responseObject objectForKey:@"data"] objectForKey:@"searchCity"];
        
        //模型嵌套模型
        [FYLookMoreCityData mj_setupObjectClassInArray:^NSDictionary *{
            
            return @{
                     @"city" : @"FYSingleCityData",
                     };
        }];
        
        self.cityArr = [FYLookMoreCityData mj_objectArrayWithKeyValuesArray:searchCityArr];
        
        [self.cityTableView reloadData];
        
        
        
    } failur:^(NSError *error) {
        
        NSLog(@"error : %@",error);
        
    }];

}

#pragma mark -- UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"点击的城市id:%@",self.cityArr[indexPath.section].city[indexPath.row].ID);
}

#pragma mark -- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.cityArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cityArr[section].city.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.cityTableView dequeueReusableCellWithIdentifier:@"cityCell"];
    
    cell.textLabel.text = self.cityArr[indexPath.section].city[indexPath.row].cityNameCh;
    
    return cell;
}

//头部标题
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.cityArr[section].word;
}

//右侧索引
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *sectionArr = [[NSMutableArray array] init];
    
    for (FYLookMoreCityData *lookMoreCityData in self.cityArr) {
        
        [sectionArr addObject:lookMoreCityData.word];
    }
    
    return sectionArr;
}

//点击索引滚动到指定位置
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    return index;
    
}


#pragma mark -- UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.searchedTableView.searchWord = self.searchField.text;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.searchField resignFirstResponder];
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
