//
//  ZPARConfiger.m
//  zhaopin
//
//  Created by lth on 2018/5/7.
//  Copyright © 2018年 zhaopin.com. All rights reserved.
//

#import "ZPARConfiger.h"
#import "ZPARMateDataRecorder.h"
#import "ZPARRecordGather.h"
#import "ZPARNetRecorder.h"
#import "ZPARStaticDataProviderIMP.h"

@implementation ZPARConfiger

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doConfigAction) name:UIApplicationDidFinishLaunchingNotification object:nil];
    });
}

+ (void)doConfigAction
{
    // 注册需要被监听的类
    [configerHead startRecordObjectActionFromRecordMode_classesMap];
    // 有需要被上报的日志消息时  会调用这个callbak  有外界调用者提供上报方式
    [ZPARRecordGather configRecordReportCallback:configerHead.reportCallBack];
    // 配置全局静态数据
    [ZPARStaticDataProviderIMP configStaticDataWithDataProvider:configerHead];
}


+ (NSDictionary *)evtid_paramkeyMapForModuleName:(NSString *)moduleName
{
    NSDictionary *dict = [self valueForKey:NSStringFromSelector(@selector(evtid_paramkey_map)) inModuleName:moduleName];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        return dict;
    }
    return nil;
}

+ (NSArray<NSString *> *)basickeysFromEvtid_paramkeyMapForModuleName:(NSString *)moduleName evtid:(NSString *)evtid
{
    if (![evtid isKindOfClass:[NSString class]] ||
        ![moduleName isKindOfClass:[NSString class]] ||
        evtid.length == 0 ||
        moduleName.length == 0) {
        return nil;
    }
    NSDictionary *evtid_paramkey = [self evtid_paramkeyMapForModuleName:moduleName];
    NSString *basicCommonKeys = evtid_paramkey[@"ZPAR_common"][@"basic"];
    NSString *basicKeys = evtid_paramkey[evtid][@"basic"];
    
    NSArray *basicCommonkeyArr = [basicCommonKeys componentsSeparatedByString:@","]?:@[];
    NSArray *paramkeyArr = [basicCommonkeyArr arrayByAddingObjectsFromArray:[basicKeys componentsSeparatedByString:@","]];
    return paramkeyArr;
}

+ (NSArray<NSString *> *)propskeysFromEvtid_paramkeyMapForModuleName:(NSString *)moduleName evtid:(NSString *)evtid
{
    if (![evtid isKindOfClass:[NSString class]] ||
        ![moduleName isKindOfClass:[NSString class]] ||
        evtid.length == 0 ||
        moduleName.length == 0) {
        return nil;
    }
    NSDictionary *evtid_paramkey = [self evtid_paramkeyMapForModuleName:moduleName];
    NSString *propsCommonKeys = evtid_paramkey[@"ZPAR_common"][@"props"];
    NSString *propsKeys = evtid_paramkey[evtid][@"props"];    
    NSArray *propsCommonkeyArr = [propsCommonKeys componentsSeparatedByString:@","]?:@[];
    NSArray *paramkeyArr = [propsCommonkeyArr arrayByAddingObjectsFromArray:[propsKeys componentsSeparatedByString:@","]];
    return paramkeyArr;
}


+ (NSDictionary *)static_dataKey_typeMapForModuleName:(NSString *)moduleName
{
    NSDictionary *dict = [self valueForKey:NSStringFromSelector(@selector(static_dataKey_type_map)) inModuleName:moduleName];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        return dict;
    }
    return nil;
}

+ (NSDictionary *)metaDataProviderKey_inputLoc_mapForModuleName:(NSString *)moduleName
{
    NSDictionary *dict = [self valueForKey:NSStringFromSelector(@selector(metaDataProviderKey_inputLoc_map)) inModuleName:moduleName];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        return dict;
    }
    return nil;
}

+ (NSDictionary *)url_recordTypeConfigMapForModuleName:(NSString *)moduleName
{
    NSDictionary *dict = [self valueForKey:NSStringFromSelector(@selector(url_recordTypeConfigMap)) inModuleName:moduleName];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        return dict;
    }
    return nil;
}

+ (id)valueForKey:(NSString *)key inModuleName:(NSString *)moduleName
{
    __block id value = nil ;
    NSLog(@"configer valueForKey %@  %@" , key , moduleName);
    [self enumerateConfigChainUsing:^(ZPARConfiger *configer,BOOL *needStop,NSInteger index) {
        if ([configer.moduleName isEqualToString:moduleName]) {
            *needStop = YES ;
            value = [configer valueForKey:key];
        }else if (value == nil && [configer.moduleName isEqualToString:kZPARConfigerBaseModuleName])
        {
            value = [configer valueForKey:key];
        }
    }];

    return value;
}

