
//
//  RubyView.m
//  RubyTest
//
//  Created by Morten Bertz on 9/18/14.
//  Copyright (c) 2014 Morten Bertz. All rights reserved.
//

#import "RubyView.h"
#import "NSString+Japanese.h"
#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@import CoreText;

@implementation RubyView{
    
    
}

// inspired by http://dev.classmethod.jp/references/ios8-ctrubyannotationref/


-(CFAttributedStringRef)furiganaAttributedString:(NSAttributedString*) string{
   
    
    if (self.type==RubyTypeFurigana) {
        
        NSDictionary *furiganaDict=[string.string hiraganaReplacementsForString];
        if (self.orientation==RubyVerticalText) {
            NSMutableParagraphStyle *para=[[NSMutableParagraphStyle alloc]init];
            para.lineHeightMultiple=1;
            NSDictionary *dict=@{(NSString*)kCTVerticalFormsAttributeName:@YES, NSParagraphStyleAttributeName:para};
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
            NSMutableParagraphStyle *para=[[NSMutableParagraphStyle alloc]init];
            para.lineHeightMultiple=1;

            [vertical addAttributes:@{(NSString*)kCTVerticalFormsAttributeName:@YES, NSParagraphStyleAttributeName:para} range:NSMakeRange(0, vertical.length)];
            
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
    CFAttributedStringBeginEditing(stringMutable);
    for (NSValue *value in furigana.keyEnumerator) {
        NSRange range=value.rangeValue;
        NSString *string=[furigana objectForKey:value];
        CFStringRef furigana[kCTRubyPositionCount] = {(__bridge CFStringRef)string, NULL, NULL, NULL};
        CTRubyAnnotationRef rubyRef = CTRubyAnnotationCreate(kCTRubyAlignmentAuto, kCTRubyOverhangNone, 0.5, furigana);
        CFRange r=CFRangeMake(range.location, range.length);
        CFAttributedStringSetAttribute(stringMutable, r, kCTRubyAnnotationAttributeName, rubyRef);
        CFRelease(rubyRef);
    }
    CFAttributedStringEndEditing(stringMutable);
    CFAttributedStringRef rubyString=CFAttributedStringCreateCopy(NULL, stringMutable);
    CFRelease(stringMutable);
    
    
    return rubyString;
    
}




-(CGSize)sizeThatFits:(CGSize)size{
    
    if (self.stringToTransform.length>0) {
       
        self.rubyString=[self furiganaAttributedString:self.stringToTransform];

        CTFramesetterRef framesetter=CTFramesetterCreateWithAttributedString(self.rubyString);
        
        CFRange fitrange;
        CGSize newSize;
        if (self.orientation==RubyVerticalText){
            CGSize constraints=CGSizeMake(CGFLOAT_MAX ,self.hostingScrollView.bounds.size.height);
            NSDictionary *dict=@{(NSString *)kCTFrameProgressionAttributeName:@(kCTFrameProgressionRightToLeft)};
            CFDictionaryRef cfDict=(__bridge CFDictionaryRef)(dict);
            newSize=CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, CFAttributedStringGetLength(self.rubyString)), cfDict, constraints, &fitrange);
            CFRelease(framesetter);
            if (newSize.width<self.hostingScrollView.bounds.size.width) {
                newSize.width=self.hostingScrollView.bounds.size.width;
            }
            
            CGSize integerSize=CGSizeMake(ceil(newSize.width), ceil(newSize.height));
            self.intrinsicContentSize=integerSize;
            [self.hostingScrollView setContentSize:integerSize];
            CGRect scrollViewrect=CGRectMake(integerSize.width-self.hostingScrollView.bounds.size.width, 0, self.hostingScrollView.bounds.size.width, self.hostingScrollView.bounds.size.height);
            [self.hostingScrollView scrollRectToVisible:scrollViewrect animated:YES];
            [self.hostingScrollView setPagingEnabled:YES];
            return integerSize;
            
        }
        else{
            CGSize constraints=CGSizeMake(self.hostingScrollView.bounds.size.width, CGFLOAT_MAX);
             newSize=CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, CFAttributedStringGetLength(self.rubyString)), NULL, constraints, &fitrange);
            CFRelease(framesetter);
            [self.hostingScrollView setPagingEnabled:NO];
            CGSize integerSize=CGSizeMake(ceil(newSize.width), ceil(newSize.height));
            self.intrinsicContentSize=integerSize;
            [self.hostingScrollView setContentSize:integerSize];
            return integerSize;
            
        }
        
    }
    return self.bounds.size;

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


