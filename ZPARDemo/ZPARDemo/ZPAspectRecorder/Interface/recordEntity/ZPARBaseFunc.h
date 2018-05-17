//
//  ZPARBaseFunc.h
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/19.
//  Copyright © 2018年 lth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZPARDataCheck.h"

@protocol ZPARBaseFunc <NSObject>

@required
/// 外部调用者传入的数据检查类  可以介入
@property (nonatomic , weak) id<ZPARDataCheck> recordDataChecker;
/// memor -> disk
+ (void)storageToDisk;
/// disk -> memory
+ (void)resumFromDisk;

@end
