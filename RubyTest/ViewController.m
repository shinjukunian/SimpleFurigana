//
//  ViewController.m
//  RubyTest
//
//  Created by Morten Bertz on 9/18/14.
//  Copyright (c) 2014 Morten Bertz. All rights reserved.
//

#import "ViewController.h"
#import "RubyView.h"

@import CoreText;

@interface ViewController (){
 
    NSDictionary *attributes;
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *input=@"事前参加登録者 各位※本メールはBCCでお送りしております。このたびは、日本生物物理学会 第52回年会（札幌）へ参加ご登録いただき、ありがとうございます。また、【年会参加費】をご送金いただき、ありがとうございました。貴殿におかれましては、<年度会費>のお支払いが完了されていないようです。申し訳ありませんが、会費を滞納されますと、会員価格が適用できませんので、年会当日、会員受付（2番受付）でお支払いくださいますよう、お願いいたします。既に会費をご送金いただいている場合は、払込書控え（受領証）を受付にご持参ください。お支払い手続き完了後、参加証をお渡しいたします。それでは、札幌でお待ちしております";
   
    attributes=@{NSFontAttributeName:[UIFont systemFontOfSize:20]};
    
    NSAttributedString *inputAttributed=[[NSAttributedString alloc]initWithString:input attributes:attributes];
    [self.inputTextView setDelegate:self];
    [self.inputTextView setAttributedText:inputAttributed];
    [self.rubyView setStringToTransform:inputAttributed];
    [self.rubyView setType:RubyTypeNone];
    [self.rubyView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
   
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

  //  [self.rubyView sizeToFit];
   
       
    
}




-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.rubyView sizeToFit];
    [self.rubyView setNeedsDisplay];
}




-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
 
    NSString *new=[textView.text stringByReplacingCharactersInRange:range withString:text];
    NSAttributedString *newAttributed=[[NSAttributedString alloc]initWithString:new attributes:attributes];
    [self.rubyView setStringToTransform:newAttributed];
    [self.rubyView sizeToFit];
    [self.rubyView setNeedsDisplay];
        
    return YES;
}


-(IBAction)transliterationMethodDidChange:(UISegmentedControl*)sender{
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self.rubyView setType:RubyTypeNone];
            break;
        
        case 1:
            [self.rubyView setType:RubyTypeHiraganaOnly];
            break;
        case 2:
            [self.rubyView setType:RubyTypeFurigana];
            break;
        default:
            break;
    }
    [self.rubyView sizeToFit];
    [self.rubyView setNeedsDisplay];
    
    
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
