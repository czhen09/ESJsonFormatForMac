//
//  NSApp+Helper.m
//  ESJsonFormatForMac
//
//  Created by Bin Shang on 2019/6/19.
//  Copyright © 2019 ZX. All rights reserved.
//

#import "NSApplication+Helper.h"

@implementation NSApplication (Helper)

+ (void)beginSheet:(NSWindowController *)windowController{
    [NSApp beginSheet:windowController.window modalForWindow:NSApp.mainWindow modalDelegate:nil didEndSelector:nil contextInfo:nil];
    [NSApp runModalForWindow:windowController.window];
}

@end
