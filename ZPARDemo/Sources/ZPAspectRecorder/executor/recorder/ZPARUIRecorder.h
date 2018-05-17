//
//  ZPARUIRecorder.h
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/20.
//  Copyright © 2018年 lth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZPARecorderBase.h"
#import "ZPARUIRecorded.h"
/// 数据记录时机 可以多种模式叠加
typedef NS_OPTIONS(NSInteger, ZPARUIRecordMode)
{
    /// 页面出现到屏幕上
    ZPARUIRecordModePageIn = 1 << 0,
    /// 页面从屏幕上消失
    ZPARUIRecordModePageOut = 1 << 1,
    /// 页面滑到某一偏移量
    ZPARUIRecordModeListOffset = 1 << 2,
    /// 不做任何记录
    ZPARUIRecordModeNone = 0,
    /// 所有模式代表的时机 均记录
    ZPARUIRecordModeAll = ZPARUIRecordModePageIn | ZPARUIRecordModePageOut | ZPARUIRecordModeListOffset 
};


@interface ZPARUIRecorder : ZPARecorderBase

///  根据mode 处理指定被收集实体的一些收集逻辑
+ (void)handleUIRecordWithRecordedEntity:(NSObject<ZPARUIRecorded>*)recordedEntity recordMode:(ZPARUIRecordMode)recordMode;

@end


/// scrollview 监听滑动 快捷开关
@interface UIScrollView (ZPARUIRecordSupport)

@property (nonatomic , assign) BOOL ZPAR_recordOffsetOn;


@end
