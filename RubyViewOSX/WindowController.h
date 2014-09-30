//
//  WindowController.h
//  RubyTest
//
//  Created by Morten Bertz on 9/29/14.
//  Copyright (c) 2014 Morten Bertz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class RubyViewOSX;

@interface WindowController : NSWindowController<NSTextViewDelegate,NSToolbarDelegate,NSWindowDelegate>


@property IBOutlet NSTextView *textView;
@property IBOutlet NSScrollView *scrollView;
@property IBOutlet RubyViewOSX *rubyView;


@end
