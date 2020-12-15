//
//  ESUtils.h
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/7/12.  Change by ZX on 17/5/17
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESUtils : NSObject

/**
 *  获取Xcode大版本
 *
 */
+ (NSInteger)XcodePreVsersion;

/**
 *  是否是Xcode7或者之后
 *
 */
+ (BOOL)isXcode7AndLater;

@end