/// 判断一个configer 是不是基类
+ (BOOL)isBaseClass
{
    return [self isMemberOfClass:[ZPARConfiger class]];
}

/// 判断一个configer 是不是基类
- (BOOL)isBaseClass
{
    return [self isMemberOfClass:[ZPARConfiger class]];
}

+ (NSDictionary<NSNumber * , NSArray<Class> *> *)recordMode_classesMap
{
    return nil;
}

/// 注册需要被监听的类
- (void)startRecordObjectActionFromRecordMode_classesMap
{

    if (self.hasConfigOnlyOnceParams == NO) {
        self.hasConfigOnlyOnceParams = YES ;
        [self.recordMode_classesMap enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSArray<Class> * _Nonnull classes, BOOL * _Nonnull stop) {
            ZPARDataRecordMode recordMode = [key integerValue];
            [classes enumerateObjectsUsingBlock:^(Class  _Nonnull klazz, NSUInteger idx, BOOL * _Nonnull stop) {
                [ZPARMateDataRecorder startRecordObjectActionOfClass:klazz
                                                          recordMode:recordMode
                                                          moduleName:self.moduleName];
            }];

        }];
    }
    [self.nextConfiger startRecordObjectActionFromRecordMode_classesMap];
}

+ (BOOL)ZPAR_recordOnForModuleName:(NSString *)moduleName
{
    return  [[self valueForKey:NSStringFromSelector(@selector(ZPAR_recordOn)) inModuleName:moduleName] boolValue];
}

// kvc 数据转接到 实际的数据提供者
- (id)valueForUndefinedKey:(NSString *)key
{
    return [self staticDataForKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"ZPARConfigerEntity setValue:(id)value forUndefinedKey: %@ : v :%@" , key , value);
}

- (id)staticDataForKey:(NSString *)key
{

    /// 从本地预置的map中 取值 有的话 就不做下面的fetch
    __block id resV = nil ;
    
    resV = self.static_dataKey_type_map[key];
    if (resV) {
        return resV ;
    }
    
    if (self.nextConfiger) {
        return [self.nextConfiger staticDataForKey:key];
    }
    return nil;
}


static __kindof ZPARConfiger *configerHead = nil;

/// 添加一个配置类
+ (void)registerToConfigChain
{
    ZPARConfiger *configer = [[self alloc] init];
    if (configerHead == nil) {
        configerHead =configer ;
        return ;
    }
    
    if ([configer.moduleName isEqualToString:kZPARConfigerBaseModuleName])
    {
        ZPARConfiger *configerH = configerHead ;
        while (configerH.nextConfiger) {
            configerH = configerH.nextConfiger;
        }
        configerH.nextConfiger = configer;
        
        return ;
    }
    
    [configer setNextConfiger:configerHead];
    configerHead = configer;
//    [self doConfigAction];
}
/// 移除一个配置类
+ (void)removeFromConfigChain
{
    /// 处理边界  头结点就是需要移除的
    if ([configerHead isBaseClass])
    {
        configerHead = configerHead.nextConfiger;
        [self doConfigAction];
        return ;
    }
    
    ZPARConfiger *configer = configerHead.nextConfiger;
    ZPARConfiger *preConfiger = configerHead;
    while (configer) {
        
        if ([configer isBaseClass]) {
            preConfiger.nextConfiger = configer.nextConfiger;
            break;
        }
        configer = configer.nextConfiger;
        preConfiger = preConfiger.nextConfiger;
    }
}

+ (void)enumerateConfigChainUsing:(void(^)(ZPARConfiger* , BOOL *stop , NSInteger index))block
{
    BOOL needStop = NO;
    NSInteger index = 0;
    if (configerHead == nil) {
        if (block) {
            block(nil,&needStop,index);
        }
        return ;
    }
    ZPARConfiger *tmpP = configerHead ;
    while (tmpP) {
        if (block) {
            block(tmpP,&needStop,index++);
        }
        if (needStop == YES) {
            break;
        }
        tmpP = tmpP.nextConfiger;
    }
}

+ (NSString *)removeFrameworkPrefixWithKey:(NSString *)key
{
    /// 去掉ZPAR_ 前缀  如果有的话
    if ([key hasPrefix:@"ZPAR_"])
    {
        key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 5) withString:@""];
    }
    return key;
}

@end
