//
//  ZPARModelRecorded.h
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/20.
//  Copyright © 2018年 lth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZPARRecordDataProvider.h"


///便捷添加 收集框架预设的property 实例变量
#define ZPAR_convinent_synthesize_ZPARModelRecorded ZPAR_convinent_synthesize(ZPAR_shouldIgnoreObserved)\
ZPAR_convinent_synthesize(ZPAR_recordNotifyOnlyOnce)\
ZPAR_convinent_synthesize(ZPAR_hasRecordOn)\
ZPAR_convinent_synthesize(ZPAR_pos)\
@dynamic ZPAR_dataDisplayedOnWindowCall;


#define ZPAR_safeNotifyDataDisplayState(currentModel,onView , moduleName)     do {\
if ([currentModel respondsToSelector:@selector(ZPAR_dataDisplayedOnWindowCall)] && currentModel.ZPAR_dataDisplayedOnWindowCall)\
{\
currentModel.ZPAR_dataDisplayedOnWindowCall(currentModel, onView , moduleName);\
}\
} while (0);

/// jdno 提供便利getter
#define ZPAR_provide_jdno(jdnoStatm) \
- (NSString *)ZPAR_jdno\
{\
jdnoStatm\
}

/// score 提供便利getter
#define ZPAR_provide_score(scoretatm) \
- (NSString *)ZPAR_score\
{\
scoretatm\
}

/// recordNotifyOnlyOnce 提供便利getter
#define ZPAR_provide_recordNotifyOnlyOnce(statm)\
- (BOOL)ZPAR_recordNotifyOnlyOnce\
{\
statm\
}


@protocol ZPARModelRecorded

typedef void(^ZPAR_dataDisplayedOnWindowCallBlockType)(id<ZPARModelRecorded,ZPARRecordDataProvider> , BOOL,NSString *);
/// 如果不希望当前对象被监听,收集数据 设置为YES 默认为NO
@property (nonatomic , assign) BOOL ZPAR_shouldIgnoreObserved;

/// 这个属性开启后 每个model的每种记录模式只会相应一次 默认开启
@property (nonatomic , assign) BOOL ZPAR_recordNotifyOnlyOnce;

/// 这个block属性是模块内hook实现的 不需要接口实现者实现 如果接口实现者实现了,会造成模块和外界调用者通信中断 数据展示到了屏幕上传YES  数据展示视图从屏幕中移除后传NO 
@property (nonatomic , readonly) ZPAR_dataDisplayedOnWindowCallBlockType ZPAR_dataDisplayedOnWindowCall;

@property (nonatomic , assign) BOOL ZPAR_hasRecordOn;

///  被监听的对象在当前容器中的绝对位置
@property (nonatomic , assign) NSInteger ZPAR_pos;

@end
