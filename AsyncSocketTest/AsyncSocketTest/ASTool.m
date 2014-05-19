//
//  ASTool.m
//  AsyncSocketTest
//
//  Created by 周健 on 14-5-19.
//  Copyright (c) 2014年 周健. All rights reserved.
//

#import "ASTool.h"

@implementation ASTool
+ (void)scrollTextViewToBottom:(UITextView *)textView {
    if(textView.text.length > 0 ) {
        NSRange bottom = NSMakeRange(textView.text.length -1, 1);
        [textView scrollRangeToVisible:bottom];
    }
    
}
@end
