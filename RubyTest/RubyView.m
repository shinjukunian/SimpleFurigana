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

@implementation RubyView{
    
    
    NSLayoutConstraint *heightConstraint;
}

// inspired by http://dev.classmethod.jp/references/ios8-ctrubyannotationref/


-(CFAttributedStringRef)furiganaAttributedString:(NSAttributedString*) string{
    
    
    if (self.type==RubyTypeFurigana) {
        
        NSDictionary *furiganaDict=[string.string hiraganaReplacementsForString];
        if (self.orientation==RubyVerticalText) {
            NSDictionary *dict=@{(NSString*)kCTVerticalFormsAttributeName:@YES};
            NSMutableAttributedString *vert=string.mutableCopy;
            [vert addAttributes:dict range:NSMakeRange(0, string.length)];
            return [self createRubyAttributedString:(__bridge CFAttributedStringRef)(vert) furiganaRanges:furiganaDict];
        
        }
        else{
            return [self createRubyAttributedString:(__bridge CFAttributedStringRef)(string) furiganaRanges:furiganaDict];
        }
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




-(CGSize)sizeThatFits:(CGSize)size{
    
    if (self.stringToTransform.length>0) {
       
        self.rubyString=[self furiganaAttributedString:self.stringToTransform];
        
        [self removeConstraint:heightConstraint];
        CTFramesetterRef framesetter=CTFramesetterCreateWithAttributedString(self.rubyString);
        CGSize constraints=CGSizeMake(self.bounds.size.width, CGFLOAT_MAX);
        CFRange fitrange;
        CGSize newSize;
        if (self.orientation==RubyVerticalText){
            NSDictionary *dict=@{(NSString *)kCTFrameProgressionAttributeName:@(kCTFrameProgressionRightToLeft)};
            CFDictionaryRef cfDict=(__bridge CFDictionaryRef)(dict);
            newSize=CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, CFAttributedStringGetLength(self.rubyString)), cfDict, constraints, &fitrange);
            
        }
        else{
             newSize=CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, CFAttributedStringGetLength(self.rubyString)), NULL, constraints, &fitrange);
            
        }
        //newSize.width=size.width;
        self.intrinsicContentSize=newSize;
        CFRelease(framesetter);
        heightConstraint=[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:newSize.height];

        [self addConstraint:heightConstraint];
       
        
        NSLog(@"%@",NSStringFromCGSize(newSize));
        return newSize;
    }
    else{
        return self.bounds.size;
    }
}




- (void)drawRect:(CGRect)rect {
    
    if (self.stringToTransform.length>0) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
        CGContextTranslateCTM(ctx, 0, ([self bounds]).size.height );
        CGContextScaleCTM(ctx, 1.0, -1.0);
        
        //seems a lot easier to use a framesetter than manual linebreaks

        CTFramesetterRef frameSetter=CTFramesetterCreateWithAttributedString(self.rubyString);
        CGPathRef path=CGPathCreateWithRect(self.bounds, NULL);
        CTFrameRef frame;
        if (self.orientation==RubyVerticalText) {
            NSDictionary *dict=@{(NSString *)kCTFrameProgressionAttributeName:@(kCTFrameProgressionRightToLeft)};
            CFDictionaryRef cfDict=(__bridge CFDictionaryRef)(dict);
            frame=CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, CFAttributedStringGetLength(self.rubyString)), path, cfDict);
        }
        else{
            frame=CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, CFAttributedStringGetLength(self.rubyString)), path, NULL);
            
        }
        CTFrameDraw(frame, context);
        CFRelease(frame);
        CFRelease(path);
        CFRelease(frameSetter);
     
        
    }
    

}


@end
