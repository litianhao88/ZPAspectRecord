//
//  NSObject+ZPARModuleNameSupport.m
//  ZPARDemo
//
//  Created by lth on 2018/5/17.
//  Copyright © 2018年 lth. All rights reserved.
//

#import "NSObject+ZPARModuleNameSupport.h"
#import <objc/runtime.h>
#import "NSString+ZPARSupport.h"
@implementation NSObject (ZPARModuleNameSupport)

- (NSString *)moduleName_using
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setModuleName_using:(NSString *)moduleName_using
{
    objc_setAssociatedObject(self, @selector(moduleName_using), moduleName_using, OBJC_ASSOCIATION_COPY);
}

- (NSString *)moduleName_location
{
    NSString *moduleName = objc_getAssociatedObject(self, _cmd);
    if (moduleName == nil) {
        moduleName =  [[[NSBundle bundleForClass:[self class]] bundlePath] ZPAR_MD5String];
        self.moduleName_location = moduleName;
    }
    return moduleName;
}

- (void)setModuleName_location:(NSString *)moduleName_location
{
    objc_setAssociatedObject(self, @selector(moduleName_location), moduleName_location, OBJC_ASSOCIATION_COPY);
}

@end
