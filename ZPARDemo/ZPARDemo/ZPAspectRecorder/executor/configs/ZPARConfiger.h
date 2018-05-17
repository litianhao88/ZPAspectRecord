//
//  ZPARConfiger.h
//  zhaopin
//
//  Created by lth on 2018/5/7.
//  Copyright © 2018年 zhaopin.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZPARMarcos.h"

#define kZPARConfigerBaseModuleName @"ZPAspectRecorder"


/// 外部调用模块 如果没有指定的添加配置时机 可以用这个便捷宏  自动注入配置类  用这个宏  意味着调用方不在乎配置与其他模块有相同配置参数时的优先级问题
#define ZPAR_convinent_register_to_configerChain + (void)load\
{\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        [self registerToConfigChain];\
    });\
}


/// 外部调用者需要为模块提供一些配置信息 全部由这个类来实现 通过复写方法的方式 进行基类-子类通信 完成外部调用方注入数据的需求
@interface ZPARConfiger : NSObject 
{
    NSDictionary<NSNumber * , NSArray<Class> *> *_recordMode_classesMap;
    ZPARRecordReportCallbackType _reportCallBack;
}
/// 当前configer所在模块 是否开启record
@property (nonatomic , assign ) BOOL ZPAR_recordOn;
/// 配置类所属的模块名称
@property (nonatomic , copy   ) NSString *moduleName;

/// 注册需要被监听的类 key : 监听模式  value : 被监听类的数组
@property (nonatomic , strong , readonly) NSDictionary<NSNumber * , NSArray<Class> *> *recordMode_classesMap;

/// 有需要被上报的日志消息时  会调用这个callbak  有外界调用者提供上报方式
@property (nonatomic , copy , readonly) ZPARRecordReportCallbackType reportCallBack;

///  网络接口监听上报的 url-recordtype  配置表
@property (nonatomic , strong) NSDictionary *url_recordTypeConfigMap;


/// 数据收集模块 总开关 外部动态传值
+ (BOOL)ZPAR_recordOnForModuleName:(NSString *)moduleName;

/// 每种上报事件 需要的key值
@property (nonatomic , strong) NSDictionary *evtid_paramkey_map;
/// 静态全局配置参数
@property (nonatomic , strong) NSDictionary *static_dataKey_type_map;
/// 各种上报字段的数据来源映射表
@property (nonatomic , strong) NSDictionary *metaDataProviderKey_inputLoc_map;

/// 注入静态上报数据 一定不要调用父类
- (id)staticDataForKey:(NSString *)key ;

/// 配置链上 下一个配置类
@property (nonatomic , strong) __kindof ZPARConfiger *nextConfiger;

+ (NSDictionary *)metaDataProviderKey_inputLoc_mapForModuleName:(NSString *)moduleName;
+ (NSDictionary *)url_recordTypeConfigMapForModuleName:(NSString *)moduleName;
/// 根据 moduleName  evtid 获取basic key列表
+ (NSArray<NSString *> *)basickeysFromEvtid_paramkeyMapForModuleName:(NSString *)moduleName evtid:(NSString *)evtid;
/// 根据 moduleName  evtid 获取props key列表
+ (NSArray<NSString *> *)propskeysFromEvtid_paramkeyMapForModuleName:(NSString *)moduleName evtid:(NSString *)evtid;
+ (NSDictionary *)static_dataKey_typeMapForModuleName:(NSString *)moduleName;


+ (void)registerToConfigChain;

+ (void)removeFromConfigChain;

/// 判断一个configer 是不是基类
+ (BOOL)isBaseClass;

/// 判断一个configer 是不是基类
- (BOOL)isBaseClass;

+ (NSString *)removeFrameworkPrefixWithKey:(NSString *)key;

@property (nonatomic , assign) BOOL hasConfigOnlyOnceParams;

@end
