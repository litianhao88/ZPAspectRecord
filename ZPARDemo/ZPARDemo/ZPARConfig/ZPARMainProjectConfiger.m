//
//  ZPARConfigerEntity.m
//  zhaopin
//
//  Created by lth on 2018/5/7.
//  Copyright © 2018年 zhaopin.com. All rights reserved.
//

#import "ZPARMainProjectConfiger.h"
#import "ZPARMarcos.h"
#import <UIKit/UIKit.h>
#import "NSObject+ZPARModuleNameSupport.h"

@implementation ZPARMainProjectConfiger

/// 注册 configerChain 执行时机
ZPAR_convinent_register_to_configerChain

- (instancetype)init
{
    if (self = [super init]) {
        self.moduleName = self.moduleName_location;
        NSString *suffix = @"mainProj";
        self.evtid_paramkey_map = ZPAR_loadPlistNamed(kZPAREvtidParamkeyMapDefaultConfigFileName,suffix);
        self.url_recordTypeConfigMap = ZPAR_loadPlistNamed(kZPARNetRecorderDefaultConfigFileName,suffix);
        self.static_dataKey_type_map = ZPAR_loadPlistNamed(kZPARStaticDataKeyTypeMapDefaultConfigFileName,suffix);
        self.metaDataProviderKey_inputLoc_map = ZPAR_loadPlistNamed(kZPARMetaDataKeyLocMapDefaultConfigFileName,suffix);
    }
    return self;
}

- (NSDictionary<NSNumber *,NSArray<Class> *> *)recordMode_classesMap
{
    if (!_recordMode_classesMap)
    {
        Class classToRecord = NSClassFromString(@"ZPARDemoModel");
        if (classToRecord) {
            _recordMode_classesMap = @{@(ZPARDataRecordModeDisplayOnWindow) : @[classToRecord]};
        }
    }
    return _recordMode_classesMap;
}

/// 有需要被上报的日志消息时  会调用这个callbak  有外界调用者提供上报方式

- (ZPARRecordReportCallbackType)reportCallBack
{
    if (!_reportCallBack) {
        __weak typeof(self) weakSelf = self ;
        _reportCallBack = ^BOOL(id<ZPARRecordOutput> record) {
            /// moduleName不是当前模块名称 就不处理 (基类除外)
            if (![record.moduleName isEqualToString:weakSelf.moduleName] &&
                [weakSelf.moduleName isEqualToString:kZPARConfigerBaseModuleName]) {
                BOOL success = NO;
                if (weakSelf.nextConfiger.reportCallBack)
                {
                    success = weakSelf.nextConfiger.reportCallBack(record);
                }
                return success;
            }
            
            if ([record respondsToSelector:@selector(ZPAR_basicDictDataForExposeUpload)] &&
                [record respondsToSelector:@selector(ZPAR_propsDictDataForExposeUpload)])
            {
                BOOL success = YES ;
//                BOOL success = [zlStsctracker rptEvt:record.ZPAR_basicDictDataForExposeUpload
//                                             extflds:record.ZPAR_propsDictDataForExposeUpload];
                NSLog(@"上报 啦啦啦");
                if (weakSelf.nextConfiger.reportCallBack)
                {
                    success = success && weakSelf.nextConfiger.reportCallBack(record);
                }
                return success;
            }else{
                return NO ;
            }
        };
    }
    return _reportCallBack;
}

- (BOOL)ZPAR_recordOn
{
//     开关方式待定  暂时返回YES
    return YES;
}

/// 全局静态数据  在这里赋值
- (id)staticDataForKey:(NSString *)key
{
    __block id resV = nil;
    
    key = [ZPARConfiger removeFrameworkPrefixWithKey:key];

    if ([key isEqualToString:@"seid"])
    {
        resV = @"88888888";
    }
    if ([key isEqualToString:@"uid"]) {
        resV = @"50000";
    }
    if ([key isEqualToString:@"appver"]) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        resV = [infoDictionary objectForKey:@"CFBundleShortVersionString"];// app版本
    }
    
    if ([key isEqualToString:@"dvctype"])
    {
        resV = [[UIDevice currentDevice] model]; //设备类型
    }
    
    if ([key isEqualToString:@"chnlname"])
    {
        resV = @"";
    }
    
    if (resV == nil)
    {
        return [super staticDataForKey:key];
    }
    return resV ;
}


@end
