//
//  ViewController.m
//  BlueTooth
//
//  Created by YB on 16/2/27.
//  Copyright © 2016年 YB. All rights reserved.
//

#import "ViewController.h"

#import "ClientBlueTooth.h"
#import "ServerBlueTooth.h"
@interface ViewController ()
{
    CBCentralManager *manager;
    CBPeripheral * myp;
    CBPeripheralManager * pManager;

}
@end

@implementation ViewController
- (void)loadView {
    self.view = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton * service = [[UIButton alloc]initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 100)];
    service.backgroundColor = [UIColor redColor];
    [service addTarget:self action:@selector(toservice) forControlEvents:UIControlEventTouchUpInside];
    UIButton * client = [[UIButton alloc]initWithFrame:CGRectMake(0, 300, [UIScreen mainScreen].bounds.size.width, 100)];
    [client setTitle:@"作为客户端" forState:0];
        [service setTitle:@"作为服务端" forState:0];
        client.backgroundColor = [UIColor redColor];
    [client addTarget:self action:@selector(toClient) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:service];
        [self.view addSubview:client];
}
- (void)toClient {
    ClientBlueTooth * a = [[ClientBlueTooth alloc]init];
    [self.navigationController pushViewController:a animated:YES];
}
- (void)toservice {
        ServerBlueTooth * a = [[ServerBlueTooth alloc]init];
    [self.navigationController pushViewController:a animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
