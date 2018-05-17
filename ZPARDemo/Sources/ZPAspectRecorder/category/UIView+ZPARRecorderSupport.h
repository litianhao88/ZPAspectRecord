//
//  UIView+ZPARRecorderSupport.h
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/23.
//  Copyright © 2018年 lth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZPARUIRecorded.h"

@interface UIView (ZPARRecorderSupport)


@property (nonatomic , weak) UIView *ZPAR_attachView;

/// 避免重复record 设置一个bool开关
@property (nonatomic , assign) BOOL ZAPR_hasRecord;

/*
目前需求都是需要监听scrollview  没有监听单个view的需求 这个功能暂时不用
@property (nonatomic , copy , readonly) void(^ZPAR_willRemoveSubview_Hook)(UIView *currentView ,UIView *subView);
@property (nonatomic , copy , readonly) void(^ZPAR_didMoveToSuperview_Hook)(UIView *currentView);
*/
/// 当前view 展示在window上的面积占总面积的比例
- (CGFloat)ZPAR_area_ratio_displayOnWindow;

@end


