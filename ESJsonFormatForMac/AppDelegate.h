//
//  AppDelegate.h
//  ESJsonFormatForMac
//
//  Created by ZX on 2017/5/12. 
//  Copyright © 2017年 ZX. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ESInputJsonController;
@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (nonatomic,strong) IBOutlet ESInputJsonController * inputJsonController;
@property (nonatomic,strong) NSWindow * window;
@end

