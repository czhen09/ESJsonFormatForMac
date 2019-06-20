//
//  NSFileManager+Helper.h
//  MacTemplet
//
//  Created by Bin Shang on 2019/6/20.
//  Copyright © 2019 Bin Shang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (Helper)

+ (BOOL)createFileWithFolderPath:(NSString *)folderPath name:(NSString *)name content:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
