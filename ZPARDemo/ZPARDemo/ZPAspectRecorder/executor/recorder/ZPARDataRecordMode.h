//
//  ZPARDataRecordMode.h
//  zhaopin
//
//  Created by lth on 2018/5/7.
//  Copyright © 2018年 zhaopin.com. All rights reserved.
//

#ifndef ZPARDataRecordMode_h
#define ZPARDataRecordMode_h

    #ifdef __OBJC__
        /// 数据记录时机 可以多种模式叠加
        typedef NS_OPTIONS(NSInteger, ZPARDataRecordMode)
        {
            /// 数据展示到屏幕上
            ZPARDataRecordModeDisplayOnWindow = 1 << 0,
            /// 展示当前数据的视图从屏幕消失
            ZPARDataRecordModeDismissFromWindow = 1 << 1,
            /// 数据创建
            ZPARDataRecordModeCreate = 1 << 2,
            /// 数据销毁
            ZPARDataRecordModeDestory = 1 << 3,
            /// 不做任何记录
            ZPARDataRecordModeNone = 0,
            /// 所有模式代表的时机 均记录
            ZPARDataRecordModeAll = ZPARDataRecordModeDisplayOnWindow | ZPARDataRecordModeDismissFromWindow | ZPARDataRecordModeCreate | ZPARDataRecordModeDestory
        };
    #endif

#endif /* ZPARDataRecordMode_h */
