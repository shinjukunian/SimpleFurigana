//
//  ActionViewController.m
//  RubyAction
//
//  Created by Morten Bertz on 9/19/14.
//  Copyright (c) 2014 Morten Bertz. All rights reserved.
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ActionViewController ()

@property(strong,nonatomic) IBOutlet UITextView *textView;
@end

@implementation ActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get the item[s] we're handling from the extension context.
    
    // For example, look for an image and place it into an image view.
    // Replace this with something appropriate for the type[s] your extension supports.
    BOOL imageFound = NO;
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
       // NSDictionary *dict=[item userInfo];
        
        for (NSItemProvider *itemProvider in item.attachments) {
            
           // NSArray *array=[itemProvider registeredTypeIdentifiers];
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
              
                
                
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *url, NSError *error) {
                    
                    if(url) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            NSStringEncoding encoding;
                            NSString *htmlString=[NSString stringWithContentsOfURL:url usedEncoding:&encoding error:nil];
                            NSAttributedString *stringAttributed=[[NSAttributedString alloc]initWithData:[htmlString dataUsingEncoding:encoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
                           [self.textView setAttributedText:stringAttributed];
                        }];
                    }
                }];
                
                imageFound = YES;
                break;
            }
        }
        
        if (imageFound) {
            // We only handle one image, so stop looking for more.
            break;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done {
    // Return any edited content to the host app.
    // This template doesn't do anything, so we just echo the passed in items.
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

@end
