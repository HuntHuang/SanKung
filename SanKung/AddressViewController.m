//
//  AddressViewController.m
//  SanKung
//
//  Created by 黄志航 on 16/5/6.
//  Copyright © 2016年 Hunt. All rights reserved.
//

#import "AddressViewController.h"
#import "PlayViewController.h"
#import "AsyncSocket.h"

@interface AddressViewController ()<AsyncSocketDelegate>

@property (nonatomic, strong) NSMutableArray *socketArray;
@property (nonatomic, strong) AsyncSocket *socket;

@end

@implementation AddressViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    for (int i = 0; i < _playerNumber; i++)
    {
        UITextField *ipTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 80 + (i*80), 150, 50)];
        ipTextField.text = [self readIPFromUserDefaultsWithKeyName:[NSString stringWithFormat:@"%d", i]];
        ipTextField.tag = 10+i;
        [self.view addSubview:ipTextField];
        UIButton *linkBtn = [[UIButton alloc] initWithFrame:CGRectMake(250, 80 + (i*80), 100, 50)];
        [linkBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        linkBtn.tag = 20+i;
        [linkBtn setTitle:@"连接" forState:UIControlStateNormal];
        [linkBtn addTarget:self action:@selector(onClickedLink:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:linkBtn];
    }
    
    UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(130, 400, 100, 50)];
    [nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(onClickedNext) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    for (int i = 0; i < _playerNumber; i++)
    {
        UIButton *ipButton = (UIButton *)[self.view viewWithTag:20+i];
        [ipButton setTitle:@"连接" forState:UIControlStateNormal];
        [ipButton setUserInteractionEnabled:YES];
    }
    _socketArray = nil;
}

- (void)onClickedLink:(UIButton *)sender
{
    sender.selected = !sender.selected;
    for (int i = 0; i < _playerNumber; i++)
    {
        if (sender.tag == 20+i)
        {
            UITextField *ipTextField = (UITextField *)[self.view viewWithTag:10+i];
            NSError *error;
            _socket = [[AsyncSocket alloc] initWithDelegate:self];
            [_socket connectToHost:ipTextField.text onPort:6667 error:&error];
            [self saveIPToUserDefaultsWithString:ipTextField.text andKeyName:[NSString stringWithFormat:@"%d", i]];
            break;
        }
    }
}

- (void)onClickedNext
{
    PlayViewController *playVC = [[PlayViewController alloc] initWithNibName:@"PlayViewController" bundle:nil];
    playVC.socketArray  = self.socketArray;
    playVC.playerNumber = _playerNumber;
    [self.navigationController pushViewController:playVC animated:YES];
}

- (void)saveIPToUserDefaultsWithString:(NSString *)str andKeyName:(NSString *)keyName
{
    [[NSUserDefaults standardUserDefaults] setObject:str forKey:keyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)readIPFromUserDefaultsWithKeyName:(NSString *)keyName
{
    NSString *getdata = [[NSUserDefaults standardUserDefaults] valueForKey:keyName];
    return getdata;
}

#pragma mark - AsyncSocketDelegate
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"success!!! host:%@, port:%u", host, port);
    for (int i = 0; i < _playerNumber; i++)
    {
        NSString *ipAddress = [self readIPFromUserDefaultsWithKeyName:[NSString stringWithFormat:@"%d", i]];
        if ([ipAddress isEqualToString:host])
        {
            [self.socketArray addObject:sock];
            UIButton *ipButton = (UIButton *)[self.view viewWithTag:20+i];
            [ipButton setTitle:@"连接成功" forState:UIControlStateNormal];
            [ipButton setUserInteractionEnabled:NO];
        }
    }
    [sock readDataWithTimeout:-1 tag:0];
}

- (NSMutableArray *)socketArray
{
    if (!_socketArray)
    {
        _socketArray = [NSMutableArray array];
    }
    return _socketArray;
}

@end
