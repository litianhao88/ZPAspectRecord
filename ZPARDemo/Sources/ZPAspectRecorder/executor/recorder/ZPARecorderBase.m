//
//  ZPARecorderBase.m
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/19.
//  Copyright © 2018年 lth. All rights reserved.
//

#import "ZPARecorderBase.h"
#import "ZPARecorderBaseFuncImp.h"
#import <objc/runtime.h>
#import <objc/message.h>


@implementation ZPARecorderBase
{
    @protected
//    NSMutableArray *_records;
    NSMutableDictionary *_recordObjectMap;
}

//- (NSMutableArray *)records
//{
//    if (!_records)
//    {
//        _records = [NSMutableArray array];
//    }
//    return _records;
//}
//
- (NSMutableDictionary *)recordObjectMap
{
    if (!_recordObjectMap) {
        _recordObjectMap = [NSMutableDictionary dictionary];
    }
    return _recordObjectMap;
}

/// 暂时用不到 如果后期有持久化 日志信息排序等需求 可以用这个扩展接口实现
//- (id<ZPARBaseFunc>)recorderBaseImp
//{
//    if (!_recorderBaseImp) {
//        _recorderBaseImp = [[ZPARecorderBaseFuncImp alloc] init];
//    }
//    return _recorderBaseImp;
//}


@end
