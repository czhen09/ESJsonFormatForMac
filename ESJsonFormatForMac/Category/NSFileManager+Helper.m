

//
//  NSFileManager+Helper.m
//  MacTemplet
//
//  Created by Bin Shang on 2019/6/20.
//  Copyright © 2019 Bin Shang. All rights reserved.
//

#import "NSFileManager+Helper.h"

@implementation NSFileManager (Helper)

+ (BOOL)createFileWithFolderPath:(NSString *)folderPath name:(NSString *)name content:(NSString *)content{
    NSFileManager *manager = NSFileManager.defaultManager;
    NSString *fileAtPath = [folderPath stringByAppendingPathComponent:name];
    return [manager createFileAtPath:fileAtPath contents:[content dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}

@end
