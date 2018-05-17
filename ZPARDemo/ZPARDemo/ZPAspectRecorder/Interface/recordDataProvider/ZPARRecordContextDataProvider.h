//
//  ZPARRecordContextDataProvider.h
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/24.
//  Copyright © 2018年 lth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZPARMarcos.h"

/// refdesc_current的便捷getter
#define ZPAR_convinent_getter_refdesc_current - (NSString *)ZPAR_refdesc_current\
                                                {\
                                                    return NSStringFromClass([self class]);\
                                                }

/// pageIsList 的便捷getter
#define ZPAR_convinent_getter_pageIsList(statm) - (BOOL)ZPAR_pageIsList\
                                                    {\
                                                    statm\
                                                    }

/// pageno的便捷getter
#define ZPAR_convinent_getter_pagecode(statm) - (NSInteger)ZPAR_pagecode\
                                                {\
                                                statm\
                                                }

/// pageno的便捷getter
#define ZPAR_convinent_getter_currentRefObjc - (id<ZPARRecordContextDataProvider>)ZPAR_currentRefObjc\
{\
    if ([self conformsToProtocol:@protocol(ZPARRecordContextDataProvider)]) {\
        return self;\
    }\
    return nil;\
}

/// ZPARRecordContextDataProvider接口要求的所有可读写属性的合成器
#define ZPAR_convinent_synthesize_recordContextDataProvider     ZPAR_convinent_synthesize(ZPAR_actionid)\
                                                                ZPAR_convinent_synthesize(ZPAR_detailJdno)\
                                                                ZPAR_convinent_synthesize(ZPAR_weexJumpInfo)\
                                                                ZPAR_convinent_synthesize(ZPAR_selectPos)\
                                                                ZPAR_convinent_synthesize(ZPAR_refdesc_current)\
                                                                ZPAR_convinent_synthesize(ZPAR_pageIsList)\
                                                                ZPAR_convinent_synthesize(ZPAR_pagecode)\
                                                                ZPAR_convinent_synthesize(ZPAR_currentRefObjc)


@protocol ZPARRecordContextDataProvider <NSObject>

/// 当前context 所引用的 provider 有一些动态属性 需要实时回调获取
@property (nonatomic , weak , readonly) id<ZPARRecordContextDataProvider> ZPAR_currentRefObjc;

/// 当前页面编码
@property (nonatomic , assign , readonly) NSInteger ZPAR_pagecode;
///当前页面的完整类名或url
@property (nonatomic , copy , readonly) NSString *ZPAR_refdesc_current;
/// 当前页面是否是列表页
@property (nonatomic , assign,readonly) BOOL ZPAR_pageIsList;

@optional
/// 详情页需要加载的详情职位的num
@property (nonatomic , copy) NSString *ZPAR_detailJdno;
/// 列表页点击的职位 绝对位置  跳到详情页时 要用到
@property (nonatomic , assign) NSInteger ZPAR_selectPos;
/// 告知recorder 哪个section算是底部
@property (nonatomic , assign , readonly) NSInteger  ZPAR_bottomSection;
///actionid：每次搜索访问产生一个唯一id(翻页不变)
@property (nonatomic , copy) NSString *ZPAR_actionid;
/// weex页面跳原生页面 传值 有这个map  代表当前页面是一个weex页面
@property (nonatomic , strong) NSDictionary *ZPAR_weexJumpInfo;

@end
