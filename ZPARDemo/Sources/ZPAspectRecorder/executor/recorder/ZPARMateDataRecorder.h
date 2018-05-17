//
//  ZPARMateDataRecorder.h
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/19.
//  Copyright © 2018年 lth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZPARecorderBase.h"
#import "ZPARModelRecorded.h"
#import "ZPARMarcos.h"

/// 从接口获得的某个实体数据的元数据记录器
@interface ZPARMateDataRecorder : ZPARecorderBase

///  添加指定类的对象的 指定模式的行为收集  返回值代表操作是否成功
+ (BOOL)startRecordObjectActionOfClass:(Class)klass
                            recordMode:(ZPARDataRecordMode)recordMode
                            moduleName:(NSString *)moduleName;
///  移除指定类的对象的 指定模式的行为收集 返回值代表操作是否成功
+ (BOOL)stopRecordObjectActionOfClass:(Class)klass
                           recordMode:(ZPARDataRecordMode)recordMode
                           moduleName:(NSString *)moduleName;


+ (ZPARDataRecordMode)hasRecordedModeOfModel:(id)model;
+ (void)addHasRecordedMode:(ZPARDataRecordMode)recordMode toModel:(id)model;
+ (void)resetRecordedModeToModel:(id)model;
@end

@interface NSObject(ZPARMateDataSupport)
/// 为了给recorder提供hook 添加这个方法
@property (nonatomic , copy , readonly) ZPAR_dataDisplayedOnWindowCallBlockType ZPAR_dataDisplayedOnWindowCall;

@end

