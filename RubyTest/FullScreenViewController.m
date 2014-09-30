//
//  FullScreenViewController.m
//  RubyTest
//
//  Created by Morten Bertz on 9/22/14.
//  Copyright (c) 2014 Morten Bertz. All rights reserved.
//

#import "FullScreenViewController.h"

@interface FullScreenViewController ()

@end

@implementation FullScreenViewController{
    

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.rubyView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self.scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.rubyView.stringToTransform=self.stringToTransform;
    self.rubyView.orientation=self.orientation;
    self.rubyView.type=self.type;
    self.rubyView.hostingScrollView=self.scrollView;
  

    }

-(void)viewDidLayoutSubviews{
  
    if (![self isBeingDismissed]) {
        [self.rubyView sizeToFit];

    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)dismissByEdgeSwipe:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}

-(IBAction)longPressureGestureRecongnized:(UILongPressGestureRecognizer*)sender{
    if (sender.state==UIGestureRecognizerStateBegan) {
        [self.toolBar setHidden:!self.toolBar.hidden];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
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

@end
