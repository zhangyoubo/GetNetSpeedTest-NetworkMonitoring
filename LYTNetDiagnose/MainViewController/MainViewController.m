//
//  MainViewController.m
//  LYTNetDiagnose
//
//  Created by 谭建中 on 2017/4/5.
//  Copyright © 2017年 Vieene. All rights reserved.
//

#import "MainViewController.h"
#import "MainViewCell.h"
#import "MainViewModel.h"
#import "LYTConfig.h"
#import "MJExtension.h"
#import "LYTSDKDataBase.h"

#import "UITableView+SDAutoTableViewCellHeight.h"

@interface MainViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) NSMutableArray * dataSource;
@property (nonatomic,strong) UITableView * tabView;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"网络监测";

    [self.view addSubview:self.tabView];
    [[LYTSDKDataBase shareDatabase] createSqlite];
    
}


- (UITableView *)tabView{
    if (_tabView == nil) {
        
        _tabView = [[UITableView alloc] init];
        _tabView.frame = self.view.bounds;
        _tabView.backgroundColor = kMainViewBgColor;
        _tabView.tableFooterView = [[UIView alloc] init];
        _tabView.dataSource = self;
        _tabView.delegate = self;
        _tabView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tabView;
}
- (NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [MainViewModel mj_objectArrayWithKeyValuesArray:[LYTConfig mainViewArray]];
    }
    return _dataSource;
}
#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString * ReuseId = @"MainViewCell";
    MainViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseId];
    if (cell == nil) {
        cell = [[MainViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ReuseId];
    }
    
    cell.model = self.dataSource[indexPath.row];
    
    ////// 此步设置用于实现cell的frame缓存，可以让tableview滑动更加流畅 //////
    [cell useCellFrameCacheWithIndexPath:indexPath tableView:tableView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MainViewModel * model = self.dataSource[indexPath.row];
    if (model.className) {
        
        UIViewController *vc =  [[NSClassFromString(model.className) alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc  animated:YES];
        
    }

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [_tabView cellHeightForIndexPath:indexPath model:self.dataSource[indexPath.row] keyPath:@"model" cellClass:[MainViewCell class] contentViewWidth:[self cellContentViewWith]];
}



- (CGFloat)cellContentViewWith{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    // 适配ios7横屏
    if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait && [[UIDevice currentDevice].systemVersion floatValue] < 8) {
        width = [UIScreen mainScreen].bounds.size.height;
    }
    return width;
}


@end
