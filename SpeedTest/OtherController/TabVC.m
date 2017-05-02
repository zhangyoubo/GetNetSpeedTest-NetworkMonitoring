//
//  TabVC.m
//  SpeedTest
//
//  Created by shen on 17/4/14.
//  Copyright © 2017年 shen. All rights reserved.
//

#import "TabVC.h"
#import "NaviVC.h"
#import "UIImage+Extension.h"
#import "NetWorkReachability.h"

@interface TabVC ()
@property (nonatomic) NetWorkReachability *hostReachability;
@end

@implementation TabVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addSubViewsControllers];
    [self customTabbarItem];
    
    [self.tabBar setBarTintColor:kMainScreenColor];
    
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName:[UIColor colorWithRed:184.0/255 green:184.0/255 blue:184.0/255 alpha:1]} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateSelected];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kNetWorkReachabilityChangedNotification object:nil];
    NetWorkReachability *reachability = [NetWorkReachability reachabilityWithHostName:@"www.baidu.com"];
    self.hostReachability = reachability;
    [reachability startNotifier];
    
}

- (void)reachabilityChanged:(NSNotification *)notification{
    
    NetWorkReachability *curReach = [notification object];
    NetWorkStatus netStatus = [curReach currentReachabilityStatus];
    switch (netStatus) {
        case NetWorkStatusNotReachable:
            NSLog(@"网络不可用");
            break;
        case NetWorkStatusUnknown:
            NSLog(@"未知网络");
            break;
        case NetWorkStatusWWAN2G:
            NSLog(@"2G网络");
            break;
        case NetWorkStatusWWAN3G:
            NSLog(@"3G网络");
            break;
        case NetWorkStatusWWAN4G:
            NSLog(@"4G网络");
            break;
        case NetWorkStatusWiFi:
            NSLog(@"WiFi");
            break;
            
        default:
            break;
    }
}


-(void)addSubViewsControllers{
    NSArray *classControllers = @[@"MainVC",@"MainViewController",@"SetVC"];
    NSMutableArray *conArr = [NSMutableArray array];
    
    for (int i = 0; i < classControllers.count; i ++) {
        Class cts = NSClassFromString(classControllers[i]);
        
        UIViewController *vc = [[cts alloc] init];
        
        NaviVC *naVC = [[NaviVC alloc] initWithRootViewController:vc];
        
        [conArr addObject:naVC];
    }
    self.viewControllers = conArr;
}

-(void)customTabbarItem{
    
    NSArray *titles = @[@"测速",@"网络监测",@"设置"];
    NSArray *normalImages = @[@"iconfont-home", @"iconfont-sousuo", @"iconfont-wode"];
    NSArray *selectedImages = @[@"iconfont-homeselected", @"iconfont-sousuoselected", @"iconfont-wodeselected"];
    for (int i = 0; i < titles.count; i ++) {
        UIViewController *vc = self.viewControllers[i];
        
        UIImage *normalImage = [UIImage imageWithOriginalImageName:normalImages[i]];
        UIImage *selectedImage = [UIImage imageWithOriginalImageName:selectedImages[i]];
        vc.tabBarItem = [[UITabBarItem alloc] initWithTitle:titles[i] image:normalImage selectedImage:selectedImage];
    }
    
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
