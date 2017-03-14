//
//  HomePageViewController.m
//  SanKung
//
//  Created by 黄志航 on 16/3/14.
//  Copyright © 2016年 Hunt. All rights reserved.
//

#import "HomePageViewController.h"
#import "AddressViewController.h"

@interface HomePageViewController ()

@property (strong, nonatomic) IBOutlet UITextField *playerNumberTextField;

@end

@implementation HomePageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)onClickedOK
{
    AddressViewController *vc = [[AddressViewController alloc] init];
    vc.playerNumber = [_playerNumberTextField.text integerValue];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_playerNumberTextField resignFirstResponder];
}

@end
