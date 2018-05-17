//
//  ZPARModel.m
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/19.
//  Copyright © 2018年 lth. All rights reserved.
//

#import "ZPARRecord.h"
#import "ZPARMarcos.h"
#import "ZPARRecordContextManager.h"
#import "ZPARStaticDataProviderIMP.h"
#import "ZPARConfiger.h"

@implementation ZPARRecord

ZPAR_convinent_synthesize_ZPARRecordBase

+ (instancetype)modelWithWeexReportInfo:(NSDictionary *)weexReportInfo
{
    return [[self alloc] initWithWeexReportInfo:weexReportInfo];
}

- (instancetype)initWithWeexReportInfo:(NSDictionary *)weexReportInfo
{
    if (self = [super init])
    {

        self.timeStampt = [NSDate timeIntervalSinceReferenceDate];
        self.staticDataProvider = [ZPARStaticDataProviderIMP defaultDataProvider];
        [self setValuesForKeysWithDictionary:weexReportInfo];
    }
    return self;
}

+ (instancetype)modelWithRecordDataProvider:(id<ZPARRecordDataProvider>)recordDataProvider
                              recordContext:(ZPARRecordContext *)recordContext
                                 moduleName:(NSString *)moduleName
                                      evtid:(NSString *)evtid
{
    return [[self alloc] initWithRecordDataProvider:recordDataProvider
                                      recordContext:recordContext
                                         moduleName:(NSString *)moduleName
                                              evtid:evtid];
}


- (instancetype)initWithRecordDataProvider:(id<ZPARRecordDataProvider>)recordDataProvider
                             recordContext:(ZPARRecordContext *)recordContext
                                moduleName:(NSString *)moduleName
                                     evtid:(NSString *)evtid
{
    if (self = [super init])
    {

        self.evtid = evtid ;
        self.moduleName = moduleName ;
        self.timeStampt = [NSDate timeIntervalSinceReferenceDate];
        self.staticDataProvider = [ZPARStaticDataProviderIMP defaultDataProvider];
        
        [self fillParamsWithRecordDataProvider:recordDataProvider
                                 recordContext:recordContext];
        
    }
    return self ;
}
- (void)fillParamsWithRecordDataProvider:(id<ZPARRecordDataProvider>)recordDataProvider
                           recordContext:(ZPARRecordContext *)recordContext
{
    if (recordContext == nil)
    {
        recordContext = [ZPARRecordContextManager currentContext];
    }
    
    NSDictionary *map = [ZPARConfiger metaDataProviderKey_inputLoc_mapForModuleName:self.moduleName] ;
    NSMutableDictionary *KeyMap = [map[@"ZPAR_common"] mutableCopy];
    [KeyMap setValuesForKeysWithDictionary:map[self.evtid]];
    self.dataKey_provider_map = KeyMap.copy;
    
    [KeyMap enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, id _Nonnull from, BOOL * _Nonnull stop) {
        id resValue = [self fetchValueFromRecordDataProvider:recordDataProvider
                                               recordContext:recordContext
                                                      forKey:key
                                                        from:from] ;
        
        if (resValue) {
            self.originDataDict[key] = resValue;
        }
    }];
}

