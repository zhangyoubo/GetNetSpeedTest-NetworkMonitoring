//
//  LYTPingViewController.m
//  LYTNetDiagnose
//
//  Created by Vieene on 2017/3/27.
//  Copyright © 2017年 Vieene. All rights reserved.
//

#import "LYTPingViewController.h"
#import "LYTScreenView.h"
#import "LYTNetDiagnoser.h"
#import "LYTConfig.h"
#import "LYTSDKDataBase+LYTServersList.h"

@interface LYTPingViewController ()<LYTNetPingDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textDomain;
@property (weak, nonatomic) IBOutlet UITextField *pingCount;
@property (nonatomic,strong) LYTScreenView * screenView;

@property (weak, nonatomic) IBOutlet UILabel *lostLabel;

- (IBAction)ClickPing:(UIButton *)sender;
@property (nonatomic,assign) BOOL ping;

@property (weak, nonatomic) IBOutlet UIButton *pingBtn;

@property (weak, nonatomic) IBOutlet UIButton *addDomain;

@end
static NSMutableString * _log;
@implementation LYTPingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"ping";
    _log = [@"" mutableCopy];
    [self screenView];
   
    [self.addDomain addTarget:self action:@selector(addDomain:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[LYTNetDiagnoser shareTool] stopTestPing];
}

#pragma mark - private
- (NSString *)getDomain{
    
    return self.textDomain.text;
}
- (LYTScreenView *)screenView{
    if (!_screenView) {
        _screenView = [[LYTScreenView alloc] initWithContent:@""];
        [self.view addSubview:_screenView];
    }
    return _screenView;
}
- (IBAction)ClickPing:(UIButton *)sender {
    [self.view endEditing:YES];
    if (_ping == YES) {
        [sender setTitle:@"开始" forState:UIControlStateNormal];

        [[LYTNetDiagnoser shareTool] stopTestPing];
        
    }else{
        LYWeakSelf;
        [sender setTitle:@"停止" forState:UIControlStateNormal];
        [LYTNetDiagnoser shareTool].pingDelegate = self;
        [[LYTNetDiagnoser shareTool] testPingRequestDomain:self.textDomain.text count: [self.pingCount.text integerValue] respose:^(LYTPingInfo *info)  {
            [_log appendString:info.infoStr];
            [_log appendFormat:@"\n\n"];
            [weakSelf.screenView setContent:_log];
            NSRange range = {_log.length,0};
            [weakSelf.screenView scrollToRange:range];
        } error:^(NSString *error) {
            if (error) {
                [_log appendString:error];
                [weakSelf.screenView setContent:_log];
                NSRange range = {_log.length,0};
                [weakSelf.screenView scrollToRange:range];
                [[LYTNetDiagnoser shareTool] stopTestPing];
                [self pingDidStopPingRequest];
            }
        }];

    }
    _ping = !_ping;
}

- (void)didEndPingAction{
    [[LYTNetDiagnoser shareTool] stopTestPing];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
#pragma mark -
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self.screenView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.pingCount.mas_bottom).offset(20);
        make.left.mas_equalTo(self.view).offset(15);
        make.right.mas_equalTo(self.view).offset(-15);
        make.bottom.mas_equalTo(self.view).offset(-15);
    }];
}
- (void)addDomain:(UIButton *)btn{
    [self.view endEditing:YES];
    [[LYTSDKDataBase shareDatabase] dbAllServersSucceed:^(NSArray<NSString *> *servers) {
        __block BOOL exist = NO;
        [servers enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:self.textDomain.text]) {
                exist = YES;
            }
        }];
        if (exist) {

            [self addLog:@"该域名主机已经存在\n"];
        }
        else
        {
        [[LYTSDKDataBase shareDatabase] dbInsertserver:self.textDomain.text succeed:^(BOOL result) {
            [self addLog:@"添加域名主机成功"];
        }];
        }
    }];
   
}
#pragma mark - LYTNetPingDelegate
- (void)pingDidReportSequence:(NSUInteger)seq timeout:(BOOL)isTimeout delay:(NSUInteger)delay packetLoss:(double)lossRate host:(NSString *)ip{
//    64 bytes from 163.177.151.110: icmp_seq=1 ttl=49 time=8.770 ms
//    Request timeout for icmp_seq 0
    if (!isTimeout) {
        [self addLog:[NSString stringWithFormat:@"64 bytes from %@ : icmp_seq=%zd time=%zd ms \n",ip,seq,delay]];
    }else{
        [self addLog:[NSString stringWithFormat:@"Request timeout for icmp_seq %zd \n",seq]];
    }
    self.lostLabel.text = [NSString stringWithFormat:@"丢包率:%.0f%%",lossRate];
 
    
}

- (void)pingDidStopPingRequest{
    _ping = NO;
    [self.pingBtn setTitle:@"开始" forState:UIControlStateNormal];
}
- (void)addLog:(NSString *)log{
    [_log appendString:log];
    _screenView.content = _log;
    NSRange range = {_log.length,0};
    [_screenView scrollToRange:range];
    
}
@end
