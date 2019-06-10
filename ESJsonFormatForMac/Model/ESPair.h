//
//  ESPair.h
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/7/5.  Change by ZX on 17/5/17
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESPair : NSObject

@property (nonatomic) id first;
@property (nonatomic) id second;
+ (instancetype) createWithFirst:(id)first second:(id)second;

@end
