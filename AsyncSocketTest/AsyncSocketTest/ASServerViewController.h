//
//  ASServerViewController.h
//  AsyncSocketTest
//
//  Created by 周健 on 14-5-16.
//  Copyright (c) 2014年 周健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncSocket.h"

static NSInteger asServerPort = 9100;

@interface ASServerViewController : UIViewController<AsyncSocketDelegate>
@property (weak, nonatomic) IBOutlet UIButton *serverStartButton;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

@end
