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
    NSString *input=@"Japanese Text Here.\r\rこれを知るをこれを知ると為し、知らざるを知らずと為せ。これ知るなり。";
   
    attributes=@{NSFontAttributeName:[UIFont systemFontOfSize:20]};
    
    NSAttributedString *inputAttributed=[[NSAttributedString alloc]initWithString:input attributes:attributes];
    [self.inputTextView setDelegate:self];
    [self.inputTextView setAttributedText:inputAttributed];
    [self.rubyView setStringToTransform:inputAttributed];
    [self.rubyView setType:RubyTypeNone];
    [self.rubyView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self.scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.rubyView.hostingScrollView=self.scrollView;
   
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}




-(void)viewDidLayoutSubviews{
   // NSLog(@"%@",NSStringFromCGSize(self.scrollView.bounds.size));
    
    
    if (![self presentedViewController]) {
        if (self.inputString.length>0) {
            NSAttributedString *att=[[NSAttributedString alloc]initWithString:self.inputString attributes:attributes];
            [self.inputTextView setAttributedText:att];
            [self.rubyView setStringToTransform:att];
            self.inputString=@"";
            [self.rubyView setNeedsDisplay];
            
        }
         [self.rubyView sizeToFit];
    }
   
   }


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
   
}


-(IBAction)showActivityViewController:(UIBarButtonItem*)sender{
    
    
    UIActivityViewController *activity=[[UIActivityViewController alloc]initWithActivityItems:@[self.rubyView] applicationActivities:nil];
    NSArray *excludedActivities=@[UIActivityTypeAssignToContact, UIActivityTypePostToVimeo];
    activity.excludedActivityTypes=excludedActivities;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        activity.modalPresentationStyle=UIModalPresentationPopover;
        activity.popoverPresentationController.barButtonItem=sender;
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
       
    }
    [self presentViewController:activity animated:YES completion:nil];

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
            [self.rubyView sizeToFit];
            [self.rubyView setNeedsDisplay];
            break;
        case 1:
            [self.rubyView setOrientation:RubyVerticalText];
            [self.rubyView sizeToFit];
            [self.rubyView setNeedsDisplay];
            
            break;
        default:
            break;
    }

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


-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    if (![self presentedViewController]){
        [self.rubyView sizeToFit];
        [self.rubyView setNeedsDisplay];
    }
    else if ([self presentedViewController]){
        FullScreenViewController *fullScreen=(FullScreenViewController*)[self presentedViewController];
        [fullScreen.rubyView sizeToFit];
        [fullScreen.rubyView setNeedsDisplay];

    }
        
}


@end
