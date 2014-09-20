//
//  RubyView.m
//  RubyTest
//
//  Created by Morten Bertz on 9/20/14.
//  Copyright (c) 2014 Morten Bertz. All rights reserved.
//

#import "RubyView.h"
#import "NSString+Japanese.h"

@import CoreText;

@implementation RubyView{

}




-(CFAttributedStringRef)furiganaAttributedString:(NSAttributedString*) string{
    
    CFAttributedStringRef input=(__bridge CFAttributedStringRef)(string);
    
    if (self.type==RubyTypeFurigana) {
        NSDictionary *furiganaDict=[string.string hiraganaReplacementsForString];
        return [self createRubyAttributedString:input furiganaRanges:furiganaDict];
    }
    /*  else if (self.type==RubyTypeFuriganaRomaji){
     NSDictionary *romajiDict=[string.string romajiReplacementsForString];
     return [self createAttributedString:input furiganaRanges:romajiDict];
     
     }*/
    
    else if(self.type==RubyTypeHiraganaOnly){
        NSString *hiragana=[string.string stringByReplacingJapaneseKanjiWithHiragana];
        NSAttributedString *hiraganaAttr=[[NSAttributedString alloc]initWithString:hiragana attributes:[string attributesAtIndex:0 effectiveRange:NULL]];
        return CFBridgingRetain(hiraganaAttr);
    }
    else if (self.type==RubyTypeNone){
        return input;
    }
    
    return nil;
}



- (CFAttributedStringRef)createRubyAttributedString:(CFAttributedStringRef)string furiganaRanges:(NSDictionary*)furigana
{
     CFMutableAttributedStringRef stringMutable=CFAttributedStringCreateMutableCopy(NULL, CFAttributedStringGetLength(string), string);
#if MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_10
    for (NSValue *value in furigana.keyEnumerator) {
        NSRange range=value.rangeValue;
        NSString *string=[furigana objectForKey:value];
        CFStringRef furigana[kCTRubyPositionCount] = {(__bridge CFStringRef)string, NULL, NULL, NULL};
        CTRubyAnnotationRef rubyRef = CTRubyAnnotationCreate(kCTRubyAlignmentAuto, kCTRubyOverhangNone, 0.5, furigana);
        CFRange r=CFRangeMake(range.location, range.length);
        CFAttributedStringSetAttribute(stringMutable, r, kCTRubyAnnotationAttributeName, rubyRef);
        CFRelease(rubyRef);
    }
    
    CFAttributedStringRef rubyString=CFAttributedStringCreateCopy(NULL, stringMutable);
    CFRelease(stringMutable);
    
    
    return rubyString;

#else
     CFAttributedStringRef rubyString=CFAttributedStringCreateCopy(NULL, stringMutable);
     CFRelease(stringMutable);
     return rubyString;
#endif
   
}

-(NSSize)intrinsicContentSize{
    if (self.stringToTransform.length>0) {
        
        self.rubyString=[self furiganaAttributedString:self.stringToTransform];
        
        //  [self removeConstraint:heightConstraint];
        CTFramesetterRef framesetter=CTFramesetterCreateWithAttributedString(self.rubyString);
        CGSize constraints=CGSizeMake(self.bounds.size.width, CGFLOAT_MAX);
        CFRange fitrange;
        CGSize newSize=CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, CFAttributedStringGetLength(self.rubyString)), NULL, constraints, &fitrange);
        //newSize.width=size.width;
        self.intrinsicContentSize=newSize;
        CFRelease(framesetter);
        //    heightConstraint=[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:newSize.height];
        
        //  [self addConstraint:heightConstraint];
        
        
        NSLog(@"%@",NSStringFromSize(newSize));

    return newSize;
    }
    else{
        return self.bounds.size;
    }
}

-(void)setIntrinsicContentSize:(CGSize)intrinsicContentSize{
    



}








- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    if (self.stringToTransform.length>0){
    [[NSGraphicsContext currentContext] saveGraphicsState];
    CGContextRef context=[[NSGraphicsContext currentContext]graphicsPort];
     CGContextSetTextMatrix(context, CGAffineTransformIdentity);
       
    CTFramesetterRef frameSetter=CTFramesetterCreateWithAttributedString(self.rubyString);
    CGPathRef path=CGPathCreateWithRect(self.bounds, NULL);
  //  CGSize constraints=CGSizeMake(self.bounds.size.width, CGFLOAT_MAX);
    //CFRange fitrange;
  //  CGSize sizeToFit=CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0, CFAttributedStringGetLength(self.rubyString)), NULL, constraints, &fitrange);
    CTFrameRef frame=CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, CFAttributedStringGetLength(self.rubyString)), path, NULL);
    CGContextSaveGState(context);


    CTFrameDraw(frame, context);
    CGContextRestoreGState(context);
    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(frameSetter);

}

    
    
 //   CGColorRelease(white);
   // CGColorRelease(red);
}

@end
