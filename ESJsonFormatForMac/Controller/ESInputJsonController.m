
//
//  TestWindowController.m
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/6/19.  Change by ZX on 17/5/17
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import "ESInputJsonController.h"
#import "ESDialogController.h"
#import "ESJsonFormatManager.h"
#import "ESJsonFormat.h"
#import "ESClassInfo.h"
#import "ESJsonFormatSetting.h"
#import "ESPair.h"

@interface ESInputJsonController ()<NSTextViewDelegate>

/**
 *  字段对应的类的名字[key->JSON字段 : value->类名(用户输入)]
 */


@property (nonatomic,strong) ESDialogController *dialog;



@property (nonatomic, strong) NSMutableDictionary *replaceClassNames;
@property (nonatomic, strong) NSMutableDictionary *implementMethodOfMJExtensionClassNames;

@property (unsafe_unretained) IBOutlet NSTextView *inputTextView;

@property (weak) IBOutlet NSButton *enterButton;

@property (weak) IBOutlet NSButton *cancelButton;

@property (weak) IBOutlet NSScrollView *scrollView;


//@property (unsafe_unretained) IBOutlet NSTextView *classContentTextView;
//@property (unsafe_unretained) IBOutlet NSTextView *mainClassContentTextView;
//
//@property (weak) IBOutlet NSLayoutConstraint *classContentTextViewH;



@property (unsafe_unretained) IBOutlet NSTextView *hContentTextView;
@property (unsafe_unretained) IBOutlet NSTextView *mContentTextView;


@property (weak) IBOutlet NSTextField *inputUrlTxf;




@property (weak) IBOutlet NSTextField *hLabel;
@property (weak) IBOutlet NSTextField *mLabel;





@end

@implementation ESInputJsonController



-(NSMutableDictionary *)replaceClassNames{
    if (!_replaceClassNames) {
        _replaceClassNames = [NSMutableDictionary dictionary];
    }
    return _replaceClassNames;
}

-(NSMutableDictionary *)implementMethodOfMJExtensionClassNames{
    if (!_implementMethodOfMJExtensionClassNames) {
        _implementMethodOfMJExtensionClassNames = [NSMutableDictionary dictionary];
    }
    return _implementMethodOfMJExtensionClassNames;
}



- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
       
        self.inputTextView.delegate = self;
        self.isSwift = NO;
        
        
        //因为我没有找到设置segmentcontroller初始设置选中的方法...所以...这样了
        [[NSUserDefaults standardUserDefaults] setBool:self.isSwift forKey:@"isSwift"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isYYModel"];
    }
    
    return self;
}


-(void)windowWillClose:(NSNotification *)notification{
    if ([self.delegate respondsToSelector:@selector(windowWillClose)]) {
        [self.delegate windowWillClose];
    }
}

- (IBAction)selectedModelTypeSegmentControllerAction:(NSSegmentedControl *)sender {
    
    BOOL isYYModel = (sender.selectedSegment == 1)?YES:NO;
    [[NSUserDefaults standardUserDefaults] setBool:isYYModel forKey:@"isYYModel"];
    
}

- (IBAction)segmentControllerAction:(NSSegmentedControl *)sender {
    
    NSLog(@"%ld",sender.selectedSegment);
    self.isSwift = (sender.selectedSegment == 0)?YES:NO;
    
    [[NSUserDefaults standardUserDefaults] setBool:self.isSwift forKey:@"isSwift"];
    
    [ESJsonFormat instance].isSwift = self.isSwift;
}



- (IBAction)sendRequestBtnAction:(id)sender {
    
     __weak typeof(self) weakSelf = self;
    [self requestDataWithUrlStr:self.inputUrlTxf.stringValue success:^(NSString *jsonStr) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            weakSelf.inputTextView.string = jsonStr;
            
            //    self.classContentTextView.string = @"";
            //    self.mainClassContentTextView.string = @"";
            weakSelf.hContentTextView.string = @"";
            weakSelf.mContentTextView.string = @"";
            
            
            NSTextView *textView = weakSelf.inputTextView;
            id result = [weakSelf dictionaryWithJsonStr:textView.string];
            if ([result isKindOfClass:[NSError class]]) {
                NSError *error = result;
                NSAlert *alert = [NSAlert alertWithError:error];
                [alert runModal];
                NSLog(@"Error：Json is invalid");
            }else{
                
                ESClassInfo *classInfo = [weakSelf dealClassNameWithJsonResult:result];
                [weakSelf close];
                [weakSelf outputResult:classInfo];
            }
            
        });

        
    }];
    
}





