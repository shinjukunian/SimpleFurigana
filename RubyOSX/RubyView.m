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
    CGRect printRect;
    BOOL portrait;
    NSUInteger currentPage;
    NSUInteger numberOfPages;

}




-(CFAttributedStringRef)furiganaAttributedString:(NSAttributedString*) string{
    
    
    if (self.type==RubyTypeFurigana) {
        NSDictionary *furiganaDict=[string.string hiraganaReplacementsForString];
        return [self createRubyAttributedString:(__bridge CFAttributedStringRef)(string) furiganaRanges:furiganaDict];
    }
    /*  else if (self.type==RubyTypeFuriganaRomaji){
     NSDictionary *romajiDict=[string.string romajiReplacementsForString];
     return [self createAttributedString:input furiganaRanges:romajiDict];
     
     }*/
    
    else if(self.type==RubyTypeHiraganaOnly){
        NSString *hiragana=[string.string stringByReplacingJapaneseKanjiWithHiragana];
        NSMutableDictionary *dict=[[string attributesAtIndex:0 effectiveRange:NULL]mutableCopy];
        
        if (self.orientation==RubyVerticalText) {
             [dict setObject:@YES forKey:(NSString*)kCTVerticalFormsAttributeName];
         }
        NSAttributedString *hiraganaAttr=[[NSAttributedString alloc]initWithString:hiragana attributes:dict];
        return CFBridgingRetain(hiraganaAttr);
    }
    else if (self.type==RubyTypeNone){
        
        if (self.orientation==RubyVerticalText) {
            NSMutableAttributedString *vertical=[[NSMutableAttributedString alloc]initWithAttributedString:string];
            [vertical addAttributes:@{(NSString*)kCTVerticalFormsAttributeName:@YES} range:NSMakeRange(0, vertical.length)];
            return CFBridgingRetain(vertical.copy);
        }
        else{
            
            return (__bridge CFAttributedStringRef)(string);
        }
       
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



-(BOOL)knowsPageRange:(NSRangePointer)range{
    printRect=self.printInfo.imageablePageBounds;
    printRect=CGRectInset(printRect, 20, 20);
    CTFramesetterRef framesetter=CTFramesetterCreateWithAttributedString(self.rubyString);
    CGSize constraints=printRect.size;
    NSUInteger stringLength=CFAttributedStringGetLength(self.rubyString);
    CFRange stringRange=CFRangeMake(0, stringLength);
    CFRange fitrange=CFRangeMake(0, 0);
    
    numberOfPages=0;
    while (fitrange.location+fitrange.length<stringLength) {
        CTFramesetterSuggestFrameSizeWithConstraints(framesetter, stringRange, NULL, constraints, &fitrange);
        stringRange.location=fitrange.location+fitrange.length;
        stringRange.length=stringLength-stringRange.location;
        numberOfPages+=1;
    }
    range->length=numberOfPages;

    
    return YES;
}



-(NSRect)rectForPage:(NSInteger)page{
    
    currentPage=page;
    return printRect;
}




- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    if (self.stringToTransform.length>0){
        
        if ( ![NSGraphicsContext currentContextDrawingToScreen] ) {//printing
            
            [[NSGraphicsContext currentContext] saveGraphicsState];
            CGContextRef context=[[NSGraphicsContext currentContext]graphicsPort];
            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
            
            CTFramesetterRef frameSetter=CTFramesetterCreateWithAttributedString(self.rubyString);
            CGPathRef path=CGPathCreateWithRect(printRect, NULL);
            CTFrameRef frame;
            CGSize constraints=printRect.size;
            NSUInteger stringLength=CFAttributedStringGetLength(self.rubyString);
            CFRange stringRange=CFRangeMake(0, stringLength);
            CFRange fitrange=CFRangeMake(0, 0);
            NSUInteger page=0;
            while (fitrange.location+fitrange.length<stringLength) {
                CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, stringRange, NULL, constraints, &fitrange);
                page+=1;
                if (page==currentPage) {
                    break;
                }
                stringRange.location=fitrange.location+fitrange.length;
                stringRange.length=stringLength-stringRange.location;
                
            }
            
            if (self.orientation==RubyVerticalText) {
                NSDictionary *dict=@{(NSString *)kCTFrameProgressionAttributeName:@(kCTFrameProgressionRightToLeft)};
                CFDictionaryRef cfDict=(__bridge CFDictionaryRef)(dict);
                frame=CTFramesetterCreateFrame(frameSetter, fitrange, path, cfDict);
            }
            else{
                frame=CTFramesetterCreateFrame(frameSetter, fitrange
                                               , path, NULL);
                
            }
            
            CGContextSaveGState(context);
            CTFrameDraw(frame, context);
            CGContextRestoreGState(context);
            CFRelease(frame);
            CFRelease(path);
            CFRelease(frameSetter);
        
        
        
        }
        
        else{
        
            [[NSGraphicsContext currentContext] saveGraphicsState];
            CGContextRef context=[[NSGraphicsContext currentContext]graphicsPort];
            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
       
            CTFramesetterRef frameSetter=CTFramesetterCreateWithAttributedString(self.rubyString);
            CGPathRef path=CGPathCreateWithRect(CGRectInset(self.bounds, 10, 10), NULL);
            CTFrameRef frame;
            if (self.orientation==RubyVerticalText) {
                NSDictionary *dict=@{(NSString *)kCTFrameProgressionAttributeName:@(kCTFrameProgressionRightToLeft)};
                CFDictionaryRef cfDict=(__bridge CFDictionaryRef)(dict);
                frame=CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, CFAttributedStringGetLength(self.rubyString)), path, cfDict);
            }
            else{
                frame=CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, CFAttributedStringGetLength(self.rubyString)), path, NULL);
            
            }
   
            CGContextSaveGState(context);
            CTFrameDraw(frame, context);
            CGContextRestoreGState(context);
            CFRelease(frame);
            CFRelease(path);
            CFRelease(frameSetter);
        }
    }

}

@end
