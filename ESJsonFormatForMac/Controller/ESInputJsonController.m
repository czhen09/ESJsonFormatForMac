
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

#import "DataModel.h"
#import "HttpRequestTool.h"

@interface ESInputJsonController ()<NSTextViewDelegate,NSTableViewDataSource,NSTabViewDelegate,NSTextFieldDelegate,NSTextDelegate>

/**
 *  字段对应的类的名字[key->JSON字段 : value->类名(用户输入)]
 */
@property (nonatomic,strong) ESDialogController *dialog;
@property (nonatomic, strong) NSMutableDictionary *replaceClassNames;
@property (nonatomic, strong) NSMutableDictionary *implementMethodOfMJExtensionClassNames;
@property (unsafe_unretained) IBOutlet NSTextView *inputTextView;
@property (weak) IBOutlet NSButton *enterButton;
@property (weak) IBOutlet NSScrollView *scrollView;
//@property (unsafe_unretained) IBOutlet NSTextView *classContentTextView;
//@property (unsafe_unretained) IBOutlet NSTextView *mainClassContentTextView;
//
//@property (weak) IBOutlet NSLayoutConstraint *classContentTextViewH;
@property (unsafe_unretained) IBOutlet NSTextView *hContentTextView;
@property (unsafe_unretained) IBOutlet NSTextView *mContentTextView;
@property (weak) IBOutlet NSTextField *inputUrlTxf;
@property (weak) IBOutlet NSTextField *inputJointUrlTxf;

@property (weak) IBOutlet NSTextField *hLabel;
@property (weak) IBOutlet NSTextField *mLabel;


@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSView *btnBackView;
/**存放参数字典*/
@property (unsafe_unretained) IBOutlet NSTextView *paramsTxv;

@property (weak) IBOutlet NSPopUpButton *popUpBtn;





/**保存参数模型数组*/
@property (nonatomic,strong) NSMutableArray * dataArr;
/**记录tableView中celld个数*/
@property (nonatomic,assign) NSInteger rowCount;
/**当前选中cell,用于删除*/
@property (nonatomic,assign) NSInteger  selectedRow;

@property (nonatomic,assign) BOOL isPost;

@end

@implementation ESInputJsonController


#pragma mark - Life Cycle
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.inputUrlTxf.tag = 998;
    NSString *base_Url = [[NSUserDefaults standardUserDefaults] valueForKey:@"Base_Url"];
    if (base_Url) {
        
        self.inputUrlTxf.stringValue = base_Url;
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.inputUrlTxf.delegate = self;
    [self.tableView reloadData];
    [self creatAddAndDeledateBtn];
    
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
        
        self.isSwift = NO;
        self.isPost = YES;
        
        
        //因为我没有找到设置segmentcontroller初始设置选中的方法...所以...这样了
        [[NSUserDefaults standardUserDefaults] setBool:self.isSwift forKey:@"isSwift"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isYYModel"];
        self.rowCount = 1;
        self.selectedRow = -1;
        
        [self.dataArr removeAllObjects];
        for (int i=0; i<10; i++) {
            
            DataModel *dataModel = [DataModel new];
            dataModel.key = @"";
            dataModel.value = @"";
            [self.dataArr addObject:dataModel];
        }
        
    }
    
    return self;
}


#pragma mark - Private Methods
- (void)creatAddAndDeledateBtn{
    
    //添加按钮
    NSButton *addBtn = [[NSButton alloc] initWithFrame:CGRectMake(0, 0, 40, 75)];
    addBtn.title = @"+";
    addBtn.font = [NSFont systemFontOfSize:25];
    addBtn.wantsLayer = YES;
    addBtn.layer.cornerRadius = 3.0f;
    addBtn.layer.borderColor = [NSColor lightGrayColor].CGColor;
    [addBtn setTarget:self];
    addBtn.action = @selector(addRowUnderTheSelectedRow);
    [self.btnBackView addSubview:addBtn];
    
    
    //删除按钮
    NSButton *deleteBtn = [[NSButton alloc] initWithFrame:CGRectMake(0, 75, 40, 75)];
    deleteBtn.title = @"-";
    deleteBtn.font = [NSFont systemFontOfSize:25];
    deleteBtn.wantsLayer = YES;
    deleteBtn.layer.cornerRadius = 3.0f;
    deleteBtn.layer.borderColor = [NSColor lightGrayColor].CGColor;
    [deleteBtn setTarget:self];
    deleteBtn.action = @selector(deleteTheSelectedRow);
    [self.btnBackView addSubview:deleteBtn];
}


#pragma mark - Beyond Description

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


-(void)windowWillClose:(NSNotification *)notification{
    if ([self.delegate respondsToSelector:@selector(windowWillClose)]) {
        [self.delegate windowWillClose];
    }
}




