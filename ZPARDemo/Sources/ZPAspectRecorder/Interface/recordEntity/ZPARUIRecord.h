//
//  ZPARUIRecord.h
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/23.
//  Copyright © 2018年 lth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZPARRecordBase.h"

///便捷添加 收集框架预设的property 实例变量
#define ZPAR_convinent_synthesize_ZPARUIRecord    ZPAR_convinent_synthesize(ZPAR_isBottom)\
ZPAR_convinent_synthesize(pageno)\
ZPAR_convinent_synthesize(pos)\
ZPAR_convinent_synthesize(srccode)\
ZPAR_convinent_synthesize(refdesc)\
ZPAR_convinent_synthesize(ref)\
ZPAR_convinent_synthesize(pageIsList)\
ZPAR_convinent_synthesize(timeonpage)\
ZPAR_convinent_synthesize(pagecode)

@protocol ZPARUIRecord <ZPARRecordBase>

@property (nonatomic , assign) BOOL ZPAR_isBottom;
/// 列表页码
@property (nonatomic , assign) NSInteger pageno;
/// 曝光职位在列表中的绝对位置
@property (nonatomic , assign) NSInteger pos;
/// 来源曝光列表位置编码，搜索结果列表=501901/首页推荐列表=502001
@property (nonatomic , copy ) NSString *srccode;
/// 上一页类名 或 url
@property (nonatomic , copy ) NSString *refdesc;

/// 上一页页码
@property (nonatomic , copy ) NSString *ref;

@property (nonatomic , assign ) BOOL pageIsList;

/// 页面停留时长
@property (nonatomic , assign ) NSInteger timeonpage;

/// 页面编码
@property (nonatomic , assign ) NSInteger pagecode;


@end
