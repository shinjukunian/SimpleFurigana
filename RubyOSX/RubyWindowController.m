//
//  RubyWindowController.m
//  RubyTest
//
//  Created by Morten Bertz on 9/20/14.
//  Copyright (c) 2014 Morten Bertz. All rights reserved.
//

#import "RubyWindowController.h"
#import "RubyView.h"

@interface RubyWindowController ()

@end

@implementation RubyWindowController{
    NSDictionary *attributes;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    NSString *input=@"事前参加登録者 各位※本メールはBCCでお送りしております。このたびは、日本生物物理学会 第52回年会（札幌）へ参加ご登録いただき、ありがとうございます。また、【年会参加費】をご送金いただき、ありがとうございました。貴殿におかれましては、<年度会費>のお支払いが完了されていないようです。申し訳ありませんが、会費を滞納されますと、会員価格が適用できませんので、年会当日、会員受付（2番受付）でお支払いくださいますよう、お願いいたします。既に会費をご送金いただいている場合は、払込書控え（受領証）を受付にご持参ください。お支払い手続き完了後、参加証をお渡しいたします。それでは、札幌でお待ちしております";
    
    attributes=@{NSFontAttributeName:[NSFont systemFontOfSize:20]};
    NSAttributedString *strAttr=[[NSAttributedString alloc]initWithString:input attributes:attributes];
    [self.textView.textStorage replaceCharactersInRange:NSMakeRange(0, self.textView.textStorage.length) withAttributedString:strAttr];
    [self.rubyView setStringToTransform:strAttr];
    [self.rubyView setType:RubyTypeNone];
    [self.scrollView setBackgroundColor:[NSColor whiteColor]];
    [self.scrollView setDrawsBackground:YES];
    [self.rubyView invalidateIntrinsicContentSize];
    
    
    
}

@end
