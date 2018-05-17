//
//  ZPARMacTime.m
//  zhaopin
//
//  Created by lth on 2018/5/8.
//  Copyright © 2018年 zhaopin.com. All rights reserved.
//

#import "ZPARMacTime.h"
#include <mach/mach_time.h>


@implementation ZPARMacTime

+ (uint64_t)getStartTime
{
    uint64_t nStartTick = mach_absolute_time();// 纳秒
    return nStartTick;
}

+ (double)getDurationSecondTime:(uint64_t)nStartTick
{
    uint64_t nTotalTick = mach_absolute_time()-nStartTick;
    double fTotalSecond = [self machTimeToSecs: nTotalTick];
    return fTotalSecond;
}

+ (double)machTimeToSecs:(uint64_t)time
{
    mach_timebase_info_data_t timebase;
    mach_timebase_info(&timebase);
    return (double)time*(double)timebase.numer/(double)timebase.denom;//ns 转换为 s
}

+ (double)durationSecondTimeWithStart:(uint64_t)startTime endTime:(uint64_t)endTime
{
    uint64_t nTotalTick = endTime-startTime;
    double fTotalSecond = [self machTimeToSecs: nTotalTick];
    return fTotalSecond;
}

@end
