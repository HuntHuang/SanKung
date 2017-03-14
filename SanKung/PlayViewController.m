//
//  PlayViewController.m
//  SanKung
//
//  Created by 黄志航 on 16/4/26.
//  Copyright © 2016年 Hunt. All rights reserved.
//

#import "PlayViewController.h"
#import "AsyncSocket.h"

@interface PlayViewController ()<AsyncSocketDelegate>

@property (nonatomic, strong) AsyncSocket *acceptSocket;
@property (nonatomic, strong) AsyncSocket *socket;
@property (nonatomic, strong) NSMutableArray *numberArray;
@property (nonatomic, assign) NSInteger bankerCardCount;
@property (nonatomic, assign) NSInteger playerCardCount;
@property (nonatomic, weak) UIImageView *coverImage;

@end

@implementation PlayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self debugSocket];
    UIImageView *coverImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64 - 50)];
    self.coverImage = coverImage;
    [self.view addSubview:self.coverImage];
}

- (void)debugSocket
{
    NSError *err = nil;
    if ([self.socket acceptOnPort:6667 error:&err])
    {
        NSLog(@"accept ok.");
    }
    else
    {
        NSLog(@"accept failed.");
    }
    if (err)
    {
        NSLog(@"error: %@",err);
    }
}

- (IBAction)onClickedDeal
{
    [self initNumberArray];
    for (int i = 10; i < 13; i++)
    {
        UIImageView *imageView = (UIImageView *)[self.view viewWithTag:i];
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld.JPG", (long)[self noRepeatNumber]]];
    }
    self.coverImage.image = [self imageWithColor:[UIColor darkGrayColor] size:self.coverImage.bounds.size];
    NSDictionary *dic = @{@"imageString":self.numberArray};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    [self __socketWriteData:data];
}

- (IBAction)onClickdOver
{
    if (_socketArray.count == _playerNumber)
    {
        for (int i = 0; i < _socketArray.count; i++)
        {
            AsyncSocket *socket = [_socketArray objectAtIndex:i];
            [socket disconnect];
        }
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"结束了" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private
- (NSInteger)noRepeatNumber
{
    NSInteger count = self.numberArray.count;
    int index = arc4random() % count;
    NSInteger number = [self.numberArray[index] integerValue];
    [self.numberArray removeObjectAtIndex:index];
    return number;
}

- (void)initNumberArray
{
    _numberArray = [[NSMutableArray alloc] initWithCapacity:100];
    for (int i = 10; i <= 61; i ++)
    {
        [_numberArray addObject:@(i)];
    }
}

- (void)__socketWriteData:(NSData *)data
{
    if (_socketArray.count == _playerNumber)
    {
        for (int i = 0; i < _socketArray.count; i++)
        {
            AsyncSocket *socket = [_socketArray objectAtIndex:i];
            [socket writeData:data withTimeout:-1 tag:0];
        }
    }
}

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 触摸任意位置
    UITouch *touch = touches.anyObject;
    // 触摸位置在图片上的坐标
    CGPoint cententPoint = [touch locationInView:self.coverImage];
    // 设置清除点的大小
    CGRect  rect = CGRectMake(cententPoint.x, cententPoint.y, 35, 35);
    // 默认是去创建一个透明的视图
    UIGraphicsBeginImageContextWithOptions(self.coverImage.bounds.size, NO, 0);
    // 获取上下文(画板)
    CGContextRef ref = UIGraphicsGetCurrentContext();
    // 把imageView的layer映射到上下文中
    [self.coverImage.layer renderInContext:ref];
    // 清除划过的区域
    CGContextClearRect(ref, rect);
    // 获取图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    // 结束图片的画板, (意味着图片在上下文中消失)
    UIGraphicsEndImageContext();
    self.coverImage.image = image;
}

#pragma mark - AsyncSocketDelegate
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
    if (!_acceptSocket)
    {
        _acceptSocket = newSocket;
    }
}

#pragma mark - getter/setter
- (AsyncSocket *)socket
{
    if (!_socket)
    {
        _socket = [[AsyncSocket alloc] initWithDelegate:self];
    }
    return _socket;
}

@end