- (IBAction)cancelButtonClick:(NSButton *)sender {
    
    [self.dialog close];
}



- (IBAction)enterButtonClick:(NSButton *)sender {
    
           
       //self.classContentTextView.string = @"";
       //self.mainClassContentTextView.string = @"";
       self.hContentTextView.string = @"";
       self.mContentTextView.string = @"";
       
       
       NSTextView *textView = self.inputTextView;
       id result = [self dictionaryWithJsonStr:textView.string];
       if ([result isKindOfClass:[NSError class]]) {
           NSError *error = result;
           NSAlert *alert = [NSAlert alertWithError:error];
           [alert runModal];
           NSLog(@"Error：Json is invalid");
       }else{
           
           ESClassInfo *classInfo = [self dealClassNameWithJsonResult:result];
           [self close];
           [self outputResult:classInfo];
       }

}


- (IBAction)hCopyBtnAction:(id)sender {

    [self copyContent:self.hContentTextView.string];
}


- (IBAction)mCopyBtnAction:(id)sender {

    [self copyContent:self.mContentTextView.string];
}

- (IBAction)clearJsonBtnAction:(id)sender {

    self.inputTextView.string = @"";
}

- (void)copyContent:(NSString *)str{
    
    NSPasteboard *pab = [NSPasteboard generalPasteboard];
    [pab declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
    [pab setString:str forType:NSStringPboardType];
}



- (void)requestDataWithUrlStr:(NSString *)urlStr success:(void(^)(NSString *jsonStr))jsonResult{
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       
        if (!error) {
            
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            //这里进行了重复转换，主要为了NSJSONWritingPrettyPrinted---能够让json中出现换行符
            NSString *jsonStr = [self dictionaryToJson:jsonDic];
            jsonResult(jsonStr);
        }
        
    }];
    
    
    [dataTask resume];
}

//转换成json字符串
- (NSString*)dictionaryToJson:(NSDictionary *)dic

{
    
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}

/**
 *  初始类名，RootClass/JSON为数组/创建文件与否
 *
 *  @param result JSON转成字典或者数组
 *
 *  @return 类信息
 */
