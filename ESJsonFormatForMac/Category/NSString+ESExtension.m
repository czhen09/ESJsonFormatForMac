//
//  NSString+ESExtension.m
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/7/4.  Change by ZX on 17/5/17
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import "NSString+ESExtension.h"

@implementation NSString (ESExtension)

-(id)objcValue{
    NSString * string = self;
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"jsonString=%@",string);
    NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id dicOrArray = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingMutableContainers
                                                      error:&err];
    if (err) {
        return err;
    }else{
        return dicOrArray;
    }
}

- (NSString *)substringWithStartStr:(NSString *)start endStr:(NSString *)endStr{
    NSString *resultStr = nil;
    NSRange range;
    NSRange tempRange = [self rangeOfString:start];
    if (tempRange.location !=NSNotFound) {
        range.location = tempRange.location+tempRange.length;
        tempRange = [self rangeOfString:endStr];
        if (tempRange.location!=NSNotFound) {
            range.length = tempRange.location-range.location;
            return [self substringWithRange:range];
        }
    }
    return resultStr;
}

@end
