//
//  ZPARRecordBase.h
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/23.
//  Copyright © 2018年 lth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZPARRecordOutput.h"
#import "ZPARRecordDataProvider.h"
#import "ZPARRecordContext.h"


///便捷添加 收集框架预设的property 实例变量
#define ZPAR_convinent_synthesize_ZPARRecordBase    ZPAR_convinent_synthesize(timeStampt)\
ZPAR_convinent_synthesize(evtid)\
ZPAR_convinent_synthesize(moduleName)\
ZPAR_convinent_synthesize(dataKey_provider_map)



@protocol ZPARRecordBase <ZPARRecordOutput>

///// 记录id  用来将多个收集器收集来的数据 进行同类合并(多种不同类型的记录用recordId来判断是否合并)
//@property (nonatomic , copy) NSString *recordId;
/// 记录生成时的时间戳
@property (nonatomic , assign) NSTimeInterval timeStampt;
/// 事件id
@property (nonatomic , copy) NSString *evtid;
////每次搜索访问产生一个唯一id(翻页不变)
//@property (nonatomic , copy) NSString *actionid;

/// 上报事件对应的 上报字段以及他的provider  映射表
@property (nonatomic , strong) NSDictionary *dataKey_provider_map;



/// 当前record 所属模块名称
@property (nonatomic , copy)  NSString *moduleName;


+ (instancetype)modelWithRecordDataProvider:(id<ZPARRecordDataProvider>)recordDataProvider
                              recordContext:(ZPARRecordContext *)recordContext
                                 moduleName:(NSString *)moduleName
                                      evtid:(NSString *)evtid;

- (instancetype)initWithRecordDataProvider:(id<ZPARRecordDataProvider>)recordDataProvider
                             recordContext:(ZPARRecordContext *)recordContext
                                moduleName:(NSString *)moduleName
                                     evtid:(NSString *)evtid;



/// 用weex上报的数据初始化record
+ (instancetype)modelWithWeexReportInfo:(NSDictionary *)weexReportInfo;

- (instancetype)init NS_UNAVAILABLE;

@end
