//
//  ASViewController.h
//  AsyncSocketTest
//
//  Created by 周健 on 14-5-15.
//  Copyright (c) 2014年 周健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncSocket.h"

@interface ASClientViewController : UIViewController<AsyncSocketDelegate>
@property (weak, nonatomic) IBOutlet UIButton *collectButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

@end
