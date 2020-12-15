//
//  TestWindowController.h
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/6/19.  Change by ZX on 17/5/17
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol ESInputJsonControllerDelegate <NSObject>

@optional
-(void)windowWillClose;
@end

@interface ESInputJsonController : NSViewController

@property (nonatomic, weak) id<ESInputJsonControllerDelegate> delegate;

@property (nonatomic, copy) NSString *currentFilePath;
@property (nonatomic, assign) BOOL isSwift;


@end