#pragma mark - UITableViewAndDataSourceDelegate
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.rowCount;
}
//这个方法虽然不返回什么东西，但是必须实现，不实现可能会出问题－比如行视图显示不出来等。（10.11貌似不实现也可以，可是10.10及以下还是不行的）
- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    return nil;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 58;
}
- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *strIdt=[tableColumn identifier];
    NSTableCellView *aView = [tableView makeViewWithIdentifier:strIdt owner:self];
    if (!aView)
        aView = [[NSTableCellView alloc]initWithFrame:CGRectMake(0, 0, tableColumn.width, 58)];
    else
        for (NSView *view in aView.subviews)[view removeFromSuperview];
    
    NSTextField *textField = [[NSTextField alloc] initWithFrame:CGRectMake(15, 20, 156+50, 30)];
    DataModel *dataModel = nil;
    if (self.dataArr.count>0) {
        
        dataModel = self.dataArr[row];
    }
    
    if ([strIdt isEqualToString:@"key"]) {
        
        textField.stringValue = dataModel.key;
        textField.placeholderString  = @"key";
        textField.tag = 1000+row;
        
    }
    if ([strIdt isEqualToString:@"value"]) {
        
        textField.stringValue = dataModel.value;
        textField.placeholderString  = @"value";
        textField.tag = 2000+row;
    }
    
    textField.font = [NSFont systemFontOfSize:15.0f];
    textField.textColor = [NSColor blackColor];
    textField.drawsBackground = NO;
    textField.bordered = NO;
    textField.delegate = self;
    textField.focusRingType = NSFocusRingTypeNone;
    textField.editable = YES;
    [aView addSubview:textField];
    
    return aView;
}


- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    
    self.selectedRow = row;
    NSLog(@"self.selectedRow===%ld",(long)self.selectedRow);
    return YES;
}


#pragma mark - NSTextFieldDelegate
- (void)controlTextDidEndEditing:(NSNotification *)obj
{
    NSTextField *txf = (NSTextField *)obj.object;
    DataModel *dataModel = [DataModel new];
    if (txf.tag<2000&&txf.tag>=1000) {
        
        dataModel.key = txf.stringValue;
        DataModel *data = self.dataArr[txf.tag-1000];
        data.key = dataModel.key;
        
    }else if(txf.tag>=2000){
        
        dataModel.value = txf.stringValue;
        DataModel *data = self.dataArr[txf.tag-2000];
        data.value = dataModel.value;
        
//        if (![data.key isEqualToString:@""]) {
//            
//             [self addRowUnderTheSelectedRow];
//        }
        
    }else if (txf.tag==998){
        
        //保存BaseUrl
        NSString *originalBase_Url = [[NSUserDefaults standardUserDefaults] valueForKey:@"Base_Url"];
        NSString *newBase_Url       = self.inputUrlTxf.stringValue;
        if (!originalBase_Url||![originalBase_Url isEqualToString:newBase_Url]||[originalBase_Url isEqualToString:@""]) {
            
            [[NSUserDefaults standardUserDefaults] setValue:txf.stringValue forKey:@"Base_Url"];
        }
        
        
    }
   
    NSLog(@"txf.stringValue====%@",txf.stringValue);
    NSLog(@"%ld",(long)txf.tag);
    
    self.paramsTxv.string = [self outputParamsStrByDataArr:self.dataArr];
    
}


- (NSString *)outputParamsStrByDataArr:(NSArray *)dataArr{
    
    NSString *tempStr = [NSString stringWithFormat:@"\n\n%@\n",@"NSMutableDictionary * params = [NSMutableDictionary dictionary];"];
    NSString *paramsStr = tempStr;
    for (DataModel *dataModel in self.dataArr) {
        
        if (![dataModel.key isEqualToString:@""]) {
            
            NSString *params = [NSString stringWithFormat:@"params[@\"%@\"] = @\"%@\";\n",dataModel.key,dataModel.value];
            paramsStr = [paramsStr stringByAppendingString:[NSString stringWithFormat:@"%@",params]];

        }
    }
    
    if ([paramsStr isEqualToString:tempStr]) {
        
        return @"\nNo Parameters";
    }else{
        
        return paramsStr;
    }
    
}

#pragma mark - Event Response

- (IBAction)popUpBtnAction:(NSPopUpButton *)sender {
    
    NSLog(@"sender.indexOfSelectedItem===%ld",(long)sender.indexOfSelectedItem);
    NSInteger selectedIndex = sender.indexOfSelectedItem;
    self.isPost = (selectedIndex == 0)?YES:NO;
}

