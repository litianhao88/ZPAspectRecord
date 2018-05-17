//
//  ZPAR_swizzling_method.h
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/25.
//  Copyright © 2018年 lth. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN void ZPAR_swizzling_exchangeMethod(Class clazz ,SEL originalSelector, SEL swizzledSelector);

FOUNDATION_EXTERN void ZPAR_swizzling_exchangeMethodWithNewClass(Class clazz ,SEL originalSelector,Class swizzledClazz, SEL swizzledSelector);
