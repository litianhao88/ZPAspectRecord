//
//  ZPARMateDataRecord.h
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/23.
//  Copyright © 2018年 lth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZPARRecordBase.h"


///便捷添加 收集框架预设的property 实例变量
#define ZPAR_convinent_synthesize_ZPARMateDataRecord    ZPAR_convinent_synthesize(jdno)\
                                                        ZPAR_convinent_synthesize(score)\
                                                        ZPAR_convinent_synthesize(rsmno)\
                                                        ZPAR_convinent_synthesize(jdlist)\
                                                        ZPAR_convinent_synthesize(rsltnum)\
                                                        ZPAR_convinent_synthesize(pagelim)\
                                                        ZPAR_convinent_synthesize(method)\
                                                        ZPAR_convinent_synthesize(rparams)\
                                                        ZPAR_convinent_synthesize(srchkey)\
                                                        ZPAR_convinent_synthesize(selected)\
                                                        ZPAR_convinent_synthesize(netExtParams)\




@protocol ZPARMateDataRecord <ZPARRecordBase>

/// 职位id
@property (nonatomic , copy) NSString *jdno;
/// 曝光分数
@property (nonatomic , copy) NSString *score;


/// 简历编码
@property (nonatomic , copy) NSString *rsmno;

/// jdlist：职位列表，例：[{jdno：职位编码，pos：职位在列表中的绝对位置}]
@property (nonatomic , copy) NSString *jdlist;

//rsltnum：服务端返回的结果个数
@property (nonatomic , assign) NSInteger rsltnum;

//pagelim：每页的条数限制
@property (nonatomic , assign) NSInteger pagelim;


//method：排序策略，服务端返回的method。
@property (nonatomic , copy) NSString *method;

//rparams：二次排序策略的参数(用于细化分析)
@property (nonatomic , copy) NSString *rparams;


//srchkey：搜索关键词
@property (nonatomic , copy) NSString *srchkey;

//selected：搜索条件，例：{area：'北京'}
@property (nonatomic , strong) NSMutableDictionary *selected;

@property (nonatomic , strong) NSDictionary *netExtParams;

@end
