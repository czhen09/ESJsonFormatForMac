//
//  AppDelegate.m
//  ESJsonFormatForMac
//
//  Created by ZX on 2017/5/12. 
//  Copyright © 2017年 ZX. All rights reserved.
//

#import "AppDelegate.h"
#import "ESInputJsonController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    self.inputJsonController = [[ESInputJsonController alloc] initWithNibName:@"ESInputJsonController" bundle:nil];
    self.window = NSApplication.sharedApplication.keyWindow;
    [self.window.contentView addSubview:self.inputJsonController.view];
    self.inputJsonController.view.frame = self.window.contentView.bounds;
    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