/// 根据配置表中的来源字段  从入参中获取对应value  如果找不到 尝试查找加了 'ZPAR_' 前缀的属性
- (id)fetchValueFromRecordDataProvider:(id<ZPARRecordDataProvider>)recordDataProvider
                         recordContext:(ZPARRecordContext *)recordContext
                                forKey:(NSString *)key
                                  from:(id)from
{
    id resValue = nil;
    if ([from isKindOfClass:[NSString class]])
    {
        if ([from isEqualToString:@"pageCtx"])
        {
            resValue = [recordContext valueForKey:key];
            if (resValue == nil  &&
                ![key hasPrefix:@"ZPAR_"])
            {
                resValue = [recordContext valueForKey:[NSString stringWithFormat:@"ZPAR_%@",key]];
            }
        }
        if ([from isEqualToString:@"pvd"])
        {
            resValue = [recordDataProvider ZPAR_valueForKey:key];
            if (resValue == nil  &&
                ![key hasPrefix:@"ZPAR_"])
            {
                resValue = [recordDataProvider ZPAR_valueForKey:[NSString stringWithFormat:@"ZPAR_%@",key]];
            }
        }
    }
    else
    {
        if (resValue == nil)
        {
            resValue = [recordDataProvider ZPAR_valueForKey:key];
        }
        if (resValue == nil)
        {
            resValue = [recordContext valueForKey:key];
        }
        

        if (resValue == nil  &&
            ![key hasPrefix:@"ZPAR_"])
        {
            resValue = [recordContext valueForKey:[NSString stringWithFormat:@"ZPAR_%@",key]];
        }
        
        if (resValue == nil  &&
            ![key hasPrefix:@"ZPAR_"])
        {
            resValue = [recordDataProvider ZPAR_valueForKey:[NSString stringWithFormat:@"ZPAR_%@",key]];
        }
    }
    return resValue;
}

- (NSMutableDictionary *)netDataDict
{
    if (!_netDataDict) {
        _netDataDict = [NSMutableDictionary dictionary];
    }
    return _netDataDict ;
}


- (NSMutableDictionary *)originDataDict
{
    if (!_originDataDict) {
        _originDataDict = [NSMutableDictionary dictionary];
    }
    return _originDataDict;
}



