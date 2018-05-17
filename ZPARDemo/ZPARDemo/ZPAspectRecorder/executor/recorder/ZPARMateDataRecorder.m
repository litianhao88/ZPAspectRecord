//
//  ZPARMateDataRecorder.m
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/19.
//  Copyright © 2018年 lth. All rights reserved.
//

#import "ZPARMateDataRecorder.h"
#import <objc/runtime.h>
#import "ZPARModelRecorded.h"
#import "ZPARMarcos.h"
#import "ZPARRecord.h"
#import "ZPARRecordGather.h"
#import "ZPARStaticDataProviderIMP.h"
#import "ZPAR_swizzling_method.h"
#import "ZPARConfiger.h"
#import "ZPARDataRecordMode.h"
#import "ZPARRecordDataProvider.h"

@implementation NSObject(ZPARMateDataSupport)

/// 占位方法 具体实现不在这里 为了防止错写而导致 方法找不到的crash  这里提供空方法
- (ZPAR_dataDisplayedOnWindowCallBlockType)ZPAR_dataDisplayedOnWindowCall
{
    return nil ;
}

@end

@interface ZPARMateDataRecorder()

@end

@implementation ZPARMateDataRecorder

- (ZPARDataRecordMode)recorModeOfClass:(Class)klass moduleName:(NSString *)moduleName
{
    NSString *className = NSStringFromClass(klass);
    if (!className) {
        return  ZPARDataRecordModeNone;
    }
    return [self.recordObjectMap[moduleName][className] integerValue];
}


- (ZPAR_dataDisplayedOnWindowCallBlockType)ZAPRSwizz_ZPAR_dataDisplayedOnWindowCall
{
    
    // 这个方法内部的self 是交换前 原对象的指针
    // 注意 这里面的self 不是当前类对象 调用当前对象方法会崩溃
    ZPAR_dataDisplayedOnWindowCallBlockType callback_block = objc_getAssociatedObject(self, @selector(ZPAR_dataDisplayedOnWindowCall));
    
    if (!callback_block)
    {
        callback_block = ^(id<ZPARModelRecorded,ZPARRecordDataProvider> currentModel , BOOL displayOnWindow,NSString *moduleName)
        {
            // 没有模块名称 不做任何处理
            if (moduleName.length == 0) {
                return ;
            }
            // 总开关 关闭 不做任何处理
            if (![ZPARConfiger ZPAR_recordOnForModuleName:moduleName]) {
                return;
            }

            if (![currentModel respondsToSelector:@selector(ZPAR_shouldIgnoreObserved)] || [currentModel ZPAR_shouldIgnoreObserved])
            {
                return ;
            }
            
            ZPARMateDataRecorder *recorder = [ZPARMateDataRecorder shareInstance];
              // 判断当前上报模式是否包含在已经注册过的模式
            if( displayOnWindow && ZPAR_recordModeContain([recorder recorModeOfClass:[currentModel class] moduleName:moduleName] , ZPARDataRecordModeDisplayOnWindow))
            {
                // 如果model开启了onlyOnce  在这里判断是否已经上报过
                if (!currentModel.ZPAR_recordNotifyOnlyOnce ||
                    !ZPAR_recordModeContain( [ZPARMateDataRecorder hasRecordedModeOfModel:currentModel] , ZPARDataRecordModeDisplayOnWindow))
                {
                    [ZPARMateDataRecorder addHasRecordedMode:ZPARDataRecordModeDisplayOnWindow toModel:currentModel];
                        ZPARRecord *record = [ZPARRecord modelWithRecordDataProvider:currentModel
                                                                       recordContext:nil
                                                                          moduleName:moduleName
                                                                               evtid:ZPAR_evtid_jdvsl_expose];
                        [ZPARRecordGather enqueueRecord:record];
                }
            }
            /* 当前需求只上报 displayOnWindow 下面的暂时不用
            else if( !displayOnWindow && ZPAR_recordModeContain([recorder recorModeOfClass:[currentModel class]] , ZPARDataRecordModeDismissFromWindow))
            {
                
                if (!currentModel.ZPAR_recordNotifyOnlyOnce ||
                    !ZPAR_recordModeContain( [ZPARMateDataRecorder hasRecordedModeOfModel:currentModel] , ZPARDataRecordModeDismissFromWindow)) {
                    [ZPARMateDataRecorder addHasRecordedMode:ZPARDataRecordModeDismissFromWindow toModel:currentModel];
                    if ([currentModel conformsToProtocol:@protocol(ZPARDataProvider)])
                    {
                        ZPARRecord *record =
                        [ZPARRecord modelWithMetaDataProvider:currentModel
                                               uiDataProvider:currentModel
                                           staticDataProvider:[ZPARStaticDataProviderIMP defaultDataProvider] recordContext:nil
                                                        evtid:@"待定 "];
                        [ZPARRecordGather enqueueRecord:record];
                    }
                }
            }
            */
        };
        objc_setAssociatedObject(self, @selector(ZPAR_dataDisplayedOnWindowCall), callback_block, OBJC_ASSOCIATION_COPY);
    }
    
    return callback_block;
}


