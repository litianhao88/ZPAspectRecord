//
//  ZPARDataCheck.h
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/19.
//  Copyright © 2018年 lth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZPARRecord.h"
@protocol ZPARDataCheck <NSObject>

/// 有改动 返回YES
- (BOOL)checkAndFixLogData:(ZPARRecord*)record;

@end
