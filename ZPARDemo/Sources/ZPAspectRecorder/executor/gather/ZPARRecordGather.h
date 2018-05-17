//
//  ZPARRecordGather.h
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/23.
//  Copyright © 2018年 lth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZPARRecordOutput.h"
#import "ZPARMarcos.h"

/// 合并 同步 各种不同类型record 最终输出可以直接传到后台的格式化数据
@interface ZPARRecordGather : NSObject

+ (BOOL)enqueueRecord:(id<ZPARRecordOutput>)record;

/// 调用方传入的回调 最终的record消息会用这个回调来处理
+ (void)configRecordReportCallback:(ZPARRecordReportCallbackType)callback;
/// week埋点数据上报是map类型 用这个方法传入
+ (BOOL)enqueueRecordWithDict:(NSDictionary *)dict;

@end
