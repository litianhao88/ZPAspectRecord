//
//  ZPARRecordGather.m
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/23.
//  Copyright © 2018年 lth. All rights reserved.
//

#import "ZPARRecordGather.h"
#import "ZPARMarcos.h"
#import "ZPARRecord.h"

/// 所有埋点record的合并 上报  当前实现是:有数据就处理
/// 如果以后有复杂的缓存需求 就在这个类中实现
@interface ZPARRecordGather()

//@property (nonatomic , strong) NSMutableArray<id<ZPARRecordOutput>> *recordQueue;
@property (nonatomic , copy) ZPARRecordReportCallbackType recordReportCallback;

@end

@implementation ZPARRecordGather

+ (instancetype)shareInstance
{
    static ZPARRecordGather *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (void)configRecordReportCallback:(ZPARRecordReportCallbackType)callback
{
    [[self shareInstance] setRecordReportCallback:callback];
}


//- (NSMutableArray<id<ZPARRecordOutput>> *)recordQueue
//{
//    if (!_recordQueue) {
//        _recordQueue = [NSMutableArray array];
//    }
//    return _recordQueue;
//}


/// 依据当前需求 来一条处理一条就可以 因此暂时取消了队列功能 以后有复杂的功能需求, 再修改
+ (BOOL)enqueueRecord:(id<ZPARRecordOutput>)record
{
    ZPARRecordGather *gather = [self shareInstance];
    return [gather logOut:record];
}

+ (BOOL)enqueueRecordWithDict:(NSDictionary *)dict
{
    if (dict == nil)
    {
        return NO;
    }
    
   return [self enqueueRecord:[ZPARRecord modelWithWeexReportInfo:dict]];
}

//- (void)dequeueAndLogAll
//{
//    if (self.recordQueue.count <= 1)
//    {
//        [self logOut:self.recordQueue.firstObject];
//    }else
//    {
//        [self.recordQueue enumerateObjectsUsingBlock:^(id<ZPARRecordOutput>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            [self logOut:obj];
//        }];
//    }
//    [self.recordQueue removeAllObjects];
//}

- (BOOL)logOut:(id<ZPARRecordOutput>)record
{
    if (self.recordReportCallback) {
       return self.recordReportCallback(record);
    }
    return NO;
}

@end