static char const hasRecoredModeAssociateKey;
+ (ZPARDataRecordMode)hasRecordedModeOfModel:(id)model
{
    return (ZPARDataRecordMode)[objc_getAssociatedObject(model, &hasRecoredModeAssociateKey) integerValue];
}
+ (void)addHasRecordedMode:(ZPARDataRecordMode)recordMode toModel:(id)model
{
    ZPARDataRecordMode originMode = [self hasRecordedModeOfModel:model];
    objc_setAssociatedObject(model, &hasRecoredModeAssociateKey, @(ZPAR_mergeRecordMode(originMode, recordMode)), OBJC_ASSOCIATION_ASSIGN);
}

+ (void)resetRecordedModeToModel:(id)model
{
    objc_setAssociatedObject(model, &hasRecoredModeAssociateKey,@(ZPARDataRecordModeNone), OBJC_ASSOCIATION_ASSIGN);
}

+ (instancetype)shareInstance
{
    static ZPARMateDataRecorder *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

///  添加指定类的对象的 指定模式的行为收集
+ (BOOL)startRecordObjectActionOfClass:(Class)klass
                            recordMode:(ZPARDataRecordMode)recordMode
                            moduleName:(NSString *)moduleName
{
    if (moduleName.length == 0) {
        ZPARLog(@"startRecordObjectActionOfClass failed reason moduleName nil");
        return  NO;
    }
    NSString *className = nil;
    /// 检查入参合法性
    ZPAR_CheckClassAndRecordModeValidity(klass,className, recordMode)
    
    ZPARMateDataRecorder *recorder = [self shareInstance];
    NSMutableDictionary *recordMap = recorder.recordObjectMap[moduleName];
    
    if (recordMap == nil)
    {
        recordMap = [NSMutableDictionary dictionary];
        recorder.recordObjectMap[moduleName] = recordMap;
    }
    
    NSNumber *originRecordModeNumBox = recordMap[className];
    if (!originRecordModeNumBox)
    {
        originRecordModeNumBox = @(recordMode);
        recordMap[className] = originRecordModeNumBox ;
        return YES;
    }
    
    ZPARDataRecordMode originRecordMode = (ZPARDataRecordMode)[originRecordModeNumBox integerValue];
    ZPARDataRecordMode resRecordMode = ZPAR_mergeRecordMode(originRecordMode, recordMode);
    recordMap[className] = @(resRecordMode) ;
    return YES;

}

///  移除指定类的对象的 指定模式的行为收集
+ (BOOL)stopRecordObjectActionOfClass:(Class)klass
                           recordMode:(ZPARDataRecordMode)recordMode
                           moduleName:(NSString *)moduleName

{
    if (moduleName.length == 0) {
        ZPARLog(@"startRecordObjectActionOfClass failed reason moduleName nil");
        return  NO;
    }
    NSString *className = nil ;
    /// 检查入参合法性
    ZPAR_CheckClassAndRecordModeValidity(klass,className, recordMode)
    
    NSMutableDictionary *recordMap = [[self shareInstance] recordObjectMap][moduleName];
    
    NSNumber *originRecordModeNumBox = recordMap[className];
    if (!originRecordModeNumBox) {
        NSLog(@"stopRecordObject failed reason : map has not contain class : %@ , recordMode : %@" , className , ZPAR_nameOfRecordMode(recordMode));
        return NO;
    }
    ZPARDataRecordMode originRecordMode = (ZPARDataRecordMode)[originRecordModeNumBox integerValue];
    ZPARDataRecordMode resRecordMode = ZPAR_removeMode(originRecordMode, recordMode);
    
    // 如果移除指定mode后 结果mode为none 就直接移除class的键值对
    recordMap[className] = resRecordMode == ZPARDataRecordModeNone ? nil : @(resRecordMode);
    return YES;
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ZPAR_swizzling_exchangeMethodWithNewClass([NSObject class], @selector(ZPAR_dataDisplayedOnWindowCall), [self class], @selector(ZAPRSwizz_ZPAR_dataDisplayedOnWindowCall));
    });
}


