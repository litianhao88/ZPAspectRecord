//
//  ZPARModel.h
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/19.
//  Copyright © 2018年 lth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZPARRecordOutput.h"
#import "ZPARRecordBase.h"
#import "ZPARMateDataRecord.h"
#import "ZPARUIRecord.h"
#import "ZPARNetContext.h"

/// recorder生成的model 的基类
@interface ZPARRecord : NSObject<ZPARRecordBase>

- (void)setExtNetDataWithRequestParams:(NSDictionary *)requestParams
                          responseDict:(NSDictionary *)responseDict
                            netContext:(ZPARNetContext *)netContext;


@property (nonatomic , strong) NSObject *staticDataProvider;

@property (nonatomic , strong) NSMutableDictionary *originDataDict;

@property (nonatomic , strong) NSMutableDictionary *netDataDict;


@end
