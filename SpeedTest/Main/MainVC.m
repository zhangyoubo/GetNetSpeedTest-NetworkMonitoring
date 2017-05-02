//
//  MainVC.m
//  SpeedTest
//
//  Created by shen on 17/4/14.
//  Copyright © 2017年 shen. All rights reserved.
//

#import "MainVC.h"
#import "NetWorkReachability.h"
#import "MeasurNetTools.h"
#import "QBTools.h"
#import "ReplicatorView.h"
#import "CKAlertViewController.h"

@interface MainVC ()
@property(strong,nonatomic) UILabel *delayLabel;
@property(strong,nonatomic) UILabel *netNameLabel;
@property(strong,nonatomic) UILabel *downLabel;

@property(strong,nonatomic) UIButton *speedTestBtn;
@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"网速测试";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kNetWorkReachabilityChangedNotification object:nil];
    
    [self addMeasurementSpeedTestView];
    
}

-(void)addMeasurementSpeedTestView{
    
    NSArray *titleArr = [[NSArray alloc] initWithObjects:@"实时网速(秒)",@"当前网络",@"平均网速(秒)", nil];
    
    for (int i = 0; i < titleArr.count; i ++ ) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(i *kScreenWidth/3, 84, kScreenWidth/3, 30)];
        titleLabel.text = titleArr[i];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:titleLabel];
    }
    
    self.delayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,120, kScreenWidth/3, 30)];
    self.delayLabel.text = @"--";
    self.delayLabel.textAlignment = NSTextAlignmentCenter;
    self.delayLabel.font = [UIFont boldSystemFontOfSize:14];
    self.delayLabel.textColor = kMainScreenColor;
    [self.view addSubview:self.delayLabel];
    
    
    self.netNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.delayLabel.frame),120, kScreenWidth/3, 30)];
    self.netNameLabel.text = @"--";
    self.netNameLabel.textAlignment = NSTextAlignmentCenter;
    self.netNameLabel.font = [UIFont boldSystemFontOfSize:14];
    self.netNameLabel.textColor = kMainScreenColor;
    [self.view addSubview:self.netNameLabel];
    
    self.downLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.netNameLabel.frame),120, kScreenWidth/3, 30)];
    self.downLabel.text = @"--";
    self.downLabel.textAlignment = NSTextAlignmentCenter;
    self.downLabel.font = [UIFont boldSystemFontOfSize:14];
    self.downLabel.textColor = kMainScreenColor;
    [self.view addSubview:self.downLabel];
    
    
    self.speedTestBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, kScreenHeight - 60 - 49, kScreenWidth - 60, 40)];
    [self.speedTestBtn setTitle:@"一键测速" forState:UIControlStateNormal];
    [self.speedTestBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.speedTestBtn setBackgroundColor:kMainScreenColor];
    [self.speedTestBtn addTarget:self action:@selector(speedTestBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.speedTestBtn.layer.masksToBounds = YES;
    self.speedTestBtn.layer.cornerRadius = 6.0;
    self.speedTestBtn.layer.borderWidth = 1.0;
    self.speedTestBtn.layer.borderColor = [[UIColor orangeColor] CGColor];
    [self.view addSubview:self.speedTestBtn];
    
}

-(void)speedTestBtnClicked{
    CKAlertViewController *alertVC = [CKAlertViewController alertControllerWithTitle:@"提示" message:@"测速要消耗一定的流量，您是否还要测速？" ];
    CKAlertAction *cancel = [CKAlertAction actionWithTitle:@"放弃" handler:^(CKAlertAction *action) {
        NSLog(@"点击了 %@ 按钮",action.title);
    }];
    CKAlertAction *sure = [CKAlertAction actionWithTitle:@"继续" handler:^(CKAlertAction *action) {
        [self startMeasurementSpeedTest];
        
    }];
    [alertVC addAction:cancel];
    [alertVC addAction:sure];
    [self presentViewController:alertVC animated:NO completion:nil];
}

-(void)startMeasurementSpeedTest{
    
    MeasurNetTools * meaurNet = [[MeasurNetTools alloc] initWithblock:^(float speed) {
        
        [ReplicatorView showReplicatorLoadingInView:self.view];
        self.delayLabel.text = [NSString stringWithFormat:@"%@", [QBTools formattedFileSize:speed]];;
        [self.speedTestBtn setTitle:@"正在测速...." forState:UIControlStateNormal];
        
        NSLog(@"即时速度:speed:%@",self.delayLabel.text);
        
    } finishMeasureBlock:^(float speed) {
        
        [ReplicatorView disMissReplicatorLoadingInView:self.view];
        self.downLabel.text = [NSString stringWithFormat:@"%@", [QBTools formattedFileSize:speed]];
        [self.speedTestBtn setTitle:@"重新测试" forState:UIControlStateNormal];
        [self testSpeedDetails:[NSString stringWithFormat:@"您的网络相当于带宽：%@",[QBTools formatBandWidth:speed]]];
        
        NSLog(@"平均速度为：%@",self.downLabel.text);
        NSLog(@"相当于带宽：%@",[QBTools formatBandWidth:speed]);
        
    } failedBlock:^(NSError *error) {
        
    }];
    
    [meaurNet startMeasur];
}


- (void)reachabilityChanged:(NSNotification *)notification{
    
    NetWorkReachability *curReach = [notification object];
    NetWorkStatus netStatus = [curReach currentReachabilityStatus];
    
    switch (netStatus) {
        case NetWorkStatusNotReachable:
            [[EPProgressShow showHUDManager] showErrorWithStatus:@"网络不可用"];
            self.netNameLabel.text = @"网络不可用";
            break;
        case NetWorkStatusUnknown:
            [self showMsgViewMethod:@"未知网络"];
            break;
        case NetWorkStatusWWAN2G:
            [self showMsgViewMethod:@"2G"];
            break;
        case NetWorkStatusWWAN3G:
            [self showMsgViewMethod:@"3G"];
            break;
        case NetWorkStatusWWAN4G:
            [self showMsgViewMethod:@"4G"];
            break;
        case NetWorkStatusWiFi:
            [self showMsgViewMethod:@"WiFi"];
            break;
            
        default:
            break;
    }
}

-(void)testSpeedDetails:(NSString *)string{
    CKAlertViewController *alertVC = [CKAlertViewController alertControllerWithTitle:@"提示" message:string];
    CKAlertAction *cancel = [CKAlertAction actionWithTitle:@"好的，我知道了" handler:^(CKAlertAction *action) {
        NSLog(@"点击了 %@ 按钮",action.title);
    }];
    [alertVC addAction:cancel];
    [self presentViewController:alertVC animated:NO completion:nil];
}


-(void)showMsgViewMethod:(NSString *)string{
    
    [[EPProgressShow showHUDManager] showInfoWithStatus:[NSString stringWithFormat:@"当前使用的网络为%@",string]];
    
    self.netNameLabel.text = string;
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
