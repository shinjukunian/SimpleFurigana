//
//  FullScreenViewController.h
//  RubyTest
//
//  Created by Morten Bertz on 9/22/14.
//  Copyright (c) 2014 Morten Bertz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RubyView.h"

@interface FullScreenViewController : UIViewController


@property IBOutlet RubyView *rubyView;
@property RubyType type;
@property NSAttributedString *stringToTransform;
@property textOrientation orientation;
@property IBOutlet UIToolbar *toolBar;
@property IBOutlet UIScrollView *scrollView;

@end
