//
//  ASServerViewController.m
//  AsyncSocketTest
//
//  Created by 周健 on 14-5-16.
//  Copyright (c) 2014年 周健. All rights reserved.
//

#import "ASServerViewController.h"
#import "ASTool.h"
#import "ASConstans.h"

static NSString *welMsg = @"Welcome to beijin\r\n";
static NSTimeInterval defTimeout = 10.0;

@interface ASServerViewController ()
@property (retain, nonatomic) AsyncSocket *listenSocket;
@property (retain, nonatomic) NSMutableArray *socketArray;
@end

@implementation ASServerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.messageTextView.layer.borderColor = [UIColor grayColor].CGColor;
    self.messageTextView.layer.borderWidth = 1;
    self.messageTextView.layer.cornerRadius = 5;
    
    self.socketArray = [[NSMutableArray alloc]initWithCapacity:1];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startButtonPress:(id)sender {
    if (!self.listenSocket) {
        self.listenSocket = [[AsyncSocket alloc]initWithDelegate:self];
        NSError *error = nil;
        if(![self.listenSocket acceptOnPort:asServerPort error:&error])
        {
            NSLog(@"open server socket error %@" , error);
        }
        
        [self.listenSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    }
    
}

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket{
    NSLog(@"new socket coming");
    [self.socketArray addObject:newSocket];
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    [sock writeData:[welMsg dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:WelTag];
    [sock readDataToData:[AsyncSocket CRLFData] withTimeout:defTimeout tag:DataTag];
    NSLog(@"server socket connect");
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock{
    NSLog(@"server socket disconnect");
    [self.socketArray removeObject:sock];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"server socket read complete");
    NSString *message = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    self.messageTextView.text = [[self.messageTextView.text stringByAppendingString:@"read from client: "] stringByAppendingString:message];
    [ASTool scrollTextViewToBottom:self.messageTextView];
    
    //resposn to client
    NSString *resposeMessage = [@"Accept success,  message: " stringByAppendingString:message];
    [sock writeData:[resposeMessage dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1  tag:DataTag];
    
    [sock readDataToData:[AsyncSocket CRLFData] withTimeout:defTimeout tag:DataTag];
    
}

/**
 some firewall will disconnect socket when no data is sending, so polling with timeout can prevent it
 **/
- (NSTimeInterval)onSocket:(AsyncSocket *)sock
  shouldTimeoutReadWithTag:(long)tag
				   elapsed:(NSTimeInterval)elapsed
				 bytesDone:(NSUInteger)length
{
	if(elapsed <= defTimeout)
	{
		NSData *warningData = [CheckStatMsg dataUsingEncoding:NSUTF8StringEncoding];
		
		[sock writeData:warningData withTimeout:-1 tag:WarningTag];
		
		return defTimeout;
	}
	
	return 0.0;
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"server socket write complete");
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
	NSLog(@"Client Disconnected: %@:%hu", [sock connectedHost], [sock connectedPort]);
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