/// 根据不同的上报evtid 从接口请求回来的数据中解析获得上报数据
- (void)setExtNetDataWithRequestParams:(NSDictionary *)requestParams
                       responseDict:(NSDictionary *)responseDict
                         netContext:(ZPARNetContext *)netContext
{
    
        [self.dataKey_provider_map enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, id _Nonnull from, BOOL * _Nonnull stop) {
            id resValue = [self fetchNetValueFromRequestParams:requestParams
                                                  responseDict:responseDict
                                                    netContext:netContext
                                                        forKey:key
                                                          from:from] ;
            if (resValue) {
                self.netDataDict[key] = resValue;
            }
        }];
    
}
/// 根据配置表中的来源字段  从入参中获取对应value  如果找不到 尝试查找加了 'ZPAR_' 前缀的属性
- (id)fetchNetValueFromRequestParams:(NSDictionary *)requestParams
                        responseDict:(NSDictionary *)responseDict
                          netContext:(ZPARNetContext *)netContext
                              forKey:(NSString *)key
                                from:(id)from
{
    
    id resValue = nil;
    
    if ([from isKindOfClass:[NSString class]])
    {
        NSArray *fromParams = [from componentsSeparatedByString:@":"];
        from = fromParams.firstObject;
        if (fromParams.count > 1)
        {
            key = fromParams[1];
        }
        
        if ([from isEqualToString:@"netReq"])
        {
            resValue = [requestParams valueForKey:key];
            if (resValue == nil  &&
                ![key hasPrefix:@"ZPAR_"])
            {
                resValue = [requestParams valueForKey:[NSString stringWithFormat:@"ZPAR_%@",key]];
            }
        }
        if ([from isEqualToString:@"netCtx"])
        {
            resValue = [netContext valueForKey:key];
            if (resValue == nil  &&
                ![key hasPrefix:@"ZPAR_"])
            {
                resValue = [netContext valueForKey:[NSString stringWithFormat:@"ZPAR_%@",key]];
            }
        }
        if ([from isEqualToString:@"netRes"])
        {
            resValue = [responseDict valueForKey:key];
            if (resValue == nil  &&
                ![key hasPrefix:@"ZPAR_"])
            {
                resValue = [responseDict valueForKey:[NSString stringWithFormat:@"ZPAR_%@",key]];
            }
        }
    }
    else if ([from isKindOfClass:[NSDictionary class]])
    {
        /// 示例 expose 的 jdlist
        /// 用来完成 数据来源复杂的列表拼接
        NSString *type = from[@"type"];
        NSString *fromName = [from[@"key"] componentsSeparatedByString:@":"].firstObject;
        NSString *keyName = [from[@"key"] componentsSeparatedByString:@":"].lastObject;
        NSDictionary *elementInfo = from[@"elements"];
        
        if ([type isKindOfClass:[NSString class]]) {
            if ([type isEqualToString:@"array"])
            {
                NSArray *resArr = nil;
                if ([fromName isEqualToString:@"netReq"]) {
                    resArr = requestParams[keyName];
                }else if ([fromName isEqualToString:@"netRes"])
                {
                    resArr = responseDict[keyName];
                }else if ([fromName isEqualToString:@"netCtx"])
                {
                    resArr = [netContext valueForKey:keyName];
                }else if ([fromName isEqualToString:@"self"])
                {
                    resArr = [self valueForKey:keyName];
                }
                
                if ([resArr isKindOfClass:[NSArray class]]) {
                    NSMutableArray *arrM_res = [NSMutableArray array];
                    [resArr enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull info, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([info isKindOfClass:[NSDictionary class]]) {
                            NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
                            [arrM_res addObject:dicM];
                            [elementInfo enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull keyForUpload, id  _Nonnull keyInOrigin, BOOL * _Nonnull stop) {

                                if ([keyForUpload isEqualToString:@"pos"])
                                {
                                    NSInteger page = [requestParams[from[@"page"]] integerValue];
                                    NSInteger pageSize = [requestParams[from[@"pageSize"]] integerValue];
                                    
                                    dicM[@"pos"] = @(idx + 1 + (page - 1 ) * pageSize);
                                    return ;
                                }
                                id value = info[keyInOrigin];
                                if (value) {
                                    dicM[keyForUpload] = value;
                                }
                            }];
                        }
                    }];
                    resValue = arrM_res;
                }
            }else if ([type isEqualToString:@"dict"])
            {
                // 示例 : 搜索列表曝光 expose  selected字段
                NSMutableDictionary *res_dict = [NSMutableDictionary dictionary];
                NSString *alternativeKeyPath = from[@"alternative"];
                id providerObjc = nil ;
                NSString *valueKeyPath = nil ;
                NSDictionary *alternativeMap = nil ;
                if ([alternativeKeyPath isKindOfClass:[NSString class]])
                {
                    NSArray *keys = [alternativeKeyPath componentsSeparatedByString:@":"];
                    if (keys.count > 1) {
                        if ([keys.firstObject isEqualToString:@"netCtx"]) {
                            providerObjc = netContext;
                        }
                        if ([keys.firstObject isEqualToString:@"netReq"]) {
                            providerObjc = requestParams;
                        }
                        if ([keys.firstObject isEqualToString:@"netRes"]) {
                            providerObjc = responseDict;
                        }
                        valueKeyPath = keys[1];
                    }
                }
                
                if (providerObjc && valueKeyPath) {
                    alternativeMap = [providerObjc valueForKey:valueKeyPath];
                    if (![alternativeMap isKindOfClass:[NSDictionary class]]) {
                        alternativeMap = nil;
                    }
                }
                
                
                
                if (alternativeMap) {
                    [res_dict setValuesForKeysWithDictionary:alternativeMap];
                }
            }
        }
    }
    else
    {
        if (resValue == nil)
        {
            resValue = [requestParams valueForKey:key];
        }
        if (resValue == nil)
        {
            resValue = [responseDict valueForKey:key];
        }
        if (resValue == nil)
        {
            resValue = [netContext valueForKey:key];
        }
        if (resValue == nil  &&
            ![key hasPrefix:@"ZPAR_"])
        {
            resValue = [requestParams valueForKey:[NSString stringWithFormat:@"ZPAR_%@",key]];
        }
        
        if (resValue == nil  &&
            ![key hasPrefix:@"ZPAR_"])
        {
            resValue = [responseDict valueForKey:[NSString stringWithFormat:@"ZPAR_%@",key]];
        }
        if (resValue == nil  &&
            ![key hasPrefix:@"ZPAR_"])
        {
            resValue = [netContext valueForKey:[NSString stringWithFormat:@"ZPAR_%@",key]];
        }
        
    }
    
    return resValue;
}

