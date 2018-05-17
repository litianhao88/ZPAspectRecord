//
//  ZPARRecordContextManager.h
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/24.
//  Copyright © 2018年 lth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZPARRecordContext.h"
#import "ZPARUIRecorded.h"
#import "ZPARNetRecorded.h"


// 管理页面上下文切换的类 每个tabbaritem 有一套独立的上下文切换环境

@interface ZPARRecordContextManager : NSObject

+ (instancetype)singleManager;

+ (ZPARRecordContext *)currentContext ;

+ (void)changeRecordContextWithRecordedEntity:(NSObject<ZPARUIRecorded>*)recordedEntity;



@end
