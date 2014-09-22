//
//  ViewController.m
//  RubyTest
//
//  Created by Morten Bertz on 9/18/14.
//  Copyright (c) 2014 Morten Bertz. All rights reserved.
//

#import "ViewController.h"
#import "RubyView.h"
#import "FullScreenViewController.h"
@import CoreText;

@interface ViewController (){
 
    NSDictionary *attributes;
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *input=@"事前参加登録者.事前参加登録者. 事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.事前参加登録者.";
   
    attributes=@{NSFontAttributeName:[UIFont systemFontOfSize:20]};
    
    NSAttributedString *inputAttributed=[[NSAttributedString alloc]initWithString:input attributes:attributes];
    [self.inputTextView setDelegate:self];
    [self.inputTextView setAttributedText:inputAttributed];
    [self.rubyView setStringToTransform:inputAttributed];
    [self.rubyView setType:RubyTypeNone];
    [self.rubyView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.rubyView.hostingScrollView=self.scrollView;
   
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

  //  [self.rubyView sizeToFit];
    UIPasteboard *pasteBoard=[UIPasteboard generalPasteboard];
    if ([pasteBoard containsPasteboardTypes:UIPasteboardTypeListString]) {
        NSArray *array=[pasteBoard strings];
        NSString *string=[array componentsJoinedByString:@""];
        if (string.length>0) {
            NSAttributedString *att=[[NSAttributedString alloc]initWithString:string attributes:attributes];
            [self.inputTextView setAttributedText:att];
            [self.rubyView setStringToTransform:att];
            [self.rubyView sizeToFit];
            [self.rubyView setNeedsDisplay];

        }
    }
       
    
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

-(IBAction)writingOrientationDidChange:(UISegmentedControl*)sender{
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self.rubyView setOrientation:RubyHorizontalText];
            break;
        case 1:
            [self.rubyView setOrientation:RubyVerticalText];
            break;
        default:
            break;
    }
    [self.rubyView sizeToFit];
    [self.rubyView setNeedsDisplay];
    
    
}


-(IBAction)tapToDismissKeyboard:(id)sender{
    [self.inputTextView resignFirstResponder];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    if([segue.identifier isEqualToString:@"toFullscreen"]){
        
        FullScreenViewController *fullScreen=segue.destinationViewController;
        fullScreen.stringToTransform=self.rubyView.stringToTransform;
        fullScreen.type=self.rubyView.type;
        fullScreen.orientation=self.rubyView.orientation;
               
    }
    
    
    
}


@end
