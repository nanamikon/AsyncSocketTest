//
//  ASViewController.m
//  AsyncSocketTest
//
//  Created by 周健 on 14-5-15.
//  Copyright (c) 2014年 周健. All rights reserved.
//

#import "ASClientViewController.h"
#import "ASTool.h"
#import "ASConstans.h"


//static NSString *asServerHost = @"172.161.16.110";
static NSString *asServerHost = @"127.0.0.1";
static NSInteger asServerPort = 9100;
static Boolean isAutoReconnect = true;

static NSData* (^openMonitor)(void) = ^(void){
    Byte byte[] = {0x1B, 0x70, 0x01, 0x10, 0x20} ;
    return [[NSData alloc]initWithBytes:byte length:5];
};

static NSDictionary* monitorCode;


@interface ASClientViewController ()

@property (retain,nonatomic) AsyncSocket *socket;
@end

@implementation ASClientViewController

- (void)initData{
    if (!monitorCode) {
        monitorCode = @{@"Open Cash Drawer": openMonitor};
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    NSError *error = nil;
//    AsyncSocket *socket = [[AsyncSocket alloc]initWithDelegate:self];
//    if(![socket acceptOnPort:asServerPort error:&error])
//    {
//        NSLog(@"open server socket error %@" , error);
//    }
    //socket.connectedHost
    
    [self initData];

 
    self.messageTextView.layer.borderColor = [UIColor grayColor].CGColor;
    self.messageTextView.layer.borderWidth = 1;
    self.messageTextView.layer.cornerRadius = 5;
}

//- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket{
//    NSLog(@"new socket , %@ : %d", newSocket.connectedHost, newSocket.connectedPort);
//}

- (IBAction)connectButtonClick:(id)sender {
    NSError *error = nil;
    
    if (!self.socket || ![self.socket isConnected]) {
        self.socket = [[AsyncSocket alloc]initWithDelegate:self];
        if(![self.socket connectToHost:asServerHost onPort:asServerPort error:&error]){
            NSLog(@"client connect error %@" , error);
        }
    }else{
        [self.socket disconnect];
    }
}
- (IBAction)sendButtonPress:(id)sender {
    [self.socket writeData:[[self.messageTextField.text stringByAppendingString:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]  withTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    
    self.messageTextView.text = [self.messageTextView.text stringByAppendingFormat:@"socket connect success! host: %@, port: %d\r\n" ,host,port];

    //[sock writeData:openMonitor withTimeout:-1 tag:0];
    
    [sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:WelTag];

}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                     message:message
                                                    delegate:nil
                                           cancelButtonTitle:@"Dismiss"
                                           otherButtonTitles:nil];
    [alert show];
}

-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString *message = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    self.messageTextView.text = [self.messageTextView.text stringByAppendingString:message];
    [ASTool scrollTextViewToBottom:self.messageTextView];
    NSLog(@"client finish read");
    
    //[sock writeData:[@"i am ken\r\n" dataUsingEncoding:NSUTF8StringEncoding]  withTimeout:-1 tag:0];
    
    NSString *const dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (tag == WarningTag) {
        if (isAutoReconnect && [dataString isEqualToString:CheckStatMsg]) {
            [sock writeData:[@"Yes, i am here\r\n" dataUsingEncoding:NSUTF8StringEncoding]  withTimeout:-1 tag:DataTag];
        }else{
            [sock disconnect];

        }
    }else{
        [sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:DataTag];
        [sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:WarningTag];
    }
}

-(void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"client finish write");
}

-(NSTimeInterval)onSocket:(AsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length{
    NSLog(@"client reading");
    return 10;
}

-(void)onSocketDidDisconnect:(AsyncSocket *)sock{
    NSLog(@"client disconnect");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
