//
//  ZPARMarcos.h
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/20.
//  Copyright © 2018年 lth. All rights reserved.
//

#ifndef ZPARMarcos_h
#define ZPARMarcos_h

#ifdef __OBJC__

#import "ZPARRecordOutput.h"
#import "ZPARDataRecordMode.h"

#define ZPARLog(frmt,...) do{NSLog(@"\n--------------------------- ZPAR START ---------------------------\n%@\n--------------------------- ZPAR END---------------------------",[NSString stringWithFormat:frmt, ##__VA_ARGS__]);} while(0)

//    #define ZPARLog(frmt,...) do{printf("\n--------------------------- ZPAR START ---------------------------\n%s\n--------------------------- ZPAR END---------------------------",[[NSString stringWithFormat:frmt, ##__VA_ARGS__] UTF8String]);} while(0)

//职位列表  单条职位可视范围的曝光统计
#define ZPAR_evtid_jdvsl_expose @"jdvsl_expose"

// 列表曝光
#define ZPAR_evtid_expose @"expose"

//单条投递
#define ZPAR_evtid_deliver @"deliver"

//批量投递
#define ZPAR_evtid_bdeliver @"bdeliver"

//页面可视
#define ZPAR_evtid_pagein @"pagein"

//页面消失
#define ZPAR_evtid_pageout @"pageout"
//浏览到底部
#define ZPAR_evtid_pvtobottom @"pvtobottom"
//页面加载和重新加载时上报
#define ZPAR_evtid_pageopen @"pageopen"

#define ZPAR_safeString(str)  (str?:@"")
#define ZPAR_safeArr(arr)  (arr?:@[])
#define ZPAR_safeDict(dict)  (dict?:@{})
#define ZPAR_safeObject(obj)  (obj?:[NSNull null])

#define ZPAR_maxLogMate_count (10)

/// 用对象的指针值做字典key时 需要把object的指针强转为整型值
#define ZPAR_IntegerPtrForObj(obj) ((NSInteger)(__bridge void *)(obj))


/// 简写 FR  failReason
static NSString *const FR_clsProtocolErr = @"nstartRecordObject failed reason : klass don't conformsToProtocol  ZPARModelRecorded";
static NSString *const FR_clsTypErr = @"nstartRecordObject failed reason : inputArg(named klass) is not a Class Type ";
static NSString *const FR_parmNilErr = @"nstartRecordObject failed reason : param nil ";

/// check params valid
#define ZPAR_CheckClassAndRecordModeValidity(klass ,className,recordMode)         do {\
if(!class_conformsToProtocol(klass, @protocol(ZPARModelRecorded)))\
{\
ZPARLog(@"%@ \n  klass : %@ recordMode : %@\n" ,\
FR_clsProtocolErr ,klass, ZPAR_nameOfRecordMode(recordMode));\
return NO;\
}\
if (!object_isClass(klass)) {\
ZPARLog(@"%@ \n  klass : %@ recordMode : %@\n" ,\
FR_clsTypErr,klass, ZPAR_nameOfRecordMode(recordMode));\
return NO;\
}\
className = NSStringFromClass(klass) ;\
if (className == nil || className.length == 0 || !ZPAR_checkRecordModeValidity(recordMode))\
{\
ZPARLog(@"%@\n klass : %@ recordMode : %@\n" ,\
FR_parmNilErr,className, ZPAR_nameOfRecordMode(recordMode));\
return NO;\
}\
} while (0);

/// 便捷合成器
#define ZPAR_convinent_synthesize(propertyName)  @synthesize propertyName=_##propertyName;
/// 便捷动态合成器
#define ZPAR_convinent_dynamic(propertyName)  @dynamic propertyName;

/*
 *  有需要被上报的日志消息时  会调用这个类型的block  有由外界调用者提供上报方式
 *   param :  record 日志model  上报的实体
 *   return : bool  是否上报成功
*/
typedef BOOL(^ZPARRecordReportCallbackType)(id<ZPARRecordOutput> record);

///  网络接口监听上报的 url-recordtype  配置表默认文件名称
#define kZPARNetRecorderDefaultConfigFileName @"ZPAR_url_netRecordType_map"

/// record上报数据转map时 的mapkey值搜索表 默认文件名称 
#define kZPAREvtidParamkeyMapDefaultConfigFileName @"ZPAR_evtid_paramkey_map"

/// 全局静态数据配置表 默认文件名
#define kZPARStaticDataKeyTypeMapDefaultConfigFileName @"ZPAR_static_datakeys_type_map"

/// 上报字段 数据来源映射表
#define kZPARMetaDataKeyLocMapDefaultConfigFileName @"ZPAR_MetaDataProviderKey_inputLoc_map"

/// 每种上报事件 对应需要的字段 及获取途径 映射表本地文件默认路径
#define kZPARMetaDataProviderKeyInputLocMapDefaultConfigFileName @"ZPAR_MetaDataProviderKey_inputLoc_map.plist"

#define ZPAR_loadPlistNamed(fileName,moduleName) [NSDictionary dictionaryWithContentsOfFile:\
                                [[NSBundle bundleForClass:[self class]]\
                                pathForResource:[NSString stringWithFormat:@"%@_%@",fileName,moduleName]\
                                ofType:@"plist"]]

#endif

#endif /* ZPARMarcos_h */
