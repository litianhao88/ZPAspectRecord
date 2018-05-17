//
//  UIViewController+ZPARRecordSupport.m
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/23.
//  Copyright © 2018年 lth. All rights reserved.
//

#import "UIViewController+ZPARRecordSupport.h"
#import "ZPAR_swizzling_method.h"
#import <objc/runtime.h>
#import "ZPARUIRecorder.h"
#import "ZPARRecordContextManager.h"
#import "ZPARMacTime.h"
@implementation UIViewController (ZPARRecordSupport)

- (BOOL)ZPAR_recordPageAction
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setZPAR_recordPageAction:(BOOL)ZPAR_recordPageAction
{
    objc_setAssociatedObject(self, @selector(ZPAR_recordPageAction), @(ZPAR_recordPageAction), OBJC_ASSOCIATION_ASSIGN);
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        swizzling_exchangeMethod(self, @selector(viewDidDisappear:), @selector(ZPARswizzle_viewDidDisappear:));
        ZPAR_swizzling_exchangeMethod(self, @selector(viewWillAppear:), @selector(ZPARswizzle_viewWillAppear:));
        ZPAR_swizzling_exchangeMethod(self, @selector(viewWillDisappear:), @selector(ZPARswizzle_viewWillDisappear:));
        ZPAR_swizzling_exchangeMethod(self, @selector(viewDidAppear:), @selector(ZPARswizzle_viewDidAppear:));
    });
}

- (void)ZPARswizzle_viewWillAppear:(BOOL)animated
{
    [self ZPARswizzle_viewWillAppear:animated];
    if ([self conformsToProtocol:@protocol(ZPARUIRecorded)])
    {
        /// 为新的ZPARUIRecorded创建上下文 切换当前record上下文
        [ZPARRecordContextManager changeRecordContextWithRecordedEntity:(NSObject<ZPARUIRecorded>*)self];
    }
}

- (void)ZPARswizzle_viewWillDisappear:(BOOL)animated
{
    [self ZPARswizzle_viewWillDisappear:animated];
    
    if (self.ZPAR_recordPageAction && [self conformsToProtocol:@protocol(ZPARUIRecorded)])
    {
        /// 报告pageOut事件
        [ZPARUIRecorder handleUIRecordWithRecordedEntity:(NSObject<ZPARUIRecorded>*)self recordMode:ZPARUIRecordModePageOut];
    }
    /// 设置 页面退出时间点
    if ([self respondsToSelector:@selector(recordContext)]) {
        [(ZPARRecordContext *)[self valueForKey:@"recordContext"] setPageOutTime:[ZPARMacTime getStartTime]];
    }
}
- (void)ZPARswizzle_viewDidAppear:(BOOL)animated
{
    [self ZPARswizzle_viewDidAppear:animated];
    if (self.ZPAR_recordPageAction && [self conformsToProtocol:@protocol(ZPARUIRecorded)])
    {
        /// 报告pageIn事件
        [ZPARUIRecorder handleUIRecordWithRecordedEntity:(NSObject<ZPARUIRecorded>*)self recordMode:ZPARUIRecordModePageIn];
    }
    
    /// 设置页面进入时间点
    if ([self respondsToSelector:@selector(recordContext)])
    {
        [(ZPARRecordContext *)[self valueForKey:@"recordContext"] setPageInTime:[ZPARMacTime getStartTime]];
    }
}

//- (void)ZPARswizzle_viewDidDisappear:(BOOL)animated
//{
//    [self ZPARswizzle_viewDidDisappear:animated];
//}

//- (NSString *)ZPAR_refdesc_current
//{
//    return NSStringFromClass([self class]);
//}

@end
