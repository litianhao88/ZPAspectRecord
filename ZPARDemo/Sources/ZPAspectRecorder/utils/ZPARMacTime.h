//
//  ZPARMacTime.h
//  zhaopin
//
//  Created by lth on 2018/5/8.
//  Copyright © 2018年 zhaopin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZPARMacTime : NSObject
/// 获取当前时间点的mac时间信息
+ (uint64_t)getStartTime;
/// 获取nStartTick到当前时间点的时间差(秒)
+ (double)getDurationSecondTime:(uint64_t)nStartTick;
/// 获取两个时间点的时间差(秒)
+ (double)durationSecondTimeWithStart:(uint64_t)startTime endTime:(uint64_t)endTime;

@end

