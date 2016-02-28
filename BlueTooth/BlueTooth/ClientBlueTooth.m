//
//  ClientBlueTooth.m
//  BlueTooth
//
//  Created by YB on 16/2/27.
//  Copyright © 2016年 YB. All rights reserved.
//

#import "ClientBlueTooth.h"
#define charactUU @"1CBB0646-AADD-4826-89F5-D607D6C26815"
#define serviceUU @"90993845-8F46-45F5-8188-4E002D091194"

@interface ClientBlueTooth()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *dataArray;
 CBCentralManager * centralManager;
CBPeripheral *myPeripheral;
    CBCharacteristic * chara;
    UITextField * textF;
    UITableView * table;

}

@end

@implementation ClientBlueTooth
- (void)loadView {
    self.view= [[UIView alloc]initWithFrame:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64 - 40)];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    dataArray = [[NSMutableArray alloc]init];
    table = [[UITableView alloc]initWithFrame:CGRectMake(0,64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64 - 40) style:UITableViewStyleGrouped];
    table.delegate = self;
    table.dataSource = self;


   centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"发送" style:UIBarButtonItemStyleDone target:self action:@selector(send)];
     textF = [[UITextField alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 40, [UIScreen mainScreen].bounds.size.width, 40)];
    textF.backgroundColor = [UIColor blueColor];
        [textF setPlaceholder:@"请输入"];
    [self.view addSubview:textF];
    [self.view addSubview:table];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardWillDisMiss:) name:UIKeyboardWillHideNotification object:nil];

    table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
}

- (void)keyBoardWillShow:(NSNotification * )noti{
    NSDictionary * userInfo = [noti userInfo];
    NSValue * va = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyBoard = [va CGRectValue];
    CGFloat h = keyBoard.size.height;
    textF.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 40- h, [UIScreen mainScreen].bounds.size.width, 40);
}
- (void)keyBoardWillDisMiss:(NSNotification * )noti {
    textF.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 40 , [UIScreen mainScreen].bounds.size.width, 40);
}
- (void)send {
    if (!textF.text.length) {
        textF.text = @"哈哈哈什么也没有说";
    }
        [dataArray addObject:textF.text];
    [myPeripheral writeValue:[textF.text dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:chara type:CBCharacteristicWriteWithResponse];
    textF.text = @"";
    [textF resignFirstResponder];
    [table reloadData];

}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBCentralManagerStatePoweredOn) {
        [central scanForPeripheralsWithServices:nil options:nil];
    }
}
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"%@",peripheral.name);
    if (![dataArray containsObject:peripheral])
    {
        [dataArray addObject:peripheral];
        [table reloadData];
    }
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}
    

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    id p = dataArray [indexPath.row];
    if ([p isKindOfClass:[NSData class]]) {
        cell.userInteractionEnabled = NO;

        cell.textLabel.text = [NSString stringWithFormat :@"TA说--%@",[[NSString alloc]initWithData:p encoding:NSUTF8StringEncoding]];
    }else if ([p isKindOfClass:[NSString class]]){
        cell.userInteractionEnabled = NO;
        cell.textLabel.text = [NSString stringWithFormat:@"我说--%@",p];
    }else {
     cell.textLabel.text =   [(CBPeripheral *)p name];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBPeripheral * p = dataArray [indexPath.row];
    [centralManager connectPeripheral:p options:nil];
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    peripheral.delegate = self;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:serviceUU]]];
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:charactUU]] forService:peripheral.services[0]];
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    myPeripheral = peripheral;
    chara = (CBCharacteristic *)service.characteristics[0];
    [peripheral setNotifyValue:YES forCharacteristic:service.characteristics[0]];
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"%@",characteristic.value);
    [dataArray addObject:characteristic.value];
    [table reloadData];
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"断开--%@",error);
}
@end