/// 当前模型转字典 目的是为了上传曝光埋点数据 所以只转换指定字段
/// props扩展参数
- (NSDictionary *)ZPAR_propsDictDataForExposeUpload
{
    /*
     seid：一次登录产生的ID，WEB为长连接保持中不变，APP是应用一次启动中不切换账号的情况下保持不变。
     actionid：每次搜索访问产生一个唯一id(翻页不变)
     jdlist：职位列表，例：[{jdno：职位编码，pos：职位在列表中的绝对位置}]
     rsmno：简历编号
     projectid：arith_rt_0420
     */
    NSArray *paramkeyArr = [ZPARConfiger propskeysFromEvtid_paramkeyMapForModuleName:self.moduleName evtid:self.evtid];
    
    /// 从配置表中读取需要的参数名 依据名称 赋值
     NSMutableDictionary *baseReportDictM = [self setParamsFromParamKeyArr:paramkeyArr];

    /// extParams 存入上报消息
//    if (self.netExtParams.count > 0)
//    {
//        [self.netExtParams enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//
//            if (obj)
//            {
//                if ([[baseReportDictM allKeys] containsObject:key]) {
//                    NSDictionary *dict = baseReportDictM[key];
//                    if ([dict isKindOfClass:[NSDictionary class]] &&
//                        [obj isKindOfClass:[NSDictionary class]])
//                    {
//                        /// 如果 netExtParams 中有字段是已经赋值过的 map  用下面的逻辑 取合并两个map 而不是覆盖
//                        NSMutableDictionary *dictM = dict.mutableCopy;
//                        [dictM setValuesForKeysWithDictionary:obj];
//                        baseReportDictM[key] = dictM.copy;
//                    }
//                }else
//                {
//                    [baseReportDictM setObject:obj forKey:key];
//                }
//            }
//        }];
//    }
    
    return baseReportDictM.copy;
}

/// 当前模型转字典 目的是为了上传曝光埋点数据 所以只转换指定字段
/// basic 主参数
- (NSDictionary *)ZPAR_basicDictDataForExposeUpload
{
    NSArray *paramkeyArr = [ZPARConfiger basickeysFromEvtid_paramkeyMapForModuleName:self.moduleName evtid:self.evtid];
    return [self setParamsFromParamKeyArr:paramkeyArr];
}

/// 从配置表中读取需要的参数名 依据名称 赋值
- (NSMutableDictionary *)setParamsFromParamKeyArr:(NSArray *)paramKeyArr
{
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    /// 从配置表中读取需要的参数名 依据名称 赋值
    [paramKeyArr enumerateObjectsUsingBlock:^(NSString *  _Nonnull keyName, NSUInteger idx, BOOL * _Nonnull stop) {
        if (keyName.length > 0) {
            
            keyName = [keyName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            id value = [self valueForKey:keyName];
            
            /// 不存入空串
            if ([value respondsToSelector:@selector(length)] && [value length] == 0) {
                dictM[keyName] = @"";
                return ;
            }
            if (value) {
                    dictM[keyName] = value;
            }else
            {
                dictM[keyName] = @"";
            }
        }
    }];
    return dictM;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{}

- (id)valueForUndefinedKey:(NSString *)key
{
    id valueRes = [self.staticDataProvider valueForKey:key];
    if (valueRes) {
        return valueRes;
    }
    
    // 获取初始化dict中的数据
    valueRes = [self.originDataDict objectForKey:key];
    if (valueRes) {
        return valueRes ;
    }

    // 获取初始化dict中的数据
    valueRes = [self.netDataDict objectForKey:key];
    if (valueRes) {
        return valueRes ;
    }
    

    /// 如果原始属性没找到 就去找 带前缀的属性
    if (![key hasPrefix:@"ZPAR_"])
    {
        return [self valueForKey:[NSString stringWithFormat:@"ZPAR_%@",key]];
    }
    NSLog(@"%@" , key);
    return nil;
}



- (NSString *)moduleName
{
    return _moduleName;
}

@end


