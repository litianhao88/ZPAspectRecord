//
//  UIView+ZPARRecorderSupport.m
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/23.
//  Copyright © 2018年 lth. All rights reserved.
//

#import "UIView+ZPARRecorderSupport.h"
#import "ZPAR_swizzling_method.h"
#import <objc/runtime.h>

@implementation UIView (ZPARRecorderSupport)

- (CGFloat)ZPAR_area_ratio_displayOnWindow
{
    UIView *attachView = self.ZPAR_attachView;
    if (attachView == nil)
    {
        /// 如果调用方没有指定attachView  就按默认规则取
        /// 规则 : tableview上的cell  就取tableview  普通view取superview
        if ([self isKindOfClass:[UITableViewCell class]])
        {
            UIView *superView = self.superview;

            while (superView || ![superView isKindOfClass:[UIWindow class]])
            {
                if ([superView isKindOfClass:[UITableView class]])
                {
                    self.ZPAR_attachView = superView;
                    break ;
                }
                superView = superView.superview ;
            }
        }
        
        if (self.ZPAR_attachView == nil) {
            self.ZPAR_attachView = self.superview ;
        }
        
        attachView = self.superview;
    }
    /// frame 转换成与attachV相同的坐标系下
    CGRect frame_onAttachView= [attachView convertRect:self.frame fromView:self.superview];
    /// 与attachView的相交区域
    CGRect visableframe_onAttachView = CGRectIntersection(attachView.bounds , frame_onAttachView);
    /// 在attachView上的面积
    CGFloat areaVisable =  visableframe_onAttachView.size.width * visableframe_onAttachView.size.height;
    /// 计算面积占比
    return areaVisable / (self.bounds.size.width * self.bounds.size.height);
}

- (UIView *)ZPAR_attachView
{
    return objc_getAssociatedObject(self, _cmd);
}

/// 要正确计算view 在屏幕中展示面积 需要外界传入一个正确的参照view
- (void)setZPAR_attachView:(UIView *)ZPAR_attachView
{
    objc_setAssociatedObject(self, @selector(ZPAR_attachView), ZPAR_attachView, OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)ZAPR_hasRecord
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setZAPR_hasRecord:(BOOL)ZAPR_hasRecord
{
    objc_setAssociatedObject(self, @selector(ZAPR_hasRecord), @(ZAPR_hasRecord), OBJC_ASSOCIATION_ASSIGN);
}


/*
 目前需求都是需要监听scrollview  没有监听单个view的需求 这个功能暂时不用

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ZPAR_swizzling_exchangeMethod(self, @selector(willRemoveSubview:), @selector(ZPARswizzle_willRemoveSubview:));
        ZPAR_swizzling_exchangeMethod(self, @selector(didMoveToSuperview), @selector(ZPARswizzle_didMoveToSuperview));
    });
}

- (void)ZPARswizzle_willRemoveSubview:(UIView *)subview
{
    //    NSLog(@"ZPARswizzle_willRemoveSubview %@" , self);
    if (self.ZPAR_willRemoveSubview_Hook)
    {
        self.ZPAR_willRemoveSubview_Hook(self,subview);
    }
    [self ZPARswizzle_willRemoveSubview:subview];
}

- (void)ZPARswizzle_didMoveToSuperview
{
    //    NSLog(@"ZPARswizzle_didMoveToSuperview %@" , self);
    if (self.ZPAR_didMoveToSuperview_Hook) {
        self.ZPAR_didMoveToSuperview_Hook(self);
    }
    [self ZPARswizzle_didMoveToSuperview];
}


- (void (^)(UIView *,UIView *))ZPAR_willRemoveSubview_Hook
{
    return nil;
}

- (void (^)(UIView *))ZPAR_didMoveToSuperview_Hook
{
    return nil;
}
 */

@end
