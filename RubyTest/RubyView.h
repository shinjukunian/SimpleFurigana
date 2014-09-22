//
//  RubyView.h
//  RubyTest
//
//  Created by Morten Bertz on 9/18/14.
//  Copyright (c) 2014 Morten Bertz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RubyView : UIView


typedef enum{
    RubyTypeFuriganaRomaji,
    RubyTypeFurigana,
    RubyTypeHiraganaOnly,
    RubyTypeRomajiOnly,
    RubyTypeNone,
}RubyType;

typedef enum{
    RubyHorizontalText,
    RubyVerticalText,
    
}textOrientation;

@property CFAttributedStringRef rubyString;
@property NSAttributedString *stringToTransform;
@property CGSize intrinsicContentSize;
@property RubyType type;
@property textOrientation orientation;
@property (weak) UIScrollView *hostingScrollView;

@end