- (ESClassInfo *)dealClassNameWithJsonResult:(id)result{
    __block ESClassInfo *classInfo = nil;
    //如果当前是JSON对应是字典
    if ([result isKindOfClass:[NSDictionary class]]) {
        //如果是生成到文件，提示输入Root class name
        if (![ESJsonFormatSetting defaultSetting].outputToFiles) {
            self.dialog = [[ESDialogController alloc] initWithWindowNibName:@"ESDialogController"];
            NSString *msg = [NSString stringWithFormat:@"The root class for output to files name is:"];
            
             __weak typeof(self) weakSelf = self;
            
            [self.dialog setDataWithMsg:msg defaultClassName:ESRootClassName enter:^(NSString *className) {
                classInfo = [[ESClassInfo alloc] initWithClassNameKey:ESRootClassName ClassName:className classDic:result];
                
                if (weakSelf.isSwift) {
                    
                    weakSelf.hLabel.stringValue = [NSString stringWithFormat:@"%@.swift",className];
                     weakSelf.mLabel.stringValue  = @"";
                    
                }else{
                   
                    weakSelf.hLabel.stringValue = [NSString stringWithFormat:@"%@.h",className];
                    weakSelf.mLabel.stringValue  = [NSString stringWithFormat:@"%@.m",className];
                    
                }
                
            }];
            
            [NSApp beginSheet:[self.dialog window] modalForWindow:[NSApp mainWindow] modalDelegate:nil didEndSelector:nil contextInfo:nil];
            [NSApp runModalForWindow:[self.dialog window]];
            [self dealPropertyNameWithClassInfo:classInfo];
        }else{
            //不生成到文件，Root class 里面用户自己创建
            classInfo = [[ESClassInfo alloc] initWithClassNameKey:ESRootClassName ClassName:ESRootClassName classDic:result];
            [self dealPropertyNameWithClassInfo:classInfo];
        }
    }else if([result isKindOfClass:[NSArray class]]){
        if ([ESJsonFormatSetting defaultSetting].outputToFiles) {
            //当前是JSON代表数组，生成到文件需要提示用户输入Root Class name，
            ESDialogController *dialog = [[ESDialogController alloc] initWithWindowNibName:@"ESDialogController"];
            NSString *msg = [NSString stringWithFormat:@"The root class for output to files name is:"];
            __block NSString *rootClassName = ESRootClassName;
            [dialog setDataWithMsg:msg defaultClassName:ESRootClassName enter:^(NSString *className) {
                rootClassName = className;
            }];
            [NSApp beginSheet:[dialog window] modalForWindow:[NSApp mainWindow] modalDelegate:nil didEndSelector:nil contextInfo:nil];
            [NSApp runModalForWindow:[dialog window]];
            
            //并且提示用户输入JSON对应的key的名字
            dialog = [[ESDialogController alloc] initWithWindowNibName:@"ESDialogController"];
            msg = [NSString stringWithFormat:@"The JSON is an array,the correspond 'key' is:"];
            [dialog setDataWithMsg:msg defaultClassName:ESArrayKeyName enter:^(NSString *className) {
                //输入完毕之后，将这个class设置
                NSDictionary *dic = [NSDictionary dictionaryWithObject:result forKey:className];
                classInfo = [[ESClassInfo alloc] initWithClassNameKey:ESRootClassName ClassName:rootClassName classDic:dic];
            }];
            [NSApp beginSheet:[dialog window] modalForWindow:[NSApp mainWindow] modalDelegate:nil didEndSelector:nil contextInfo:nil];
            [NSApp runModalForWindow:[dialog window]];
            [self dealPropertyNameWithClassInfo:classInfo];
        }else{
            //Root class 已存在，只需要输入JSON对应的key的名字
            ESDialogController *dialog = [[ESDialogController alloc] initWithWindowNibName:@"ESDialogController"];
            NSString *msg = [NSString stringWithFormat:@"The JSON is an array,the correspond 'key' is:"];
            [dialog setDataWithMsg:msg defaultClassName:ESArrayKeyName enter:^(NSString *className) {
                //输入完毕之后，将这个class设置
                NSDictionary *dic = [NSDictionary dictionaryWithObject:result forKey:className];
                classInfo = [[ESClassInfo alloc] initWithClassNameKey:ESRootClassName ClassName:ESRootClassName classDic:dic];
            }];
            [NSApp beginSheet:[dialog window] modalForWindow:[NSApp mainWindow] modalDelegate:nil didEndSelector:nil contextInfo:nil];
            [NSApp runModalForWindow:[dialog window]];
            [self dealPropertyNameWithClassInfo:classInfo];
        }
    }
    return classInfo;
}


/**
 *  处理属性名字(用户输入属性对应字典对应类或者集合里面对应类的名字)
 *
 *  @param classInfo 要处理的ClassInfo
 *
 *  @return 处理完毕的ClassInfo
 */
- (ESClassInfo *)dealPropertyNameWithClassInfo:(ESClassInfo *)classInfo{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:classInfo.classDic];
    for (NSString *key in dic) {
        //取出的可能是NSDictionary或者NSArray
        id obj = dic[key];
        if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDictionary class]]) {
            ESDialogController *dialog = [[ESDialogController alloc] initWithWindowNibName:@"ESDialogController"];
            NSString *msg = [NSString stringWithFormat:@"The '%@' correspond class name is:",key];
            if ([obj isKindOfClass:[NSArray class]]) {
                //May be 'NSString'，will crash
                if (!([[obj firstObject] isKindOfClass:[NSDictionary class]] || [[obj firstObject] isKindOfClass:[NSArray class]])) {
                    continue;
                }
                dialog.objIsKindOfArray = YES;
                msg = [NSString stringWithFormat:@"The '%@' child items class name is:",key];
            }
            __block NSString *childClassName;//Record the current class name
            [dialog setDataWithMsg:msg defaultClassName:[key capitalizedString] enter:^(NSString *className) {
                if (![className isEqualToString:key]) {
                    self.replaceClassNames[key] = className;
                }
                childClassName = className;
            }];
            [NSApp beginSheet:[dialog window] modalForWindow:[NSApp mainWindow] modalDelegate:nil didEndSelector:nil contextInfo:nil];
            [NSApp runModalForWindow:[dialog window]];
            //如果当前obj是 NSDictionary 或者 NSArray，继续向下遍历
            if ([obj isKindOfClass:[NSDictionary class]]) {
                ESClassInfo *childClassInfo = [[ESClassInfo alloc] initWithClassNameKey:key ClassName:childClassName classDic:obj];
                [self dealPropertyNameWithClassInfo:childClassInfo];
                //设置classInfo里面属性对应class
                [classInfo.propertyClassDic setObject:childClassInfo forKey:key];
            }else if([obj isKindOfClass:[NSArray class]]){
                //如果是 NSArray 取出第一个元素向下遍历
                NSArray *array = obj;
                if (array.firstObject) {
                    NSObject *obj = [array firstObject];
                    //May be 'NSString'，will crash
                    if ([obj isKindOfClass:[NSDictionary class]]) {
                        ESClassInfo *childClassInfo = [[ESClassInfo alloc] initWithClassNameKey:key ClassName:childClassName classDic:(NSDictionary *)obj];
                        [self dealPropertyNameWithClassInfo:childClassInfo];
                        //设置classInfo里面属性类型为 NSArray 情况下，NSArray 内部元素类型的对应的class
                        [classInfo.propertyArrayDic setObject:childClassInfo forKey:key];
                    }
                }
            }
        }
    }
    return classInfo;
}