/// inputMode 合并到 originMode 中 会进行非法检测 如果非法 就返回originMode
 ZPARDataRecordMode ZPAR_mergeRecordMode(ZPARDataRecordMode originMode , ZPARDataRecordMode inputMode)
{
    //判断inputMode是否合法
    if (!ZPAR_checkRecordModeValidity(inputMode)) {
        return originMode;
    }
    
    return originMode | inputMode ;
}


/// 判断inputMode 是否是一个合法的mode
 BOOL ZPAR_checkRecordModeValidity(ZPARDataRecordMode inputMode)
{
    return ZPAR_recordModeContain(ZPARDataRecordModeAll, inputMode);
}

/// 判断originMode 是否包含了 inputMode 如果inputMode中包含了originMode没有的mode 就返回NO
 BOOL ZPAR_recordModeContain(ZPARDataRecordMode originMode , ZPARDataRecordMode inputMode)
{
    // 两个mode取交集不为空 并且 originMode的补集与inputMode没有交集  就是originMode全包含inputMode
    return (originMode&inputMode) && !((~originMode)&inputMode);
}

/// 从originMode 中 移除 inputMode
 ZPARDataRecordMode ZPAR_removeMode(ZPARDataRecordMode originMode , ZPARDataRecordMode inputMode)
{
    // originMode 和 inputMode的补集求交集
    return (originMode & (~inputMode)) ;
}

/// 调试用的 枚举类型转字符串
NSString *ZPAR_nameOfRecordMode(ZPARDataRecordMode inputMode)
{
    if (inputMode == ZPARDataRecordModeAll) {
        return @"ZPARDataRecordModeAll";
    }
    
    if (inputMode == ZPARDataRecordModeNone) {
        return @"ZPARDataRecordModeNone";
    }
    
    NSMutableString *string = [NSMutableString string];
    if (inputMode & ZPARDataRecordModeDisplayOnWindow)
    {
        [string appendString:@"ZPARDataRecordModeDisplayOnWindow"];
    }
    
    if (inputMode & ZPARDataRecordModeDismissFromWindow)
    {
        if (string.length > 0)
        {
            [string appendString:@" | "];
        }
        [string appendString:@"ZPARDataRecordModeDismissFromWindow"];
    }
    if (inputMode & ZPARDataRecordModeCreate) {
        if (string.length > 0) {
            [string appendString:@" | "];
        }
        [string appendString:@"ZPARDataRecordModeCreate"];
    }
    if (inputMode & ZPARDataRecordModeDestory) {
        if (string.length > 0) {
            [string appendString:@" | "];
        }
        [string appendString:@"ZPARDataRecordModeDestory"];
    }
    return string.copy;
}

@end
