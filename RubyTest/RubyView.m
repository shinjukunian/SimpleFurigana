//
//  RubyView.m
//  RubyTest
//
//  Created by Morten Bertz on 9/18/14.
//  Copyright (c) 2014 Morten Bertz. All rights reserved.
//

#import "RubyView.h"
#import "NSString+Japanese.h"

@import CoreText;

@implementation RubyView

// inspired by http://dev.classmethod.jp/references/ios8-ctrubyannotationref/


-(CFAttributedStringRef)furiganaAttributedString:(NSAttributedString*) string{
   
    CFAttributedStringRef input=(__bridge CFAttributedStringRef)(string);
    NSDictionary *furiganaDict=[string.string hiraganaReplacementsForString];
       
    return [self createAttributedString:input furiganaRanges:furiganaDict];
}

- (CFAttributedStringRef)createAttributedString:(CFAttributedStringRef)string furiganaRanges:(NSDictionary*)furigana
{
    CFMutableAttributedStringRef stringMutable=CFAttributedStringCreateMutableCopy(NULL, CFAttributedStringGetLength(string), string);
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
    
}




- (void)drawRect:(CGRect)rect {
    
    if (self.stringToTransform.length>0) {

        CFAttributedStringRef rubyStr=[self furiganaAttributedString:self.stringToTransform];
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
        CGContextTranslateCTM(ctx, 0, ([self bounds]).size.height );
        CGContextScaleCTM(ctx, 1.0, -1.0);
        
       /* CGPoint textPosition = CGPointMake(floor(CGRectGetMinX(self.bounds)),
                                           floor(CGRectGetMaxY(self.bounds)));
        CGFloat boundsWidth = CGRectGetWidth(self.bounds);
        
        CTTypesetterRef typesetter=CTTypesetterCreateWithAttributedString(rubyStr);
        
        CFIndex start = 0;
        NSUInteger length = CFAttributedStringGetLength(rubyStr);
        while (start < length && textPosition.y > self.bounds.origin.y)
        {
            CFIndex count = CTTypesetterSuggestLineBreak(typesetter, start, boundsWidth);
            CTLineRef line = CTTypesetterCreateLine(typesetter, CFRangeMake(start, count));
            start+=count;
            CGFloat ascent;
            CGFloat descent;
            CGFloat leading;
            double lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            textPosition.y -= ceil(ascent)*1.5;
            CGContextSetTextPosition(context, textPosition.x, textPosition.y);
            CTLineDraw(line, context);
            CFRelease(line);
        }
        CFRelease(typesetter);
        CFRelease(rubyStr);*/
        
        //seems a lot easier to use a framesetter than manual linebreaks
        
        
        CTFramesetterRef frameSetter=CTFramesetterCreateWithAttributedString(rubyStr);
        CGPathRef path=CGPathCreateWithRect(self.bounds, NULL);
        CTFrameRef frame=CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, CFAttributedStringGetLength(rubyStr)), path, NULL);
        CTFrameDraw(frame, context);
        CFRelease(frame);
        CFRelease(path);
        CFRelease(frameSetter);
        CFRelease(rubyStr);
        
    }
        
        
    
        

}


@end
