//
//  RubyView.m
//  RubyTest
//
//  Created by Morten Bertz on 9/20/14.
//  Copyright (c) 2014 Morten Bertz. All rights reserved.
//

#import "RubyViewOSX.h"
#import "NSString+Japanese.h"

@import CoreText;

@implementation RubyViewOSX{
    CGRect printRect;
    BOOL portrait;
    NSUInteger currentPage;
    NSUInteger numberOfPages;
    NSArray *lineRects;
    NSArray *lines;
    NSArray *lineOrigins;
    CGRect highlightRect;
    CGRect textBoundingBox;
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




-(CGSize)sizeToFit:(CGSize)size{
    if (self.stringToTransform.length>0) {
        
        self.rubyString=[self furiganaAttributedString:self.stringToTransform];
        
        CTFramesetterRef framesetter=CTFramesetterCreateWithAttributedString(self.rubyString);
        
        CGSize constraints=CGSizeMake(self.hostingScrollView.contentSize.width , CGFLOAT_MAX);
        CFRange fitrange;
        CGSize newSize=CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, CFAttributedStringGetLength(self.rubyString)), NULL, constraints, &fitrange);
    
        CFRelease(framesetter);
        NSLog(@"%@",NSStringFromSize(newSize));
        [self.hostingScrollView.contentView setFrameSize:newSize];
        self.sizeToFit=newSize;
        return newSize;
    }
    else{
        return self.bounds.size;
    }
}




-(void)viewWillDraw{
    
    
    
}


-(void)viewWillStartLiveResize{
    
}


-(void)viewDidEndLiveResize{
    
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



-(void)mouseDown:(NSEvent *)theEvent{
    
    highlightRect=CGRectNull;
    self.highlightRange=NSMakeRange(0, 0);
    self.needsDisplay=YES;

}




-(void)mouseDragged:(NSEvent *)theEvent{
    
    CGPoint hitpoint=[theEvent locationInWindow];
    CGPoint localPoint=[self convertPoint:hitpoint fromView:nil];
    for (NSUInteger i=0; i<lineRects.count; i++) {
        CGRect lineRect=[[lineRects objectAtIndex:i]rectValue];
        BOOL touchInside=CGRectContainsPoint(lineRect, localPoint);
        if (touchInside) {
            CGPoint origin=[[lineOrigins objectAtIndex:i]pointValue];
            CTLineRef line=(__bridge CTLineRef)([lines objectAtIndex:i]);
            CFIndex index=CTLineGetStringIndexForPosition(line, localPoint);

            NSString *str=[self.stringToTransform.string substringWithRange:NSMakeRange(index-1, 1)];
            CGFloat secondaryOffset1;
            CGFloat offset1=CTLineGetOffsetForStringIndex(line, index-1, &secondaryOffset1);
            CGFloat secondaryOffset2;
            CGFloat offset2=CTLineGetOffsetForStringIndex(line, index, &secondaryOffset2);
            if (self.highlightRange.length==0) {
                self.highlightRange=NSMakeRange(index-1, 1);
            }
            else{
                self.highlightRange=NSUnionRange(self.highlightRange, NSMakeRange(index-1, 1));
            }
            CGRect rect=CGRectMake(offset1+origin.x+textBoundingBox.origin.x, lineRect.origin.y, offset2-offset1, lineRect.size.height);
            highlightRect=CGRectUnion(highlightRect, rect);
            NSLog(@"%@",NSStringFromRange(self.highlightRange));
            self.needsDisplay=YES;
            break;
        }
        
    }

    
}

-(void)mouseUp:(NSEvent *)theEvent{
    
    
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    if (self.stringToTransform.length>0){
        
        self.rubyString=[self furiganaAttributedString:self.stringToTransform];
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
            NSLog(@"%@",NSStringFromRect(dirtyRect));
            [[NSGraphicsContext currentContext] saveGraphicsState];
            CGContextRef context=[[NSGraphicsContext currentContext]graphicsPort];
            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
            CGContextSetFillColorWithColor(context, [[NSColor redColor]CGColor]);
            
            CTFramesetterRef frameSetter=CTFramesetterCreateWithAttributedString(self.rubyString);
            CGPathRef path=CGPathCreateWithRect(CGRectInset(self.bounds, 0, 0), NULL);
            CTFrameRef frame;
            if (self.orientation==RubyVerticalText) {
                NSDictionary *dict=@{(NSString *)kCTFrameProgressionAttributeName:@(kCTFrameProgressionRightToLeft)};
                CFDictionaryRef cfDict=(__bridge CFDictionaryRef)(dict);
                frame=CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, CFAttributedStringGetLength(self.rubyString)), path, cfDict);
            }
            else{
                frame=CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, CFAttributedStringGetLength(self.rubyString)), path, NULL);
            
            }
            CFArrayRef cflines=CTFrameGetLines(frame);
            NSArray *lineArray=(__bridge NSArray *)(cflines);
            CGPoint origins[lineArray.count];
            CTFrameGetLineOrigins(frame, CFRangeMake(0, lineArray.count), origins);
            NSMutableArray *originArray=[NSMutableArray array];
            for (NSUInteger i=0; i<lineArray.count; i++) {
                [originArray addObject:[NSValue valueWithPoint:origins[i]]];
            }
            
            CGRect firstLineRect;
            NSMutableArray *lineRectArray=[NSMutableArray array];
            for (NSUInteger i=0; i<lineArray.count; i++) {
               // CGRect imageRect=CTLineGetImageBounds((CTLineRef)lineArray[i], context);
                CFRange characterRange=CTLineGetStringRange((CTLineRef)lineArray[i]);
                CGFloat ascent;
                CGFloat descent;
                CGFloat leading;
                double width=CTLineGetTypographicBounds((CTLineRef)lineArray[i], &ascent, &descent, &leading);
                CGFloat secondaryOffsetFirtCharacter;
                CGFloat offsetFirstCharacter=CTLineGetOffsetForStringIndex((CTLineRef)lineArray[i], 0, &secondaryOffsetFirtCharacter);
                CGFloat secondaryOffsetLastCharacter;
                CGFloat offsetLastCharacter=CTLineGetOffsetForStringIndex((CTLineRef)lineArray[i], characterRange.length, &secondaryOffsetLastCharacter);
                CGRect boundingBox=CGPathGetBoundingBox(path);
                textBoundingBox=boundingBox;
                CGPoint origin=[[originArray objectAtIndex:i]pointValue];
                CGRect lineRect=CGRectMake(origin.x+offsetFirstCharacter+boundingBox.origin.x, origin.y-descent+boundingBox.origin.y, width, ascent+descent);
                [lineRectArray addObject:[NSValue valueWithRect:lineRect]];
               
            }
             CGContextFillRect(context, highlightRect);
            lineRects=lineRectArray.copy;
            lines=lineArray;
            lineOrigins=originArray.copy;
            
           
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
