//
//  ServerBlueTooth.m
//  BlueTooth
//
//  Created by YB on 16/2/27.
//  Copyright © 2016年 YB. All rights reserved.
//

#import "ServerBlueTooth.h"
#import <CoreBluetooth/CoreBluetooth.h>
#define charactUU @"1CBB0646-AADD-4826-89F5-D607D6C26815"
#define serviceUU @"90993845-8F46-45F5-8188-4E002D091194"

@interface ServerBlueTooth()<CBPeripheralManagerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    CBPeripheralManager * pManager;
    NSMutableArray *dataArray;
    CBMutableCharacteristic * myC;
    UITextField * textF;
    UITableView * table;
}
@end
@implementation ServerBlueTooth
- (void)loadView {
    self.view= [[UIView alloc]initWithFrame:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64 - 40)];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    dataArray = [[NSMutableArray alloc]init];
    table = [[UITableView alloc]initWithFrame:CGRectMake(0,64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64 - 40) style:UITableViewStyleGrouped];
    table.delegate = self;
    table.dataSource = self;
    pManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
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
    textF.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 40 - h, [UIScreen mainScreen].bounds.size.width, 40);
}
- (void)keyBoardWillDisMiss:(NSNotification * )noti {
    textF.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 40 , [UIScreen mainScreen].bounds.size.width, 40);
}
- (void)send {
    if (!textF.text.length) {
        textF.text = @"哈哈哈什么也没有说";
    }
    [dataArray addObject:textF.text];
    [pManager updateValue:[textF.text dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:myC    onSubscribedCentrals:nil];
    textF.text = @"";
    [textF resignFirstResponder];
    [table reloadData];
    

}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        pManager = peripheral;
        [self setUp];
    }
}
- (void)setUp {
    myC = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:charactUU] properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyWrite | CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable |CBAttributePermissionsWriteable];
    CBMutableService * myS = [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:serviceUU] primary:YES];
    [myS setCharacteristics:@[myC]];
    [pManager addService:myS];
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    [pManager startAdvertising:@{CBAdvertisementDataServiceDataKey:@[[CBUUID UUIDWithString:CBUUIDCharacteristicUserDescriptionString]],
                                 CBAdvertisementDataLocalNameKey:@"我是服务器"}];
}
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    [pManager updateValue:[@"你要和我聊天么" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:myC    onSubscribedCentrals:nil];

}
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    myC.value = requests[0].value;
    [pManager respondToRequest:requests[0] withResult:CBATTErrorSuccess];
    [dataArray addObject:requests[0]];
    [table reloadData];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count + 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.userInteractionEnabled = NO;
    if (indexPath.row == 0) {
        cell.textLabel.text = @"与客户端对话";
    }else {
        CBATTRequest * re = dataArray[indexPath.row - 1];
        if ([re isKindOfClass:[NSString class]]) {
            cell.textLabel.text =[NSString stringWithFormat:@"我说--%@",re];
        }else {
        cell.textLabel.text =[NSString stringWithFormat:@"TA说--%@", [[NSString alloc]initWithData:re.value encoding:NSUTF8StringEncoding]];
    }
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

@end