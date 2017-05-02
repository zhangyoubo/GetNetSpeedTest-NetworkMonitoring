//
//  TracerouteViewController.m
//  LYTNetDiagnose
//
//  Created by 谭建中 on 2017/4/7.
//  Copyright © 2017年 Vieene. All rights reserved.
//

#import "TracerouteViewController2.h"
#import "LYTNetTraceRoute.h"
#import "LYTScreenView.h"
#import "LYTNetDiagnoser.h"
#import "LYTConfig.h"
#import "LYTSDKDataBase+LYTServersList.h"

static NSMutableString *_log;
@interface TracerouteViewController2 ()<LYTNetTraceRouteDelegate>{
    LYTNetTraceRoute *_traceRouter;
    LYTScreenView *_screeenView;
    NSString * _dormain;
}
@property (nonatomic,assign) BOOL running;

@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UITextField *domaintextFiled;
- (IBAction)clickStart:(UIButton *)sender;
- (IBAction)clickAddServer:(UIButton *)sender;

@end

@implementation TracerouteViewController2
+ (void)initialize{
}
- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.title = @"Traceroute";
    _log = [@"" mutableCopy];
    [self screeenView];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self stopTraceroute];
}
- (LYTScreenView *)screeenView{
    if (!_screeenView) {
        _screeenView = [[LYTScreenView alloc] initWithContent:@""];
        [self.view addSubview:_screeenView];
    }
    return _screeenView;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
#pragma mark - traceRouteDelegate
- (void)appendRouteLog:(NSString *)routeLog
{
    [self addLog:routeLog];
}

- (void)traceRouteDidEnd
{

    [self addLog:@"\n TraceRouteDidEnd \n"];
    [self stopTraceroute];
}

- (void)addLog:(NSString *)log{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_log appendString:log];
        [_log appendString:@"\n"];
        _screeenView.content = _log;
        NSRange range = {_log.length,0};
        [_screeenView scrollToRange:range];
    });
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [_screeenView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.startBtn.mas_bottom).offset(20);
        make.left.mas_equalTo(self.view).offset(15);
        make.right.mas_equalTo(self.view).offset(-15);
        make.bottom.mas_equalTo(self.view).offset(-15);
    }];
}
- (IBAction)clickStart:(UIButton *)sender {
    [self.view endEditing:YES];
    if (_running == YES)
    {
        [self stopTraceroute];
    }
    else
    {
        _dormain = self.domaintextFiled.text;
        [sender setTitle:@"停止" forState:UIControlStateNormal];
        _traceRouter = [[LYTNetTraceRoute alloc] initWithMaxTTL:TRACEROUTE_MAX_TTL
                                                       timeout:TRACEROUTE_TIMEOUT
                                                   maxAttempts:TRACEROUTE_ATTEMPTS
                                                          port:TRACEROUTE_PORT];
        _traceRouter.delegate = self;
        if (_traceRouter) {
            [NSThread detachNewThreadSelector:@selector(doTraceRoute:)
                                     toTarget:_traceRouter
                                   withObject:_dormain];
        }
    }
    _running = !_running;
}

- (IBAction)clickAddServer:(UIButton *)sender {
    [self.view endEditing:YES];
    [[LYTSDKDataBase shareDatabase] dbAllServersSucceed:^(NSArray<NSString *> *servers) {
        __block BOOL exist = NO;
        [servers enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:self.domaintextFiled.text]) {
                exist = YES;
            }
        }];
        if (exist) {
            
            [self addLog:@"该域名主机已经存在\n"];
        }
        else
        {
            [[LYTSDKDataBase shareDatabase] dbInsertserver:self.domaintextFiled.text succeed:^(BOOL result) {
                [self addLog:@"添加域名主机成功\n"];
            }];
        }
    }];
}

- (void)stopTraceroute{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_traceRouter stopTrace];
        [self.startBtn setTitle:@"开始" forState:UIControlStateNormal];
    });
   
    
}

@end