-(void)close{

//    [self close];
}

-(void)textDidChange:(NSNotification *)notification{
    NSTextView *textView = notification.object;
    id result = [self dictionaryWithJsonStr:textView.string];
    if ([result isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = result;
        [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([obj isKindOfClass:[NSArray class]]) {
                *stop = YES;
            }
        }];
    }
}


/**
 *  检查是否是一个有效的JSON
 */
-(id)dictionaryWithJsonStr:(NSString *)jsonString{
    jsonString = [[jsonString stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"jsonString=%@",jsonString);
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
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




-(void)outputResult:(ESClassInfo*)classInfo{
    
    if ([ESJsonFormatSetting defaultSetting].outputToFiles) {
        //选择保存路径
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        [panel setTitle:@"ESJsonFormat"];
        [panel setCanChooseDirectories:YES];
        [panel setCanCreateDirectories:YES];
        [panel setCanChooseFiles:NO];
        
        if ([panel runModal] == NSModalResponseOK) {
            NSString *folderPath = [[[panel URLs] objectAtIndex:0] relativePath];
            [classInfo createFileWithFolderPath:folderPath];
            [[NSWorkspace sharedWorkspace] openFile:folderPath];
        }
        
    }else{
        if (!self.hContentTextView) return;
        
        if (!self.isSwift) {
           
            
            //如果输入主类的话就一起显示了
            
            [self.hContentTextView insertText:classInfo.atClassContent replacementRange:NSMakeRange(0, self.hContentTextView.string.length)];
            
            [self.hContentTextView insertText:[NSString stringWithFormat:@"\n%@",classInfo.classContentForH] replacementRange:NSMakeRange(self.hContentTextView.string.length, 0)];
            [self.hContentTextView insertText:[NSString stringWithFormat:@"\n%@",classInfo.classInsertTextViewContentForH] replacementRange:NSMakeRange(self.hContentTextView.string.length, 0)];
            
            
            
            
            [self.mContentTextView insertText:classInfo.classContentForM replacementRange:NSMakeRange(0, self.mContentTextView.string.length)];
            [self.mContentTextView insertText:[NSString stringWithFormat:@"\n%@",classInfo.classInsertTextViewContentForM] replacementRange:NSMakeRange(self.mContentTextView.string.length,0)];
            
            
            
            
//             //如果不输入主类的话，就可以分开展示
//            //先添加主类的属性
//            [self.mainClassContentTextView insertText:classInfo.propertyContent];
//            
//            //再添加把其他类的的字符串拼接到最后面
//            [self.hContentTextView insertText:classInfo.classInsertTextViewContentForH replacementRange:NSMakeRange(self.hContentTextView.string.length, 0)];
//            
//            //@class
//            [self.classContentTextView insertText:classInfo.atClassContent];
            
            
//            //.m文件
//            [self.mContentTextView insertText:classInfo.classInsertTextViewContentForM replacementRange:NSMakeRange(0, self.mContentTextView.string.length)];
            
            
        }else{
        
            //Swift
            [self.hContentTextView insertText:classInfo.classContentForH];
            
            //再添加把其他类的的字符串拼接到最后面
            [self.hContentTextView insertText:classInfo.classInsertTextViewContentForH replacementRange:NSMakeRange(self.hContentTextView.string.length, 0)];
        }
    }
}

@end
