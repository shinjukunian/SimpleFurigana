//
//  ViewController.h
//  RubyTest
//
//  Created by Morten Bertz on 9/18/14.
//  Copyright (c) 2014 Morten Bertz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RubyView;

@interface ViewController : UIViewController<UITextViewDelegate>

@property IBOutlet UITextView *inputTextView;
@property IBOutlet RubyView *rubyView;



@end

