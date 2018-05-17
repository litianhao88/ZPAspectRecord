//
//  ZPARBaseModuleConfiger.m
//  zhaopin
//
//  Created by lth on 2018/5/11.
//  Copyright © 2018年 zhaopin.com. All rights reserved.
//

#import "ZPARBaseModuleConfiger.h"

@implementation ZPARBaseModuleConfiger

ZPAR_convinent_register_to_configerChain

- (instancetype)init
{
    if (self = [super init]) {

        self.moduleName = kZPARConfigerBaseModuleName;

        self.ZPAR_recordOn = YES ;
        self.evtid_paramkey_map = [NSDictionary dictionaryWithContentsOfFile:
                                   [[NSBundle bundleForClass:[self class]]
                                    pathForResource:kZPAREvtidParamkeyMapDefaultConfigFileName
                                                                                    ofType:@"plist"]];
        self.url_recordTypeConfigMap = [NSDictionary dictionaryWithContentsOfFile:
                                        [[NSBundle bundleForClass:[self class]]
                                         pathForResource:kZPARNetRecorderDefaultConfigFileName
                                                                                         ofType:@"plist"]];
        self.static_dataKey_type_map = [NSDictionary dictionaryWithContentsOfFile:
                                        [[NSBundle bundleForClass:[self class]] pathForResource:kZPARStaticDataKeyTypeMapDefaultConfigFileName
                                                                                         ofType:@"plist"]];
    }
    return self;
}

- (ZPARRecordReportCallbackType)reportCallBack
{
    if (!_reportCallBack) {
        __weak typeof(self) weakSelf = self ;
        _reportCallBack = ^BOOL(id<ZPARRecordOutput> record) {
            
            /// moduleName不是当前模块名称 就不处理 (基类除外)
            if (![record.moduleName isEqualToString:weakSelf.moduleName] &&
                ![weakSelf.moduleName isEqualToString:kZPARConfigerBaseModuleName]
                ) {
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
                BOOL success = NO ;

                ZPARLog(@"basic : %@ \n props : %@  success : %zd" , record.ZPAR_basicDictDataForExposeUpload , record.ZPAR_propsDictDataForExposeUpload , success);
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

- (id)staticDataForKey:(NSString *)key
{
    return [super staticDataForKey:key];
}


@end