-(id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType{
    
    if (activityType==UIActivityTypeMessage || activityType==UIActivityTypeSaveToCameraRoll || activityType==UIActivityTypeCopyToPasteboard || activityType==UIActivityTypeAirDrop) {
        return [self drawRubyViewinImage];
    }
   else if (activityType==UIActivityTypeMail) {
        return [self drawRubyViewinPDF];
    }
    
   else if(activityType==UIActivityTypePrint){
       
        return [self drawPDFPagesForPaper:CGRectInfinite];
   }
    
    else {
        return nil;
   }
    
 
}

-(id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController{
    UIImage *dummy=[[UIImage alloc]init];
    return dummy;
}

-(NSString*)activityViewController:(UIActivityViewController *)activityViewController dataTypeIdentifierForActivityType:(NSString *)activityType{
    
    if (activityType==UIActivityTypeMail || activityType== UIActivityTypePrint) {
 
        return @"com.adobe.pdf";
    }
    else if (activityType==UIActivityTypeMessage|| activityType==UIActivityTypeSaveToCameraRoll || activityType==UIActivityTypeCopyToPasteboard || activityType==UIActivityTypeAirDrop) {
    }
    return @"";
    
    
}

-(UIImage*)drawRubyViewinImage{
    
    UIGraphicsBeginImageContextWithOptions(self.intrinsicContentSize, NO, 2);
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CTFramesetterRef frameSetter=CTFramesetterCreateWithAttributedString(self.rubyString);
    CGRect drawRect=CGRectMake(0, 0, self.intrinsicContentSize.width, self.intrinsicContentSize.height);
    CGPathRef path=CGPathCreateWithRect(drawRect, NULL);
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
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0, -drawRect.size.height);
    CTFrameDraw(frame, context);
    CGContextRestoreGState(context);
    CFRelease(frame);
    CFRelease(path);
    CFRelease(frameSetter);

    
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


-(NSData*)drawRubyViewinPDF{
    
    CGRect drawRect=CGRectMake(0, 0, self.intrinsicContentSize.width, self.intrinsicContentSize.height);
    NSMutableData *pdfData = [NSMutableData data];
    CGDataConsumerRef dataConsumer = CGDataConsumerCreateWithCFData((__bridge CFMutableDataRef)(pdfData));
    CGContextRef pdfContext =CGPDFContextCreate(dataConsumer, &drawRect, NULL);
    CGContextBeginPage(pdfContext, &drawRect);
    UIGraphicsPushContext(pdfContext);
    CTFramesetterRef frameSetter=CTFramesetterCreateWithAttributedString(self.rubyString);
    CGPathRef path=CGPathCreateWithRect(drawRect, NULL);
    CTFrameRef frame;
    if (self.orientation==RubyVerticalText) {
        NSDictionary *dict=@{(NSString *)kCTFrameProgressionAttributeName:@(kCTFrameProgressionRightToLeft)};
        CFDictionaryRef cfDict=(__bridge CFDictionaryRef)(dict);
        frame=CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, CFAttributedStringGetLength(self.rubyString)), path, cfDict);
    }
    else{
        frame=CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, CFAttributedStringGetLength(self.rubyString)), path, NULL);
        
    }
    CTFrameDraw(frame, pdfContext);
    CFRelease(frame);
    CFRelease(path);
    CFRelease(frameSetter);
    
    
    UIGraphicsPopContext();
 
    CGContextEndPage(pdfContext);
    CGPDFContextClose(pdfContext);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pathString=[documentsDirectory stringByAppendingPathComponent:@"test.pdf"];
    [pdfData writeToFile:pathString options:NSDataWritingAtomic error:nil];
    CGContextRelease(pdfContext);
    CGDataConsumerRelease(dataConsumer);

    
    return pdfData;
}


