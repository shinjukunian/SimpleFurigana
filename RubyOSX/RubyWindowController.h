//
//  RubyWindowController.h
//  RubyTest
//
//  Created by Morten Bertz on 9/20/14.
//  Copyright (c) 2014 Morten Bertz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class RubyView;

@interface RubyWindowController : NSWindowController<NSTextViewDelegate,NSToolbarDelegate,NSWindowDelegate>

@property IBOutlet NSTextView *textView;
@property IBOutlet NSScrollView *scrollView;
@property IBOutlet RubyView *rubyView;

@end
