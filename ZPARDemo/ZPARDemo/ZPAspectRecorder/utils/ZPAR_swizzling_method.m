//
//  ZPAR_swizzling_method.m
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/25.
//  Copyright © 2018年 lth. All rights reserved.
//

#import "ZPAR_swizzling_method.h"
#import <objc/runtime.h>


FOUNDATION_EXTERN void ZPAR_swizzling_exchangeMethod(Class clazz ,SEL originalSelector, SEL swizzledSelector)
{
    Method originalMethod = class_getInstanceMethod(clazz, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(clazz, swizzledSelector);
    
    BOOL success = class_addMethod(clazz, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (success) {
        class_replaceMethod(clazz, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

FOUNDATION_EXTERN void ZPAR_swizzling_exchangeMethodWithNewClass(Class clazz ,SEL originalSelector,Class swizzledClazz, SEL swizzledSelector)
{
    Method originM = class_getInstanceMethod(clazz, originalSelector);
    Method newM = class_getInstanceMethod(swizzledClazz, swizzledSelector);
    
    IMP newImp =  method_getImplementation(newM);
    BOOL addMethodSucess = class_addMethod(clazz, swizzledSelector, newImp, method_getTypeEncoding(newM));
    
    if (addMethodSucess)
    {
        class_replaceMethod(clazz, originalSelector, newImp, method_getTypeEncoding(newM));
    }else
    {
        method_exchangeImplementations(originM, newM);
    }

}


