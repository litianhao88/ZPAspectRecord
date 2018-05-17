//
//  ZPARNetRecorder.m
//  zhaopin
//
//  Created by lth on 2018/4/27.
//  Copyright © 2018年 zhaopin.com. All rights reserved.
//

#import "ZPARNetRecorder.h"
#import "ZPAR_swizzling_method.h"
#import "ZPARRecordContextManager.h"
#import "ZPARRecordGather.h"
#import "ZPARRecord.h"
#import "UIViewController+ZPARRecordSupport.h"
#import "ZPARConfiger.h"
#import "ZPARRecordDataProvider.h"
#import <objc/runtime.h>
@implementation NSObject(ZPARNetRecordSupport)

/// 占位方法 具体实现不在这里 为了防止错写而导致 方法找不到的crash  这里提供空方法
- (ZPAR_handle_APIRecord_BlockType)ZPAR_handle_APIRecord
{
    return nil;
}

@end

@implementation ZPARNetRecorder

+ (instancetype)shareInstance
{
    static ZPARNetRecorder *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ZPAR_swizzling_exchangeMethodWithNewClass([NSObject class], @selector(ZPAR_handle_APIRecord), [self class], @selector(ZPAR_swizzling_handle_APIRecord));
    });
}

- (ZPAR_handle_APIRecord_BlockType)ZPAR_swizzling_handle_APIRecord
{
   ZPAR_handle_APIRecord_BlockType resBlock = objc_getAssociatedObject(self, @selector(ZPAR_handle_APIRecord));
    if (resBlock == nil)
    {
        resBlock = ^(ZPARRecordContext *pageContext , ZPARNetContext *netContext , NSString * requestUrl,NSDictionary *requestParams, NSDictionary *responseDict)
        {
            // 总开关 关闭 不做任何处理
            if (![ZPARConfiger ZPAR_recordOnForModuleName:netContext.moduleName]) {
                return ;
            }
            
            if (netContext == nil || netContext.recordOn == NO) {
                return  ;
            }
            if (pageContext == nil)
            {
                pageContext = [ZPARRecordContextManager currentContext];
                if (pageContext == nil)
                {
                    return ;
                }
            }
//            ZPARLog(@"---------------------------- API Recorder Log ----------------");
//            ZPARLog(@"%@ context ref" , context.ZPAR_currentRefObjc);
//            ZPARLog(@"%@ requestUrl" , requestUrl);
//            ZPARLog(@"%@ requestParams" , requestParams);
//            ZPARLog(@"%@ responseDict" , responseDict);
//            ZPARLog(@"---------------------------- API Recorder Log ----------------");
//            
            /*
             seid：一次登录产生的ID，WEB为长连接保持中不变，APP是应用一次启动中不切换账号的情况下保持不变。
             actionid：每次搜索访问产生一个唯一id(翻页不变)
             jdlist：职位列表，例：[{jdno：职位编码，pos：职位在列表中的绝对位置}]
             rsmno：简历编号
             projectid：arith_rt_0420
             
             seid：一次登录产生的ID，WEB为长连接保持中不变，APP是应用一次启动中不切换账号的情况下保持不变。
             actionid：每次搜索访问产生一个唯一id(翻页不变)
             jdno：职位编码
             rsmno：简历编码
             refdesc：上一页面的完整类名或url
             srccode：来源曝光列表位置编码，搜索结果列表=501901/首页推荐列表=502001
             projectid：arith_rt_0420
             */
            NSString *evtid = [ZPARNetRecorder netRecordTypeFromUrl:requestUrl
                                                      requestParams:requestParams
                                                         moduleName:netContext.moduleName] ;
            if ([evtid isEqualToString:ZPAR_evtid_pageopen]) {
                if(!([pageContext.ZPAR_currentRefObjc respondsToSelector:@selector(ZPAR_recordPageAction)] &&
                   [(UIViewController *)pageContext.ZPAR_currentRefObjc ZPAR_recordPageAction]))
                {
                    evtid = nil;
                }
            }
            
            if (evtid.length > 0)
            {
                ZPARRecord *record = [ZPARRecord modelWithRecordDataProvider:nil
                                                               recordContext:pageContext
                                                                  moduleName:netContext.moduleName
                                                                       evtid:evtid];
                
                [record setExtNetDataWithRequestParams:requestParams
                                       responseDict:responseDict
                                         netContext:netContext];
                
                [ZPARRecordGather enqueueRecord:record];
            }
            
        };
        objc_setAssociatedObject(self, @selector(ZPAR_handle_APIRecord), resBlock, OBJC_ASSOCIATION_COPY);
    }
    return resBlock;
}

+ (NSString *)netRecordTypeFromUrl:(NSString *)requestUrl
                     requestParams:(NSDictionary *)requestParams
                        moduleName:(NSString *)moduleName
{
    __block NSString *evtid_res = @"" ;

    NSURL *url = [NSURL URLWithString:requestUrl];
    if (url)
    {
        NSURLComponents *comps = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
        NSString *path = comps.path;
        NSDictionary *ZPAR_url_netRecordType_map = [ZPARConfiger url_recordTypeConfigMapForModuleName:moduleName];
        /// 遍历调用方的url配置表 , 用当前requestUrl得出对用的上报type
        [ZPAR_url_netRecordType_map enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull urlKey, NSString * _Nonnull evtid, BOOL * _Nonnull stop) {
            
            NSArray *urlComp_inner = [urlKey componentsSeparatedByString:@"?"];

            NSString *urlPath_inner = urlComp_inner.firstObject;
            // 找到相同path的url
            if ([path rangeOfString:urlPath_inner].location != NSNotFound) {
                // 有额外的配置信息
                __block BOOL match = YES;

                if (urlComp_inner.count > 1)
                {
                    NSString *params_string = urlComp_inner.lastObject ;
                    NSArray *params_inner = [params_string componentsSeparatedByString:@"&"];
                    // 遍历每一个配置参数
                    [params_inner enumerateObjectsUsingBlock:^(NSString *_Nonnull paramString, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSArray *configParams = [paramString componentsSeparatedByString:@"="];
                        if (configParams.count > 1)
                        {
                            id value = requestParams[configParams.firstObject];
                            BOOL inner_match_success =
                            ([value isKindOfClass:[NSString class]] && [value isEqualToString:configParams.lastObject]) ||
                            ([value isKindOfClass:[NSNumber class]] &&
                             ([value integerValue] == [configParams.lastObject integerValue] ||
                              [value doubleValue] - [configParams.lastObject doubleValue] < 0.000001));
                            if (!inner_match_success) {
                                // 参数匹配不成功
                                match = NO;
                                *stop = YES ;
                            }
                        }
                    }];
                }
                
                /// match成功 说明url命中
                if (match) {
                    evtid_res = evtid;
                    *stop = YES ;
                }
            }
        }];
    }
    return evtid_res;
}

@end