-(void)deleteTheSelectedRow
{
    if (self.rowCount==0) {
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"\nNo more rows"];
        [alert runModal];
        return;
    }
    
    
    if (self.selectedRow == -1){
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"\nPlease choose a row which you want to delete"];
        [alert runModal];
        return;
    
    }
    [self.tableView beginUpdates];
    [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:self.selectedRow] withAnimation:NSTableViewAnimationSlideUp];
    [self.tableView endUpdates];
    
    //移除原来数据;
    [self.dataArr removeObjectAtIndex:self.selectedRow];
    DataModel *dataModel = [DataModel new];
    dataModel.key = @"";
    dataModel.value = @"";
    //再最末再添加一个数据;
    [self.dataArr addObject:dataModel];
    self.paramsTxv.string = [self outputParamsStrByDataArr:self.dataArr];
    self.selectedRow = -1;
    self.rowCount -= 1;
}
-(void)addRowUnderTheSelectedRow
{
    
    if (self.rowCount==10) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"\nThe maximum parameters is 10"];
        [alert runModal];
        return;
    }
    self.rowCount += 1;
    [_tableView beginUpdates];
    
    
//    [self.dataArr removeLastObject];
//    DataModel *dataModel = [DataModel new];
//    dataModel.key = @"";
//    dataModel.value = @"";
//    [self.dataArr insertObject:dataModel atIndex:0];
    
    [_tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:self.rowCount-1] withAnimation:NSTableViewAnimationSlideDown];
    [_tableView endUpdates];
    
    
    //滚动到底部//必须写在[_tableView endUpdates];之后
    CGPoint scrollOrigin = CGPointMake(0, (self.rowCount-1)*50);
    [[self.tableView enclosingScrollView].contentView scrollToPoint:scrollOrigin];

    
    
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
    
    if ([self.inputUrlTxf.stringValue isEqualToString:@""]) {
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"\nPlease input base_url or whole_url"];
        [alert runModal];
        return;
    }
    
    self.isPost?[self PostRequest]:[self GetRequest];
    
    
    
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


#pragma mark - RequestData

- (NSDictionary *)getParamsDicFromDataArr:(NSArray *)dataArr{
        
        
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    for (DataModel *dataModel in self.dataArr) {
        
        if (![dataModel.key isEqualToString:@""]) {
            params[dataModel.key] = dataModel.value;
        }
    }
    return [params copy];
}

- (void)PostRequest{
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",self.inputUrlTxf.stringValue,self.inputJointUrlTxf.stringValue];
    NSDictionary *params = [self getParamsDicFromDataArr:self.dataArr];
    
    [HttpRequestTool postWithUrlString:urlStr parameters:params success:^(NSString *jsonStr) {
       
        [self refreshUI:jsonStr];
        
    } failure:^(NSError *error) {
        
        
    }];
    
}

- (void)GetRequest{
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",self.inputUrlTxf.stringValue,self.inputJointUrlTxf.stringValue];
    NSDictionary *params = [self getParamsDicFromDataArr:self.dataArr];
    
    
    [HttpRequestTool getWithUrlString:urlStr parameters:params success:^(NSString *jsonStr) {
        
        [self refreshUI:jsonStr];
        
        
    } failure:^(NSError *error) {
        
        
    }];
}

- (void)refreshUI:(NSString *)jsonStr{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        weakSelf.inputTextView.string = jsonStr;
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
}

#pragma mark - Change ESJsonFormat
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
            
            
            NSString *mContent = [NSString stringWithFormat:@"%@\n%@",classInfo.classContentForM,classInfo.classInsertTextViewContentForM];
            self.mContentTextView.string = mContent;
            
            //如果输入主类的话就一起显示了
            [self.hContentTextView insertText:classInfo.atClassContent replacementRange:NSMakeRange(0, self.hContentTextView.string.length)];
            [self.hContentTextView insertText:[NSString stringWithFormat:@"\n%@",classInfo.classContentForH] replacementRange:NSMakeRange(self.hContentTextView.string.length, 0)];
            [self.hContentTextView insertText:[NSString stringWithFormat:@"\n%@",classInfo.classInsertTextViewContentForH] replacementRange:NSMakeRange(self.hContentTextView.string.length, 0)];
            
            //.m文件内容不能使用废除的insert方法插入，否则""将失效；
//            [self.mContentTextView insertText:classInfo.classContentForM replacementRange:NSMakeRange(0, self.mContentTextView.string.length)];
//            [self.mContentTextView insertText:[NSString stringWithFormat:@"\n%@",classInfo.classInsertTextViewContentForM] replacementRange:NSMakeRange(self.mContentTextView.string.length,0)];
            
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
#pragma mark - Getter And Setter
- (NSMutableArray *)dataArr
{
    
    if (!_dataArr) {
        
        _dataArr = [NSMutableArray array];
    }
    
    return _dataArr;
}
@end
