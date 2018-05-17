//
//  ZPARNetRecorder.h
//  zhaopin
//
//  Created by lth on 2018/4/27.
//  Copyright © 2018年 zhaopin.com. All rights reserved.
//

#import "ZPARecorderBase.h"
#import "ZPARNetRecorded.h"
#import "ZPARMarcos.h"

@interface ZPARNetRecorder : ZPARecorderBase

+ (NSString *)netRecordTypeFromUrl:(NSString *)requestUrl requestParams:(NSDictionary *)requestParams moduleName:(NSString *)moduleName;

@end

@interface NSObject(ZPARNetRecordSupport)
/// 为了给recorder提供hook 添加这个方法
@property (nonatomic , copy , readonly) ZPAR_handle_APIRecord_BlockType ZPAR_handle_APIRecord;

@end
