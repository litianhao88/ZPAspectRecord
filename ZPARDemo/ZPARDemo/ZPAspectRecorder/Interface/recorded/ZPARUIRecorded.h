//
//  ZPARUIRecorded.h
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/23.
//  Copyright © 2018年 lth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZPARModelRecorded.h"
#import "ZPARRecordContext.h"
#import "ZPARRecordDataProvider.h"

///便捷添加 收集框架预设的property 实例变量
#define ZPAR_convinent_synthesize_ZPARUIRecorded ZPAR_convinent_synthesize(recordContext)\
ZPAR_convinent_synthesize(ZPAR_jdno)

@protocol ZPARUIRecorded <NSObject>
@property (nonatomic , copy , readonly) id<ZPARModelRecorded,ZPARRecordDataProvider> ZPAR_modelForRecorded;
@optional
/// 用于信息收集的上下文  每个页面独有 可以按需求跨页面传值
@property (nonatomic , strong) ZPARRecordContext *recordContext;

@property (nonatomic , copy  ) NSString *ZPAR_jdno;

/// 忽略收集  如果view实现接口 这个属性返回YES 那么即使它是scrollview的subview  也不会被record
@property (nonatomic , assign , readonly) BOOL ZPAR_ignoreRecord;

///// 当前被监听的对象 属于那一模块
//@property (nonatomic , copy , readonly) NSString *ZPAR_moduleName;

@end
