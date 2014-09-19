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
    NSString *input=@"山田電機はとても高いです。\r最近忙しいですか？";
    attributes=@{NSFontAttributeName:[UIFont systemFontOfSize:20]};
    
    NSAttributedString *inputAttributed=[[NSAttributedString alloc]initWithString:input attributes:attributes];
    [self.inputTextView setDelegate:self];
    [self.inputTextView setAttributedText:inputAttributed];
    [self.rubyView setStringToTransform:inputAttributed];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
}


-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
 
    NSString *new=[textView.text stringByReplacingCharactersInRange:range withString:text];
    NSAttributedString *newAttributed=[[NSAttributedString alloc]initWithString:new attributes:attributes];
    [self.rubyView setStringToTransform:newAttributed];
    [self.rubyView setNeedsDisplay];
        
    return YES;
}








- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
