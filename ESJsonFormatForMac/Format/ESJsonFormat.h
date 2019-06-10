//
//  ESJsonFormat.h
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/6/28.  Change by ZX on 17/5/17
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import <AppKit/AppKit.h>

@class ESJsonFormat;

static ESJsonFormat *sharedPlugin;
static ESJsonFormat *instance;

@interface ESJsonFormat : NSObject

@property (nonatomic, assign) BOOL isSwift;
@property (nonatomic, strong, readonly) NSBundle* bundle;

+ (instancetype)sharedPlugin;
+ (instancetype)instance;
- (id)initWithBundle:(NSBundle *)plugin;

@end
