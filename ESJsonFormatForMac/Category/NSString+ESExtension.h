//
//  NSString+ESExtension.h
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/7/4.  Change by ZX on 17/5/17
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ESExtension)

-(id)objcValue;

- (NSString *)substringWithStartStr:(NSString *)start endStr:(NSString *)endStr;
@end
