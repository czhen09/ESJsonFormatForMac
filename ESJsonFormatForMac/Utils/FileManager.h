//
//  FileManager.h
//  ESJsonFormatForMac
//
//  Created by zx on 17/6/13.
//  Copyright © 2017年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject

+ (FileManager *)sharedInstance;
- (void)handleBaseData:(NSString *)folderPath
             hFileName:(NSString *)hFileName
             mFileName:(NSString *)mFileName
              hContent:(NSString *)hContent
              mContent:(NSString *)mContent;

@end