-(NSData*)drawPDFPagesForPaper:(CGRect)paper{
    
    CGRect drawRect;
    CTFramesetterRef frameSetter=CTFramesetterCreateWithAttributedString(self.rubyString);
    NSUInteger numberOfPages=0;
    NSMutableArray *pageRanges=[NSMutableArray array];
    if (self.orientation==RubyHorizontalText) {
        drawRect=CGRectMake(0, 0, 595, 842);
        drawRect=CGRectInset(drawRect, 40, 40);
        CGSize constraints=CGSizeMake(drawRect.size.width,drawRect.size.height);
        CFRange fitrange=CFRangeMake(0, 0);
        NSUInteger length=CFAttributedStringGetLength(self.rubyString);
        CFRange stringRange=CFRangeMake(0, length);
        while (fitrange.location+fitrange.length<length) {
            CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, stringRange, NULL, constraints, &fitrange);
            numberOfPages+=1;
            stringRange.location=fitrange.location+fitrange.length;
            stringRange.length=length-stringRange.location;
            [pageRanges addObject:[NSValue valueWithRange:NSMakeRange(fitrange.location, fitrange.length)]];
        }
        
    }
    else if(self.orientation==RubyVerticalText){
        drawRect=CGRectMake(0, 0, 842,595);
        drawRect=CGRectInset(drawRect, 40, 40);
        NSDictionary *dict=@{(NSString *)kCTFrameProgressionAttributeName:@(kCTFrameProgressionRightToLeft)};
        CFDictionaryRef cfDict=(__bridge CFDictionaryRef)(dict);
        CGSize constraints=CGSizeMake(drawRect.size.width,drawRect.size.height);
        CFRange fitrange=CFRangeMake(0, 0);
        NSUInteger length=CFAttributedStringGetLength(self.rubyString);
        CFRange stringRange=CFRangeMake(0, length);

        while (fitrange.location+fitrange.length<length) {
            CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, stringRange, cfDict, constraints, &fitrange);
            numberOfPages+=1;
            stringRange.location=fitrange.location+fitrange.length;
            stringRange.length=length-stringRange.location;
            [pageRanges addObject:[NSValue valueWithRange:NSMakeRange(fitrange.location, fitrange.length)]];
        }
    }
   
    NSMutableData *pdfData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData(pdfData, drawRect, nil);
    CGContextRef pdfContext=UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(pdfContext, CGAffineTransformIdentity);
        for (NSUInteger i=0; i<numberOfPages; i++) {
        NSRange range=[[pageRanges objectAtIndex:i]rangeValue];
        UIGraphicsBeginPDFPage();
        CGPathRef path=CGPathCreateWithRect(drawRect, NULL);
        CTFrameRef frame;
        if (self.orientation==RubyVerticalText) {
            NSDictionary *dict=@{(NSString *)kCTFrameProgressionAttributeName:@(kCTFrameProgressionRightToLeft)};
            CFDictionaryRef cfDict=(__bridge CFDictionaryRef)(dict);
            frame=CTFramesetterCreateFrame(frameSetter, CFRangeMake(range.location, range.length), path, cfDict);
        }
        else{
            frame=CTFramesetterCreateFrame(frameSetter, CFRangeMake(range.location,range.length), path, NULL);
        
        }
        CGContextSaveGState(pdfContext);
        CGContextScaleCTM(pdfContext, 1.0, -1.0);
        CGContextTranslateCTM(pdfContext, 0, -drawRect.size.height);
        CTFrameDraw(frame, pdfContext);
        CGContextRestoreGState(pdfContext);
        CFRelease(frame);
        CFRelease(path);
    
    
    }
    UIGraphicsEndPDFContext();
    CFRelease(frameSetter);
   // NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
   // NSString *documentsDirectory = [paths objectAtIndex:0];
   // NSString *pathString=[documentsDirectory stringByAppendingPathComponent:@"test.pdf"];
    //[pdfData writeToFile:pathString options:NSDataWritingAtomic error:nil];

    return pdfData;
}




@end
