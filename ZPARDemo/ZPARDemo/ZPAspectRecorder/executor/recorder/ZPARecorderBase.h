//
//  ZPARecorderBase.h
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/19.
//  Copyright © 2018年 lth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZPARBaseFunc.h"

@interface ZPARecorderBase : NSObject

/// 暂时用不到 如果后期有持久化 日志信息排序等需求 可以用这个扩展接口实现
//@property (nonatomic , strong) id<ZPARBaseFunc> recorderBaseImp;

/// 已经注册到收集的类的map  <被监听的类 或对象, 监听模式>
@property (nonatomic , strong , readonly) NSMutableDictionary *recordObjectMap;

@end
