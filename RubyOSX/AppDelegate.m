//
//  AppDelegate.m
//  RubyOSX
//
//  Created by Morten Bertz on 9/20/14.
//  Copyright (c) 2014 Morten Bertz. All rights reserved.
//

#import "AppDelegate.h"
#import "RubyWindowController.h"
@interface AppDelegate ()


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.windowController=[[RubyWindowController alloc]initWithWindowNibName:@"RubyWindowController"];
    [self.windowController showWindow:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
