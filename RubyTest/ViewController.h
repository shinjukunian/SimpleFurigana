//
//  ViewController.h
//  RubyTest
//
//  Created by Morten Bertz on 9/18/14.
//  Copyright (c) 2014 Morten Bertz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RubyView;
@interface ViewController : UIViewController<UITextViewDelegate,UIScrollViewDelegate>

@property IBOutlet UITextView *inputTextView;
@property IBOutlet UIScrollView *scrollView;
@property IBOutlet RubyView *rubyView;
@property NSString *inputString;

@end

